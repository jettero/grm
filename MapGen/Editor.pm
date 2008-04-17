
package Games::RolePlay::MapGen::Editor;

use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app
use Gtk2::SimpleMenu;

use constant {
    WINDOW => 0,
};

1;

# NOTE: much of this code is ripped from
# http://perlmonks.org/?node_id=583578

sub new {
    my $class = shift;
    my $this  = bless [], $class;

    my $window = $this->[WINDOW] = new Gtk2::Window("toplevel");
       $window->signal_connect( delete_event => sub { $this->quit } );
       $window->set_size_request(640,480); # TODO: the size and postion should have some kind of persistance
       $window->set_position('center');

    # NOTE: This awesome tree example comes from http://www.drdobbs.com/web-development/184416069
    # (but it turns out that the example in the Gtk2::SimpleMenu pod is just as helpful)

    my $menu_tree = [
        _File => {
            item_type => '<Branch>',
            children => [
                _Quit => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->quit },
                    accelerator => '<ctrl>Q',
                    extra_data  => 'gtk-quit',
                },
            ],
        },
        _Help => {
            item_type => '<LastBranch>',
            children => [
                _Help => {
                    item_type       => '<StockItem>',
                    callback_action => 3,
                    accelerator     => '<ctrl>H',
                    extra_data      => 'gtk-help',
                }
            ],
        },
    ];

    my $menu = Gtk2::SimpleMenu->new (
        menu_tree        => $menu_tree,
        default_callback => sub { $this->unknown_menu_callback },
    );

    my $vbox = new Gtk2::VBox;
       $vbox->pack_start($menu->{widget}, 0, 0, 0);

    $window->add($vbox);

    return $this;
}

sub unknown_menu_callback {
    my $this = shift;
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
