# $Id: Queue.pm 270.7007.98bvuVNhSEr4mDz1PiubHXVYiQs 2007-05-04 19:33:56 -0400 $

package Games::RolePlay::MapGen::Queue;

use strict;
use Carp;

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
    return 0 if $loc->[0] < 1;
    return 0 if $loc->[1] < 1;
    return 0 if $loc->[0] > $this->{xm};
    return 0 if $loc->[1] > $this->{ym};

    my $type = $this->{_the_map}[ $loc->[1] ][ $loc->[0] ]{type};
    return 0 if $type eq "wall";

    return $loc;
}
# }}}
# _lline_of_sight {{{
sub _lline_of_sight {
    my $this = shift;

    1; # TODO: write this
}
# }}}
# _ldistance {{{
sub _ldistance {
    my $this = shift;
    my $lhs  = shift;
    my $rhs  = shift;

    return sqrt ( (($lhs->[0]-$rhs->[0]) ** 2) + (($lhs->[1]-$rhs->[1]) ** 2) );
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
