
# This is the basic map package for dealing with objects in the world, walls, and things of that nature.

# this should be part of the mapgen distro ... a generic map class that functions like an array or whatever.

package m_map;

use strict;

1;

sub new {
    my $class = shift;
    my $this  = bless {}, $class;
    my $opts  = { @_ };

    if( exists $opts->{file} ) {
        $this->build_from_file( $this->{file} );

    } else {
        $this->build_empty_map(10, 10);
    }

    return $this;
}

package m_mapcell;

use strict;

1;

sub new {
    my $class = shift;
    my $this  = bless {}, $class;

    return $this;
}

package m_mapclosure;

use strict;

1;

sub new {
    my $class = shift;
    my $this  = bless {}, $class;

    return $this;
}
