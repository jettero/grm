# $Id: Basic.pm,v 1.26 2005/03/25 21:19:12 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;
use base qw(Games::RolePlay::MapGen::Generator::SparseAndLoops);
use Games::RolePlay::MapGen::Tools qw( choice roll );

1;

# genmap {{{
sub genmap {
    my $this = shift;
    my $opts = $this->gen_opts;
    my ($map, $groups) = $this->SUPER::genmap(@_);

    # $this->mark_various_things

    return ($map, $groups);
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

This module really just drops rooms onto Jamis Buck's fantastic maze generator.

=head1 SEE ALSO

Games::RolePlay::MapGen, Games::RolePlay::MapGen::Generator::Perfect, Games::RolePlay::MapGen::Generator::SparseAndLoops

=cut
