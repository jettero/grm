# $Id: Text.pm,v 1.7 2005/03/23 17:46:35 jettero Exp $
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

    my $map       = "";
    my $room_list = "";

    my @rooms = &filter( @$g, sub { $_[0]->{type} eq "room" } );
    for my $r (@rooms) {
        $room_list .= "$r->{name} $r->{loc_size}\n";
        for my $i ($r->{loc}[1]..$r->{loc}[1]+($r->{size}[1]-1)) {
            for my $j ($r->{loc}[0]..$r->{loc}[0]+($r->{size}[0]-1)) {
                my $tile  = $m->[$i][$j];

                my ($n, $e, $s, $w) = map($tile->{od}{$_}, qw(n e s w));

                $tile->{_sym} = "?";
                if( $n and $s and $e and $w ) {
                    $tile->{_sym} = ".";

                } elsif( $n and $s and $e and not $w ) {
                    $tile->{_sym} = "{";

                } elsif( $n and $s and $w and not $e ) {
                    $tile->{_sym} = "}";

                } elsif( $e and $w and $n and not $s ) {
                    $tile->{_sym} = "v";

                } elsif( $e and $w and $s and not $n ) {
                    $tile->{_sym} = "^";

                } elsif( $s and $e and not $w and not $n ) {
                    $tile->{_sym} = "/";

                } elsif( $n and $w and not $s and not $e ) {
                    $tile->{_sym} = "/";

                } elsif( $w and $s and not $n and not $e ) {
                    $tile->{_sym} = "\\";

                } elsif( $n and $e and not $s and not $w ) {
                    $tile->{_sym} = "\\";

                }
            }
        }
    }

    for my $i (0..$#$m) {
        for my $j (0..$#{ $m->[$i] }) {
            my $tile  = $m->[$i][$j];

            $map .= $tile->{_sym} || " ";
        }

        $map .= "\n";
    }

    return $map . $room_list;
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
