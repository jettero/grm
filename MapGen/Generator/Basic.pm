# $Id: Basic.pm,v 1.10 2005/03/23 12:21:20 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( _group _tile str_eval range );

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

    $this->_gen_bounding_size( $opts );

    croak "ERROR: bounding_box is a required option for " . ref($this) . "::go()" unless $opts->{x_size} and $opts->{y_size};
    croak "ERROR: num_rooms is a required option for " . ref($this) . "::go()" unless $opts->{num_rooms};

    $opts->{min_size} = "2x2" unless $opts->{min_size};
    $opts->{max_size} = "9x9" unless $opts->{max_size};

    croak "ERROR: room sizes are of the form 9x9, 3x10, 2x2, etc" unless $opts->{min_size} =~ m/^\d+x\d+$/ and $opts->{max_size} =~ m/^\d+x\d+$/;

    return $this->_genmap( $opts );
}
# }}}
# _gen_room_size {{{
sub _gen_room_size {
    my $this = shift;
    my $opts = shift;

    my ($xm, $ym) = split /x/, $opts->{min_size};
    my ($xM, $yM) = split /x/, $opts->{max_size};

    return (
        int range($xm, $xM),
        int range($ym, $yM),
    );
}
# }}}
# _gen_bounding_size {{{
sub _gen_bounding_size {
    my $this = shift;
    my $opts = shift;

    if( $opts->{bounding_box} ) {
        die "ERROR: illegal bounding box description '$opts->{bounding_box}'" unless $opts->{bounding_box} =~ m/^(\d+)x(\d+)/;
        $opts->{x_size} = $1;
        $opts->{y_size} = $2;
    }
}
# }}}

# _genmap {{{
sub _genmap {
    my $this   = shift;
    my $opts   = shift;
    my @map    = ();
    my @groups = ();

    my $unvisited = 0;

    for my $y (1 .. $opts->{y_size}) {
        my $a = [];

        for my $x (1 .. $opts->{x_size}) {
            push @$a, &_tile;
            $unvisited ++;
        }

        push @map, $a;
    }

    for my $rn (1 .. &str_eval($opts->{num_rooms})) {
        my @size = $this->_gen_room_size( $opts );

        my @min_pos = (1, 1);
        my @max_pos = ( (($opts->{x_size}-1) - $size[0]), (($opts->{y_size}-1) - $size[1]) );

        my $redos = $opts->{room_fit_redos} || 100;
        FIND_A_SPOT_FOR_IT: {
            my @spot = map( int range($min_pos[$_], $max_pos[$_]), 0..1 );

            my $no_collision = 1;
            for my $y ($spot[1]..($size[1]-1)+$spot[1]) {
                for my $x ($spot[0]..($size[0]-1)+$spot[0]) {
                    if( $map[$y][$x]{group} ) {
                        $no_collision = 0;
                        last;
                    }
                }
            }

            if( $no_collision ) {
                my $group = &_group;
                   $group->{name}     = "Room #$rn";
                   $group->{loc_size} = "$size[0]x$size[1] ($spot[0], $spot[1])";
                   $group->{type}     = "room";
                   $group->{size}     = [@size];
                   $group->{loc}      = [@spot];

                for my $y ($spot[1]..($size[1]-1)+$spot[1]) {
                    for my $x ($spot[0]..($size[0]-1)+$spot[0]) {
                        $map[$y][$x]->{group}   = $group;
                        $map[$y][$x]->{visited} = 1;
                    }
                }

                for my $y ($spot[1]..($size[1]-1)+$spot[1]) {
                    $map[$y][0]->{od} = 1;
                }

                push @groups, $group;

            } else {
                redo unless --$redos < 1;
            }
        }
    }

    return (\@map, \@groups);
}
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Generator::Basic - The basic random bounded dungeon generator

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_generator( "Games::RolePlay::MapGen::Generator::Basic" );

    generate $map;

=head1 DESCRIPTION

This generator creates a specified number of rooms inside a
bounding box and then adds the specified number of hallways
-- trying to get at least one per room.

Here is the URL to the steps listed below: http://www.aarg.net/~minam/dungeon_design.html

=head2 Jamis Buck's Dungeon Generator Algorithm

1. Start with a rectangular grid, x units wide and y units tall. Mark each cell in the grid
unvisited.

2. Pick a random cell in the grid and mark it visited. This is the current cell.

3. From the current cell, pick a random direction (north, south, east, or west). If (1) there is no
cell adjacent to the current cell in that direction, or (2) if the adjacent cell in that direction
has been visited, then that direction is invalid, and you must pick a different random direction. If
all directions are invalid, pick a different random visited cell in the grid and start this step
over again.

4. Let's call the cell in the chosen direction C. Create a corridor between the current cell and C,
and then make C the current cell. Mark C visited.

5. Repeat steps 3 and 4 until all cells in the grid have been visited.

6. Look at every cell in the maze grid. If the given cell contains a corridor that exits the cell in
only one direction (in otherwords, if the cell is the end of a dead-end hallway), "erase" that cell
by removing the corridor.

7. Repeat step #6 sparseness times (ie, if sparseness is five, repeat step #6 five times).

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
