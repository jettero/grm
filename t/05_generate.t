
use strict;
use Test;

my $tests = 1;
plan tests => $tests;

use Games::RolePlay::MapGen;

my $map = new Games::RolePlay::MapGen;

generate  $map;
visualize $map ("map.txt");

if( -f "map.txt" ) {
    ok( 1 );

} else {
    ok( 0 ) for 1 .. $tests; # no map.txt, means no tests!
}
