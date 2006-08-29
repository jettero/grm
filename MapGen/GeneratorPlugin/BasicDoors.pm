# $Id: BasicDoors.pm,v 1.8 2006/08/29 21:45:45 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::GeneratorPlugin::BasicDoors;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( roll _door choice );

$Games::RolePlay::MapGen::known_opts{       "open_room_corridor_door_percent" } = { door => 95, secret =>  2, stuck => 25, locked => 50 };
$Games::RolePlay::MapGen::known_opts{     "closed_room_corridor_door_percent" } = { door =>  5, secret => 95, stuck => 10, locked => 30 };
$Games::RolePlay::MapGen::known_opts{   "open_corridor_corridor_door_percent" } = { door =>  1, secret => 10, stuck => 25, locked => 50 };
$Games::RolePlay::MapGen::known_opts{ "closed_corridor_corridor_door_percent" } = { door =>  1, secret => 95, stuck => 10, locked => 30 };
$Games::RolePlay::MapGen::known_opts{ "max_span"                              } = 20;

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

    my $minor_dirs = {
        n => [qw(e w)],
        s => [qw(e w)],

        e => [qw(n s)],
        w => [qw(n s)],
    };

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
                            if( $t->{group}{name} eq $n->{group}{name} ) {
                                next;

                            } else {
                                $ntype = "corridor";
                            }
                        }

                        my $tkey  = ( $t->{od}{$dir} ? "open" : "closed" );
                           $tkey .= "_" . join("_", reverse sort( $ttype, $ntype ));
                           $tkey .= "_door_percent";

                        my $chances = $opts->{$tkey};
                        die "chances error for $tkey" unless defined $chances;

                        if( (my $r = roll(1, 10000)) <= (my $c = $chances->{door}*100) ) {
                            my $d1 = sprintf("%40s: (%5d, %5d)", $tkey, $r, $c);
                            my $d2 = sprintf("(%2d, %2d, $dir)", $j, $i);

                            # print STDERR "$d1 dooring $d2\n";

                            # Even when we're successfull, we won't make a door
                            # unless we can span an opening entirely (using
                            # walls).

                            my $opp = $Games::RolePlay::MapGen::opp{$dir};

                            $t->{od}{$dir} = $n->{od}{$opp} = &_door(

                                (map {$_ => ((roll(1, 10000) <= $chances->{$_}*100) ? 1:0) } qw(locked stuck secret)),

                                open_dir => {
                                    major => &choice( $dir, $opp ),
                                    minor => &choice( @{$minor_dirs->{$dir}} ),
                                },

                                siblings => [$t, $n],
                            );
                        }

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

Games::RolePlay::MapGen::GeneratorPlugin::BasicDoors - The basic generator for simple doors.

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
                                                       
Here I would enumerate the precise meaning of each option, but it seems pretty
clear to me.  Here's an example instead. The default options listed above state
that there's a 95.00% chance that a door would be placed on a room/corridor
boundary (without a wall) and that it'd be stuck about 25.00% of the time.

OK, another?  There would be a 0.10% chance of finding a door in the middle of
an open corridor and said door would be hidden 10.00% of the time.

=head2 The Special Case

Notice that there are no room_room settings.  If any two tiles are both
room type tiles, then the tile is skipped unless the tiles are in different
rooms.  If they _are_ in different rooms, then the opening is treated as if
it were a room_corridor opening (whether open or closed).

=head2 max_span

In order to put a door somewhere, and have it make sense, the BasicDoors plugin
builds walls around the door to complete a span and close something off.  It
will not do this for a span larger than max_span.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
