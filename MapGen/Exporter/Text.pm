# $Id: Text.pm,v 1.2 2005/03/18 18:01:29 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Visualization::Text;

use strict;
use Carp;

1;

sub new {
    my $class = shift;
    my $this  = bless {o => {@_}}, $class;

    return $this;
}

sub go {
    my $this = shift;
    my $opts = {@_};

    for my $k (keys %{ $this->{o} }) {
        $opts->{$k} = $this->{o}{$k} if not exists $opts->{$k};
    }

    croak "ERROR: fname is a required option for " . ref($this) . "::go()" unless $opts->{fname};

    open _MAP_OUT, ">$opts->{fname}" or die "ERROR: couldn't open $opts->{fname} for write: $!";
    print _MAP_OUT "supz\n";
    close _MAP_OUT;
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Visualization::Text - A pure text mapgen visualization.

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_visual( "Games::RolePlay::MapGen::Visualization::Text" );

    generate  $map;
    visualize $map( "filename.txt" );

=head1 DESCRIPTION

    This simple plugin shows maps like so:

                 #.#         #.#  
                 #.#         #.#  
    ##############+###########+#########
    ....................................
    ##############+###########+#########
               #.....#       #.#
               #.....#       #.#
               #.....#       #.#########
               #######       #..........
                             ###########
=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
