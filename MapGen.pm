# $Id: MapGen.pm,v 1.3 2005/03/17 12:16:47 jettero Exp $
# vi:tw=0:

package Games::RolePlay::MapGen;

use strict;
use AutoLoader;
use Carp;

our $VERSION = "0.01";
our $AUTOLOAD;

1;

# AUTOLOAD {{{
sub AUTOLOAD {
    my $this = shift;
    my $sub  = $AUTOLOAD;

    if( $sub =~ m/MapGen\:\:set_([\w\d\_]+)$/ ) {
        $this->{$1} = shift;
        return;
    }

    croak "ERROR: function $sub() not found";
}
sub DESTROY {}
# }}}

sub new {
    my $class = shift;
    my @opts  = @_;
    my $opts  = ( (@opts == 1 and ref($opts[0]) eq "HASH") ? $opts[0] : {@opts} );
    my $this  = bless $opts, $class;

    return $this;
}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen - The base object for generating dungeons and maps

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    my $default_map_object = new Games::RolePlay::MapGen;

=head1 AUTHOR

Jettero Heller <japh@voltar-confed.org>

Jet is using this software in his own projects...
If you find bugs, please please please let him know. :)

Actually, let him know if you find it handy at all.
Half the fun of releasing this stuff is knowing 
that people use it.

=head1 COPYRIGHT

GPL!  I included a gpl.txt for your reading enjoyment.

Though, additionally, I will say that I'll be tickled if you were to
include this package in any commercial endeavor.  Also, any thoughts to
the effect that using this module will somehow make your commercial
package GPL should be washed away.

I hereby release you from any such silly conditions.

This package and any modifications you make to it must remain GPL.  Any
programs you (or your company) write shall remain yours (and under
whatever copyright you choose) even if you use this package's intended
and/or exported interfaces in them.

=head1 SEE ALSO

perl(1)

=cut
