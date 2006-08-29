# $Id: FiveSplit.pm,v 1.4 2006/08/29 19:37:29 jettero Exp $
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

    for my $y ( 0 .. $ysize ) {
        for my $x ( 0 .. $xsize ) {
            my $tile = $map->[$y][$x];

            $tile->{x} = $x;
            $tile->{y} = $y;
        }
    }
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

        for my $oldtile (@{ $retrows[$#retrows] }) {
            my $nt = $oldtile->dup;

            if( $oldtile->{type} ) {
                die "unknown type, assuming open" unless $oldtile->{type} eq "room" or $oldtile->{type} eq "corridor";

                $oldtile->{od}{s} = 1;
                     $nt->{od}{n} = 1;
            }

            push @$another_row, $nt;
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
        for ( 1 .. $mults ) {
            my $nt = $oldtile->dup;

            if( $oldtile->{type} ) {
                die "unknown type, assuming open" unless $oldtile->{type} eq "room" or $oldtile->{type} eq "corridor";

                $oldtile->{od}{e} = 1;
                     $nt->{od}{w} = 1;
            }

            push @$newrow, $nt;
            $oldtile = $nt;
        }
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
