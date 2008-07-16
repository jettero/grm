# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::SubMap;

use strict;
use Carp;
use base qw(Games::RolePlay::MapGen::Generator);
use Games::RolePlay::MapGen::Tools qw( _group _tile _door );

1;

sub genmap {
    my $this = shift;
    my $opts = shift;

    my $map    = [];
    my $groups = [];

    return ($map, $groups);
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Generator::SubMap - Given a MapGen object and some co-ordinates, generate a sub-map

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
       $map->set_generator( "XMLImport" );
       $map->generate( xml_input_file => "map.xml" );

    my $sub_map = new Games::RolePlay::MapGen;
       $sub_map->set_generator( "SubMap" );
       $sub_map->generate( map_input => $map, upper_left=>[5,5], lower_right=>[10,10] );

The MapGen base object also knows a shortcut to perform the above:

    my $submap = Games::RolePlay::MapGen->sub_map($map, [5,5], [10,10]);

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
