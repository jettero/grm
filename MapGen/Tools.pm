# $Id: Tools.pm,v 1.7 2005/03/23 23:35:24 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::_group;

use strict;

1;

sub new { bless {}, shift }

package Games::RolePlay::MapGen::_tile;

use strict;

1;

sub new { bless { v=>0, od=>{n=>0, s=>0, e=>0, w=>0} }, shift }

package Games::RolePlay::MapGen::Tools;

use strict;
use Carp;
use base q(Exporter);

our @EXPORT_OK = qw(filter choice roll random irange range str_eval _group _tile);

1;

# helper functions
# filter {{{
sub filter {
    my @a = ();
    my $function = pop;

    for my $e (@_) {
        push @a, $e if $function->($e);
    }

    return @a;
}
# }}}
# choice {{{
sub choice {
    return $_[&random(int @_)] || "";
}
# }}}
# roll {{{
sub roll {
    my ($num, $sides) = @_;
    my $roll = 0; 
    
    $roll += int rand $sides for 1 .. $num;
    $roll += $num;

    return $roll;
}
# }}}
# random {{{
sub random {
    return int rand shift;
}
# }}}
# range {{{
sub range {
    my $lhs = shift;
    my $rhs = shift;
    my $correlation = shift;

    ($lhs, $rhs) = ($rhs, $lhs) if $rhs < $lhs;

    my $rand;
    if( $correlation ) {
        croak "correlated range without previous value!!" unless defined $global::last_rand;

        if( $correlation == 1 ) {
            $rand = $global::last_rand;

        } elsif( $correlation == -1 ) {
            $rand = 1000000.0 - $global::last_rand;

        } else {
            croak "unsupported correlation value";
        }

    } else {
        $rand = rand 1000000.0;
        $global::last_rand = $rand;

    }

    $rand /= 1000000.0;

    my $diff = $rhs  - $lhs;
       $rand = $rand * $diff;

    return $lhs + $rand;
}
# }}}
# irange {{{
sub irange {
    return sprintf('%0.0f', range(@_));
}
# }}}
# str_eval {{{
sub str_eval {
    my $str = shift;

    return int $str if $str =~ m/^\d+$/;

    $str =~ s/^\s*(\d+)d(\d+)\s*$/&roll($1, $2)/eg;
    $str =~ s/^\s*(\d+)d(\d+)\s*([\+\-])\s*(\d+)$/&roll($1, $2) + ($3 eq "+" ? $4 : 0-$4)/eg;

    return undef if $str =~ m/\D/;
    return int $str;
}
# }}}

sub _group { return new Games::RolePlay::MapGen::_group(@_) }
sub _tile  { return new Games::RolePlay::MapGen::_tile(@_) }

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Tools - Some support tools and objects for the mapgen suite

=head1 SYNOPSIS

    use Games::RolePlay::MapGen::Tools qw( filter choice roll random range str_eval );

    my $r1 = roll(1, 20);                   # 1d20
    my $r2 = random(20);                    # 0-20
    my $r3 = range(50, 100);                # some number between 50 and 100 (not an integer!)
    my $r4 = range(9000, 10000, 1);         # 100% positively correlated with the last range (ie, not random at all)
    my $r5 = range(7, 12, -1);              # 100% negatively correlated with the last range (ie, not random at all)
    my $ri = irange(0, 7);                  # An integer between 0 and 7
    my $e  = choice(qw(test this please));  # picks one of test, this, and please at random
    my $v  = str_eval("1d8");               # returns int(roll(1,8)) -- returns undef on parse error

    # filters any elements that don't evaluate to true out of the array. (eg, @a = ("test", "this"))
    my @a  = filter(qw(test this please), sub { ($_[0] =~ m/^t/ }) 

    # In case you were curious, choice and filter are actually from LPC (and probably pike).


    # This package also exports _group and _tile, which are shortcut functions for new
    # Games::RolePlay::MapGen::_tile and ::_group objects.

=head1 Games::RolePlay::MapGen::_group

At this time, the ::_group object is just a blessed hash that contains some
variables that need to be set by the ::Generator objects.

    $group->{name}     = "Room #$rn";
    $group->{loc_size} = "$size[0]x$size[1] ($spot[0], $spot[1])";
    $group->{type}     = "room";
    $group->{size}     = [@size];
    $group->{loc}      = [@spot];

=head1 Games::RolePlay::MapGen::_tile

At this time, the ::_tile object is just a blessed hash that the
::Generators instantiate at every map location.  There are no required
variables at this time.

    v=>0, 
    od=>{n=>0, s=>0, e=>0, w=>0}

Though, for convenience, visited is set to 0 and "open directions" is set to
all zeros.

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
