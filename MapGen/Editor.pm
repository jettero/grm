
package Games::RolePlay::MapGen::Editor;

use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app
use Gtk2::SimpleMenu;
use Games::RolePlay::MapGen;
use DB_File;
use Storable qw(freeze thaw);

use constant {
    MAP      => 0,
    WINDOW   => 1,
    SETTINGS => 2,
    MENU     => 3,
    MAREA    => 4,
    FNAME    => 5,
};

1;

# NOTE: much of this code is ripped from
# http://perlmonks.org/?node_id=583578

# new {{{
sub new {
    my $class = shift;
    my $this  = bless [], $class;

    warn "settings saved to 'stupid_name'"; sleep 1;
    my %o; tie %o, DB_File => "/tmp/stupid_name" or die $!;

    $this->[SETTINGS] = \%o;

    my $vbox = new Gtk2::VBox;
    my $window = $this->[WINDOW] = new Gtk2::Window("toplevel");
       $window->signal_connect( delete_event => sub { $this->quit } );
       $window->set_size_request(200,200); # TODO: should be persistant
       $window->set_position('center');    # TODO: should be persistant
       $window->add($vbox);

    # NOTE: This awesome tree example comes from http://www.drdobbs.com/web-development/184416069
    # (but it turns out that the example in the Gtk2::SimpleMenu pod is just as helpful)

    my $menu_tree = [
        _File => {
            item_type => '<Branch>',
            children => [
                _Open => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->open },
                    accelerator => '<ctrl>O',
                    extra_data  => 'gtk-open',
                },
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
              # _Help => {
              #     item_type    => '<StockItem>',
              #     accelerator  => '<ctrl>H',
              #     extra_data   => 'gtk-help',
              # },
                _About => {
                    item_type => '<StockItem>',
                    callback  => sub { $this->about },
                },
            ],
        },
    ];

    my $menu = $this->[MENU] = Gtk2::SimpleMenu->new (
        menu_tree        => $menu_tree,
        default_callback => sub { $this->unknown_menu_callback },
    );

    $vbox->pack_start($menu->{widget}, 0,0,0);
    $window->add_accel_group($menu->{accel_group});

    my $marea = $this->[MAREA] = new Gtk2::Image;
    my $scwin = Gtk2::ScrolledWindow->new;
    my $vp    = Gtk2::Viewport->new (undef,undef);

    $scwin->add($vp);
    $vp->add($marea);
    $vbox->pack_start($scwin,1,1,0);

    $this->read_file($ARGV[0]) if $ARGV[0] and -f $ARGV[0];
    $this->draw_map;

    return $this;
}
# }}}

# open {{{
sub open {
    my $this = shift;

    my $file_chooser =
        Gtk2::FileChooserDialog->new ('Open a Map File',
            $this->[WINDOW], 'open', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');

    if ('ok' eq $file_chooser->run) {
        my $filename = $file_chooser->get_filename;

        # TODO: in order for this to work right, I think we need a custom signal
        # so we can return to gtk (letting the destroy happen) and come back to
        # draw the dialog and load the file... moan

        $file_chooser->destroy;
        $this->read_file($filename);
        return;
    }

    $file_chooser->destroy;
}
# }}}
# read_file {{{
sub read_file {
    my $this = shift;
    my $file = shift;

    my $dialog = new Gtk2::Dialog;
    my $label  = new Gtk2::Label("Reading $file ...");
    my $prog   = new Gtk2::ProgressBar;

    $dialog->vbox->pack_start( $label, TRUE, TRUE, 0 );
    $dialog->vbox->pack_start( $prog, TRUE, TRUE, 0 );
    $dialog->show_all;

    for(1 .. 3) { Gtk2->main_iteration while Gtk2->events_pending; }
    my $map = $this->[MAP] = Games::RolePlay::MapGen->import_xml( $file, r_cb => sub {
        for(1 .. 3) { Gtk2->main_iteration while Gtk2->events_pending; }
        $prog->pulse;
    });

    $this->[FNAME] = $file;
    $this->draw_map;

    $dialog->destroy;
}
# }}}

# draw_map {{{
sub draw_map {
    my $this = shift;

    my $map = $this->[MAP];
       $map = $this->[MAP] = $this->new_map unless $map;

    $map->set_exporter( "BasicImage" );
    my $image = $map->export( -retonly );

    my $loader = Gtk2::Gdk::PixbufLoader->new;
       $loader->write($image->png);
       $loader->close;

    $this->[MAREA]->set_from_pixbuf($loader->get_pixbuf)
}
# }}}
# new_map {{{
sub new_map {
    my $this = shift;

    $this->[FNAME] = undef;

    my $map = $this->[MAP] = new Games::RolePlay::MapGen({
        tile_size    => 10,
        cell_size    => "23x23", # TODO: these need to be settings
        bounding_box => "15x15", # TODO: these need to be settings
    });

    $map->set_generator("Blank");
    $map->generate; 
    $map;
}
# }}}

# about {{{
sub about {
    my $this = shift;

    # TODO: consider using Gtk2::AboutDialog

    my $dialog = new Gtk2::Dialog; 
    my $button = new Gtk2::Button("Close");
    my $label  = new Gtk2::Label("This is a Games::RolePlay::MapGen::Editor.");

    $dialog->action_area->pack_start( $button, TRUE, TRUE, 0 );
    $button->show;

    $dialog->vbox->pack_start( $label, TRUE, TRUE, 0 );
     $label->show;
    $dialog->show;

    $button->signal_connect( clicked => sub {
        $dialog->destroy;
    });
}
# }}}

# unknown_menu_callback {{{
sub unknown_menu_callback {
    my $this = shift;
}
# }}}
# quit {{{
sub quit {
    my $this = shift;

    my ($w,$h) = $this->[WINDOW]->get_size;
    my ($x,$y) = $this->[WINDOW]->get_position;

    $this->[SETTINGS]{MAIN_SIZE_POS} = freeze [$w,$h,$x,$y];
    $this->[SETTINGS]{LAST_FNAME}    = $this->[FNAME];

    Gtk2->main_quit;
}
# }}}
# run {{{
sub run {
    my $this = shift;

    if( my $sp = $this->[SETTINGS]{MAIN_SIZE_POS} ) {
        my ($w,$h,$x,$y) = @{thaw $sp};

        warn "setting window params: ($w,$h,$x,$y)";

        $this->[WINDOW]->resize( $w,$h );
      # $this->[WINDOW]->set_position( $x,$y ); # TODO: this takes single scalars like "center" ... lame
    }

    $this->[WINDOW]->show_all;

  # TODO: to do this properly, we'll need to do it *after* calling ->main I thik
  # if( my $f = $this->[SETTINGS]{LAST_FNAME} ) {
  #     $this->read_file($f) if -f $f;
  # }

    Gtk2->main;
}
# }}}
