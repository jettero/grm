# $Id: Queue.pm 464.13261.bumnIlb8Ywd9qeXfBICH0qW81TQ 2007-05-06 14:59:42 -0400 $

package Games::RolePlay::MapGen::Queue;

use strict;
use Carp;
use Exporter;
use constant {
    LOS_NO_COVER        => 1,
    LOS_IGNORABLE_COVER => 2,
    LOS_COVER           => 3, };

use base qw(Exporter);
our @EXPORT = qw(LOS_NO_COVER LOS_IGNORABLE_COVER LOS_COVER);

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

    my @x_ext  = ($min_x+1, $max_x-1);
    my @y_ext  = ($min_y+1, $max_y-1);

    my @range  = ($x_ext[0] .. $x_ext[1]);
    my @domain = ($y_ext[0] .. $y_ext[1]);

    my $x_dir = ($lhs[0][0]<$rhs[0][0] ? "e" : "w");
    my $y_dir = ($lhs[0][1]<$rhs[0][1] ? "s" : "n");

    warn "---- lhs=[@$lhs]; rhs=[@$rhs]; range=[@range]; domain=[@domain]\n";

    my @results = ();
    LHS: for my $l (@lhs) { unshift @results, [];
    RHS: for my $r (@rhs) { unshift @{ $results[0] }, LOS_NO_COVER;

        warn "\tl=[@$l]; r=[@$r];\n";
        #### X-walls
        if( $l->[0] == $r->[0] ) {
            # vertical -- @range tests false
            die "no vertical tests available";

        } else {
            # not vertical
            my $m = ($r->[1]-$l->[1]) / ($r->[0]-$l->[0]);
            my $b = $l->[1] - $m * $l->[0];

            for my $x (@range) {
                my $y = $m * $x + $b;

                warn "\t\tX=$x; y=$y\n";

                my @tile_locs = ();
                if( $y >= $y_ext[0] and $y <= $y_ext[1] ) {
                    @tile_locs = ([ $x-1, int $y]);
                    if( $y == (int $y) ) {
                        push @tile_locs, [$x-1, $y-1];
                    }
                }

                my $this_open = 0;
                for my $l (@tile_locs) {
                    my $od = $this->{_the_map}[ $l->[1] ][ $l->[0] ]{od}{ $x_dir };

                    if( ref $od ) {
                        $od = $od->{'open'};
                        warn "\t\t\tchecking [@$l]:$x_dir od=door($od)\n";

                    } else {
                        warn "\t\t\tchecking [@$l]:$x_dir od=$od\n";
                    }

                    $this_open ++ if $od;
                }

                if( $this_open < @tile_locs ) {
                    my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                    my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                    my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                    warn "\t\t\tc=$c (@$l)->(@$r) [x]\n";
                    $results[0][0] = $c if $c > $results[0][0];

                    # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                }
            }

            for my $y (@domain) {
                my $x = ($y-$b)/$m;

                warn "\t\tx=$x; Y=$y\n";

                my @tile_locs = ();
                if( $x >= $x_ext[0] and $x <= $x_ext[1] ) {
                    @tile_locs = ([ int $x, $y-1 ]);
                    if( $x == (int $x) ) {
                        push @tile_locs, [$x-1, $y-1];
                    }
                }

                my $this_open = 0;
                for my $l (@tile_locs) {
                    my $od = $this->{_the_map}[ $l->[1] ][ $l->[0] ]{od}{ $y_dir };

                    if( ref $od ) {
                        $od = $od->{'open'};
                        warn "\t\t\tchecking [@$l]:$y_dir od=door($od)\n";

                    } else {
                        warn "\t\t\tchecking [@$l]:$y_dir od=$od\n";
                    }

                    $this_open ++ if $od;
                }

                if( $this_open < @tile_locs ) {
                    my $dl = sqrt( ($lhs->[0] - $x)**2 + ($lhs->[1] - $y)**2 );
                    my $dr = sqrt( ($rhs->[0] - $x)**2 + ($rhs->[1] - $y)**2 );

                    my $c = ($dl<$dr ? LOS_IGNORABLE_COVER : LOS_COVER);
                    warn "\t\t\tc=$c (@$l)->(@$r) [y]\n";
                    $results[0][0] = $c if $c > $results[0][0];

                    # next RHS; # we don't skip ahead here in case there is LOS_COVER for both the LHS and the RHS!
                }
            }
        }
    }}

    use Data::Dumper; $Data::Dumper::Indent = 0;
    die Dumper( \@results )."\n";
    1; # TODO: write this
}
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

    croak "you should provide 4 arguments to ldistance()" unless @_ == 4;

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
