# $Id: Text.pm,v 1.8 2005/03/23 18:47:33 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Visualization::Text;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( filter );

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
        print _MAP_OUT $map;
        close _MAP_OUT;
    }

    return $map;
}
# }}}

sub _genmap {
    my $this = shift;
    my $opts = shift;
    my $m    = $opts->{_the_map};
    my $g    = $opts->{_the_groups};

    my $map  = "";

    for my $i (0..$#$m) {
        for my $j (0..$#{ $m->[$i] }) {
            my $tile  = $m->[$i][$j];

            $map .= $tile->{_sym} || " ";
        }

        $map .= "\n";
    }

    return $map;
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

    This is how they'd look in a rogue-like... Unfortunately, this design won't
    work with a cell based map... It'll have to look more like that below.

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

    Sadly, since every cell has up to 4 exits and adjacent cells aren't necessarilly open to eachother, 
    the text based map has to have a little more space init.

                 |.|             |.| 
                   
                 |.|             |.| 
    - - - - - - - + - - - - - - - + - - - 
    . . . . . . . . . . . . . . . . . . .
    - - - - - - - + - - - - - - - + - - - 
             |. . . . .|         |.|

             |. . . . .|         |.|
                                    - - -
             |. . . . .|         |. . . .
              - - - - -           - - - - 

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
