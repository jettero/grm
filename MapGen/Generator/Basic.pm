# $Id: Basic.pm,v 1.19 2005/03/24 18:43:13 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;
use base 'Games::RolePlay::MapGen::Generator::Perfect';
# use Games::RolePlay::MapGen::Tools qw( _group _tile str_eval irange choice roll );

1;

sub go {
    my $this = shift;
    my ($map, $groups) = $this->SUPER::go(@_);
    my $opts = $this->_gen_opts;

    return ($map, $groups);
}

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

1. Start with Jamis Buck's perfect maze

2. Look at every cell in the maze grid. If the given cell contains a corridor that exits the cell in
only one direction (in otherwords, if the cell is the end of a dead-end hallway), "erase" that cell
by removing the corridor.

3. Repeat step #3 sparseness times (ie, if sparseness is five, repeat step #6 five times).

2. Add Rooms

=head1 SEE ALSO

Games::RolePlay::MapGen, Games::RolePlay::MapGen::Generator::Perfect

=cut
