# $Id: XML.pm,v 1.1 2005/04/04 15:23:56 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Exporter::XML;

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
# go {{{
sub go {
    my $this = shift;
    my $opts = {@_};

    for my $k (keys %{ $this->{o} }) {
        $opts->{$k} = $this->{o}{$k} if not exists $opts->{$k};
    }

    croak "ERROR: fname is a required option for " . ref($this) . "::go()" unless $opts->{fname};
    croak "ERROR: _the_map is a required option for " . ref($this) . "::go()" unless ref($opts->{_the_map});

    my $map = $this->genmap($opts);
    unless( $opts->{fname} eq "-retonly" ) {
        open _MAP_OUT, ">$opts->{fname}" or die "ERROR: couldn't open $opts->{fname} for write: $!";
        print _MAP_OUT $map;
        close _MAP_OUT;
    }

    return $map;
}
# }}}
# genmap {{{
sub genmap {
    my $this = shift;
    my $opts = shift;
    my $m    = $opts->{_the_map};
    my $g    = $opts->{_the_groups};

    return "<xml/>";
}
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Exporter::XML - An xml MapGen exporter.

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->set_exporter( "XML" );

    generate  $map;
    export    $map( "filename.xml" );

=head1 DESCRIPTION

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
