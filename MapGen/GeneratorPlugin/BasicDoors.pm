# $Id: BasicDoors.pm,v 1.2 2005/04/02 15:43:36 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::GeneratorPlugin::BasicDoors;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( choice roll _group irange str_eval );

$Games::RolePlay::MapGen::known_opts{open_room_corridor_door_percent}       => { door => 95, secret =>  2, stuck => 25, locked => 50 };
$Games::RolePlay::MapGen::known_opts{closed_room_corridor_door_percent}     => { door =>  5, secret => 95, stuck => 10, locked => 30 };
$Games::RolePlay::MapGen::known_opts{open_corridor_corridor_door_percent}   => { door =>  1, secret => 10, stuck => 25, locked => 50 };
$Games::RolePlay::MapGen::known_opts{closed_corridor_corridor_door_percent} => { door =>  1, secret => 95, stuck => 10, locked => 30 };

1;

# new {{{
sub new {
    my $class = shift;
    my $this  = [qw(door)]; # you have to be the types of things you hook

    return bless $this, $class;
}
# }}}
# doorgen {{{
sub doorgen {
    my $this   = shift;
    my $opts   = shift;
    my $map    = shift;
    my $groups = shift;

    for my $i ( 0 .. $#$map ) {
        my $jend = $#{ $map->[$i] };

        for my $j ( 0 .. $jend ) {
            my $t = $map->[$i][$j];

            if( $t->{type} ) {
                for my $dir (qw(n e s w)) {
                    my $n = $t->{nb}{$dir};
                    next unless $n and $n->{type};

                    unless( $t->{_bchkt}{$dir} ) {
                        my ($ttype, $ntype) = ($t->{type}, $n->{type});

                        if( $ttype eq "room" and $ntype eq "room" ) {
                        }

                        my $tkey  = ( $n->{od}{$dir} ? "open" : "closed" );
                           $tkey .= "_" . join("_", reverse sort( $ttype, $ntype ));
                           $tkey .= "_door_percent";

                        my $chances = $opts->{$tkey};
                        die "chances error for $tkey" unless defined $chances;

                        print STDERR "dooring ($j, $i):$dir -- $tkey?\n";

                        $t->{_bchkt}{$dir} = 1;
                    }
                }
            }
        }
    }

    delete $_->{_bchkt} for map(@$_, @$map); # btw, bchkt stands for: basic doors checked tile [direction]
}
# }}}


__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::GeneratorPlugin::BasicDoorsAndTraps - The basic generator with a simple doors and traps generator

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->add_generator_plugin( "BasicDoors" );

=head1 DESCRIPTION

This module inserts doors all over the map.

It takes the following options (defaults shown):

=head2 The Percentages

      open_room_corridor_door_percent     => { door =>  95, secret =>  2, stuck => 25, locked => 50 },
    closed_room_corridor_door_percent     => { door =>   5, secret => 95, stuck => 10, locked => 30 },
      open_corridor_corridor_door_percent => { door => 0.1, secret => 10, stuck => 25, locked => 50 },
    closed_corridor_corridor_door_percent => { door =>   1, secret => 95, stuck => 10, locked => 30 },
                                                       
Here I would enumerate the precise meaning of each option, but it seems
pretty clear to me.  Here's an example instead. The default options listed
above state that there's a 95% chance that a door would be placed on a
room/corridor boundary (without a wall) and that it'd be stuck about 25% of
the time.

OK, another?  There would be a 0.1% chance of finding a door in the middle of
an open corridor and said door would be hidden 10% of the time.

=head2 The Special Case

Notice that there are no room_room settings.  If any two tiles are both
room type tiles, then the tile is skipped unless the tiles are in different
rooms.  If they _are_ in different rooms, then the opening is treated as if
it were a room_corridor opening (whether open or closed).

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
