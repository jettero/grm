# $Id: Basic.pm,v 1.16 2005/03/24 14:02:24 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( _group _tile filter str_eval irange choice roll );

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
        irange($xm, $xM),
        irange($ym, $yM),
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

    # create tiles {{{
    for my $i (0 .. $opts->{y_size}-1) {
        my $a = [];

        for my $j (0 .. $opts->{x_size}-1) {
            push @$a, &_tile(x=>$j, y=>$i);
        }

        push @map, $a;
    }
    # }}}
    # fully interconnect tiles (to ease perfect maze generation) {{{
    # This is sloppy and wasteful, but it sure makes the maze alg easier to do.
    for my $i (0 .. $#map) {
        my $jend = $#{ $map[$i] };

        for my $j (0 .. $jend) {
            $map[$i][$j]->{nb}{s} = $map[$i+1][$j] unless $i == $#map;
            $map[$i][$j]->{nb}{n} = $map[$i-1][$j] unless $i == 0;
            $map[$i][$j]->{nb}{e} = $map[$i][$j+1] unless $j == $jend;
            $map[$i][$j]->{nb}{w} = $map[$i][$j-1] unless $j == 0;
        }
    }
    # }}}
    # generate a perfect maze {{{
    my $tiles   = $opts->{y_size} * $opts->{x_size};
    my @dirs    = (qw(n s e w));
    my %opp     = ( n=>"s", s=>"n", e=>"w", w=>"e" );
    my $isnt    = sub { $_[0] ne $_[1] };
    my $dir     = &choice(@dirs);
    my @togo    = &filter(\@dirs, $isnt, $dir);
    my $cur     = &choice(map(@$_, @map));      
    my @visited = ( $cur );

    $cur->{type} = "corridor";

    open LOG, ">maze.log" or die $!;
    print LOG "$$ $0 starting maze.log\n";

    my $DEBUG_looping = 100000;
    while( @visited < $tiles ) {
        my $nex = $cur->{nb}{$dir};
         

        my $show = sub { my $n = shift; if($n) { return sprintf('(%2d, %2d)', $n->{x}, $n->{y}) } else { return "undef   " } };

        print LOG "int(\@visited) = ", sprintf('%3d', int(@visited)), 
            " \$dir=$dir; \$cur=", $show->($cur), " \$nex=", $show->($nex), " ";

        if( $nex and not $nex->{visited} ) {
            $cur->{od}{$dir} = 1;

            $cur = $nex;
            $cur->{visited} = 1;
            push @visited, $cur;

            $cur->{od}{$opp{$dir}} = 1;
            $cur->{type} = 'corridor';

            $dir  = &choice(@dirs) if &roll(2, 6) == 11; # we usually go the same way, unless we get a craps...
            @togo = &filter(\@dirs, $isnt, $dir);        # whatever, redo the @todo (ignoring the obvious way-we-came)

            print LOG "\n";

        } else {
            if( @togo ) {
                $dir  = &choice(@togo);
                @togo = &filter(\@togo, $isnt, $dir);
                print LOG "\@togo = (@togo)\n";

            } else {
                # This node is so boring, we don't want to accidentally try it again
                @visited = &filter(\@visited, $isnt, $cur); 

                print LOG "\$cur is boring...\n";

                unless( @visited ) {
                    warn "ran out of visited nodes for some reason...";
                    last;
                }

                $cur = &choice(@visited);
            }
        }

        last if --$DEBUG_looping < 1;
    }

    close LOG;
    warn "DEBUG: looping floored!!" if $DEBUG_looping < 1;

    # }}}
    # clean-up interconnections {{{
    for my $i (0 .. $#map) {
        my $jend = $#{ $map[$i] };

        for my $j (0 .. $jend) {
            # Destroying the map won't destroy the tiles if they're self
            # referencing like this.  That's not a problem because of the
            # global destructor, *whew*; except that each new map generated,
            # until perl exits, would eat up more memory.  

            delete $map[$i][$j]->{n}; # So we have to break the self-refs here.
        }
    }
    # }}}

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
