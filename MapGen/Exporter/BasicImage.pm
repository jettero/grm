# $Id: BasicImage.pm,v 1.4 2005/03/24 21:29:45 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Visualization::BasicImage;

use strict;
use Carp;
use GD;

1;

# new {{{
sub new {
    my $class = shift;
    my $this  = bless {o => {@_}}, $class;

    return $this;
}
# }}}
# go {{{
sub go {
    my $this = shift;
    my $opts = {@_};

    for my $k (keys %{ $this->{o} }) {
        $opts->{$k} = $this->{o}{$k} if not exists $opts->{$k};
    }

    croak "ERROR: fname is a required option for " . ref($this) . "::go()" unless $opts->{fname};
    croak "ERROR: _the_map is a required option for " . ref($this) . "::go()" unless ref($opts->{_the_map});

    my $map = $this->_genmap($opts);
    unless( $opts->{fname} eq "-retonly" ) {
        open _MAP_OUT, ">$opts->{fname}" or die "ERROR: couldn't open $opts->{fname} for write: $!";
        print _MAP_OUT $map->png; # the format should really be an option... at some point
        close _MAP_OUT;
    }

    return $map;
}
# }}}

# _gen_cell_size {{{
sub _gen_cell_size {
    my $this = shift;
    my $opts = shift;

    if( $opts->{cell_size} ) {
        die "ERROR: illegal cell size '$opts->{cell_size}'" unless $opts->{cell_size} =~ m/^(\d+)x(\d+)/;
        $opts->{x_size} = $1;
        $opts->{y_size} = $2;
    }
}
# }}}

sub _genmap {
    my $this = shift;
    my $opts = shift;
    my $m    = $opts->{_the_map};

    $this->_gen_cell_size($opts);

    my $gd    = new GD::Image(1+($opts->{x_size} * @{$m->[0]}), 1+($opts->{y_size} * @$m));
    my $white = $gd->colorAllocate(255, 255, 255);
    my $black = $gd->colorAllocate(  0,   0,   0);
    my $grey  = $gd->colorAllocate(240, 240, 240);

    $gd->interlaced('true');

    for my $i (0..$#$m) {
        my $jend = $#{$m->[$i]};

        for my $j (0..$jend) {
            my $t = $m->[$i][$j];
            my $I = $i+1;
            my $J = $j+1;

            $gd->line( $j*$opts->{x_size}, $i*$opts->{y_size} => $J*$opts->{x_size}, $i*$opts->{y_size}, ($t->{od}{n} ? $grey : $black) );
            $gd->line( $j*$opts->{x_size}, $I*$opts->{y_size} => $J*$opts->{x_size}, $I*$opts->{y_size}, ($t->{od}{s} ? $grey : $black) );
            $gd->line( $J*$opts->{x_size}, $i*$opts->{y_size} => $J*$opts->{x_size}, $I*$opts->{y_size}, ($t->{od}{e} ? $grey : $black) );
            $gd->line( $j*$opts->{x_size}, $i*$opts->{y_size} => $j*$opts->{x_size}, $I*$opts->{y_size}, ($t->{od}{w} ? $grey : $black) );
        }
    }

    return $gd;
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Visualization::BasicImage - A pure text mapgen visualization.

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
