# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::OneBigRoom;

use strict;
use Carp;
use base qw(Games::RolePlay::MapGen::Generator);
use Games::RolePlay::MapGen::Tools qw( _group _tile choice roll );

1;

sub create_tiles {
    my $this = shift;
    my $opts = shift;
    my @map  = ();

    for my $i (0 .. $opts->{y_size}-1) {
        my $a = [];

        for my $j (0 .. $opts->{x_size}-1) {
            push @$a, &_tile(x=>$j, y=>$i);
        }

        push @map, $a;
    }

    return @map;
}

sub genmap {
    my $this   = shift;
    my $opts   = shift;
    my @map    = $this->create_tiles( $opts );
    my $map    = new Games::RolePlay::MapGen::_interconnected_map(\@map);
    my $groups = [];

    my $group = &_group;
       $group->{name}     = "One Big Room";
       $group->{loc_size} = "(whole map)";
       $group->{type}     = "room";
       $group->{size}     = [$opts->{x_size}, $opts->{y_size}];
       $group->{loc}      = [0, 0];

    my $ymax = $#map;
    my $xmax = $#{ $map[0] };

    for my $y ( 0 .. $ymax ) {
        for my $x ( 0 .. $xmax ) {
            my $tile = $map[$y][$x];

            $tile->{type}  = "room";
            $tile->{group} = $group;

            for my $dir (qw(n e s w)) {
                next if $y == 0     and $dir eq 'n';
                next if $y == $ymax and $dir eq 's';
                next if $x == 0     and $dir eq 'w';
                next if $x == $xmax and $dir eq 'e';

                $tile->{od}{$dir} = 1; # open every direction... except the above

                if( my $n = $tile->{nb}{$dir} ) {
                    $n->{od}{$Games::RolePlay::MapGen::opp{$dir}} = 1;
                }
            }
        }
    }

    return ($map, $groups);
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Generator::Basic - The basic random bounded dungeon generator

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_generator( "Games::RolePlay::MapGen::Generator::Basic" );

    generate $map;

=head1 DESCRIPTION

This module really just drops rooms onto Jamis Buck's fantastic maze generator.

=head1 SEE ALSO

Games::RolePlay::MapGen, Games::RolePlay::MapGen::Generator::Perfect, Games::RolePlay::MapGen::Generator::SparseAndLoops

=cut
