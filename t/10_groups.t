
use strict;
use Test;

my ($x, $y) = (15, 15);

use Games::RolePlay::MapGen;

my $map = new Games::RolePlay::MapGen({ tile_size=>10, num_rooms=>"2d4", bounding_box=>join("x", $x, $y) });

$map->set_generator( "Basic" );
# $map->add_generator_plugin( "FiveSplit" ); # UNCOMMENT
$map->add_generator_plugin( "BasicDoors" );
$map->generate; 

my $m = $map->{_the_map};
my @g = @{$map->{_the_groups}};

($x,$y) = $map->size;

my $group_count = 0;
for my $g (@g) {
    my $s = $g->{size};

    $group_count += $s->[0] * $s->[1];
}

my $tile_count = 0;
for my $i (0 .. $y-1) { for my $j (0 .. $x-1) {
    $m->[ $j ][ $i ]{visited} = 0;

    if( $m->[ $j ][ $i ]{group} ) {
        $m->[ $j ][ $i ]{needs_visit} = 1;
        $tile_count ++;
    }
}}

plan tests => $tile_count + $group_count;

for my $g (@g) {
    my $s = $g->{size};
    my $l = $g->{loc};
    my $rhs = 0 + $g;

    for my $x ( 0 .. $s->[0]-1 ) { for my $y ( 0 .. $s->[1]-1 ) {
        my ($i, $j) = ($x+$l->[0], $y+$l->[1]);

        my $lhs  = $m->[ $j ][ $i ]{group} || {};
        my $name = $lhs->{name};

        $lhs += 0;

        ok( "($i,$j,$name) $lhs", "($i,$j,$g->{name}) $rhs" );
        $m->[$j][$i]{visited} = 1;
    }}
}

for my $i (0 .. $y-1) { for my $j (0 .. $x-1) {
    my $t = $m->[ $j ][ $i ];
    if( $m->[ $j ][ $i ]{needs_visit} ) {
        ok( "($i,$j) $t->{visited}", "($i,$j) 1" );
    }
}}
