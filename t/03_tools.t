
# $Id: 03_tools.t,v 1.1 2005/03/20 13:18:00 jettero Exp $

use strict;
use Test;

plan tests => 1 + 4 + 8 + 8 + 3000;

use Games::RolePlay::MapGen::Tools qw(filter choice roll random range _group _tile);

# filter 1 {{{
my @a = filter(qw(test this please), sub { $_[0] =~ m/^t/ }); 
ok("@a", "test this"); 
# }}}
# choice 4 {{{
my %h = ( 1=>1, 2=>2, 3=>3, 4=>4 );
alarm 3; # in case it loops, which it shouldn't
while( my @k = keys %h ) {
    my $e = choice(@k);

    die "ran out of elements or something" if @k and not $e;

    ok($e, $h{$e});
    delete $h{$e};
}
# }}}
# roll 8 {{{
%h = ();
alarm 3; # in case it loops, which it shouldn't
while( not( $h{1} and $h{2} and $h{3} and $h{4} and $h{5} and $h{6} and $h{7} and $h{8} ) ) {
    my $roll = roll(1, 8);

    redo if $h{$roll};

    $h{$roll} = 1;
    ok(1);
}
# }}}
# random 8 {{{
%h = ();
alarm 3; # in case it loops, which it shouldn't
while( not( $h{0} and $h{1} and $h{2} and $h{3} and $h{4} and $h{5} and $h{6} and $h{7} ) ) {
    my $roll = random( 8 );

    redo if $h{$roll};

    $h{$roll} = 1;
    ok(1);
}
# }}}
# range 3000 {{.{
for(1..1000) {
    my $num = range(37, 99);
    my $cor = range(370, 990, 1);
    my $neg = range(37, 99, -1);

    ok( $num >= 37 and $num <= 99 );
    ok( sprintf('%0.4f', $cor/10), sprintf('%0.4f', $num) );
    ok( sprintf('%0.4f', $neg),    sprintf('%0.4f', 99 - ($num-37)) );
}
# }}}

# _group
# _tile
