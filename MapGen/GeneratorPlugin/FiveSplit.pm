# $Id: FiveSplit.pm,v 1.1 2006/08/29 13:25:42 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::GeneratorPlugin::FiveSplit;

use strict;
use Carp;
use Games::RolePlay::MapGen::Tools qw( roll choice );

1;

sub new {
    my $class = shift;
    my $this  = [qw(tile)]; # you have to be the types of things you hook

    return bless $this, $class;
}
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::GeneratorPlugin::FiveSplit - Split tiles larger than 5ft into 5ft tiles

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $map = new Games::RolePlay::MapGen;
    
    $map->add_generator_plugin( "FiveSplit" );

=head1 DESCRIPTION

This module splites tiles greater than 5ft in size into 5ft tiles.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
