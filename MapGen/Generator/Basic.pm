# $Id: Basic.pm,v 1.2 2005/03/18 18:01:29 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator::Basic;

use strict;
use Carp;

1;

sub new {
    my $class = shift;
    my $this  = bless {o => {@_}}, $class;

    croak "ERROR: x_size and y_size are required arguments for $class" unless $this->{o}{x_size} and $this->{o}{y_size};

    return $this;
}

sub go {
    my $this = shift;

    my @map = ();

    for my $i (1 .. $this->{o}{x_size}) {
        my $a = [];

        for my $j (1 .. $this->{o}{y_size}) {
            push @$a, ' ';
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
