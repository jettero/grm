# $Id: Text.pm,v 1.1 2005/03/18 12:31:36 jettero Exp $
# vi:tw=0:

package Games::RolePlay::MapGen::Visualization::Text;

use strict;
use Carp;

1;

sub new {
    my $class = shift;
    my $this  = bless {}, $class;

    return $this;
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Visualization::Text - A pure text mapgen visualization.

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_visual( "Games::RolePlay::MapGen::Visualization::Text" );

    generate  $map;
    visualize $map( "filename.txt" );

=head1 DESCRIPTION

    This simple plugin shows maps like so:

                 #.#         #.#  
                 #.#         #.#  
    ##############+###########+#########
    ....................................
    ##############+###########+#########
               #.....#       #.#
               #.....#       #.#
               #.....#       #.#########
               #######       #..........
                             ###########
=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
