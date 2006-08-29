# $Id: Tools.pm,v 1.19 2006/08/29 19:37:29 jettero Exp $
# vi:tw=0 syntax=perl:

# package ::_interconnected_map {{{
package Games::RolePlay::MapGen::_interconnected_map;

use strict;
use Carp;

1;

# interconnect_map {{{
sub interconnect_map {
    my $map = shift;

    # This interconnected array stuff is _REALLY_ handy, but it needs to be cleaned up, so it gets it's own class

    for my $i (0 .. $#$map) {
        my $jend = $#{ $map->[$i] };

        for my $j (0 .. $jend) {
            $map->[$i][$j]->{nb}{s} = $map->[$i+1][$j] unless $i == $#$map;
            $map->[$i][$j]->{nb}{n} = $map->[$i-1][$j] unless $i == 0;
            $map->[$i][$j]->{nb}{e} = $map->[$i][$j+1] unless $j == $jend;
            $map->[$i][$j]->{nb}{w} = $map->[$i][$j-1] unless $j == 0;
        }
    }
}
# }}}
# disconnect_map {{{
sub disconnect_map {
    my $map = shift;

    for my $i (0 .. $#$map) {
        my $jend = $#{ $map->[$i] };

        for my $j (0 .. $jend) {
            # Destroying the map wouldn't destroy the tiles if they're self
            # referencing like this.  That's not a problem because of the
            # global destructor, *whew*; except that each new map generated,
            # until perl exits, would eat up more memory.  

            delete $map->[$i][$j]{nb}; # So we have to break the self-refs here.
        }
    }

    # You can test to make sure the tiles are dying when a map goes out of
    # scope by setting the VERBOSE_TILE_DEATH environment variable to a true
    # value.  If they fail to die when they go out of scope, it would say so on
    # the warning line.  If you'd really really like to see that, change the
    # {nb} above to {nb_borked} and you'll see what I mean.

    # Lastly, if you'd like to read a lengthy dissertation on this subject,
    # search for "Two-Phased" in the perlobj man page.
}
# }}}
# new {{{
sub new {
    my $class = shift;
    my $arg   = shift;
    my $map   = bless $arg, $class;

    $map->interconnect_map; # also used by save_map()

    return $map;
}
# }}}
# DESTROY {{{
sub DESTROY {
    my $map = shift;

    $map->disconnect_map; # also used by save_map()
}
# }}}

# }}}
# package ::_group; {{{
package Games::RolePlay::MapGen::_group;

use strict;

1;

sub new { my $class = shift; bless {@_}, $class }
# }}}
# package ::_tile; {{{
package Games::RolePlay::MapGen::_tile;

use strict;

1;

sub dup {
    my $that  = shift;
    my $class = $that->{__c};
    my $this  = bless {od=>{n=>1, s=>1, e=>1, w=>1}}, $class;

    $this->{$_}     = $that->{$_}     for grep {not ref $that->{$_}} keys %$that;
    $this->{od}{$_} = $that->{od}{$_} for keys %{ $that->{od} };

    return $this;
}

sub new { my $class = shift; bless { @_, __c=>$class, v=>0, od=>{n=>0, s=>0, e=>0, w=>0} }, $class }
sub DESTROY { warn "tile verbosely dying" if $ENV{VERBOSE_TILE_DEATH} }  # search for VERBOSE above...
# }}}
# package ::_door; {{{
package Games::RolePlay::MapGen::_door;

use strict;

1;

sub new {
    my $class = shift; 
    my $this  = bless { @_ }, $class; 

    $this->{locked}   = 0 unless $this->{locked};
    $this->{stuck}    = 0 unless $this->{stuck};
    $this->{secret}   = 0 unless $this->{secret};
    $this->{open_dir} = { major=>undef, minor=>undef } unless ref($this->{open_dir});

    return $this;
}

# }}}

package Games::RolePlay::MapGen::Tools;

use strict;
use Carp;
use base q(Exporter);

our @EXPORT_OK = qw(choice roll random irange range str_eval _group _tile _door);

1;

# helper functions
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
    my $il = shift;
    my $ir = shift;

    $il -= 0.4999999999;
    $ir += 0.4999999999;

    my $s = sprintf('%0.0f', range($il, $ir, @_));

    $s = 0 if $s eq "-0";

    return $s;
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
sub _door  { return new Games::RolePlay::MapGen::_door(@_) }

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::Tools - Some support tools and objects for the mapgen suite

=head1 SYNOPSIS

    use Games::RolePlay::MapGen::Tools qw( choice roll random range str_eval );

    my $r1 = roll(1, 20);                   # 1d20
    my $r2 = random(20);                    # 0-20
    my $r3 = range(50, 100);                # some number between 50 and 100 (not an integer!)
    my $r4 = range(9000, 10000, 1);         # 100% positively correlated with the last range (ie, not random at all)
    my $r5 = range(7, 12, -1);              # 100% negatively correlated with the last range (ie, not random at all)
    my $ri = irange(0, 7);                  # An integer between 0 and 7
    my $e  = choice(qw(test this please));  # picks one of test, this, and please at random
    my $v  = str_eval("1d8");               # returns int(roll(1,8)) -- returns undef on parse error

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

=head1 Games::RolePlay::MapGen::_interconnected_map

This object interconnects all the tiles in a map array, so 
$tile = $map->[$y][$x] and $tile->{nb} is an array of neighboring tiles.
Example: $east_neighbor = $map->[$y][$x]->{nb}{e};

(It also cleans up self-referencing loops at DESTROY time.)

=head1 Games::RolePlay::MapGen::_door

A simple object that stores information about a door.  Example:

    my $door = &_door(
        stuck    => 0,
        locked   => 0,
        secret   => 0,
        open_dir => {
            major => "n", # the initial direction of the opening door
            minor => "w", # the final direction of the opening door (think 90 degree swing)
        },
    );

    print "The door is locked.\n" if $door->{locked};

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
