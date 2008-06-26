
use strict;
use Test;
use Games::RolePlay::MapGen::MapQueue::Object;

my $s7 = new Games::RolePlay::MapGen::MapQueue::Object(7);
my $st = new Games::RolePlay::MapGen::MapQueue::Object("test");

plan tests => 11;

ok($s7+0, 1);
ok($s7+2, 3);
ok($s7/5, 1/5);

ok($st, "test");

$st->nonunique;
ok($st, "test #1");

$st->unique;
ok($st, "test");

$st->quantity(5);
ok($st+3, 8);
ok($st, "test");
ok($st->desc, "test (5)");

$st->nonunique;
ok($st, "test #1");
ok($st->desc, "test (5) #1");
