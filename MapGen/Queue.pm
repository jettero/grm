# $Id: Queue.pm 504.13822.nCUTYzI3oZH5wU6MJ+lp1/Du/uk 2007-05-08 07:27:51 -0400 $

package Games::RolePlay::MapGen::Queue;

use strict;
use Carp;
use Exporter;
use constant {
    LOS_NO              => 0,
    LOS_COVER           => 1,
    LOS_IGNORABLE_COVER => 2,
    LOS_YES             => 3,
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

    warn "---= lhs=[@$lhs]; rhs=[@$rhs]; X=[@X]; Y=[@Y]; x_dir=$x_dir; y_dir=$y_dir;\n";
    ## DEBUG ## warn "\tSET\n";

    my @od_segments = (); # the solid line segments we might have to pass through
    for my $x (@X[0 .. $#X]) {
        for my $y (@Y[0 .. $#Y]) {
            my $x_od = $this->{_the_map}[ $y ][ $x ]{od}{ $x_dir };
            my $y_od = $this->{_the_map}[ $y ][ $x ]{od}{ $y_dir };

            ## DEBUG ## warn "\t\tchecking <$x, $y>\n";

            for( $x_od, $y_od ) {
                $_ = $_->{'open'} if ref $_;
            }

            ## DEBUG ## $x_od = $y_od = 0;

            unless( $x_od or $x == ($x_dir eq "e" ? $X[$#X]:$X[0]) ) {
                if( $x_dir eq "e" ) { push @od_segments, [[ $x+1, $y ] => [$x+1, $y+1]] }
                else                { push @od_segments, [[ $x,   $y ] => [$x,   $y+1]] }
            }

            unless( $y_od or $y == ($y_dir eq "s" ? $Y[$#Y]:$Y[0]) ) {
                if( $y_dir eq "s" ) { push @od_segments, [[ $x, $y+1 ] => [$x+1, $y+1]] }
                else                { push @od_segments, [[ $x, $y   ] => [$x+1, $y  ]] }
            }
        }
    }
    
    ## DEBUG ## warn "\tDONE\n";

    ## DEBUG ## warn "\tSET\n";
    ## DEBUG ## warn "\t\ttarget <@$rhs>\n";
    ## DEBUG ## warn "\t\tnon-od=[ (@{$_->[0]})->(@{$_->[1]}) ]" for @od_segments;
    ## DEBUG ## warn "\tDONE\n";

    ##---------------- LOS CALC
    my @rhs = (
        [ $rhs->[0]+0, $rhs->[1]+0 ], # sw corner
        [ $rhs->[0]+1, $rhs->[1]+0 ], # se corner
        [ $rhs->[0]+0, $rhs->[1]+1 ], # nw corner
        [ $rhs->[0]+1, $rhs->[1]+1 ], # ne corner
    );

    my $line = 0;
    my @dl = ($lhs->[0]+0.5, $rhs->[1]+0.5);

    LOS_CALC: for my $r (@rhs) {
        for my $od_segment (@od_segments) {
            if( not $this->_line_segments_intersect( (map {@$_} @$od_segment) => (@dl=>@$r) ) ) {
                $line = 1;

                last LOS_CALC;
            }
        }
    }

    ##---------------- COVER CALC
    return LOS_NO unless $line;
    return LOS_YES; # cover needs to be double checked

    my @lhs = (
        [ $lhs->[0]+0, $lhs->[1]+0 ], # sw corner
        [ $lhs->[0]+1, $lhs->[1]+0 ], # se corner
        [ $lhs->[0]+0, $lhs->[1]+1 ], # nw corner
        [ $lhs->[0]+1, $lhs->[1]+1 ], # ne corner
    );

    my @results;
    for my $l (@lhs) { unshift @results, [];
    for my $r (@rhs) { unshift @{$results[0]}, LOS_YES;
        my $i = 0;
        for my $od_segment (@od_segments) {
            if( my @p = $this->_line_segments_intersect( (map {@$_} @$od_segment) => (@$l=>@$r) ) ) {
                warn "SET\n" unless $i;
                warn "\t(@{$od_segment->[0]})->(@{$od_segment->[1]}) intersects (@$l)->(@$r)\n";
                $i ++;

                if( $results[0][0] > LOS_IGNORABLE_COVER and $this->_ldistance( \@p => $l ) < $this->_ldistance( \@p => $r ) ) {
                    $results[0][0] = LOS_IGNORABLE_COVER;

                } else {
                    $results[0][0] = LOS_COVER;
                }
            }
        }
        warn "\ttarget <@$rhs>\n" if $i;
        warn "DONE\n" if $i;
    }}

    use Data::Dumper; $Data::Dumper::Indent = 0;
    warn "result=" . Dumper(\@results) . "\n";

    my $at_least_one_LoS = 0;
    for my $ca (@results) {
        my $min = LOS_YES;
        my $max = LOS_NO;

        for my $c (@$ca) {
            $min = $c if $c < $min;
            $max = $c if $c > $max;
        }

        $ca = $min;

        $at_least_one_LoS = 1 if $max == LOS_YES;
    }

    return LOS_NO unless $at_least_one_LoS;

    my $max = LOS_NO;
    for my $min (@results) {
        $max = $min if $min > $max;
    }

    return $max;
}


sub _line_segments_intersect {
    my $this = shift;
    # this is http://perlmonks.org/?node_id=253983

    my ( $ax,$ay, $bx,$by, $cx,$cy, $dx,$dy ) = @_;

    # P = p*A + (1-p)*B
    # Q = q*C + (1-q)*D

    # for p=0, P=A, and for p=1, P=B
    # for 0<=p<=1, P is on the line segment between A and B

    # find p,q such than P=Q
    # (... lengthy derivation ...)

    my $d = ($ax-$bx)*($cy-$dy) - ($ay-$by)*($cx-$dx);
    if( $d == 0 ) {
        # d=0 when len(C->D)==0 !!
        for my $l ([$ax,$ay], [$bx, $by]) {
        for my $r ([$cx,$cy], [$dx, $dy]) {
            return (@$l) if $l->[0] == $r->[0] and $l->[1] == $r->[1];
        }}

        return; # probably parallel
    }

    my $p = ( ($by-$dy)*($cx-$dx) - ($bx-$dx)*($cy-$dy) ) / $d;

    # we probably don't need to find q because we already restricted the domain/range above

    return unless $p >= 0 and $p <= 1;

    my $px = $p*$ax + (1-$p)*$bx;
    my $py = $p*$ay + (1-$p)*$by;

    return ($px, $py);
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
    my @l    = $this->all_open_locations;
    my $i    = int rand int @l;

    return (wantarray ? @{$l[$i]}:$l[$i]);
}
# }}}
# all_open_locations {{{
sub all_open_locations {
    my $this = shift;
    my ($X, $Y) = ($this->{xm}+1, $this->{ym}+1);
    my @ret = ();

    for my $x ( 0 .. $this->{xm} ) {
    for my $y ( 0 .. $this->{ym} ) {
        push @ret, [$x, $y] if defined $this->{_the_map}[ $y ][ $x ]{type}; # the wall type is <undef>
    }}

    return (wantarray ? @ret:\@ret);
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
