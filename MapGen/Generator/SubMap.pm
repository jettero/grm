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

    my @X = ( sort {$a<=>$b} ($opts->{upper_left}[0], $opts->{lower_right}[0]) );
    my @Y = ( sort {$a<=>$b} ($opts->{upper_left}[1], $opts->{lower_right}[1]) );

    for my $x ( 0 .. $X[1]+2 ) {
        my $y = 0;       $map->[ $y ][ $x ] = &_tile( x=>$x, y=>$y, type=>'fog' );
           $y = $Y[1]+2; $map->[ $y ][ $x ] = &_tile( x=>$x, y=>$y, type=>'fog' );
    }

    for my $y ( 1 .. $Y[1]+1 ) {
        my $x = 0;       $map->[ $y ][ $x ] = &_tile( x=>$x, y=>$y, type=>'fog' );
           $x = $X[1]+2; $map->[ $y ][ $x ] = &_tile( x=>$x, y=>$y, type=>'fog' );
    }

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
