
use strict;
use Test;
use Games::RolePlay::MapGen::MapQueue::Object;

my $s7 = new Games::RolePlay::MapGen::MapQueue::Object(7);
my $st = new Games::RolePlay::MapGen::MapQueue::Object("test");

plan tests => 2;

ok($s7+0, 7);
ok($st, "test");
