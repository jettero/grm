# $Id: Text.pm,v 1.3 2005/03/19 12:05:41 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Visualization::Text;

use strict;
use Carp;

1;

# new {{{
sub new {
    my $class = shift;
    my $this  = bless {o => {@_}}, $class;

    use Data::Dumper;
    die Dumper( {@_} );

    croak "ERROR: _the_map is a required option for " . ref($this) . "::new()" unless ref($this->{o}{_the_map});

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

    my $map = $this->_genmap;

    croak "ERROR: fname is a required option for " . ref($this) . "::go()" unless $opts->{fname};

    unless( $opts->{fname} eq "-retonly" ) {
        open _MAP_OUT, ">$opts->{fname}" or die "ERROR: couldn't open $opts->{fname} for write: $!";
        print _MAP_OUT $map;
        close _MAP_OUT;
    }

    return $map;
}
# }}}

sub genmap {
    my $this = shift;
    my $map  = "";

    # for my $i (0..$#

    return $map
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
