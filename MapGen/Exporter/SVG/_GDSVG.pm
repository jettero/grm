package Games::RolePlay::MapGen::Exporter::SVG::_GDSVG;

# NOTE: ALL of this code is ripped from GD::SVG v0.28

use strict;
use Carp;
use SVG;

package Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Image;
use Carp 'croak','carp','confess';

# There must be a better way to trap these errors
sub _error {
  my ($self,$method) = @_;
  warn "GD method $method is not implemented in Games::RolePlay::MapGen::Exporter::SVG::_GDSVG" if ($self->{debug} > 0);
}


#########################
# GD Constants
#########################
# Kludge - use precalculated values of cos(theta) and sin(theta)
# so that I do no have to examine quadrants

my @cosT = (qw/1024 1023 1023 1022 1021 1020 1018 1016 1014 1011 1008
1005 1001 997 993 989 984 979 973 968 962 955 949 942 935 928 920 912
904 895 886 877 868 858 848 838 828 817 806 795 784 772 760 748 736
724 711 698 685 671 658 644 630 616 601 587 572 557 542 527 512 496
480 464 448 432 416 400 383 366 350 333 316 299 282 265 247 230 212
195 177 160 142 124 107 89 71 53 35 17 0 -17 -35 -53 -71 -89 -107 -124
-142 -160 -177 -195 -212 -230 -247 -265 -282 -299 -316 -333 -350 -366
-383 -400 -416 -432 -448 -464 -480 -496 -512 -527 -542 -557 -572 -587
-601 -616 -630 -644 -658 -671 -685 -698 -711 -724 -736 -748 -760 -772
-784 -795 -806 -817 -828 -838 -848 -858 -868 -877 -886 -895 -904 -912
-920 -928 -935 -942 -949 -955 -962 -968 -973 -979 -984 -989 -993 -997
-1001 -1005 -1008 -1011 -1014 -1016 -1018 -1020 -1021 -1022 -1023
-1023 -1024 -1023 -1023 -1022 -1021 -1020 -1018 -1016 -1014 -1011
-1008 -1005 -1001 -997 -993 -989 -984 -979 -973 -968 -962 -955 -949
-942 -935 -928 -920 -912 -904 -895 -886 -877 -868 -858 -848 -838 -828
-817 -806 -795 -784 -772 -760 -748 -736 -724 -711 -698 -685 -671 -658
-644 -630 -616 -601 -587 -572 -557 -542 -527 -512 -496 -480 -464 -448
-432 -416 -400 -383 -366 -350 -333 -316 -299 -282 -265 -247 -230 -212
-195 -177 -160 -142 -124 -107 -89 -71 -53 -35 -17 0 17 35 53 71 89 107
124 142 160 177 195 212 230 247 265 282 299 316 333 350 366 383 400
416 432 448 464 480 496 512 527 542 557 572 587 601 616 630 644 658
671 685 698 711 724 736 748 760 772 784 795 806 817 828 838 848 858
868 877 886 895 904 912 920 928 935 942 949 955 962 968 973 979 984
989 993 997 1001 1005 1008 1011 1014 1016 1018 1020 1021 1022 1023
1023/);

my @sinT = (qw/0 17 35 53 71 89 107 124 142 160 177 195 212 230 247
265 282 299 316 333 350 366 383 400 416 432 448 464 480 496 512 527
542 557 572 587 601 616 630 644 658 671 685 698 711 724 736 748 760
772 784 795 806 817 828 838 848 858 868 877 886 895 904 912 920 928
935 942 949 955 962 968 973 979 984 989 993 997 1001 1005 1008 1011
1014 1016 1018 1020 1021 1022 1023 1023 1024 1023 1023 1022 1021 1020
1018 1016 1014 1011 1008 1005 1001 997 993 989 984 979 973 968 962 955
949 942 935 928 920 912 904 895 886 877 868 858 848 838 828 817 806
795 784 772 760 748 736 724 711 698 685 671 658 644 630 616 601 587
572 557 542 527 512 496 480 464 448 432 416 400 383 366 350 333 316
299 282 265 247 230 212 195 177 160 142 124 107 89 71 53 35 17 0 -17
-35 -53 -71 -89 -107 -124 -142 -160 -177 -195 -212 -230 -247 -265 -282
-299 -316 -333 -350 -366 -383 -400 -416 -432 -448 -464 -480 -496 -512
-527 -542 -557 -572 -587 -601 -616 -630 -644 -658 -671 -685 -698 -711
-724 -736 -748 -760 -772 -784 -795 -806 -817 -828 -838 -848 -858 -868
-877 -886 -895 -904 -912 -920 -928 -935 -942 -949 -955 -962 -968 -973
-979 -984 -989 -993 -997 -1001 -1005 -1008 -1011 -1014 -1016 -1018
-1020 -1021 -1022 -1023 -1023 -1024 -1023 -1023 -1022 -1021 -1020
-1018 -1016 -1014 -1011 -1008 -1005 -1001 -997 -993 -989 -984 -979
-973 -968 -962 -955 -949 -942 -935 -928 -920 -912 -904 -895 -886 -877
-868 -858 -848 -838 -828 -817 -806 -795 -784 -772 -760 -748 -736 -724
-711 -698 -685 -671 -658 -644 -630 -616 -601 -587 -572 -557 -542 -527
-512 -496 -480 -464 -448 -432 -416 -400 -383 -366 -350 -333 -316 -299
-282 -265 -247 -230 -212 -195 -177 -160 -142 -124 -107 -89 -71 -53 -35
-17 /);


#############################
# Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Image methods
#############################
sub new {
  my ($self,$width,$height,$debug) = @_;
  my $this = bless {},$self;
  my $img = SVG->new(width=>$width,height=>$height);
  $this->{img}    = $img;
  $this->{width}  = $width;
  $this->{height} = $height;

  # Let's create an internal representation of the image in GD
  # so that I can easily use some of GD's methods
  ###GD###$this->{gd} = Games::RolePlay::MapGen::Exporter::SVG::_GDImage->new($width,$height);

  # Let's just assume that we always want the foreground color to be
  # black This, for the most part, works for Bio::Graphics. This
  # certainly needs to be fixed...
  $this->{foreground} = $this->colorAllocate(0,0,0);
  $this->{debug} = ($debug) ? $debug : Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::DEBUG;
  return $this;
}


#############################
# Image Data Output Methods #
#############################
sub svg {
  my $self = shift;
  my $img = $self->{img};
  $img->xmlify(-pubid => "-//W3C//DTD SVG 1.0//EN",
               -inline => 1);
}

###GD###sub png {
###GD###  my ($self,$compression) = @_;
###GD###  return $self->{gd}->png($compression);
###GD###}

###GD###sub jpeg {
###GD###  my ($self,$quality) = @_;
###GD###  return $self->{gd}->jpeg($quality);
###GD###}

#############################
# Color management routines #
#############################
# As with GD, colorAllocate returns integers...
# This could easily rely on GD itself to generate the indices
sub colorAllocate {
  my ($self,$r,$g,$b) = @_;
  $r ||= 0;
  $g ||= 0;
  $b ||= 0;

  ###GD###my $newindex = $self->{gd}->colorAllocate($r,$g,$b);

  # Cannot use the numberof keys to generate index
  # colorDeallocate removes keys.
  # Instead use the colors_added array.
  my $new_index = (defined $self->{colors_added}) ? scalar @{$self->{colors_added}} : 0;
  $self->{colors}->{$new_index} = [$r,$g,$b];

  # Keep a list of colors in the order that they are added
  # This is used as a kludge for setBrush
  push (@{$self->{colors_added}},$new_index);
  return $new_index;
}

sub colorAllocateAlpha {
  my ($self,$r,$g,$b,$alpha) = @_;
  ###GD###$self->{gd}->colorAllocateAlpha($r,$g,$b,$alpha);
  $self->_error('colorAllocateAlpha');
}

sub colorDeallocate {
  my ($self,$index) = @_;
  my $colors = %{$self->{colors}};
  delete $colors->{$index};
  ###GD###$self->{gd}->colorDeallocate($index);
}

# workaround for bad GD
sub colorClosest {
  my ($self,@c) = @_;
  ###GD###my $index = $self->{gd}->colorClosest(@c);

  # Let's just return the color for now.
  # Terrible kludge.
  my $index = $self->colorAllocate(@c);
  return $index;
  #  my ($self,$gd,@c) = @_;
  #  return $self->{closestcache}{"@c"} if exists $self->{closestcache}{"@c"};
  #  return $self->{closestcache}{"@c"} = $gd->colorClosest(@c) if $GD::VERSION < 2.04;
  #  my ($value,$index);
  #  for (keys %COLORS) {
  #    my ($r,$g,$b) = @{$COLORS{$_}};
  #    my $dist = ($r-$c[0])**2 + ($g-$c[1])**2 + ($b-$c[2])**2;
  #    ($value,$index) = ($dist,$_) if !defined($value) || $dist < $value;
  #  }
  #  return $self->{closestcache}{"@c"} = $self->{translations}{$index};
}

sub colorClosestHWB { shift->_error('colorClosestHWB'); }

sub colorExact {
  my ($self,$r,$g,$b) = @_;
  ###GD###my $index = $self->{gd}->colorExact($r,$g,$b);
  
  # Let's just allocate the color instead of looking it up
  my $index = $self->colorAllocate($r,$g,$b);
  if ($index) {
    return $index;
  } else {
    return ('-1');
  }
}

sub colorResolve {
  my ($self,$r,$g,$b) = @_;
  ###GD###my $index = $self->{gd}->colorResolve($r,$g,$b);
  my $index = $self->colorAllocate($r,$g,$b);
  return $index;
}

sub colorsTotal {
  my $self = shift;
  ###GD###return $self->{gd}->colorsTotal;
  return scalar keys %{$self->{colors}};
}


sub getPixel {
  my ($self,$x,$y) = @_;
  # Internal GD - probably unnecessary in this context...
  # Will contstruct appropriate return value later
  ###GD### $self->{gd}->getPixel($x,$y);
  
  # I don't have any cogent way to fetch the value of an asigned pixel
  # without calculating all positions and loading into memory.
  
  # For these purposes, I could maybe just look it up...  From a hash
  # table or something - Keep track of all assigned pixels and their
  # color. Ugh. Compute intensive.
  return (1);
}

# Given the color index, return its rgb triplet
sub rgb {
  my ($self,$index) = @_;
  my ($r,$g,$b) = @{$self->{colors}->{$index}};
  return ($r,$g,$b);
}

sub transparent { shift->_error('transparent'); }


#######################
# Special Colors
#######################
# Kludgy preliminary support for gdBrushed This is based on
# Bio::Graphics implementation of set_pen which in essence just
# controls line color and thickness...  We will assume that the last
# color added is intended to be the foreground color.
sub setBrush {
  my ($self,$pen) = @_;
  ###GD###$self->{gd}->setBrush($pen);
  my ($width,$height) = $pen->getBounds();
  my $last_color = $pen->{colors_added}->[-1];
  my ($r,$g,$b) = $self->rgb($last_color);
  $self->{gdBrushed}->{color} = $self->colorAllocate($r,$g,$b);
  $self->{gdBrushed}->{thickness} = $width;
}

# There is no direct translation of gdStyled.  In gd, this is used to
# set the style for the line using the settings of the current brush.
# Drawing with the new style is then used by passing the gdStyled as a
# color.
sub setStyle {
  my ($self,@colors) = @_;
  ###GD###$self->{gd}->setStyle(@colors);
  $self->{gdStyled}->{color} = [ @colors ];
  return;
}

# Lines in GD are 1 pixel in diameter by default.
# setThickness allows line thickness to be changed.
# This should be retained until it's changed again
# Each method should check the thickness of the line...
sub setThickness {
  my ($self,$thickness) = @_;
  ###GD### $self->{gd}->setThickness($thickness);
  $self->{line_thickness} = $thickness;
  # WRONG!
  # $self->{prev_line_thickness} = (!defined $self->{prev_line_thickness}) ? $thickness : undef;
}


#######################
# Drawing subroutines #
#######################
sub setPixel {
  my ($self,$x1,$y1,$color_index) = @_;
  ###GD### $self->{gd}->setPixel($x1,$y1,$color_index);
  my ($img,$id,$thickness,$dasharray) = $self->_prep($x1,$y1);
  my $color = $self->_get_color($color_index);
  my $result =
    $img->circle(cx=>$x1,cy=>$y1,r=>'0.03',
		 id=>$id,
		 style=>{
			 'stroke'=>$color,
			 'fill'  =>$color,
			 'fill-opacity'=>'1.0'
			}
		);
  return $result;
}

sub line {
  my ($self,$x1,$y1,$x2,$y2,$color_index) = @_;
  # Are we trying to draw with a styled line (ie gdStyled, gdBrushed?)
  # If so, we need to deconstruct the values for line thickness,
  # foreground color, and dash spacing
  if ($color_index eq 'gdStyled' || $color_index eq 'gdBrushed') {
    my $fg = $self->_distill_gdSpecial($color_index);
    $self->line($x1,$y1,$x2,$y2,$fg);
  } else {
    ###GD### $self->{gd}->line($x1,$y1,$x2,$y2,$color_index);
    my ($img,$id) = $self->_prep($x1,$y1);
    my $style = $self->_build_style($id,$color_index,$color_index);
    my $result = $img->line(x1=>$x1,y1=>$y1,
			    x2=>$x2,y2=>$y2,
			    id=>$id,
			    style => $style,
			   );
    $self->_reset();
    return $result;
  }
}

sub dashedLine { shift->_error('dashedLine'); }

# The fill parameter is used internally as a simplification...
sub rectangle {
  my ($self,$x1,$y1,$x2,$y2,$color_index,$fill) = @_;
  if ($color_index eq 'gdStyled' || $color_index eq 'gdBrushed') {
    my $fg = $self->_distill_gdSpecial($color_index);
    $self->rectangle($x1,$y1,$x2,$y2,$fg,$fill);
  } else {
    ###GD###$self->{gd}->rectangle($x1,$y1,$x2,$y2,$color_index);
    my ($img,$id) = $self->_prep($x1,$y1);
    my $style = $self->_build_style($id,$color_index,$fill);
    my $result = 
      $img->rectangle(x=>$x1,y=>$y1,
		      width  =>$x2-$x1,
		      height =>$y2-$y1,
		      id     =>$id,
		      style => $style,
		     );
    $self->_reset();
    return $result;
  }
}

# This should just call the rectangle method passing it a flag.
# I will need to fix the glyph that bypasses this option...
sub filledRectangle {
  my ($self,$x1,$y1,$x2,$y2,$color) = @_;
  # Call the rectangle method passing the fill color
  $self->rectangle($x1,$y1,$x2,$y2,$color,$color);
}

sub polygon {
  my ($self,$poly,$color,$fill) = @_;
  $self->_polygon($poly,$color,$fill,1);
}

sub polyline {
  my ($self,$poly,$color,$fill) = @_;
  $self->_polygon($poly,$color,$fill,0);
}

sub polydraw {
  my $self = shift;	# the Games::RolePlay::MapGen::Exporter::SVG::_GDImage
  my $p    = shift;	# the GD::Polyline or GD::Polygon
  my $c    = shift;	# the color
  return $self->polyline($p, $c) if $p->isa('GD::Polyline');
  return $self->polygon($p, $c);
}

sub _polygon {
  my ($self,$poly,$color_index,$fill,$close) = @_;
  my $shape = $close ? 'polygon' : 'polyline';
  if ($color_index eq 'gdStyled' || $color_index eq 'gdBrushed') {
    my $fg = $self->_distill_gdSpecial($color_index);
    $self->$shape($poly,$fg);
  } else {
    ###GD###$self->{gd}->polygon($poly,$color);
    # Create seperate x and y arrays of vertices
    my (@xpoints,@ypoints);
    if ($poly->can('_fetch_vertices')) {
      @xpoints = $poly->_fetch_vertices('x');
      @ypoints = $poly->_fetch_vertices('y');
    } else {
      my @points = $poly->vertices;
      @xpoints   = map { $_->[0] } @points;
      @ypoints   = map { $_->[1] } @points;
    }
    my ($img,$id) = $self->_prep($xpoints[0],$ypoints[0]);
    my $points = $img->get_path(
				x=>\@xpoints, y=>\@ypoints,
				-type=>$shape,
			       );
    my $style = $self->_build_style($id,$color_index,$fill);
    my $result =
      $img->$shape(
		    %$points,
		    id=>$id,
		    style => $style,
		   );
    $self->_reset();
    return $result;
  }
}

# Passing the stroke doesn't really work as expected...
sub filledPolygon {
  my ($self,$poly,$color) = @_;
  my $result = $self->polygon($poly,$color,$color);
  return $result;
}

sub ellipse {
  my ($self,$x1,$y1,$width,$height,$color_index,$fill) = @_;
  if ($color_index eq 'gdStyled' || $color_index eq 'gdBrushed') {
    my $fg = $self->_distill_gdSpecial($color_index);
    $self->ellipse($x1,$y1,$width,$height,$fg);
  } else {
    ###GD### $self->{gd}->ellipse($x1,$y1,$width,$height,$color_index);

    my ($img,$id) = $self->_prep($x1,$y1);
    # GD uses width and height - SVG uses radii...
    $width  = $width / 2;
    $height = $height / 2;
    my $style = $self->_build_style($id,$color_index,$fill);
    my $result =
      $img->ellipse(
		    cx=>$x1, cy=>$y1,
		    rx=>$width, ry=>$height,
		    id=>$id,
		    style => $style,
		   );
    $self->_reset();
    return $result;
  }
}

sub filledEllipse {
  my ($self,$x1,$y1,$width,$height,$color) = @_;
  my $result = $self->ellipse($x1,$y1,$width,$height,$color,$color);
  return $result;
}

# GD uses the arc() and filledArc() methods in two capacities
#   1. to create closed ellipses, where start and end are 0 and 360
#   2. to create honest-to-god open arcs
# The arc method is no longer being used to draw filledArcs.
# All the fill-specific code within is no deprecated.
sub arc {
  my ($self,$cx,$cy,$width,$height,$start,$end,$color_index,$fill) = @_;
  if ($color_index eq 'gdStyled' || $color_index eq 'gdBrushed') {
    my $fg = $self->_distill_gdSpecial($color_index);
    $self->arc($cx,$cy,$width,$height,$start,$end,$fg);
  } else {
    ###GD### $self->{gd}->arc($x,$y,$width,$height,$start,$end,$color);
    # Are we just trying to draw a closed arc (an ellipse)?
    my $result;
    if ($start == 0 && $end == 360 || $end == 360 && $start == 0) {
      $result = $self->ellipse($cx,$cy,$width,$height,$color_index,$fill);
    } else {
      my ($img,$id) = $self->_prep($cy,$cx);

      # Taking a stab at drawing elliptical arcs
      my ($start,$end,$large,$sweep,$a,$b) = _calculate_arc_params($start,$end,$width,$height);
      my ($startx,$starty) = _calculate_point_coords($cx,$cy,$width,$height,$start);
      my ($endx,$endy)     = _calculate_point_coords($cx,$cy,$width,$height,$end);

      # M = move to (origin of the curve)
      # my $rotation = abs $start - $end;
      my $style = $self->_build_style($id,$color_index,$fill);
      $result =
      	$img->path('d'=>"M$startx,$starty "  .
      		   "A$a,$b 0 $large,$sweep $endx,$endy",
		   style => $style,
		  );
    }
    $self->_reset();
    return $result;
  }
}

# Return the x and y positions of start and stop of arcs.
sub _calculate_point_coords {
  my ($cx,$cy,$width,$height,$angle) = @_;
  my $x = ( $cosT[$angle % 360] * $width)  / (2 * 1024) + $cx;
  my $y = ( $sinT[$angle % 360] * $height) / (2 * 1024) + $cy;
  return ($x,$y);
}

sub _calculate_arc_params {
  my ($start,$end,$width,$height) = @_;

  # GD uses diameters, SVG uses radii
  my $a = $width  / 2;
  my $b = $height / 2;
  
  while ($start < 0 )    { $start += 360; }
  while ($end < 0 )      { $end   += 360; }
  while ($end < $start ) { $end   += 360; }

  my $large = (abs $start - $end > 180) ? 1 : 0;
  # my $sweep = ($start > $end) ? 0 : 1;  # directionality of the arc, + CW, - CCW
  my $sweep = 1; # Always CW with GD
  return ($start,$end,$large,$sweep,$a,$b);
}

sub filledArc {
  my ($self,$cx,$cy,$width,$height,$start,$end,$color_index,$fill_style) = @_;
  if ($color_index eq 'gdStyled' || $color_index eq 'gdBrushed') {
    my $fg = $self->_distill_gdSpecial($color_index);
    $self->filledArc($cx,$cy,$width,$height,$start,$end,$fg);
  } else {
    ###GD### $self->{gd}->arc($x,$y,$width,$height,$start,$end,$color_index);
    my $result;

    # distill the special colors, if provided...
    my $fill_color;
    # Set it to gdArc, the default value to avoid undef errors in comparisons
    $fill_style ||= 0;
    if ($fill_style == 2 || $fill_style == 4 || $fill_style == 6) {
      $fill_color = 'none';
    } else {
      $fill_color = $self->_get_color($color_index);
    }

    # Are we just trying to draw a closed filled arc (an ellipse)?
    if (($start == 0 && $end == 360) || ($start == 360 && $end == 0)) {
      $result = $self->ellipse($cx,$cy,$width,$height,$color_index,$fill_color);
    }

    # are we trying to draw a pie?
    elsif ($end - $start > 180 && ($fill_style == 0 || $fill_style == 4)) {
      $self->filledArc($cx,$cy,$width,$height,$start,$start+180,$color_index,$fill_style);
#      $self->filledArc($cx,$cy,$width,$height,$start+180,$end,$color_index,$fill_style);
      $result = $self->filledArc($cx,$cy,$width,$height,$start+180,$end,$color_index,$fill_style);
    }

    else {
      my ($img,$id) = $self->_prep($cy,$cx);

      my ($start,$end,$large,$sweep,$a,$b) = _calculate_arc_params($start,$end,$width,$height);
      my ($startx,$starty) = _calculate_point_coords($cx,$cy,$width,$height,$start);
      my ($endx,$endy)     = _calculate_point_coords($cx,$cy,$width,$height,$end);

      # Evaluate the various fill styles
      # gdEdged connects the center to the start and end
      if ($fill_style == 4 || $fill_style == 6) {
	$self->line($cx,$cy,$startx,$starty,$color_index);
	$self->line($cx,$cy,$endx,$endy,$color_index);
      }

      # gdNoFill outlines portions of the arc
      # noFill or gdArc|gdNoFill
      if ($fill_style == 2 || $fill_style == 6) {
	$result = $self->arc($cx,$cy,$width,$height,$start,$end,$color_index);
	return $result;
      }

      # gdChord|gdNofFill
      if ($fill_style == 3) {
	$result = $self->line($startx,$starty,$endx,$endy,$color_index);
	return $result;
      }

      # Create the actual filled portion of the arc
      # This is the default behavior for gdArc and if no style is passed.
      if ($fill_style == 0 || $fill_style == 4) {
	# M = move to (origin of the curve)
	# my $rotation = abs $start - $end;
	my $style = $self->_build_style($id,$color_index,$fill_color);	
	$result =
	  $img->path('d'=>"M$startx,$starty "  .
		     "A$a,$b 0 $large,$sweep $endx,$endy",
		     style => $style,
		    );
      }

      # If we are filling, draw a filled triangle to complete.
      # This is also the same as using gdChord by itself
      my $poly = Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Polygon->new();
      $poly->addPt($cx,$cy);
      $poly->addPt($startx,$starty);
      $poly->addPt($endx,$endy);
      $self->filledPolygon($poly,$color_index);
    }

    $self->_reset();
    return $result;
  }
}

# Flood fill that stops at first pixel of a different color.
sub fill         { shift->_error('fill'); }
sub fillToBorder { shift->_error('fillToBorder'); }

##################################################
# Image Copying Methods
##################################################

# Taking a stab at implementing the copy() methods
# Should be relatively easy to implement clone() from this
sub copy {
  my ($self,$source,$dstx,$dsty,$srcx,$srcy,$width,$height) = @_;

  my $topx    = $srcx;
  my $topy    = $srcy;
  my $bottomx = $srcx + $width;   # arithmetic right here?
  my $bottomy = $srcy + $height;

  # Fetch all elements of the source image
  my @elements = $source->{img}->getElements;
  foreach my $element (@elements) {
    my $att = $element->getAttributes();
    # Points|rectangles|text, circles|ellipses, lines
    my $x = $att->{x} || $att->{cx} || $att->{x1};
    my $y = $att->{y} || $att->{cy} || $att->{y1};

    # Use the first point for polygons
    unless ($x && $y) {
      my @points = split(/\s/,$att->{points});
      if (@points) {
	($x,$y) = split(',',$points[0]);
      }
    }

    # Paths
    unless ($x && $y) {
      my @d = split(/\s/,$att->{d});
      if (@d) {
	($x,$y) = split(',',$d[0]);
	$x =~ s/^M//;  # Remove the style directive
      }
    }

    # Are the starting coords within the bounds of the desired rectangle?
    # We will simplistically assume that the entire glyph fits inside
    # the rectangle which may not be true.
    if (($x >= $topx && $y >= $topy) &&
	($x <= $bottomx && $y <= $bottomy)) {
      my $type = $element->getType;
      # warn "$type $x $y $bottomx $bottomy $topx $topy"; 

      # Transform the coordinates as necessary,
      # calculating the offsets relative to the
      # original bounding rectangle in the source image

      # Text or rectangles
      if ($type eq 'text' || $type eq 'rect') {
	my ($newx,$newy) = _transform_coords($topx,$topy,$x,$y,$dstx,$dsty);
	$element->setAttribute('x',$newx);
	$element->setAttribute('y',$newy);	
	# Circles or ellipses
      } elsif ($type eq 'circle' || $type eq 'ellipse') {
	my ($newx,$newy) = _transform_coords($topx,$topy,$x,$y,$dstx,$dsty);
	$element->setAttribute('cx',$newx);
	$element->setAttribute('cy',$newy);
	# Lines
      } elsif ($type eq 'line') {
	my ($newx1,$newy1) = _transform_coords($topx,$topy,$x,$y,$dstx,$dsty);
      	my ($newx2,$newy2) = _transform_coords($topx,$topy,$att->{x2},$element->{y2},$dstx,$dsty);
      	$element->setAttribute('x1',$newx1);
	$element->setAttribute('y1',$newy1);
      	$element->setAttribute('x2',$newx2);
	$element->setAttribute('y2',$newy2);
	# Polygons
      } elsif ($type eq 'polygon') {
	my @points = split(/\s/,$att->{points});
	my @transformed;
	foreach (@points) {
	  ($x,$y) = split(',',$_);
	  my ($newx,$newy) = _transform_coords($topx,$topy,$x,$y,$dstx,$dsty);
	  push (@transformed,"$newx,$newy");
	}
	my $transformed = join(" ",@transformed);
	$element->setAttribute('points',$transformed);
	# Paths
      } elsif ($type eq 'path') {

      }

      # Create new elements for the destination image
      # via the generic SVG::Element::tag method
      my %attributes = $element->getAttributes;
      $self->{img}->tag($type,%attributes);
    }
  }
}

# Used internally by the copy method
# Transform coordinates of a given point with reference
# to a bounding rectangle
sub _transform_coords {
  my ($refx,$refy,$x,$y,$dstx,$dsty) = @_;
  my $xoffset = $x - $refx;
  my $yoffset = $y - $refy;
  my $newx = $dstx + $xoffset;
  my $newy = $dsty + $yoffset;
  return ($newx,$newy);
}



##################################################
# Image Transformation Methods
##################################################

# None implemented

##################################################
# Character And String Drawing
##################################################
sub string {
  my ($self,$font_obj,$x,$y,$text,$color_index) = @_;
  my $img = $self->{img};
  my $id = $self->_create_id($x,$y);
  my $formatting = $font_obj->formatting();
  my $color = $self->_get_color($color_index);
  my $result =
    $img->text(
	       id=>$id,
	       x=>$x,
	       y=>$y + $font_obj->{height} - Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::TEXT_KLUDGE,
	       %$formatting,
	       fill      => $color,
	      )->cdata($text);
  return $result;
}

sub stringUp {
  my ($self,$font_obj,$x,$y,$text,$color_index) = @_;
  my $img = $self->{img};
  my $id = $self->_create_id($x,$y);
  my $formatting = $font_obj->formatting();
  my $color = $self->_get_color($color_index);
  $x += $font_obj->height;
  my $result =
    $img->text(
	       id=>$id,
	       %$formatting,
	       'transform' => "translate($x,$y) rotate(-90)",
	       fill      => $color,
	      )->cdata($text);
}

sub char {
  my ($self,@rest) = @_;
  $self->string(@rest);
}

sub charUp {
  my ($self,@rest) = @_;
  $self->stringUp(@rest);
}

# Replicating the TrueType handling
#sub Games::RolePlay::MapGen::Exporter::SVG::_GDImage::stringFT { shift->_error('stringFT'); }


##################################################
# Alpha Channels
##################################################
sub alphaBlending { shift->_error('alphaBlending'); }
sub saveAlpha     { shift->_error('saveAlpha'); }

##################################################
# Miscellaneous Image Methods
##################################################
sub interlaced { shift->_error('inerlaced'); }

sub getBounds {
  my $self = shift;
  my $width = $self->{width};
  my $height = $self->{height};
  return($width,$height);
}

sub isTrueColor { shift->_error('isTrueColor'); }
sub compare     { shift->_error('compare'); }
sub clip        { shift->_error('clip'); }
sub boundsSafe  { shift->_error('boundsSafe'); }

##########################################
# Internal routines for meshing with SVG #
##########################################
# Fetch out typical params used for drawing.
package Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Image;
use Carp 'confess';

sub _prep {
  my ($self,@params) = @_;
  my $img = $self->{img};
  my $id = $self->_create_id(@params);
  # my $thickness = $self->_get_thickness() || 1;
#  return ($img,$id,$thickness,undef);
  return ($img,$id,undef,undef);
}

# Pass in a ordered list to create a hash ref of style parameters
# ORDER: $id,$color_index,$fill_color,$stroke_opacity);
sub _build_style {
  my ($self,$id,$color,$fill,$stroke_opacity) = @_;
  my $thickness = $self->_get_thickness() || 1;

  my $fill_opacity = ($fill) ? '1.0' : 0;
  $fill = defined $fill ? $self->_get_color($fill) : 'none';
  $stroke_opacity ||= '1.0';
  my %style = ('stroke'        => $self->_get_color($color),
	       'stroke-opacity' => $stroke_opacity,
	       'stroke-width'   => $thickness,
	       'fill'           => $fill,
	       'fill-opacity'   => $fill_opacity);
  my $dasharray = $self->{dasharray};
  if ($self->{dasharray}) {
    $style{'stroke-dasharray'} = @{$self->{dasharray}};
    $style{fill} = 'none';
  }
  return \%style;
}

# From a color index, return a stringified rgb triplet for SVG
sub _get_color {
  my ($self,$index) = @_;
  confess "somebody gave me a bum index!" unless length $index > 0;
  return ($index) if ($index =~ /rgb/); # Already allocated.
  return ($index) if ($index eq 'none'); # Generate by callbacks using none for fill
  my ($r,$g,$b) = @{$self->{colors}->{$index}};
  my $color = "rgb($r,$g,$b)";
  return $color;
}

sub _create_id {
  my ($self,$x,$y) = @_;
  $self->{id_count}++;
  return (join('-',$self->{id_count},$x,$y));
}

# Break apart the internal representation of gdBrushed
# setting the line thickness and returning the foreground color
sub _distill_gdSpecial {
  my ($self,$type) = @_;
  # Save the previous line thickness so I can restore after drawing...
  $self->{prev_line_thickness} = $self->_get_thickness() || 1;
  my $thickness = $self->{$type}->{thickness};
  $thickness ||= 1;
  my $color;
  if ($type eq 'gdStyled') {
    # Calculate the size in pixels of each dash
    # The first color only will be used starting with the first
    # dash; remaining dashes will become gaps
    my @colors = @{$self->{$type}->{color}};
    my ($prev,@dashes,$dash_length);
    foreach (@colors) {
      if (!$prev) {
	$dash_length = 1;
      } elsif ($prev && $prev == $_) {
	$dash_length++;
      } elsif ($prev && $prev != $_) {
	push (@{$self->{dasharray}},$dash_length);
	$dash_length = 1;
      }
      $prev = $_;
    }
    push (@{$self->{dasharray}},$dash_length);
    $color = $colors[0];
  } else {
    $color = $self->{$type}->{color};
  }
  
  $self->setThickness($thickness);
  return $color;
}


# Reset presistent drawing settings between uses of stylized brushes
sub _reset {
  my $self = shift;
  $self->{line_thickness} = $self->{prev_line_thickness} || $self->{line_thickness};
  $self->{prev_line_thickness} = undef;
  delete $self->{dasharray};
}

# SVG needs some self-awareness so that post-drawing operations can
# occur. This is accomplished by tracking all of the pixels that have
# been filled in thus far.
sub _save {
  my ($self) = @_;
  #  my $path = $img->get_path(x=>[$x1,$x2],y=>[$y1,$y2],-type=>'polyline',-closed=>1);
  #  foreach (keys %$path) {
  #    print STDERR $_,"\t",$path->{$_},"\n";
  #  }
  #  push (@{$self->{pixels_filled}},$path);
}

# Value-access methods
# Get the thickness of the line (if it has been set)
sub _get_thickness {  return shift->{line_thickness} }

# return the internal GD object
sub _gd { return shift->{gd} }

##################################################
# Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Polygon
##################################################
package Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Polygon;
use GD::Polygon;
use vars qw(@ISA);
@ISA = 'GD::Polygon';

sub _error {
  my ($self,$method) = @_;
  Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Image->_error($method);
}

sub DESTROY { }

# Generic Font package for accessing height and width information
# and for formatting strings
package Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Font;

use vars qw/@ISA/;
@ISA = qw(Games::RolePlay::MapGen::Exporter::SVG::_GDSVG);

# Return guestimated values on the font height and width
sub width   { return shift->{width}; }
sub height  { return shift->{height}; }
sub font    { return shift->{font}; }
sub weight  { return shift->{weight}; }
sub nchars  { shift->_error('nchars')} # NOT SUPPORTED!!

# Build the formatting hash for each font...
sub formatting {
  my $self = shift;
  my $size    = $self->height;
  my $font    = $self->font;
  my $weight  = $self->weight;
  my %format = ('font-size' => $size,
		'font'       => $font,
#		'writing-mode' => 'tb',
	       );
  $format{'font-weight'} = $weight if ($weight);
  return \%format;
}

sub Tiny  { return Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::gdTinyFont; }
sub Small { return Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::gdSmallFont; }
sub MediumBold { return Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::gdMediumBoldFont; }
sub Large { return Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::gdLargeFont; }
sub Giant { return Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::gdGiantFont; }

sub _error {
  my ($self,$method) = @_;
  Games::RolePlay::MapGen::Exporter::SVG::_GDSVG::Image->_error($method);
}

sub DESTROY { }


1;
