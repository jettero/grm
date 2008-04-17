
package Games::RolePlay::MapGen::Editor;

use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app

use constant {
    WINDOW => 0,
};

1;

# NOTE: much of this code is ripped from
# http://perlmonks.org/?node_id=583578

sub new {
    my $class = shift;
    my $this  = bless [], $class;

    my $window = $this->[WINDOW] = new Gtk2::Window ( "toplevel" );
       $window->signal_connect( delete_event => sub { $this->quit } );
       $window->set_size_request(640,480); # TODO: these need some kind of persistance settings eventually
       $window->set_position('center');

    my $main_vbox = Gtk2::VBox->new( 0, 0 );
    $window->add($main_vbox);

    my $menu_bar = Gtk2::MenuBar->new;
    $main_vbox->pack_start($main_vbox, 0, 0, 0);

    my $File = Gtk2::MenuItem->new('_File');
    $menu_bar->append($File);

    return $this;
}

sub quit {
    my $this = shift;

    Gtk2->main_quit;
}

sub run {
    my $this = shift;

    Gtk2->main;
}
