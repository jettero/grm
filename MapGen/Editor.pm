
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

    my $window    = $this->[WINDOW] = new Gtk2::Window ( "toplevel" );
       $window->signal_connect( delete_event => sub { $this->quit } );
       $window->set_size_request(640,480); # TODO: the size and postion should have some kind of persistance
       $window->set_position('center');

    my $main_vbox = Gtk2::VBox->new;         $window->add($main_vbox);
    my $menu_bar  = Gtk2::MenuBar->new;      $main_vbox->pack_start($menu_bar, 0, 0, 0);

    my $File      = Gtk2::MenuItem->new('_File');
    my $menu_file = Gtk2::Menu->new;
       $menu_bar->append($File);
       $File->set_submenu($menu_file);

    my $Exit = Gtk2::MenuItem->new('E_xit');
       $Exit->signal_connect('activate' => sub { $this->quit });
       $menu_file->append($Exit);
    

    return $this;
}

sub quit {
    my $this = shift;

    Gtk2->main_quit;
}

sub run {
    my $this = shift;
       $this->[WINDOW]->show_all;

    Gtk2->main;
}
