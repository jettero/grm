# $Id: BasicDoorsAndTraps.pm,v 1.1 2005/03/27 12:35:04 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;
use base qw(Games::RolePlay::MapGen::Generator::Basic);
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

Games::RolePlay::MapGen::Generator::BasicDoorsAndTraps - The basic generator with a simple doors and traps generator

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_generator( "Games::RolePlay::MapGen::Generator::BasicDoorsAndTraps" );

    generate $map;

=head1 DESCRIPTION

This module really just drops rooms onto Games::RolePlay::MapGen::Generator::Basic.

=head1 SEE ALSO

Games::RolePlay::MapGen, ::Generator::Perfect, ::Generator::SparseAndLoops, ::Generator::Basic

=cut
