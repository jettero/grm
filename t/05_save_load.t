# $Id: 05_save_load.t,v 1.1 2005/03/30 16:27:10 jettero Exp $

use strict;
use Test;

my ($x, $y) = (25, 25);

plan tests => 1 + (5 * $x * $y);

use Games::RolePlay::MapGen;

my $map = new Games::RolePlay::MapGen({bounding_box => join("x", $x, $y) });

generate $map;
save_map("the.map");

die "borked";
