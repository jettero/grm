# vi:tw=0 syntax=perl:

package Games::RolePlay::MapGen::Exporter;

use common::sense;
use Carp;

1;

# new {{{
sub new {
    my ($class, $opts) = @_;
    my $this = bless {o => $opts}, $class;

    return $this;
}
# }}}
# gen_opts {{{
sub gen_opts {
    my ($this, $opts) = @_;

    for my $k (keys %{ $this->{o} }) {
        $opts->{$k} = $this->{o}{$k} if not exists $opts->{$k};
    }

    return $opts;
}
# }}}
# go {{{
sub go {
    my ($this, $opts) = @_;
    $opts = $this->gen_opts($opts);

    croak "ERROR: fname is a required option for " . ref($this) . "::go()" unless $opts->{fname};
    croak "ERROR: _the_map is a required option for " . ref($this) . "::go()" unless ref($opts->{_the_map});

    my ($map, $sub) = $this->genmap($opts);
    unless( $opts->{fname} eq "-retonly" ) {
        open _MAP_OUT, ">$opts->{fname}" or die "ERROR: couldn't open $opts->{fname} for write: $!";
        print _MAP_OUT ($sub ? $map->$sub : $map);
        close _MAP_OUT;
    }

    return $map;
}
# }}}
# gen_cell_size {{{
sub gen_cell_size {
    my $this = shift;
    my $opts = shift;

    if( $opts->{cell_size} ) {
        die "ERROR: illegal cell size '$opts->{cell_size}'" unless $opts->{cell_size} =~ m/^(\d+)x(\d+)/;
        $opts->{x_size} = $1;
        $opts->{y_size} = $2;
    }

    if( $opts->{bounding_box} ) {
        die "ERROR: illegal bounding box '$opts->{bounding_box}'" unless $opts->{bounding_box} =~ m/^(\d+)x(\d+)/;
        $opts->{bound_x_size} = $1;
        $opts->{bound_y_size} = $2;
    }

    map { $opts->{'pixel_'.$_.'_size'} = $opts->{'bound_'.$_.'_size'} * $opts->{$_.'_size'} } qw(x y);
    
}
# }}}
# genmap {{{
sub genmap {
    croak "ERROR: Exporter is merely a stub class!  Use one of the other actual export modules!";
    return undef;
}
# }}}

__END__

=head1 NAME

Games::RolePlay::MapGen::Exporter - Exporter Superclass

=head1 SYNOPSIS

    
    package Games::RolePlay::MapGen::Exporter::FOO    
    use parent qw(Games::RolePlay::MapGen::Exporter);
    
    sub genmap {
       my ($this, $opts) = @_;
       ...
       return $map;  # or ($map, $sub), if $map->$sub works
    }
    
    __END__


=head1 DESCRIPTION

This is simplification of the Exporter modules with this superclass.  Only one
sub is required: genmap.  If you need some changes to your export, then overload
any of the subs you need to change.

=head1 SEE ALSO

Games::RolePlay::MapGen

=cut
