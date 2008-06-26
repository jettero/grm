# vi:filetype=perl:

package Games::RolePlay::MapGen::MapQueue::Object;

use strict;
use overload fallback => 1, bool => sub{1}, '0+' => \&n, '""' => \&q;

sub new { my $class = shift; my $val = shift; bless {q=>1, u=>1, v=>$val}, $class }

sub desc {
    my $this = shift;

    my $r = $this->{v};
       $r .= " ($this->{q})" if $this->{q} != 1;
       $r .= " #$this->{c}"  unless $this->{u};

    return $r;
}

sub q {
    my $this = shift;

    return "$this->{v} #$this->{c}" unless $this->{u};
    return $this->{v};
}

sub n {
    my $this = shift;

    return $this->{q};
}

our %item_counts;
sub quantity  { my $this = shift; $this->{q}=0+shift; }
sub    unique { my $this = shift; $this->{u}=1; }
sub nonunique { my $this = shift; $this->{u}=0;
    unless( exists $this->{c} ) {
        $this->{c} = push @{$item_counts{$this->{v}}}, $this;
    }
}
sub DESTROY {
    my $this = shift;

    delete $item_counts{$this->{v}}[$this->{c}] if exists $this->{c};
}

"I like GD::Graph.";


__END__
# Below is stub documentation for your module. You better edit it!

=head1 NAME

Games::RolePlay::MapGen::MapQueue::Object - adds special string interpolation support

=head1 SYNOPSIS

    my $s7 = new Games::RolePlay::MapGen::MapQueue::Object(7);
    my $sT = new Games::RolePlay::MapGen::MapQueue::Object("test");

=head1 SEE ALSO

Games::RolePlay::MapGen::MapQueue

=cut
