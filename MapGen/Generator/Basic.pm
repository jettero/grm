# $Id: Basic.pm,v 1.23 2005/03/25 17:01:33 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;
use base qw(Games::RolePlay::MapGen::Generator::Perfect);

1;

sub _gen_room_size {
    my $this = shift;
    my $opts = shift;

    my ($xm, $ym) = split /x/, $opts->{min_size};
    my ($xM, $yM) = split /x/, $opts->{max_size};

    return (
        irange($xm, $xM),
        irange($ym, $yM),
    );
}

sub _genmap {
    my $this = shift;
    my $opts = $this->_gen_opts;
    my ($map, $groups) = $this->SUPER::_genmap(@_);

    my $sum = sub { my $c = 0; for (qw(n s e w)) { $c ++ if $_[0]->{od}{$_} } $c };
    my %opp = ( n=>"s", s=>"n", e=>"w", w=>"e" );

    my $sparseness = 10;

    SPARSIFY: 
    my @end_tiles = grep { $sum->($_) == 1 } map(@$_, @$map);
    while( my $tile = shift @end_tiles ) {
        my($dir)= grep { $tile->{od}{$_} } (qw(n s e w)); # grep returns the resulting list size unless you evaluate in list context
        my $opp = $opp{$dir};
        my $nex = ($tile->{od}{n} ? $map->[$tile->{y}-1][$tile->{x}] :
                   $tile->{od}{s} ? $map->[$tile->{y}+1][$tile->{x}] :
                   $tile->{od}{e} ? $map->[$tile->{y}][$tile->{x}+1] :
                                    $map->[$tile->{y}][$tile->{x}-1] );

        $tile->{od} = {n=>0, s=>0, e=>0, w=>0};
        delete $tile->{type};

        die "incomplete open direction found during sparseness calculation" unless defined $nex;

        $nex->{od}{$opp}  = 0;
    }

    goto SPARSIFY if --$sparseness > 0;

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

1. Start with Jamis Buck's perfect maze

2. Look at every cell in the maze grid. If the given cell contains a corridor that exits the cell in
only one direction (in otherwords, if the cell is the end of a dead-end hallway), "erase" that cell
by removing the corridor.

3. Repeat step #2 sparseness times (ie, if sparseness is five, repeat step #6 five times).

2. Add Rooms

=head1 SEE ALSO

Games::RolePlay::MapGen, Games::RolePlay::MapGen::Generator::Perfect

=cut
