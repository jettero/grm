# vi:syntax=perl:

package Games::RolePlay::MapGen::Editor;

use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app
use Gtk2::Ex::Simple::Menu;
use Gtk2::Ex::Dialogs::ErrorMsg;
use Gtk2::Ex::Dialogs::Question;
use Gtk2::SimpleList;
use Games::RolePlay::MapGen;
use User;
use File::Spec;
use DB_File;
use Storable qw(freeze thaw);
use Data::Dump qw(dump);
use POSIX qw(ceil);

use Games::RolePlay::MapGen::Editor::_MForm qw(make_form $default_restore_defaults);;

our $DEFAULT_GENERATOR         = 'Basic';
our @GENERATORS                = (qw( Basic Blank OneBigRoom Perfect SparseAndLoops ));
our @GENERATOR_PLUGINS         = (qw( BasicDoors FiveSplit ));
our @DEFAULT_GENERATOR_PLUGINS = (qw( BasicDoors ));
our @FILTERS                   = (qw( BasicDoors FiveSplit ClearDoors ));

use vars qw($x); # like our, but at compile time so these constants work
use constant {
    MAP   => $x++, WINDOW => $x++, SETTINGS => $x++, MENU   => $x++,
    FNAME => $x++, MAREA  => $x++, MPBUF    => $x++, VP_DIM => $x++,
    STAT  => $x++, S_CO   => $x++, O_LT     => $x++,
};

1;

# new {{{
sub new {
    my $class = shift;
    my $this  = bless [], $class;

    my $fname   = "GRM Editor";
    unless( File::Spec->case_tolerant ) {
        $fname = lc $fname;
        $fname =~ s/ /_/g;
        substr($fname,0,0) = ".";
    }

    my @homedir = User->Home;
    push @homedir, "Application Data" if "@homedir" =~ m/Documents and Settings/i;

    $fname = File::Spec->catfile(@homedir, $fname);

    my %o; tie %o, DB_File => $fname or die $!;

    $o{REMEMBER_SP} = 1 unless defined $o{REMEMBER_SP};

    $this->[SETTINGS] = \%o;

    my $vbox = new Gtk2::VBox;
    my $window = $this->[WINDOW] = new Gtk2::Window("toplevel");
       $window->signal_connect( delete_event => sub { $this->quit } );
       $window->set_size_request(200,200);
       $window->set_position('center');
       $window->add($vbox);
       $window->set_title("GRM Editor");

    my $menu_tree = [
        _File => {
            item_type => '<Branch>',
            children => [
                'Generate _New Map' => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->generate },
                    accelerator => '<ctrl>N',
                    extra_data  => 'gtk-new',
                },
                _Open => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->open_file },
                    accelerator => '<ctrl>O',
                    extra_data  => 'gtk-open',
                },
                _Save => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->save_file },
                    accelerator => '<ctrl>S',
                    extra_data  => 'gtk-save',
                },
                'Save As...' => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->save_file_as },
                    accelerator => '<ctrl>S',
                    extra_data  => 'gtk-save-as',
                },
                '_Export' => {
                    item_type => '<Branch>',
                    children => [
                        "_Image..." => {
                            callback    => sub { $this->save_image_as },
                        },
                        "_Text File..." => {
                            callback    => sub { $this->save_text_as },
                        },
                    ],
                },
                _Close => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->blank_map },
                    accelerator => '<ctrl>W',
                    extra_data  => 'gtk-close',
                },
                _Quit => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->quit },
                    accelerator => '<ctrl>Q',
                    extra_data  => 'gtk-quit',
                },
            ],
        },
        _Edit => {
            item_type => '<Branch>',
            children => [
                '_Redraw' => {
                    callback    => sub { $this->draw_map },
                    accelerator => '<ctrl>R',
                },
                'Render _Settings'=> {
                    callback    => sub { $this->render_settings },
                },
                Separator => {
                    item_type => '<Separator>',
                },
                _Preferences => {
                    item_type   => '<StockItem>',
                    callback    => sub { $this->preferences },
                    accelerator => '<ctrl>P',
                    extra_data  => 'gtk-preferences',
                },
            ],
        },
        _Help => {
            item_type => '<LastBranch>',
            children => [
                _About => {
                    item_type => '<StockItem>',
                    callback  => sub { $this->about },
                    extra_data  => 'gtk-about',
                },
            ],
        },
    ];

    my $menu = $this->[MENU] = Gtk2::Ex::Simple::Menu->new (
        menu_tree        => $menu_tree,
        default_callback => sub { $this->unknown_menu_callback },
    );

    $vbox->pack_start($menu->{widget}, 0,0,0);
    $window->add_accel_group($menu->{accel_group});

    my $marea = $this->[MAREA] = new Gtk2::Image;
    my $scwin = Gtk2::ScrolledWindow->new;
    my $vp    = Gtk2::Viewport->new(undef,undef);
    my $al    = Gtk2::Alignment->new(0.5,0.5,0,0);
    my $eb    = Gtk2::EventBox->new;

    # This is so we can later determin the size of the viewport.
    $this->[VP_DIM] = my $dim = [];
    $vp->signal_connect( 'size-allocate' => sub { my $r = $_[1]; $dim->[0] = $r->width; $dim->[1] = $r->height; 0; });

    my $sb = $this->[STAT] = new Gtk2::Statusbar;
    my $cid = 1; $sb->push($cid, sprintf('tile: [%d,%d]', 0,0));
    my $s_co = $this->[S_CO] = sub { $sb->push($cid, (@_==2 ? sprintf('tile: [%d,%d]', @_) : "")) };
       $s_co->();

    $this->[O_LT]=[];

    $eb->add_events([qw(leave-notify-mask pointer-motion-mask pointer-motion-hint-mask)]);
    $eb->signal_connect( motion_notify_event => sub { $this->marea_motion_notify_event($s_co, @_); 0; });
    $eb->signal_connect(  leave_notify_event => sub { @{$this->[O_LT]} = (); $s_co->() });

    $scwin->set_policy('automatic', 'automatic');
    $scwin->add($vp);
    $al->add($eb);
    $vp->add($al);
    $eb->add($marea);
    $vbox->pack_start($scwin,1,1,0);
    $vbox->pack_end($sb,0,0,0);

    $this->read_file($ARGV[0]) if $ARGV[0] and -f $ARGV[0];
    $this->draw_map;

    return $this;
}
# }}}
# error {{{
sub error {
    my $this  = shift;
    my $error = shift;

    # The Ex dialogs use Pango Markup Language... pffft
    $error = Glib::Markup::escape_text( $error );

    Gtk2::Ex::Dialogs::ErrorMsg->new_and_run( parent_window=>$this->[WINDOW], text=>$error );
}
# }}}

# open_file {{{
sub open_file {
    my $this = shift;

    my $file_chooser =
        Gtk2::FileChooserDialog->new ('Open a Map File',
            $this->[WINDOW], 'open', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');

    if( $file_chooser->run eq 'ok' ) {
        my $filename = $file_chooser->get_filename;

        $file_chooser->destroy;
        $this->read_file($filename);
        return;
    }

    $file_chooser->destroy;
}
# }}}
# save_file {{{
sub save_file {
    my $this = shift;

    unless( $this->[FNAME] ) {
        $this->save_file_as;
        return;
    }

    my $map = $this->[MAP];
    eval {
        $map->set_exporter( "XML" );
        $map->export( $this->[FNAME] );
    };

    $this->error($@) if $@;
}
# }}}
# save_file_as {{{
sub save_file_as {
    my $this = shift;

    my $file_chooser =
        Gtk2::FileChooserDialog->new ('Save a Map File',
            $this->[WINDOW], 'save', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');

    if ('ok' eq $file_chooser->run) {
        my $fname = $file_chooser->get_filename;
           $fname .= ".xml" unless $fname =~ m/\.xml\z/i;

        $this->[FNAME] = $fname;


        $file_chooser->destroy;
        Gtk2->main_iteration while Gtk2->events_pending;
        Gtk2->main_iteration while Gtk2->events_pending;
        $this->save_file;

        return;
    }

    $file_chooser->destroy;
}
# }}}
# save_image_as {{{
sub save_image_as {
    my $this = shift;

    my $file_chooser =
        Gtk2::FileChooserDialog->new ('Save a Map Image',
            $this->[WINDOW], 'save', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');

    if ('ok' eq $file_chooser->run) {
        my $fname = $file_chooser->get_filename;
           $fname .= ".png" unless $fname =~ m/\.png\z/i;

        $file_chooser->destroy;
        Gtk2->main_iteration while Gtk2->events_pending;
        Gtk2->main_iteration while Gtk2->events_pending;

        my $map = $this->[MAP];
        eval {
            $map->set_exporter( "BasicImage" );
            $map->export( $fname );
        };

        $this->error($@) if $@;

        return;
    }

    $file_chooser->destroy;
}
# }}}
# save_text_as {{{
sub save_text_as {
    my $this = shift;

    my $file_chooser =
        Gtk2::FileChooserDialog->new ('Save a Map Image',
            $this->[WINDOW], 'save', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');

    if ('ok' eq $file_chooser->run) {
        my $fname = $file_chooser->get_filename;
           $fname .= ".txt" unless $fname =~ m/\.txt\z/i;

        $file_chooser->destroy;
        Gtk2->main_iteration while Gtk2->events_pending;
        Gtk2->main_iteration while Gtk2->events_pending;

        my $map = $this->[MAP];
        eval {
            $map->set_exporter( "Text" );
            $map->export( $fname );
        };

        $this->error($@) if $@;

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

    $dialog->set_title("File I/O");
    $dialog->vbox->pack_start( $label, TRUE, TRUE, 0 );
    $dialog->vbox->pack_start( $prog, TRUE, TRUE, 0 );
    $dialog->show_all;

    # NOTE: I'm not sure all these main_interations are necessary as written, 
    # but certainly just doing one isn't enough for some reason.
    Gtk2->main_iteration while Gtk2->events_pending;
    $prog->pulse;
    Gtk2->main_iteration while Gtk2->events_pending;
    Gtk2->main_iteration while Gtk2->events_pending;

    eval {
        $this->[MAP] = Games::RolePlay::MapGen->import_xml( $file, r_cb => sub {
            Gtk2->main_iteration while Gtk2->events_pending;
            $prog->pulse;
            Gtk2->main_iteration while Gtk2->events_pending;
        });
    };

    $this->error($@) if $@;

    $this->[FNAME] = $file;
    $this->draw_map;

    $dialog->destroy;
}
# }}}

# draw_map {{{
sub draw_map {
    my $this = shift;

    my $map = $this->[MAP];
       $map = $this->[MAP] = $this->blank_map unless $map;

    $map->set_exporter( "BasicImage" );
    my $image = $map->export( -retonly );

    my $loader = $this->[MPBUF] = Gtk2::Gdk::PixbufLoader->new;
       $loader->write($image->png);
       $loader->close;

    $this->[MAREA]->set_from_pixbuf($loader->get_pixbuf)
}
# }}}
# redraw_map {{{
sub redraw_map {
    $_[0][MAREA]->set_from_pixbuf($_[0][MPBUF]);
}
# }}}
# blank_map {{{
sub blank_map {
    my $this = shift;

    # NOTE: This is just the blank map generator, it has no settings.
    # Later, we'll have a generate_map() that has all kinds of configuations options.

    $this->[FNAME] = undef;

    my $map = $this->[MAP] = new Games::RolePlay::MapGen({
        tile_size    => 10,
        cell_size    => "23x23",
        bounding_box => "25x25",
    });

    $map->set_generator("Blank");
    $map->generate; 

    $this->draw_map;

    $map;
}
# }}}
# get_generate_opts {{{
sub get_generate_opts {
    my $this = shift;

    my $i = $this->[SETTINGS]{GENERATE_OPTS};
       $i = thaw $i if $i;
       $i = {} unless $i;

    my $options = [[ # column 1

        { mnemonic => "_Tile Size: ",
          type     => "text",
          desc     => "The size of each tile (in Feet or Units or whatever)",
          name     => 'tile_size',
          default  => 10, # NOTE: fixes and matches must exist and must be arrrefs
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+$/] },

        { mnemonic => "Cell Size: ",
          type     => "text",
          desc     => "The size of each tile in the image (in pixels)",
          name     => 'cell_size',
          default  => '23x23',
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+x\d+$/] },

        { mnemonic => "Bounding Box: ",
          type     => "text",
          desc     => "The size of the whole map (in tiles)",
          name     => 'bounding_box',
          default  => '20x20',
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+x\d+$/] },

        { mnemonic => "Number of Rooms: ",
          type     => "text",
          desc     => "The number of generated rooms, either a number or a roll (e.g., 2, 2d4, 2d4+2)",
          name     => 'num_rooms',
          default  => '2d4',
          disable  => { generator => sub { $_[0] ne "Basic" } },
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^(?:\d+|\d+d\d+|\d+d\d+[+-]\d+)$/] },

        { mnemonic => "Min Room Size: ",
          type     => "text",
          desc     => "The minimum size of generated rooms (in tiles)",
          name     => 'min_room_size',
          default  => '2x2',
          disable  => { generator => sub { $_[0] ne "Basic" } },
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+x\d+$/] },

        { mnemonic => "Max Room Size: ",
          type     => "text",
          desc     => "The maximum size of generated rooms (in tiles)",
          name     => 'max_room_size',
          default  => '7x7',
          disable  => { generator => sub { $_[0] ne "Basic" } },
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+x\d+$/] },

    ], [ # column 2

        { mnemonic => "_Generator: ",
          type     => "choice",
          desc     => "The generator used to create the map.",
          descs    => {
              Basic          => 'The basic generator uses perfect/sparseandloops to make a map and then drops rooms onto the result.',
              Perfect        => 'The perfect maze generator James Buck designed.',
              SparseAndLoops => "Pretty much, this is same map generator on James Buck's site.",
              Blank          => "Generates a boring blank map according to your selected bounding box.",
              OneBigRoom     => "Generates a boring giant room the size of your bounding box.",
          },
          name     => 'generator',
          default  => $DEFAULT_GENERATOR,
          choices  => [@GENERATORS] },

        { mnemonic => "Generator _Plugins: ", z=>3,
          type     => "choices",
          desc     => "The plugins you wish to use after the map is created.",
          descs    => {
              BasicDoors => 'Adds doors using various strategies.',
              FiveSplit  => 'Divides map tiles with tiles larger than 5 units into tiles precisely 5 units square.  E.g., if the tile size is set to 10, this will double the bounding box size of your map.',
          },
          name     => 'generator_plugins',
          disable  => { FiveSplit => {tile_size => sub { ($_[0]/5) !~ m/\./ }} },
          defaults => [@DEFAULT_GENERATOR_PLUGINS],
          choices  => [@GENERATOR_PLUGINS] },

        { mnemonic => "_Sparseness: ",
          type     => "text",
          desc     => "The number of times to repeat the remove-dead-end-tile step in James Buck's generator algorithm.",
          name     => 'sparseness',
          default  => 10,
          disable  => { generator => sub { not {Basic=>1, SparseAndLoops=>1}->{$_[0]} } },
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^(?:\d{1,2}|100)$/] },

        { mnemonic => "Same Way Percent:",
          type     => "text",
          desc     => "While digging out the perfect maze, this is the percent chance of digging in the same direction as last time each time we visit the node.",
          name     => 'same_way_percent',
          default  => 90,
          disable  => { generator => sub { not {Basic=>1, Perfect=>1, SparseAndLoops=>1}->{$_[0]} } },
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^(?:\d{1,2}|100)$/] },

        { mnemonic => "Same Node Percent:",
          type     => "text",
          desc     => "While digging out the perfect maze, this is the percent chance of restarting the digging in the same place on each iteration.",
          name     => 'same_node_percent',
          default  => 30,
          disable  => { generator => sub { not {Basic=>1, Perfect=>1, SparseAndLoops=>1}->{$_[0]} } },
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^(?:\d{1,2}|100)$/] },

        { mnemonic => "Remove Dead-End Percent:",
          type     => "text",
          desc     => "Like sparseness but tries harder to remove dead-end corridors completely.",
          name     => 'remove_deadend_percent',
          default  => 60,
          disable  => { generator => sub { not {Basic=>1, SparseAndLoops=>1}->{$_[0]} } },
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^(?:\d{1,2}|100)$/] },

    ]];

    $this->modify_generate_opts_form if $this->can("modify_generate_opts_form");

    my $extra_buttons = [
        ['Defaults', $default_restore_defaults, 'Restore default options'],
        ['Auto BB',  sub {
                my ($button, $reref) = @_;
                my $tile_size  = $reref->{tile_size}[0]{extract} or warn "no code ref?";
                my $cell_size  = $reref->{cell_size}[0]{extract} or warn "no code ref?";
                my $five_split = $reref->{generator_plugins}[0]{extract} or warn "no code ref?";
                my $vp_dim     = $this->[VP_DIM];

                $button->signal_connect( clicked => sub {
                    my $ts = $tile_size->();
                    my $cs = [ split "x", $cell_size->() ];
                    my $fs = grep {$_ eq "FiveSplit"} @{ $five_split->() };

                  # warn dump({
                  #     ts => $ts,
                  #     cs => $cs,
                  #     fs => $fs,
                  #     vp => $vp_dim,
                  # });

                    my $m = ( $fs ? $ts/5 : 1 );
                    my $x = int( $vp_dim->[0] / ($cs->[0]*$m) );
                    my $y = int( $vp_dim->[1] / ($cs->[1]*$m) );

                    $reref->{bounding_box}[1]->set_text( join("x", $x, $y) );
                });
            },
            'Generate a bounding box that will fit in the current window without scrolling.'
        ],
    ];

    my ($result, $o) = $this->make_form($this->[WINDOW], $i, $options, $extra_buttons);
    if( $result eq "ok" ) {
        $i->{$_} = $o->{$_} for keys %$o;
        $this->[SETTINGS]{GENERATE_OPTS} = freeze $i;
    }

    return ($result, $o);
}
# }}}
# generate {{{
sub generate {
    my $this = shift;

    my ($result, $settings, $generator, @plugins) = $this->get_generate_opts;

    return unless $result eq "ok";

    $this->[FNAME] = undef;

    $generator = delete $settings->{generator};
    @plugins   = @{ delete $settings->{generator_plugins} };

    my $map;
    REDO: {
        eval {
            $map = $this->[MAP] = new Games::RolePlay::MapGen($settings);
            $map->set_generator($generator);
            $map->add_generator_plugin( $_ ) for @plugins;
            $map->generate; 
        };

        if( $@ ) {
            $this->error($@);
            return $this->blank_map;
        }

        $this->draw_map;
        Gtk2->main_iteration while Gtk2->events_pending;
        Gtk2->main_iteration while Gtk2->events_pending;
        redo REDO if ask Gtk2::Ex::Dialogs::Question(text=>"Re-generate?", default_yes=>TRUE, parent_window=>$this->[WINDOW]);
    }
    $map;
}
# }}}
# render_settings {{{
sub render_settings {
    my $this = shift;

    my $options = [[
        { mnemonic => "Cell Size: ",
          type     => "text",
          desc     => "The size of each tile in the image (in pixels)",
          name     => 'cell_size',
          default  => '23x23',
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+x\d+$/] },
    ]];

    my $i = $this->[SETTINGS]{GENERATE_OPTS};
       $i = thaw $i if $i;
       $i = {} unless $i;

    my ($result, $o) = $this->make_form($this->[WINDOW], $i, $options);
    return unless $result eq "ok";

    if($i->{cell_size} ne $o->{cell_size}) {
        $this->[MAP]{$_} = $i->{$_} = $o->{$_} for keys %$o;
        $this->[SETTINGS]{GENERATE_OPTS} = freeze $i;
        $this->draw_map;
    }
}
# }}}
# preferences {{{
sub preferences {
    my $this = shift;

    my $i = {
        REMEMBER_SP => $this->[SETTINGS]{REMEMBER_SP},
        LOAD_LAST   => $this->[SETTINGS]{LOAD_LAST},
    };

    my $options = [[
        { mnemonic => "Load Last: ",
          type     => "bool",
          desc     => "Re-load the last map when the GRM Editor opens?",
          name     => 'LOAD_LAST',
          default  => 0, },

        { mnemonic => "Remember Size: ",
          type     => "bool",
          desc     => "Remember the Size of your window from the last run?",
          name     => 'REMEMBER_SP',
          default  => 1 },
    ]];

    my ($result, $o) = $this->make_form($this->[WINDOW], $i, $options);
    return unless $result eq "ok";
    $this->[SETTINGS]{$_} = $o->{$_} for keys %$o;
}
# }}}

# about {{{
sub about {
    my $this = shift;

    my $license = "LGPL -- attached to the GRM distribution";
    eval 'use Software::License::LGPL_2_1; $license = (Software::License::LGPL_2_1->new({holder=>"Paul Miller"}))->fulltext';
    warn "error loading license: $@" if $@;

    Gtk2->show_about_dialog($this->[WINDOW],

        'program-name' => "GRM Editor",
        license        => $license,
        authors        => ['Paul Miller <jettero@cpan.org>'],
        copyright      => 'Copyright (c) 2008 Paul Miller',
        comments       =>
        "This is part of the Games::RolePlay::MapGen (GRM) Distribution.
         You can use it in your own projrects with few restrictions.
         Use at your own risk.  Designed for fun.  Have fun.",
    );
}
# }}}

# unknown_menu_callback {{{
sub unknown_menu_callback {
    my $this = shift;

    warn "unknown numeric callback: @_";
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

    if( $this->[SETTINGS]{REMEMBER_SP} and my $sp = $this->[SETTINGS]{MAIN_SIZE_POS} ) {
        my ($w,$h,$x,$y) = @{thaw $sp};

      # warn "setting window params: ($w,$h,$x,$y)";

        $this->[WINDOW]->resize( $w,$h );
      # $this->[WINDOW]->set_position( $x,$y ); # TODO: this takes single scalars like "center" ... do we really want this anyway?
    }

    $this->[WINDOW]->show_all;

    if( $this->[SETTINGS]{LOAD_LAST} and my $f = $this->[SETTINGS]{LAST_FNAME} ) {
        $this->read_file($f) if -f $f;
    }

    Gtk2->main;
}
# }}}
 
# marea_motion_notify_event {{{
sub marea_motion_notify_event {
    my ($this,$s_co,undef,$em) = @_;

    my ($x, $y) = ($em->x, $em->y);
    my @cs = split 'x', $this->[MAP]{cell_size};
    my @lt = (int($x/$cs[0]), int($y/$cs[1]));

    my $o_lt = $this->[O_LT];
    if( @$o_lt!=2 or ($lt[0] != $o_lt->[0] or $lt[1] != $o_lt->[1]) ) {
        my @bb = split 'x', $this->[MAP]{bounding_box};

        $lt[0] = $bb[0]-1 if $lt[0]>=$bb[0];
        $lt[1] = $bb[1]-1 if $lt[1]>=$bb[1];

        $s_co->(@$o_lt = @lt);
    }
}
# }}}
