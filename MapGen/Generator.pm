# $Id: Generator.pm,v 1.3 2005/03/29 16:22:08 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Generator;

use strict;
use Carp;

1;

# new {{{
sub new {
    my $class = shift;
    my $this  = bless {o => {@_}}, $class;

    return $this;
}
# }}}
# gen_opts {{{
sub gen_opts {
    my $this = shift;
    my $opts = {@_};

    for my $k (keys %{ $this->{o} }) {
        $opts->{$k} = $this->{o}{$k} if not exists $opts->{$k};
    }

    return $opts;
}
# }}}
# go {{{
sub go {
    my $this = shift;
    my $opts = $this->gen_opts(@_);

    $this->gen_bounding_size( $opts );

    croak "ERROR: bounding_box is a required option for " . ref($this) . "::go()" unless $opts->{x_size} and $opts->{y_size};
    croak "ERROR: num_rooms is a required option for " . ref($this) . "::go()" unless $opts->{num_rooms};

    $opts->{min_size} = "2x2" unless $opts->{min_size};
    $opts->{max_size} = "9x9" unless $opts->{max_size};

    croak "ERROR: room sizes are of the form 9x9, 3x10, 2x2, etc" unless $opts->{min_size} =~ m/^\d+x\d+$/ and $opts->{max_size} =~ m/^\d+x\d+$/;

    my ($map, $groups) = $this->genmap( $opts );

    $this->post_genmap( $opts, $map, $groups );

    return ($map, $groups);
}
# }}}
# gen_bounding_size {{{
sub gen_bounding_size {
    my $this = shift;
    my $opts = shift;

    if( $opts->{bounding_box} ) {
        die "ERROR: illegal bounding box description '$opts->{bounding_box}'" unless $opts->{bounding_box} =~ m/^(\d+)x(\d+)/;
        $opts->{x_size} = $1;
        $opts->{y_size} = $2;
    }
}
# }}}
# post_genmap  {{{
sub post_genmap  {
    my $this = shift;
    my ($opts, $map, $groups) = @_;

    $this->doorgen(      $opts, $map, $groups );
    $this->trapgen(      $opts, $map, $groups );
    $this->encountergen( $opts, $map, $groups );
    $this->treasuregen(  $opts, $map, $groups );
}
# }}}

# Meant to be overloaded elsewhere:
sub trapgen      {}
sub doorgen      {}
sub encountergen {}
sub treasuregen  {}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Generator - A base class for Generators

Games::RolePlay::MapGen, Games::RolePlay::MapGen::Generator::Basic, Games::RolePlay::MapGen::Generator::Perfect

=cut
