# $Id: Basic.pm,v 1.5 2005/03/20 13:26:10 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw(_group _tile roll);

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

    croak "ERROR: x_size and y_size are required options for " . ref($this) . "::go()" unless $opts->{x_size} and $opts->{y_size};
    croak "ERROR: x_size and y_size are required options for " . ref($this) . "::go()" unless $opts->{x_size} and $opts->{y_size};

    return $this->_genmap( $opts );
}
# }}}

sub _genmap {
    my $this = shift;
    my $opts = shift;
    my @map  = ();

    for my $i (1 .. $opts->{x_size}) {
        my $a = [];

        for my $j (1 .. $opts->{y_size}) {
            push @$a, &_tile;
        }

        push @map, $a;
    }

    return \@map;
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

    This generator creates a specified number of rooms inside a
    bounding box and then adds the specified number of hallways
    -- trying to get at least one per room.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
