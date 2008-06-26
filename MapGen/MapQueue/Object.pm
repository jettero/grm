
package Games::RolePlay::MapGen::MapQueue::Object;

use strict;
use overload fallback => 1, bool => \&b, '0+' => \&n, '""' => \&q;

1;

sub new { my $class = shift; my $val = shift; bless {v=>$val}, $class }

sub q {
    my $this = shift;

    $this->{v};
}

sub n {
    my $this = shift;

    $this->{v};
}

sub b {
    my $this = shift;

    $this->{v};
}

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
