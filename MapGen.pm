# $Id: MapGen.pm,v 1.54 2005/04/04 15:17:19 jettero Exp $
# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen;

use strict;
use AutoLoader;
use Carp;
use Data::Dumper; $Data::Dumper::Indent = 1; $Data::Dumper::SortKeys = 1;

our $VERSION = "0.26";
our $AUTOLOAD;

our %opp = (n=>"s", e=>"w", s=>"n", w=>"e");

# known_opts {{{
our %known_opts = (
    generator              => "Basic",
    exporter               => "Text",
    bounding_box           => "50x50",
    tile_size              => "3 ft",
    cell_size              => "20x20",

    num_rooms              => "1d4+1",
    min_room_size          => "2x2",
    max_room_size          => "7x7",

    sparseness             => 10,
          same_way_percent => 90,
         same_node_percent => 30,
    remove_deadend_percent => 60,
);
# }}}

1;

# _check_mod_path {{{
sub _check_mod_path  {
    my $this = shift;
    my $omod = shift;
       $omod =~ s/\:\:/\//g;

    my $found = 0;
    my $mod;
    for my $toadd ("", "Games/RolePlay/MapGen/Generator/", "Games/RolePlay/MapGen/GeneratorPlugin/", "Games/RolePlay/MapGen/Exporter/", "Games/RolePlay/MapGen/ExporterPlugin/") {
        $mod = "$toadd$omod";
        for my $dir (@INC) {
            # warn "trying $dir/$mod.pm" if $dir =~ m/blib/ and $mod =~ m/Text/;
            if( -f "$dir/$mod.pm" ) {
                $found = 1;
                goto _NO_MORE_MOD_CHECK;
            }
        }
    }

    _NO_MORE_MOD_CHECK:
    return undef unless $found;

    $mod =~ s/\/+/\:\:/g;
    return $mod;
}
# }}}
# _check_opts {{{
sub _check_opts {
    my $this = shift;
    my @e    = ();

    # warn "checking known_opts";
    no strict 'refs';
    for my $k (keys %known_opts) {
        "set_$k"->($this, $known_opts{$k} ) unless defined $this->{$k};
    }

    for my $k ( keys %$this ) {
        unless( exists $known_opts{$k} ) {
            next if $k eq "objs";
            next if $k eq "_the_map";
            next if $k eq "_the_groups";

            push @e, "unrecognized option: '$k'";
        }
    }

    return "ERROR:\n\t" . join("\n\t", @e) . "\n" if @e;
    return;
}
# }}}

# AUTOLOAD {{{
sub AUTOLOAD {
    my $this = shift;
    my $sub  = $AUTOLOAD;

    if( $sub =~ m/MapGen\:\:set_(generator|exporter)$/ ) {
        my $type = $1;
        my $modu = shift;

        delete $this->{objs}{$type} if $this->{objs}{$type};

        croak "Couldn't locate module \"$modu\"" unless $this->{$type} = $this->_check_mod_path( $modu );

        return;

    } elsif( $sub =~ m/MapGen\:\:add_(generator|exporter)_plugin$/ ) {
        my $type = $1;
        my $plug = shift;
        my $newn;

        delete $this->{objs}{$type} if $this->{objs}{$type};

        croak "Couldn't locate module \"$plug\"" unless $newn = $this->_check_mod_path( $plug );

        push @{ $this->{plugins}{$type} }, $newn;

        return;

    } elsif( $sub =~ m/MapGen\:\:set_([\w\d\_]+)$/ ) {
        my $n = $1;

        croak "ERROR: set_$n() unknown setting" unless exists $known_opts{$n};

        $this->{$n} = shift;

        for my $o (qw(generator exporter)) {
            if( my $oo = $this->{objs}{$o} ) {
                $oo->{o}{$n} = $this->{$n};
            }
        }

        return;
    }

    croak "ERROR: function $sub() not found";
}
sub DESTROY {}
# }}}
# new {{{
sub new {
    my $class = shift;
    my @opts  = @_;
    my $opts  = ( (@opts == 1 and ref($opts[0]) eq "HASH") ? $opts[0] : {@opts} );
    my $this  = bless $opts, $class;

    if( my $e = $this->_check_opts ) { croak $e }

    return $this;
}
# }}}

# save_map {{{
sub save_map {
    my $this     = shift;
    my $filename = shift;

    $this->{_the_map}->disconnect_map;

    my @keys = keys %$this;

    open _SAVE, ">$filename" or die "couldn't open $filename for write: $!";
    print _SAVE Data::Dumper->Dump([map($this->{$_}, @keys)], [map("\$this\-\>{$_}", @keys)]);
    close _SAVE;

    $this->{_the_map}->interconnect_map;
}
# }}}
# load_map {{{
sub load_map {
    my $this     = shift;
    my $filename = shift;

    open _LOAD, "$filename" or die "couldn't open $filename for read: $!";
    my $entire_file = join("", <_LOAD>);
    close _LOAD;

    eval $entire_file;
    die "ERROR while evaluating saved map: $@" if $@;

    require Games::RolePlay::MapGen::Tools; # This would already be loaded if we were the blessed ref that did the saving
    $this->{_the_map}->interconnect_map;    # bit it wouldn't be loaded otherwise!
}
# }}}
# generate {{{
sub generate {
    my $this = shift;
    my $err;

    __MADE_GEN_OBJ:
    if( my $gen = $this->{objs}{generator} ) {

        ($this->{_the_map}, $this->{_the_groups}) = $gen->go( @_ );

        return;

    } else {
        die "ERROR: problem creating new generator object" if $err;
    }

    eval qq( require $this->{generator} ); 
    croak "ERROR locating generator module:\n\t$@\n " if $@;

    my $obj;
    my @opts = map(($_=>$this->{$_}), grep {defined $this->{$_} and $_ ne "objs"  and $_ ne "plugins" } keys %$this);

    eval qq( \$obj = new $this->{generator} (\@opts); );
    if( $@ ) {
        die   "ERROR generating generator:\n\t$@\n " if $@ =~ m/ERROR/;
        croak "ERROR generating generator:\n\t$@\n " if $@;
    }

    $obj->add_plugin( $_ ) for @{ $this->{plugins}{generator} };

    $this->{objs}{generator} = $obj;
    $err = 1;

    $this->_check_opts; # plugins, generators and exporters can add default options

    goto __MADE_GEN_OBJ;
}
# }}}
# export {{{
sub export {
    my $this = shift;
    my $err;

    __MADE_VIS_OBJ:
    if( my $vis = $this->{objs}{exporter} ) {

        $vis->go( _the_map => $this->{_the_map}, _the_groups => $this->{_the_groups}, (@_==1 ? (fname=>$_[0]) : @_) );

        return;

    } else {
        die "problem creating new exporter object" if $err;
    }

    eval qq( require $this->{exporter} );
    croak "ERROR locating exporter module:\n\t$@\n " if $@;

    my $obj;
    my @opts = map(($_=>$this->{$_}), grep {defined $this->{$_} and $_ ne "objs"  and $_ ne "plugins" } keys %$this);

    eval qq( \$obj = new $this->{exporter} (\@opts); );
    if( $@ ) {
        die   "ERROR generating exporter:\n\t$@\n " if $@ =~ m/ERROR/;
        croak "ERROR generating exporter:\n\t$@\n " if $@;
    }

    $this->{objs}{exporter} = $obj;
    $err = 1;

    $this->_check_opts; # plugins, generators and exporters can add default options

    goto __MADE_VIS_OBJ;
}
# }}}

__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen - The base object for generating dungeons and maps

=head1 SYNOPSIS

    use Games::RolePlay::MapGen;

    $map->set_generator("Basic");             # This is actually the default generator,
    $map->add_generator_plugin("BasicDoors"); # however, you must add the doors.
    generate $map("map.txt");                 # It'll generate a text map by default.

    $map->set_exporter( "BasicImage" );       # But a graphical map is probably more useful.
    export $map("map.png");

=head1 AUTHOR

Jettero Heller <japh@voltar-confed.org>

Jet is using this software in his own projects...
If you find bugs, please please please let him know. :)

Actually, let him know if you find it handy at all.
Half the fun of releasing this stuff is knowing 
that people use it.

=head1 Special Thanks to Jamis Buck

I emailed Jamis and asked for permission to duplicate the text of portions
of his "Random Dungeon Design: The Secret Workings of Jamis Buck's Dungeon
Generator" document (http://www.aarg.net/~minam/dungeon_design.html) and he
was cool with that.

Really, without his work, I never would have written this module!

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
