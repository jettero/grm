# $Id: Text.pm,v 1.11 2005/03/24 01:17:02 jettero Exp $
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

    my @above    = ();
    my $map      = "";
    my $rooms    = "";
       $rooms   .= "$_->{name} $_->{loc_size}\n" for (&filter( @$g, sub {$_[0]->{type} eq "room"} ));

    for my $i (0 .. $#$m) {
        my $p     = $1 if $i =~ m/(\d)$/;
        my $jend  = $#{ $m->[$i] };

        unless( $i ) {
            $map .= "  ";
            for my $j (0 .. $jend) {
                my $p = $1 if $j =~ m/(\d)$/;

                $map .= " $p";
            }
            $map .= " \n";
        }

        $map .= "  ";
        for my $j (0 .. $jend) {
            my $tile = $m->[$i][$j];

            if( my $type = $tile->{type} ) {
                $map .= ($tile->{od}{n} ? "  " : " -");
                $map .= " " if $j == $jend;

            } elsif( $above[$j] ) {
                $map .= ($above[$j]->{od}{s} ? "  " : " -");
                $map .= " " if $j == $jend;

            } else {
                $map .= ($j == $jend ? "   " : "  ");
            }
        }
        $map .= "\n$p ";

        for my $j (0 .. $jend) {
            my $tile  = $m->[$i][$j];

            if( my $type = $tile->{type} ) {
                $map .= ($tile->{od}{w} ? " ." : "|.");
                $map .= ($tile->{od}{e} ? " "  : "|" ) if $j == $jend;
                $above[$j] = $tile;

            } elsif( $j>0 and $above[$j-1] ) {
                $map .= ($above[$j-1]->{od}{e} ? "  " : "| ");
                $map .= " " if $j == $jend;
                $above[$j] = undef;

            } else {
                $above[$j] = undef;
                $map .= ($j == $jend ? "   " : "  ");
            }
        }
        $map .= "\n";

        if( $i == $#$m ) {
            $map .= "  ";
            for my $j (0 .. $jend) {
                my $tile  = $m->[$i][$j];

                if( my $type = $tile->{type} ) {
                    $map .= ($tile->{od}{s} ? "  " : " -");
                    $map .= " " if $j == $jend;

                } elsif( $above[$j] ) {
                    $map .= ($above[$j]->{od}{s} ? "  " : " -");
                    $map .= " " if $j == $jend;

                } else {
                    $map .= ($j == $jend ? "   " : "  ");
                }
            }
            $map .= "\n";
        }

    }

    return $map . $rooms;
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
