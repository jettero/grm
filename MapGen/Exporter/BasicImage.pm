# $Id: BasicImage.pm,v 1.15 2005/04/02 23:47:06 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Visualization::BasicImage;

use strict;
use Carp;
use GD;
use Math::Trig qw(deg2rad);

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

    my $map = $this->genmap($opts);
    unless( $opts->{fname} eq "-retonly" ) {
        open _MAP_OUT, ">$opts->{fname}" or die "ERROR: couldn't open $opts->{fname} for write: $!";
        print _MAP_OUT $map->png; # the format should really be an option... at some point
        close _MAP_OUT;
    }

    return $map;
}
# }}}

# gen_cell_size {{{
sub gen_cell_size {
    my $this = shift;
    my $opts = shift;

    if( $opts->{cell_size} ) {
        die "ERROR: illegal cell size '$opts->{cell_size}'" unless $opts->{cell_size} =~ m/^(\d+)x(\d+)/;
        $opts->{x_size} = $1;
        $opts->{y_size} = $2;
    }
}
# }}}
# genmap {{{
sub genmap {
    my $this = shift;
    my $opts = shift;
    my $map  = $opts->{_the_map};

    $this->gen_cell_size($opts);

    my $gd    = new GD::Image(1+($opts->{x_size} * @{$map->[0]}), 1+($opts->{y_size} * @$map));

    my $white  = $gd->colorAllocate(0xff, 0xff, 0xff);
    my $black  = $gd->colorAllocate(0x00, 0x00, 0x00);
    my $lgrey  = $gd->colorAllocate(0xcc, 0xcc, 0xcc);
    my $dgrey  = $gd->colorAllocate(0x60, 0x60, 0x60);
    my $grey   = $gd->colorAllocate(0x90, 0x90, 0x90);
    my $blue   = $gd->colorAllocate(0x00, 0x00, 0xbb);
    my $red    = $gd->colorAllocate(0xbb, 0x00, 0x00);
    my $green  = $gd->colorAllocate(0x00, 0xbb, 0x00);
    my $purple = $gd->colorAllocate(0xff, 0x00, 0xff);

    my $D     = 5; # the border around debugging marks
    my $B     = 1; # the border around the filled rectangles for empty tiles
    my $L     = 1; # the length of the cell ticks in open borders
       $L++;       # $L is one less than it seems...

    my ($dm, $dM) = (2, 4); # akin to L, but for doors (door minor horrizontal, door minor vertical and door major)
    my ($wx, $wy) = ( $opts->{x_size}*2-$dM*4, $opts->{y_size}*2-$dM*4 ); # the width and height of the door-arcs (cell size)

    my $oa = 45;  # show doors open by this amount
    my $or = deg2rad( $oa );
    my $sr = sin( $or ); # we'll be using this, kthx...

    $gd->interlaced('true');

    for my $i (0..$#$map) {
        my $jend = $#{$map->[$i]};

        for my $j (0..$jend) {
            my $t = $map->[$i][$j];
            my $xp =  $j    * $opts->{x_size};
            my $yp =  $i    * $opts->{y_size};
            my $Xp = ($j+1) * $opts->{x_size};
            my $Yp = ($i+1) * $opts->{y_size};

            my $ns_l = (($Xp-$dM) - ($xp+$dM));  # for the doors...
            my $ew_l = (($Yp-$dM) - ($yp+$dM));
            my $ns_h = $ns_l * $sr;
            my $ew_h = $ew_l * $sr;
            my $ns_b = sqrt( $ns_l ** 2 - $ns_h ** 2 );
            my $ew_b = sqrt( $ew_l ** 2 - $ew_h ** 2 );

            $gd->line( $xp, $yp => $Xp, $yp, $black );
            $gd->line( $xp, $Yp => $Xp, $Yp, $black );
            $gd->line( $Xp, $yp => $Xp, $Yp, $black );
            $gd->line( $xp, $yp => $xp, $Yp, $black );

            $gd->line( $xp+$L, $yp     => $Xp-$L, $yp,    $white ) if $t->{od}{n};
            $gd->line( $xp+$L, $Yp     => $Xp-$L, $Yp,    $white ) if $t->{od}{s};
            $gd->line( $Xp,    $yp+$L, => $Xp,    $Yp-$L, $white ) if $t->{od}{e};
            $gd->line( $xp,    $yp+$L, => $xp,    $Yp-$L, $white ) if $t->{od}{w};

            if( $t->{od}{n} and $t->{od}{w} ) {
                if( $t->{nb}{n}{od}{w} and $t->{nb}{w}{od}{n} ) {
                    $gd->line( $xp-$L, $yp    => $xp+$L, $yp,    $white );
                    $gd->line( $xp,    $yp-$L => $xp,    $yp+$L, $white );
                }
            }

            for my $dir (qw(n e s w)) {
                if( ref(my $door = $t->{od}{$dir}) ) {
                    unless( $door->{_drawn}{$dir} ) {

                        # use Data::Dumper;
                        # die Dumper( $door );  # these doors are all set to be drawn in their various different ways

                        if( $door->{secret} ) {
                            # This is a secret door, so it should look like a wall.
                            # Yes, you're reading it right... we're RE-drawing an erased line.

                            $gd->line( $xp, $yp => $Xp, $yp, $black ) if $dir eq "n";
                            $gd->line( $xp, $Yp => $Xp, $Yp, $black ) if $dir eq "s";
                            $gd->line( $Xp, $yp => $Xp, $Yp, $black ) if $dir eq "e";
                            $gd->line( $xp, $yp => $xp, $Yp, $black ) if $dir eq "w";

                        } else {
                            # Regular old unlocked, open, unstock, unhidden doors are these cute little rectangles.

                            $gd->filledRectangle( $xp+$dM, $yp-$dm => $Xp-$dM, $yp+$dm, $lgrey ) if $dir eq "n";
                            $gd->filledRectangle( $Xp-$dm, $yp+$dM => $Xp+$dm, $Yp-$dM, $lgrey ) if $dir eq "e";
                            $gd->filledRectangle( $xp+$dM, $Yp-$dm => $Xp-$dM, $Yp+$dm, $lgrey ) if $dir eq "s";
                            $gd->filledRectangle( $xp-$dm, $yp+$dM => $xp+$dm, $Yp-$dM, $lgrey ) if $dir eq "w";
                        }

                        # Here, we draw the diagonal line and arc indicating how the door opens.
                        my $oi = "$dir$door->{open_dir}{major}$door->{open_dir}{minor}";

                        if( $oi eq "sne" ) {
                          # $gd->arc(  $Xp-$dM, $Yp, $wx, $wy, 180, 180+$oa,       $grey );
                          # $gd->line( $Xp-$dM, $Yp => ($Xp-$dM)-$ns_b, $Yp-$ns_h, $grey );

                        } elsif( $oi eq "nne" ) {  # same as above, but $Yp changes to $yp
                          # $gd->arc(  $Xp-$dM, $yp, $wx, $wy, 180, 180+$oa,       $grey );
                          # $gd->line( $Xp-$dM, $yp => ($Xp-$dM)-$ns_b, $yp-$ns_h, $grey );

                        } elsif( $oi eq "sse" ) {  # same as two above, but 180-$oa and +$ns_h
                          # $gd->arc(  $Xp-$dM, $Yp, $wx, $wy, 180-$oa, 180,       $grey );
                          # $gd->line( $Xp-$dM, $Yp => ($Xp-$dM)-$ns_b, $Yp+$ns_h, $grey );

                        } elsif( $oi eq "nse" ) {  # same as above, but $Yp to $yp
                          # $gd->arc(  $Xp-$dM, $yp, $wx, $wy, 180-$oa, 180,       $grey );
                          # $gd->line( $Xp-$dM, $yp => ($Xp-$dM)-$ns_b, $yp+$ns_h, $grey );


                        } elsif( $oi eq "een" ) {
                          # $gd->arc(  $Xp, $yp+$dM, $wx, $wy, 90-$oa, 90,         $grey );
                          # $gd->line( $Xp, $yp+$dM => $Xp+$ew_h, ($yp+$dM)+$ew_b, $grey );

                        } elsif( $oi eq "wen" ) { # same as above but $Xp to $xp
                          # $gd->arc(  $xp, $yp+$dM, $wx, $wy, 90-$oa, 90,         $grey );
                          # $gd->line( $xp, $yp+$dM => $xp+$ew_h, ($yp+$dM)+$ew_b, $grey );

                        } elsif( $oi eq "ewn" ) { # same as two above, but 90+$oa and -$ew_h
                          # $gd->arc(  $Xp, $yp+$dM, $wx, $wy, 90, 90+$oa,         $grey );
                          # $gd->line( $Xp, $yp+$dM => $Xp-$ew_h, ($yp+$dM)+$ew_b, $grey );

                        } elsif( $oi eq "wwn" ) { # same as above but $Xp to $xp
                          # $gd->arc(  $xp, $yp+$dM, $wx, $wy, 90, 90+$oa,         $grey );
                          # $gd->line( $xp, $yp+$dM => $xp-$ew_h, ($yp+$dM)+$ew_b, $grey );
                        }

                        # Use this when everything is all debugged...
                        # $door->{_drawn}{$dir} = 1;
                    }
                }
            }

            if( not $t->{type} ) {
                $gd->filledRectangle( $xp+$B, $yp+$B => $Xp-$B, $Yp-$B, $dgrey );
            }

            if( $t->{DEBUG_red_mark} ) {
                $gd->filledRectangle( $xp+$D, $yp+$D => $Xp-$D, $Yp-$D, $red );
            }

            if( $t->{DEBUG_blue_mark} ) {
                $gd->filledRectangle( $xp+$D, $yp+$D => $Xp-$D, $Yp-$D, $blue );
            }

            if( $t->{DEBUG_green_mark} ) {
                $gd->filledRectangle( $xp+$D, $yp+$D => $Xp-$D, $Yp-$D, $green );
            }

            if( $t->{DEBUG_purple_mark} ) {
                $gd->filledRectangle( $xp+$D, $yp+$D => $Xp-$D, $Yp-$D, $purple );
            }
        }
    }

    for my $t (map(@$_, @$map)) {
        for my $d (keys %{ $t->{od} }) {
            if( ref( my $door = $t->{od}{$d} ) ) {
                delete $door->{_drawn};
            }
        }
    }

    return $gd;
}
# }}}

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
