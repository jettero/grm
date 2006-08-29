# $Id: FiveSplit.pm,v 1.3 2006/08/29 18:15:32 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::GeneratorPlugin::FiveSplit;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( roll choice );

1;

# new {{{
sub new {
    my $class = shift;
    my $this  = [qw(post)]; # general finishing filter

    return bless $this, $class;
}
# }}}
# post {{{
sub post {
    my ($this, $opts, $map, $groups) = @_;

    my $mults = 0;
    if( $opts->{tile_size} =~ m/(\d+)\s*ft/ ) {
        my $ft = $1;
        $mults = $ft / 5;
        die "$opts->{tile_size} <-- tile size must be evenly divisible by 5ft in order to FiveSplit" if $mults =~ m/\./;

        $opts->{tile_size} = "5 ft";

    } else {
        die "$opts->{tile_size} <-- tile size must be measured in integer feet in order to FiveSplit";
    }

    $opts->{bounding_box} = join("x", map { $_*$mults } split /x/, $opts->{bounding_box});

    $this->split_map($mults => $map) if $mults > 1;
}
# }}}
# split_map {{{
sub split_map {
    my $this  = shift;
    my $mults = shift; $mults --; # we use this as a counter of the number of _extra_ tiles to generate (that's one less)
    my $map   = shift;

    my $ysize = $#$map;
    my $xsize = $#{ $map->[0] };

    @$map = map {  $this->_generate_samemaprow( $_, $mults )  } @$map;
    @$map = map {( $this->_generate_nextmaprow( $_, $mults ) )} @$map;
}
# }}}
# _generate_nextmaprow {{{
sub _generate_nextmaprow {
    my $this   = shift;
    my $oldrow = shift;
    my $mults  = shift;

    my @retrows = ($oldrow);

    for( 1 .. $mults ) {
        my $another_row = [];

        for my $oldtile (@$oldrow) {
            push @$another_row, $oldtile->dup;
        }

        push @retrows, $another_row;
    }

    my $newrow = $oldrow;

    return @retrows;
}
# }}}
# _generate_samemaprow {{{
sub _generate_samemaprow {
    my $this   = shift;
    my $oldrow = shift;
    my $mults  = shift;

    my $newrow = [];
    for my $oldtile (@$oldrow) {
        push @$newrow, $oldtile;
        push @$newrow, $oldtile->dup for 1 .. $mults;
    }

    return $newrow;
}
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::GeneratorPlugin::FiveSplit - Split tiles larger than 5ft into 5ft tiles

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->add_generator_plugin( "FiveSplit" );

=head1 DESCRIPTION

This module splites tiles greater than 5ft in size into 5ft tiles.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
