# $Id: BasicImage.pm,v 1.20 2005/04/03 17:30:12 jettero Exp $
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
    my $brown  = $gd->colorAllocate(0xaa, 0x90, 0x00);


    my $door_arc_color     = $lgrey;
    my $door_color         = $brown;
    my $wall_color         = $black;
    my $non_map_tile_color = $dgrey;
    my $open_color         = $white;

    my $D     = 5; # the border around debugging marks
    my $B     = 1; # the border around the filled rectangles for empty tiles
    my $L     = 1; # the length of the cell ticks in open borders
       $L++;       # $L is one less than it seems...

    my ($dm, $dM) = (1, 4); # akin to L, but for doors (door minor horrizontal, door minor vertical and door major)
    my ($wx, $wy) = ( $opts->{x_size}*2-$dM*4, $opts->{y_size}*2-$dM*4 ); # the width and height of the door-arcs (cell size)

    my $am = $dm +1; # the arc displacement is just a little bigger so it doesn't overlap the doors...

    my $oa = 45;  # show doors open by this amount
    my $do = $oa; # show doors the same amount? or a little bit different?
       $do -= 10; # this looks kinda neat.

    my $or = deg2rad( $do );
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
            my $ns_h = int ($ns_l * $sr);
            my $ew_h = int ($ew_l * $sr);
            my $ns_b = int( sqrt( $ns_l ** 2 - $ns_h ** 2 ) );
            my $ew_b = int( sqrt( $ew_l ** 2 - $ew_h ** 2 ) );

            $gd->line( $xp, $yp => $Xp, $yp, $wall_color );
            $gd->line( $xp, $Yp => $Xp, $Yp, $wall_color );
            $gd->line( $Xp, $yp => $Xp, $Yp, $wall_color );
            $gd->line( $xp, $yp => $xp, $Yp, $wall_color );

            $gd->line( $xp+$L, $yp     => $Xp-$L, $yp,    $open_color ) if $t->{od}{n} == 1; # == 1 doesn't match doors...
            $gd->line( $xp+$L, $Yp     => $Xp-$L, $Yp,    $open_color ) if $t->{od}{s} == 1;
            $gd->line( $Xp,    $yp+$L, => $Xp,    $Yp-$L, $open_color ) if $t->{od}{e} == 1;
            $gd->line( $xp,    $yp+$L, => $xp,    $Yp-$L, $open_color ) if $t->{od}{w} == 1;

            if( $t->{od}{n} == 1 and $t->{od}{w} == 1 ) { # == 1 doesn't match doors
                if( $t->{nb}{n}{od}{w} == 1 and $t->{nb}{w}{od}{n} == 1 ) {
                    $gd->line( $xp-$L, $yp    => $xp+$L, $yp,    $open_color );
                    $gd->line( $xp,    $yp-$L => $xp,    $yp+$L, $open_color );
                }
            }

            for my $dir (qw(n e s w)) {
                if( ref(my $door = $t->{od}{$dir}) ) {
                    unless( $door->{_drawn}{$dir} ) {

                        # use Data::Dumper;
                        # die Dumper( $door );  # these doors are all set to be drawn in their various different ways

                        if( not $door->{secret} ) {
                            # Regular old unlocked, open, unstock, unhidden doors are these cute little rectangles.

                            $gd->filledRectangle( $xp+$dM, $yp-$dm => $Xp-$dM, $yp+$dm, $door_color ) if $dir eq "n";
                            $gd->filledRectangle( $Xp-$dm, $yp+$dM => $Xp+$dm, $Yp-$dM, $door_color ) if $dir eq "e";
                            $gd->filledRectangle( $xp+$dM, $Yp-$dm => $Xp-$dM, $Yp+$dm, $door_color ) if $dir eq "s";
                            $gd->filledRectangle( $xp-$dm, $yp+$dM => $xp+$dm, $Yp-$dM, $door_color ) if $dir eq "w";
                        }

                        # Here, we draw the diagonal line and arc indicating how the door opens.
                        my $oi = "$dir$door->{open_dir}{major}$door->{open_dir}{minor}";

                        # draw the door line/arcs ... sadly, this is a 16 part if-else block {{{
                        if( $oi eq "sne" ) {
                            $gd->arc(  $Xp-$dM, $Yp-$am, $wx, $wy, 180, 180+$oa,           $door_arc_color );
                            $gd->line( $Xp-$dM, $Yp-$am => ($Xp-$dM)-$ns_b, $Yp-$am-$ns_h, $door_arc_color );

                        } elsif( $oi eq "nne" ) {  # same as above, but $Yp changes to $yp
                            $gd->arc(  $Xp-$dM, $yp-$am, $wx, $wy, 180, 180+$oa,           $door_arc_color );
                            $gd->line( $Xp-$dM, $yp-$am => ($Xp-$dM)-$ns_b, $yp-$am-$ns_h, $door_arc_color );


                        } elsif( $oi eq "sse" ) {  # same as two above, but 180-$oa and +$ns_h
                            $gd->arc(  $Xp-$dM, $Yp+$am, $wx, $wy, 180-$oa, 180,           $door_arc_color );
                            $gd->line( $Xp-$dM, $Yp+$am => ($Xp-$dM)-$ns_b, $Yp+$am+$ns_h, $door_arc_color );

                        } elsif( $oi eq "nse" ) {  # same as above, but $Yp to $yp
                            $gd->arc(  $Xp-$dM, $yp+$am, $wx, $wy, 180-$oa, 180,           $door_arc_color );
                            $gd->line( $Xp-$dM, $yp+$am => ($Xp-$dM)-$ns_b, $yp+$am+$ns_h, $door_arc_color );


                        } elsif( $oi eq "snw" ) { # same as sne, but 360-$oa, $xp, and +$ns_b
                            $gd->arc(  $xp+$dM, $Yp-$am, $wx, $wy, 360-$oa, 360,           $door_arc_color );
                            $gd->line( $xp+$dM, $Yp-$am => ($xp+$dM)+$ns_b, $Yp-$am-$ns_h, $door_arc_color );

                        } elsif( $oi eq "nnw" ) { # same as above, but $yp
                            $gd->arc(  $xp+$dM, $yp-$am, $wx, $wy, 360-$oa, 360,           $door_arc_color );
                            $gd->line( $xp+$dM, $yp-$am => ($xp+$dM)+$ns_b, $yp-$am-$ns_h, $door_arc_color );


                        } elsif( $oi eq "ssw" ) { # same as sse, but $xp, +$ns_b, and 360+$oa
                            $gd->arc(  $xp+$dM, $Yp+$am, $wx, $wy, 360, 360+$oa,           $door_arc_color );
                            $gd->line( $xp+$dM, $Yp+$am => ($xp+$dM)+$ns_b, $Yp+$am+$ns_h, $door_arc_color );

                        } elsif( $oi eq "nsw" ) { # same as above, but $yp
                            $gd->arc(  $xp+$dM, $yp+$am, $wx, $wy, 360, 360+$oa,           $door_arc_color );
                            $gd->line( $xp+$dM, $yp+$am => ($xp+$dM)+$ns_b, $yp+$am+$ns_h, $door_arc_color );


                        } elsif( $oi eq "een" ) {
                            $gd->arc(  $Xp+$am, $yp+$dM, $wx, $wy, 90-$oa, 90,             $door_arc_color );
                            $gd->line( $Xp+$am, $yp+$dM => $Xp+$am+$ew_h, ($yp+$dM)+$ew_b, $door_arc_color );

                        } elsif( $oi eq "wen" ) { # same as above but $Xp to $xp
                            $gd->arc(  $xp+$am, $yp+$dM, $wx, $wy, 90-$oa, 90,             $door_arc_color );
                            $gd->line( $xp+$am, $yp+$dM => $xp+$am+$ew_h, ($yp+$dM)+$ew_b, $door_arc_color );


                        } elsif( $oi eq "ewn" ) { # same as two above, but 90+$oa and -$ew_h
                            $gd->arc(  $Xp-$am, $yp+$dM, $wx, $wy, 90, 90+$oa,             $door_arc_color );
                            $gd->line( $Xp-$am, $yp+$dM => $Xp-$am-$ew_h, ($yp+$dM)+$ew_b, $door_arc_color );

                        } elsif( $oi eq "wwn" ) { # same as above but $Xp to $xp
                            $gd->arc(  $xp-$am, $yp+$dM, $wx, $wy, 90, 90+$oa,             $door_arc_color );
                            $gd->line( $xp-$am, $yp+$dM => $xp-$am-$ew_h, ($yp+$dM)+$ew_b, $door_arc_color );


                        } elsif( $oi eq "ees" ) { # same as een, but $Yp, -$ew_b and 270+$oa
                            $gd->arc(  $Xp+$am, $Yp-$dM, $wx, $wy, 270, 270+$oa,           $door_arc_color );
                            $gd->line( $Xp+$am, $Yp-$dM => $Xp+$am+$ew_h, ($Yp-$dM)-$ew_b, $door_arc_color );

                        } elsif( $oi eq "wes" ) { # same as above, but $xp
                            $gd->arc(  $xp+$am, $Yp-$dM, $wx, $wy, 270, 270+$oa,           $door_arc_color );
                            $gd->line( $xp+$am, $Yp-$dM => $xp+$am+$ew_h, ($Yp-$dM)-$ew_b, $door_arc_color );

                        } elsif( $oi eq "ews" ) { # same as ewn above, but 
                            $gd->arc(  $Xp-$am, $Yp-$dM, $wx, $wy, 270-$oa, 270,           $door_arc_color );
                            $gd->line( $Xp-$am, $Yp-$dM => $Xp-$am-$ew_h, ($Yp-$dM)-$ew_b, $door_arc_color );

                        } elsif( $oi eq "wws" ) { # same as above, but $xp
                            $gd->arc(  $xp-$am, $Yp-$dM, $wx, $wy, 270-$oa, 270,           $door_arc_color );
                            $gd->line( $xp-$am, $Yp-$dM => $xp-$am-$ew_h, ($Yp-$dM)-$ew_b, $door_arc_color );

                        }
                        # }}}

                        # $door->{_drawn}{$dir} = 1;
                    }
                }
            }

            if( not $t->{type} ) {
                $gd->filledRectangle( $xp+$B, $yp+$B => $Xp-$B, $Yp-$B, $non_map_tile_color );
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
