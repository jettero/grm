# vi:filetype=perl:

package Games::RolePlay::MapGen::Exporter::SVG::_GDSVG;

# NOTE: Most of this code is ripped from GD::SVG v0.28, 
# /usr/local/share/perl/5.8.8/GD/SVG.pm on my machine.  ... why not just
# use GD::SVG directly?  It does a lot I don't need and does a lot I need
# in a way I don't want it to work.
#
# -Paul

use strict;
use SVG;
use Carp;

### GD Emulation

# new {{{
sub new {
    my ($class, $width, $height, $debug) = @_;

    my $this = bless {}, $class;
    my $img  = SVG->new(width=>$width, height=>$height);

    $this->{img}    = $img;
    $this->{width}  = $width;
    $this->{height} = $height;

    $this->{foreground} = $this->colorAllocate(0, 0, 0);

    return $this;
}
# }}}
# svg {{{
sub svg {
    my $this = shift;

    $this->{img}->xmlify(-pubid => "-//W3C//DTD SVG 1.0//EN", -inline => 1);
}
# }}}
# colorAllocate {{{
sub colorAllocate {
    my ($this, $r, $g, $b) = @_;
    $r ||= 0;
    $g ||= 0;
    $b ||= 0;

    my $new_index = (defined $this->{colors_added}) ? scalar @{$this->{colors_added}} : 0;
    $this->{colors}->{$new_index} = [$r, $g, $b];

    push (@{$this->{colors_added}}, $new_index);
    return $new_index;
}
# }}}
# line {{{
sub line {
    my ($this, $x1, $y1, $x2, $y2, $color_index) = @_;

    my ($img, $id) = $this->_prep($x1, $y1);
    my $style      = $this->_build_style($id, $color_index, $color_index);
       $style->{'stroke-linecap'} = 'square';

    my $result     = $img->line(
        x1    => $x1, y1=>$y1, 
        x2    => $x2, y2=>$y2, 
        id    => $id, 
        style => $style, 
    );

    return $result;
}
# }}}
# rectangle {{{
sub rectangle {
    my ($this, $x1, $y1, $x2, $y2, $color_index, $fill) = @_;

    my ($img, $id) = $this->_prep($x1, $y1);
    my $style      = $this->_build_style($id, $color_index, $fill);

    $img->rectangle( x => $x1, y => $y1, width => $x2-$x1, height => $y2-$y1, id => $id, style => $style );
}
# }}}
# filledRectangle {{{
sub filledRectangle {
    my ($this, $x1, $y1, $x2, $y2, $color) = @_;

    $this->rectangle($x1, $y1, $x2, $y2, $color, $color);
}
# }}}
# arc {{{
sub arc {
    my ($this, $cx, $cy, $width, $height, $start, $end, $color_index, $fill) = @_;

    return $this->ellipse($cx, $cy, $width, $height, $color_index, $fill)
        if ($start == 0 and $end == 360) or ($end == 360 and $start == 0);

    my ($img, $id)                              = $this->_prep($cy, $cx);
    my ($nstart, $nend, $large, $sweep, $a, $b) = _calculate_arc_params($start, $end, $width, $height);
    my ($startx, $starty)                       = _calculate_point_coords($cx, $cy, $width, $height, $nstart);
    my ($endx, $endy)                           = _calculate_point_coords($cx, $cy, $width, $height, $nend);

    my $style = $this->_build_style($id, $color_index, $fill);

    return $img->path( d => "M$startx, $starty A$a, $b 0 $large, $sweep $endx, $endy", style => $style );
}
# }}}
# ellipse {{{
sub ellipse {
    my ($this, $x1, $y1, $width, $height, $color_index, $fill) = @_;
    my ($img, $id) = $this->_prep($x1, $y1);
    my $style = $this->_build_style($id, $color_index, $fill);

    $width  =  $width / 2;
    $height = $height / 2;

    return $img->ellipse( cx => $x1, cy => $y1, rx => $width, ry => $height, id => $id, style => $style, );
}
# }}}

### Internal functions

# _prep {{{
sub _prep {
    my ($this, @params) = @_;
    my $img = $this->{img};
    my $id  = $this->_create_id;

    return ($img, $id);
}
# }}}
# _build_style {{{
sub _build_style {
    my ($this, $id, $color, $fill, $stroke_opacity) = @_;
    my $thickness    = 1; # $this->_get_thickness() || 1;
    my $fill_opacity = ($fill) ? '1.0' : 0;

    $fill = defined $fill ? $this->_get_color($fill) : 'none';
    $stroke_opacity ||= '1.0';
    return {
         stroke          => $this->_get_color($color), 
        'stroke-opacity' => $stroke_opacity, 
        'stroke-width'   => $thickness, 
         fill            => $fill, 
        'fill-opacity'   => $fill_opacity, 
    };
}
# }}}
# _create_id {{{
sub _create_id {
    my $this = shift;
    my $f = (caller(2))[3];
       $f = (split "::", $f)[-1];

    $f . (++ $this->{id}{$f});
}
# }}}
# _get_color {{{
sub _get_color {
    my ($this, $index) = @_;

    confess "somebody gave me a bum index!" unless length $index > 0;

    return ($index) if ($index =~ /rgb/); # Already allocated.
    return ($index) if ($index eq 'none'); # Generate by callbacks using none for fill
   
    my ($r, $g, $b) = @{$this->{colors}{$index}};
    my $color = "rgb($r, $g, $b)";

    return $color;
}
# }}}

"true";
