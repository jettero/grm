# $Id: 05_generate.t,v 1.5 2005/03/20 16:42:49 jettero Exp $

use strict;
use Test;

my $tests = 1;
plan tests => $tests;

use Games::RolePlay::MapGen;

my $map = new Games::RolePlay::MapGen({bounding_box => "90x35"});

generate  $map;
visualize $map ("map.txt");

if( -f "map.txt" ) {
    ok( 1 );

} else {
    ok( 0 ) for 1 .. $tests; # no map.txt, means no tests!
}
