# $Id: BasicImage.pm,v 1.7 2005/03/25 18:23:01 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Visualization::BasicImage;

use strict;
use Carp;
use GD;

1;

# new {{{
sub new {
    my $class = shift;
    my $this  = bless {o => {@_}}, $class;

    return $this;
}
# }}}
# go {{{
sub go {
    my $this = shift;
    my $opts = {@_};

    for my $k (keys %{ $this->{o} }) {
        $opts->{$k} = $this->{o}{$k} if not exists $opts->{$k};
    }

    croak "ERROR: fname is a required option for " . ref($this) . "::go()" unless $opts->{fname};
    croak "ERROR: _the_map is a required option for " . ref($this) . "::go()" unless ref($opts->{_the_map});

    my $map = $this->_genmap($opts);
    unless( $opts->{fname} eq "-retonly" ) {
        open _MAP_OUT, ">$opts->{fname}" or die "ERROR: couldn't open $opts->{fname} for write: $!";
        print _MAP_OUT $map->png; # the format should really be an option... at some point
        close _MAP_OUT;
    }

    return $map;
}
# }}}

# _gen_cell_size {{{
sub _gen_cell_size {
    my $this = shift;
    my $opts = shift;

    if( $opts->{cell_size} ) {
        die "ERROR: illegal cell size '$opts->{cell_size}'" unless $opts->{cell_size} =~ m/^(\d+)x(\d+)/;
        $opts->{x_size} = $1;
        $opts->{y_size} = $2;
    }
}
# }}}

sub _genmap {
    my $this = shift;
    my $opts = shift;
    my $m    = $opts->{_the_map};

    $this->_gen_cell_size($opts);

    my $gd    = new GD::Image(1+($opts->{x_size} * @{$m->[0]}), 1+($opts->{y_size} * @$m));
    my $white = $gd->colorAllocate(255, 255, 255);
    my $black = $gd->colorAllocate(  0,   0,   0);
    my $grey  = $gd->colorAllocate(240, 240, 240);
    my $dgrey = $gd->colorAllocate( 80,  80,  80);
    my $blue  = $gd->colorAllocate(  0,   0, 190);
    my $B     = 1; # the border around the filled rectangles for empty tiles
    my $L     = 1; # the length of the cell ticks in open borders
       $L++;       # $L is one less than it seems...

    $gd->interlaced('true');

    for my $i (0..$#$m) {
        my $jend = $#{$m->[$i]};

        for my $j (0..$jend) {
            my $t = $m->[$i][$j];
            my $xp =  $j    * $opts->{x_size};
            my $yp =  $i    * $opts->{y_size};
            my $Xp = ($j+1) * $opts->{x_size};
            my $Yp = ($i+1) * $opts->{y_size};

            $gd->line( $xp, $yp => $Xp, $yp, $black );
            $gd->line( $xp, $Yp => $Xp, $Yp, $black );
            $gd->line( $Xp, $yp => $Xp, $Yp, $black );
            $gd->line( $xp, $yp => $xp, $Yp, $black );

            $gd->line( $xp+$L, $yp    => $Xp-$L, $yp,    $white ) if $t->{od}{n};
            $gd->line( $xp+$L, $Yp    => $Xp-$L, $Yp,    $white ) if $t->{od}{s};
            $gd->line( $Xp,    $yp+$L => $Xp,    $Yp-$L, $white ) if $t->{od}{e};
            $gd->line( $xp,    $yp+$L => $xp,    $Yp-$L, $white ) if $t->{od}{w};

            if( not $t->{type} ) {
                $gd->filledRectangle( $xp+$B, $yp+$B => $Xp-$B, $Yp-$B, $dgrey );
            }

            # if( $t->{DEBUG_nex} ) {
                # $gd->filledRectangle( $xp+$B, $yp+$B => $Xp-$B, $Yp-$B, $blue );
            # }
        }
    }

    return $gd;
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Visualization::BasicImage - A pure text mapgen visualization.

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
