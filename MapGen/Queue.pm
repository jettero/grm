# $Id: Queue.pm 577.16979.RVAQ3gGyXIWTfBfOM2KlE6vzssc 2007-05-07 07:26:15 -0400 $

package Games::RolePlay::MapGen::Queue;

use strict;
use Carp;
use Exporter;
use constant {
    LOS_NO              => 0,
    LOS_YES             => 1,
    LOS_IGNORABLE_COVER => 2,
    LOS_COVER           => 3,
    };

use base qw(Exporter);
our @EXPORT = qw(LOS_NO LOS_COVER LOS_IGNORABLE_COVER LOS_YES);

1;

# new {{{
sub new {
    my $class = shift;
    my $the_m = shift;
    my $this = bless { _the_map=>$the_m, o=>{}, c=>[] }, $class;

    $this->{ym} = $#{ $the_m };
    $this->{xm} = $#{ $the_m->[0] };

    croak "where is _the_map?" unless ref $the_m;

    return $this;
}
# }}}

# _check_loc {{{
sub _check_loc {
    my $this = shift;
    my $loc  = shift;

    return 0 if @$loc != 2;
    return 0 if $loc->[0] < 0;
    return 0 if $loc->[1] < 0;
    return 0 if $loc->[0] > $this->{xm};
    return 0 if $loc->[1] > $this->{ym};

    my $type = $this->{_the_map}[ $loc->[1] ][ $loc->[0] ]{type};
    return 0 unless $type; # the wall type is <undef>

    return $loc;
}
# }}}
# _lline_of_sight {{{
sub _lline_of_sight {
    my $this = shift;
    my ($lhs, $rhs) = @_;

    return LOS_YES if "@$lhs" eq "@$rhs";

    my @X = sort {$a<=>$b} ($lhs->[0], $rhs->[0]); @X = ($X[0] .. $X[1]);
    my @Y = sort {$a<=>$b} ($lhs->[1], $rhs->[1]); @Y = ($Y[0] .. $Y[1]);

    my $x_dir = ($lhs->[0] < $rhs->[0] ? "e" : "w");
    my $y_dir = ($lhs->[1] < $rhs->[1] ? "s" : "n");

    my @od_segments = (); # the solid line segments we might have to pass through
    for my $x (@X[0 .. $#X-1]) {
        for my $y (@Y[0 .. $#Y-1]) {
            my $x_od = $this->{_the_map}[ $y ][ $x ]{od}{ $x_dir };
            my $y_od = $this->{_the_map}[ $y ][ $x ]{od}{ $y_dir };

            for( $x_od, $y_od ) {
                $_ = $_->{'open'} if ref $_;
            }

            push @od_segments, [ "line segment co-ordinates as two arrayrefs" ]
                if $x_od; # this will require different calcs for e vs w

            push @od_segments, [ "line segment co-ordinates as two arrayrefs" ]
                if $y_od; # this will require different calcs for n vs s
        }
    }

    warn "---= lhs=[@$lhs]; rhs=[@$rhs]; X=[@X]; Y=[@Y];\n";
    warn "\tSET\n";
    warn "\t\tod=[ (@{$_->[0]})->(@{$_->[1]}) ]" for @od_segments;
    warn "\tDONE\n";

    my @lhs = (
        [ $lhs->[0]+0, $lhs->[1]+0 ], # sw corner
        [ $lhs->[0]+1, $lhs->[1]+0 ], # se corner
        [ $lhs->[0]+0, $lhs->[1]+1 ], # nw corner
        [ $lhs->[0]+1, $lhs->[1]+1 ], # ne corner
    );

    my @rhs = (
        [ $rhs->[0]+0, $rhs->[1]+0 ], # sw corner
        [ $rhs->[0]+1, $rhs->[1]+0 ], # se corner
        [ $rhs->[0]+0, $rhs->[1]+1 ], # nw corner
        [ $rhs->[0]+1, $rhs->[1]+1 ], # ne corner
    );

    LHS: for my $l (@lhs) {
    RHS: for my $r (@rhs) {
    }}

    return LOS_NO;
}
=cut
sub _lline_of_sight {
    my $this = shift;
    my ($lhs, $rhs) = @_;

    return LOS_YES if "@$lhs" eq "@$rhs";

    my @lhs = (
        [ $lhs->[0]+0, $lhs->[1]+0 ], # sw corner
        [ $lhs->[0]+1, $lhs->[1]+0 ], # se corner
        [ $lhs->[0]+0, $lhs->[1]+1 ], # nw corner
        [ $lhs->[0]+1, $lhs->[1]+1 ], # ne corner
    );

    my @rhs = (
        [ $rhs->[0]+0, $rhs->[1]+0 ], # sw corner
        [ $rhs->[0]+1, $rhs->[1]+0 ], # se corner
        [ $rhs->[0]+0, $rhs->[1]+1 ], # nw corner
        [ $rhs->[0]+1, $rhs->[1]+1 ], # ne corner
    );

    my $max_x = $lhs[0][0]; my $min_x = $max_x; my $max_y = $lhs[0][1]; my $min_y = $max_y;
    for(@lhs,@rhs) {
        $max_x = $_->[0] if $_->[0] > $max_x;
        $min_x = $_->[0] if $_->[0] < $min_x;
        $max_y = $_->[1] if $_->[1] > $max_y;
        $min_y = $_->[1] if $_->[1] < $min_y;
    }

    my (@range, @domain) = ();

    if( $lhs->[0] < $rhs->[0] ) {
        @range = ( $lhs->[0] .. $rhs->[0]-1 );

    } elsif( $lhs->[0] > $rhs->[0] ) {
        @range = ( $rhs->[0] .. $lhs->[0]-1 );
    }

    if( $lhs->[1] < $rhs->[1] ) {
        @domain = ( $lhs->[1] .. $rhs->[1]-1 );

    } elsif( $lhs->[1] > $rhs->[1] ) {
        @domain = ( $rhs->[1] .. $lhs->[1]-1 );
    }

    warn "---= lhs=[@$lhs]; rhs=[@$rhs]; $min_x<=x<=$max_x; $min_y<=y<=$max_y;\n";

    my @results = ();
    LHS: for my $l (@lhs) { unshift @results, [];
    RHS: for my $r (@rhs) { unshift @{ $results[0] }, LOS_YES;

        warn "\tl=(@$l); r=(@$r); range=[@range]; domain=[@domain];\n";

        my $x_dir = ($l->[0] < $r->[0] ? "e" : "w");
        my $y_dir = ($l->[1] < $r->[1] ? "s" : "n");

        if( $l->[0] == $r->[0] ) {
            for my $y (@domain) {
                my $x = $l->[0];
                my @tile_locs = ([ $x, $y-1 ]);

                my $this_open = 0;
                for my $tl (@tile_locs) {
                    my $od = $this->{_the_map}[ $tl->[1] ][ $tl->[0] ]{od}{ $y_dir };

                    if( ref $od ) {
                        $od = $od->{'open'};
                        warn "\t\tX=l0=$x; Y=$y; tl=[@$tl]; od=door($od); y_dir=$y_dir;\n";

                    } else {
                        warn "\t\tX=l0=$x; Y=$y; tl=[@$tl]; od=$od; y_dir=$y_dir;\n";
                    }

                    $this_open ++ if $od;
                }

                if( $this_open < @tile_locs ) {
                    my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                    my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                    my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                    $results[0][0] = $c if $c > $results[0][0];

                    # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                }
            }

        } else {
            # not vertical
            my $m = ($r->[1]-$l->[1]) / ($r->[0]-$l->[0]);
            my $b = $l->[1] - $m * $l->[0];

            for my $x (@range) {
                my $y = $m * $x + $b;

                my @tile_locs = ();
                if( $y >= $min_y and $y <= $max_y ) {
                    @tile_locs = ([ $x-1, int $y]);
                    if( $y == (int $y) and $m != 0 ) {
                        push @tile_locs, [$x-1, $y-1];
                    }
                }

                my $this_open = 0;
                for my $tl (@tile_locs) {
                    my $od = $this->{_the_map}[ $tl->[1] ][ $tl->[0] ]{od}{ $x_dir };

                    if( ref $od ) {
                        $od = $od->{'open'};

                        warn "\t\tX=$x; y=$y; (m=$m; b=$b); tl=[@$tl]; od=door($od); x_dir=$x_dir;\n";

                    } else {
                        warn "\t\tX=$x; y=$y; (m=$m; b=$b); tl=[@$tl]; od=$od; x_dir=$x_dir;\n";
                    }

                    $this_open ++ if $od;
                }

                if( $this_open < @tile_locs ) {
                    my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                    my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                    my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                    $results[0][0] = $c if $c > $results[0][0];

                    # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                }
            }

            if( $m != 0 ) {
                for my $y (@domain) {
                    my $x = ($y-$b)/$m;

                    my @tile_locs = ();
                    if( $x >= $min_x and $x <= $max_x ) {
                        @tile_locs = ([ int $x, $y-1 ]);
                        if( $x == (int $x) ) {
                            push @tile_locs, [$x-1, $y-1];
                        }
                    }

                    my $this_open = 0;
                    for my $tl (@tile_locs) {
                        my $od = $this->{_the_map}[ $tl->[1] ][ $tl->[0] ]{od}{ $y_dir };

                        if( ref $od ) {
                            $od = $od->{'open'};

                            warn "\t\tx=$x; Y=$y; (m=$m; b=$b); tl=[@$tl]; od=door($od); y_dir=$y_dir\n";

                        } else {
                            warn "\t\tx=$x; Y=$y; (m=$m; b=$b); tl=[@$tl]; od=$od; y_dir=$y_dir\n";
                        }

                        $this_open ++ if $od;
                    }

                    if( $this_open < @tile_locs ) {
                        my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                        my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                        my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                        $results[0][0] = $c if $c > $results[0][0];

                        # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                    }
                }
            }
        }
    }}

    my $at_least_one_1  = 0;
    my $minimum_maximum = LOS_COVER+1;
    for my $lca (@results) {
        my $max = 0;
        for my $res (@$lca) {
            $at_least_one_1 = 1 if $res == 1;
            $max = $res if $res > $max;
        }

        $minimum_maximum = $max if $max < $minimum_maximum;
    }

    warn "---= FIN: minimum_maximum=$minimum_maximum; at_least_one_1=$at_least_one_1;";
    use Data::Dumper; $Data::Dumper::Indent = 0;
    warn Dumper(\@results)."\n\n";

    return LOS_NO unless $at_least_one_1; # there is no line of sight at all

    return $minimum_maximum;
}
=cut

# }}}
# _ldistance {{{
sub _ldistance {
    my $this = shift;
    my ($lhs, $rhs) = @_;

    return sqrt ( (($lhs->[0]-$rhs->[0]) ** 2) + (($lhs->[1]-$rhs->[1]) ** 2) );
}
# }}}
# _locations_in_line_of_sight {{{
sub _locations_in_line_of_sight {
    my $this = shift;
    my $init = shift;
    my @loc  = ();
    my @new  = ($init);

    my %checked = ( "@$init" => 1 );
    while( @new ) {
        my @very_new = ();

        for my $i (@new) {
            for my $j ( [$i->[0]+1, $i->[1]], [$i->[0]-1, $i->[1]], [$i->[0], $i->[1]+1], [$i->[0], $i->[1]-1] ) {
                next if $checked{"@$j"};
                next unless $this->_check_loc($j);

                $checked{"@$j"} = 1;

                push @very_new, $j if $this->_lline_of_sight( $init => $j );
            }
        }

        push @loc, @new;
        @new = @very_new;
    }

    return @loc;
}
# }}}

# location {{{
sub location {
    my $this = shift;
    my $that = shift;

    croak "that object/tag ($that) isn't on the map" unless exists $this->{l}{$that};

    my $l = $this->{l}{$that};
    return (wantarray ? @$l : $l);
}
# }}}
# lline_of_sight {{{
sub lline_of_sight {
    my $this = shift;

    croak "you should provide 4 arguments to lline_of_sight()" unless @_ == 4;

    my @lhs = @_[0 .. 1];
    my @rhs = @_[2 .. 3];

    croak "the first two values do not appear to form a sane map location" unless $this->_check_loc(\@lhs);
    croak "the last two values do not appear to form a sane map location"  unless $this->_check_loc(\@rhs);

    return $this->_lline_of_sight(\@lhs, \@rhs); 
}
# }}}
# ldistance {{{
sub ldistance {
    my $this = shift;

    croak "you should provide 4 arguments to ldistance()" unless @_ == 4;

    my @lhs = @_[0 .. 1];
    my @rhs = @_[2 .. 3];

    croak "the first two values do not appear to form a sane map location" unless $this->_check_loc(\@lhs);
    croak "the last two values do not appear to form a sane map location"  unless $this->_check_loc(\@rhs);

    return undef unless $this->_lline_of_sight(\@lhs => \@rhs);
    return $this->_ldistance(\@lhs => \@rhs);
}
# }}}
# distance {{{
sub distance {
    my $this = shift;
    my $lhs  = shift; croak "the lhs=$lhs isn't on the map" unless exists $this->{l}{$lhs};
    my $rhs  = shift; croak "the rhs=$rhs isn't on the map" unless exists $this->{l}{$rhs};

    $lhs = $this->{l}{$lhs};
    $rhs = $this->{l}{$rhs};

    return undef unless $this->_lline_of_sight($lhs, $rhs);
    return $this->_ldistance($lhs, $rhs);
}
# }}}
# line_of_sight {{{
sub line_of_sight {
    my $this = shift;

    croak "you should provide 2 arguments to ldistance()" unless @_ == 2;

    my ($lhs, $rhs);

    croak "the first two values do not appear to form a sane map location" unless ($lhs = $this->{l}{shift});
    croak "the last two values do not appear to form a sane map location"  unless ($rhs = $this->{l}{shift});

    return $this->_lline_of_sight($lhs, $rhs); 
}
# }}}

# add {{{
sub add {
    my $this = shift;
    my $that = shift; my $tag = "$that";
    my @loc  = @_;

    croak "that object/tag ($tag) appears to already be on the map" if exists $this->{l}{$tag};
    croak "that location (@loc) makes no sense" unless $this->_check_loc(\@loc);

    $this->{l}{$tag} = \@loc;
    push @{ $this->{c}[ $loc[1] ][ $loc[0] ] }, $that;
}
# }}}
# remove {{{
sub remove {
    my $this = shift;
    my $that = shift; my $tag = "$that";

    croak "that object/tag ($tag) isn't on the map" unless exists $this->{l}{$tag};

    my @loc = delete $this->{l}{$tag};
    my $itm = $this->{c}[ $loc[1] ][ $loc[0] ];

    if( ref $that ) {
        @$itm = ( grep {$_ != $this} @$itm );

    } else {
        @$itm = ( grep {$_ ne $tag} @$itm );
    }
}
# }}}
# replace {{{
sub replace {
    my $this = shift;
    my $that = shift; my $tag = "$that";
    my @loc  = @_;

    croak "that location (@loc) makes no sense" unless $this->_check_loc(\@loc);

    $this->remove($tag) if exists $this->{l}{$tag};
    $this->add($that => @loc);
}
# }}}

# objs_at_location {{{
sub objs_at_location {
    my $this = shift;
    my $loc  = $this->_check_loc(\@_) or croak "that location (@_) makes no sense";
    my @itm  = @{ $this->{c}[ $loc->[1] ][ $loc->[0] ] || [] };

    return @itm; # this is a copy, so it's silly to use wantarray...
}
# }}}
# objs_in_line_of_sight {{{
sub objs_in_line_of_sight {
    my $this = shift;
    my $loc  = $this->_check_loc(\@_) or croak "that location (@_) makes no sense";
    my @ret  = ();

    die "make this use _locations_in_line_of_sight instead";
    for my $row ( 0 .. $this->{ym} ) {
        for my $col ( 0 .. $this->{xm} ) {
            my $rhs = [ $col, $row ];

            if( $this->_lline_of_sight( $loc => $rhs ) ) {
                my @itm  = @{ $this->{c}[ $rhs->[1] ][ $rhs->[0] ] || [] };

                push @ret, @itm;
            }
        }
    }

    return @ret;
}
# }}}

# random_open_location {{{
sub random_open_location {
    my $this = shift;

    my $max = 1000;
    my ($X, $Y) = ($this->{xm}+1, $this->{ym}+1);
    while(1) {
        my $x = int rand $X;
        my $y = int rand $Y;

        die "problem finding x,y during rol" if --$max < 1;

        return (wantarray ? ($x,$y):[$x,$y]) if defined $this->{_the_map}[ $y ][ $x ]{type}; # the wall type is <undef>
    }
}
# }}}
# locations_in_line_of_sight {{{
sub locations_in_line_of_sight {
    my $this = shift;
    my @init = @_; $this->_check_loc(\@init) or croak "that location (@_) doesn't make any sense";

    return $this->_locations_in_line_of_sight(\@init);
}
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Queue - And object for storing objects by location, on a map, with visi-calc support

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
       $map->generate;

    my $queue = $map->queue;
       $queue->add( $object1 => (1, 2) );
       $queue->add( $object2 => (5, 3) );
       # The objects can be any unique identifier, (blessed) reference.

       $queue->replace( $object3 => (5, 3) );
       # remove first if it's already somewhere else

       $queue->remove( $object3 ); # just remove it

    my $visibility = $map->visible( $object1 => $object2 );
    # The percent (0->100) visibility of the tile containing o2
    # from the tile containing o1

    my $distance = $map->distance( $object1, $object2 );
    # the distance from o1 to o2 or undef if the tile is not visible

    my $distance1 = $map->distance( $object1, $object2, 1 );
    # the distance from o1 to o2 even if there is a wall or door in the way

=head1 AUTHOR

Jettero Heller <japh@voltar-confed.org>

Jet is using this software in his own projects...
If you find bugs, please please please let him know. :)

Actually, let him know if you find it handy at all.
Half the fun of releasing this stuff is knowing 
that people use it.

=head1 COPYRIGHT

GPL!  I included a gpl.txt for your reading enjoyment.

Though, additionally, I will say that I'll be tickled if you were to
include this package in any commercial endeavor.  Also, any thoughts to
the effect that using this module will somehow make your commercial
package GPL should be washed away.

I hereby release you from any such silly conditions.

This package and any modifications you make to it must remain GPL.  Any
programs you (or your company) write shall remain yours (and under
whatever copyright you choose) even if you use this package's intended
and/or exported interfaces in them.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
