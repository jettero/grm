
use strict;
use Test;

plan tests => 4;

use Games::RolePlay::MapGen;

my $map = new Games::RolePlay::MapGen;

generate $map;
