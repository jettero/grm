# $Id: BasicDoors.pm,v 1.1 2005/03/29 16:22:08 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::GeneratorPlugin::BasicDoors;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( choice roll _group irange str_eval );

1;

sub doorgen {
    my $this   = shift;
    my $opts   = shift;
    my $map    = shift;
    my $groups = shift;

    # First, the obvious, check to see if the openings to rooms (corridor/room) should actually be doors.
    # Next, 
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::GeneratorPlugin::BasicDoorsAndTraps - The basic generator with a simple doors and traps generator

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_generator( "Games::RolePlay::MapGen::GeneratorPlugin::Basic" );
    $map->add_generator_plugin( "BasicDoors" );

    generate $map;

=head1 DESCRIPTION

This module really just drops rooms onto Games::RolePlay::MapGen::GeneratorPlugin::Basic.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
