# $Id: 01_mg_new_auto.t,v 1.2 2005/03/17 12:28:46 jettero Exp $

use strict;
use Test;

plan tests => 4;

use Games::RolePlay::MapGen;

# $Games::RolePlay::MapGen::test_arg = 1;

START_WITH_HREF: {
    my $map = new Games::RolePlay::MapGen({ test_arg => 2 });

    $map->set_test_arg_2(3);

    ok( $map->{test_arg},   2 );
    ok( $map->{test_arg_2}, 3 );
}

START_WITH_ARRAY: {
    my $map = new Games::RolePlay::MapGen( test_arg => 2 );

    $map->set_test_arg_2(3);

    ok( $map->{test_arg},   2 );
    ok( $map->{test_arg_2}, 3 );
}
