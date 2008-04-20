# vi:syntax=perl:

package Games::RolePlay::MapGen::Editor;

use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app
use Gtk2::Ex::Simple::Menu;
use Gtk2::Ex::Dialogs::ErrorMsg;
use Gtk2::SimpleList;
use Games::RolePlay::MapGen;
use User;
use File::Spec;
use DB_File;
use Storable qw(freeze thaw);
use Data::Dump qw(dump);

our $DEFAULT_GENERATOR         = 'Basic';
our @GENERATORS                = (qw( Basic Blank OneBigRoom Perfect SparseAndLoops ));
our @GENERATOR_PLUGINS         = (qw( BasicDoors FiveSplit ));
our @DEFAULT_GENERATOR_PLUGINS = (qw( BasicDoors ));
our @FILTERS                   = (qw( BasicDoors FiveSplit ClearDoors ));

use constant {
    MAP      => 0,
    WINDOW   => 1,
    SETTINGS => 2,
    MENU     => 3,
    MAREA    => 4,
    FNAME    => 5,
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

    $this->[SETTINGS] = \%o;

    my $vbox = new Gtk2::VBox;
    my $window = $this->[WINDOW] = new Gtk2::Window("toplevel");
       $window->signal_connect( delete_event => sub { $this->quit } );
       $window->set_size_request(200,200); # TODO: should be persistant
       $window->set_position('center');    # TODO: should be persistant
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
                Separator => {
                    item_type => '<Separator>',
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
                '_Render Settings'=> {
                    callback    => sub { $this->render_settings },
                    accelerator => '<ctrl>P',
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
              # _Help => {
              #     item_type    => '<StockItem>',
              #     accelerator  => '<ctrl>H',
              #     extra_data   => 'gtk-help',
              # },
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
    my $vp    = Gtk2::Viewport->new (undef,undef);

    $scwin->add($vp);
    $vp->add($marea);
    $vbox->pack_start($scwin,1,1,0);

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
        $this->[FNAME] = $file_chooser->get_filename;

        # TODO: in order for this to work right, I think we need a custom signal
        # so we can return to gtk (letting the destroy happen) and come back to
        # draw the dialog and load the file... moan

        $file_chooser->destroy;
        Gtk2->main_iteration while Gtk2->events_pending;
        Gtk2->main_iteration while Gtk2->events_pending;
        $this->save_file;

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

    my $loader = Gtk2::Gdk::PixbufLoader->new;
       $loader->write($image->png);
       $loader->close;

    $this->[MAREA]->set_from_pixbuf($loader->get_pixbuf)
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
# generate_form {{{
sub generate_form {
    my $this = shift;
    my ($i, $options) = @_;

    my $dialog = new Gtk2::Dialog("Map Generation Options", $this->[WINDOW], [], 'gtk-cancel' => "cancel", 'gtk-ok' => "ok");
    my $table = Gtk2::Table->new(scalar @{$options->[0]}*2, scalar @$options, FALSE);

    my $c_n = 0;
    my @req;
    for my $column (@$options) {
        my $y = 0;

        for my $item (@$column) {
            my $x = 2*$c_n;

            my $label = Gtk2::Label->new_with_mnemonic($item->{mnemonic} || die "no mnemonic?");
               $label->set_alignment(1, 0.5);

            my $my_req = @req;

            my $entry;
            my $z = 1;
            if( $item->{type} eq "text" ) {
                $entry = new Gtk2::Entry;
                $entry->set_text($i->{$item->{name}} || $item->{default})
                    if exists $item->{default} or exists $i->{$item->{name}};

                $entry->signal_connect(changed => sub {
                    my $text = $entry->get_text;
                    my $chg = 0;
                    for my $fix (@{ $item->{fixes} }) {
                        $chg ++ if $fix->($text);
                    }
                    $entry->set_text($text) if $chg;
                    $req[$my_req] = 1;
                    for my $match (@{ $item->{matches} }) {
                        $req[$my_req] = 0 unless $text =~ $match;
                    }

                    $dialog->set_response_sensitive( ok => (@req == grep {$_} @req) );
                });
                 
                $item->{extract} = sub { $entry->get_text };

            } elsif( $item->{type} eq "choice" ) {
                $entry = Gtk2::ComboBox->new_text;
                my $d = $i->{$item->{name}} || $item->{default};
                my $i = 0;
                my $d_i;
                for(@{$item->{choices}}) {
                    $entry->append_text($_);
                    $d_i = $i if $_ eq $d;
                    $i++;
                }
                $entry->set_active($d_i) if defined $d_i;

                $item->{extract} = sub { $entry->get_active_text };

            } elsif( $item->{type} eq "choices" ) {
                my $def = $i->{$item->{name}};
                   $def = $item->{defaults} unless $def;
                   $def = {map {($_=>1)} @$def};

                my $d = $item->{choices};
                my @s = grep {$def->{$d->[$_]}} 0 .. $#$d;
                my $slist = Gtk2::SimpleList->new( plugin_name_unseen => "text" );
                   $slist->set_headers_visible(FALSE);
                   $slist->set_data_array($d);
                   $slist->get_selection->set_mode('multiple');
                   $slist->select( @s );

                # NOTE: $slist->{data} = $d -- doesn't work !!!! fuckers you
                # have to use @{$slist->{data}} = @$d, so I chose to just use
                # the set_data_array() why even bother trying to do the scope
                # hack... pfft.

                $entry = Gtk2::ScrolledWindow->new;
                $entry->set_policy ('automatic', 'automatic');
                $entry->add($slist);

                $z = (exists $item->{z} ? $item->{z} : 2);

                $item->{extract} = sub { [map {$d->[$_]} $slist->get_selected_indices] };
            }

            $label->set_mnemonic_widget($entry);
            $table->attach_defaults($label, $x, $x+1, $y, $y+1);  $x ++;
            $table->attach_defaults($entry, $x, $x+1, $y, $y+$z); $y += $z;
        }

        $c_n ++;
    }

    $dialog->vbox->pack_start($table,0,0,4);
    $dialog->set_response_sensitive( ok => TRUE );
    $dialog->show_all;

    my ($ok_button) = grep {$_->can("get_label") and $_->get_label =~ m/ok/} $dialog->action_area->get_children;
    if( $ok_button )  {
        # set_default_response() doesn't seem to be enough oomph...
        # It sets the ok button default, but lets the first entry in the Table get the actual focus
        $ok_button->grab_focus;

    } else {
        # This is better than nothing if we can't find the ok button with the grep...
        # It makes it so OK is selected when we tab to the action area.
        # (We're likely to always find the ok button, but for edification purposes,
        #  this is what we'd do if we didn't...)
        $dialog->set_default_response('ok');
    }

    my $o = {};
    my $r = $dialog->run;

    if( $r eq "ok" ) {
        for my $c (@$options) {
            for my $r (@$c) {
                $o->{$r->{name}} = $r->{extract}->();
            }
        }
    }

    $dialog->destroy;
    return ($r,$o);
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
          name     => 'tile_size',
          default  => 10, # NOTE: fixes and matches must exist and must be arrrefs
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+$/] },

        { mnemonic => "_Cell Size: ",
          type     => "text",
          name     => 'cell_size',
          default  => '23x23',
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+x\d+$/] },

        { mnemonic => "_Bounding Box: ",
          type     => "text",
          name     => 'bounding_box',
          default  => '20x20',
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^\d+x\d+$/] },

        { mnemonic => "_Number of Rooms: ",
          type     => "text",
          name     => 'num_rooms',
          default  => '2d4',
          fixes    => [sub { $_[0] =~ s/\s+//g }],
          matches  => [qr/^(?:\d+|\d+d\d+|\d+d\d+[+-]\d+)$/] },

    ], [ # column 2

        { mnemonic => "_Generator: ",
          type     => "choice",
          name     => 'generator',
          default  => $DEFAULT_GENERATOR,
          choices  => [@GENERATORS] },

        { mnemonic => "Generator _Plugins: ",
          type     => "choices",
          name     => 'generator_plugins',
          defaults => [@DEFAULT_GENERATOR_PLUGINS],
          choices  => [@GENERATOR_PLUGINS] },

    ]];

    my ($result, $o) = $this->generate_form($i, $options);
    if( $result eq "ok" ) {
        $this->[SETTINGS]{GENERATE_OPTS} = freeze $o;
    }

    return ($result, $o);
}
# }}}
# generate {{{
sub generate {
    my $this = shift;

    $this->[FNAME] = undef;

    my ($result, $settings, $generator, @plugins) = $this->get_generate_opts;

    return unless $result eq "ok";

    $generator = delete $settings->{generator};
    @plugins   = @{ delete $settings->{generator_plugins} };

    my $map;
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
    $map;
}
# }}}

# about {{{
sub about {
    my $this = shift;

    Gtk2->show_about_dialog($this->[WINDOW],

        'program-name' => "GRM Editor",
        license        => "LGPL -- attached to the GRM distribution",
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

    if( my $sp = $this->[SETTINGS]{MAIN_SIZE_POS} ) {
        my ($w,$h,$x,$y) = @{thaw $sp};

      # warn "setting window params: ($w,$h,$x,$y)";

        $this->[WINDOW]->resize( $w,$h );
      # $this->[WINDOW]->set_position( $x,$y ); # TODO: this takes single scalars like "center" ... lame
    }

    $this->[WINDOW]->show_all;

    if( $this->[SETTINGS]{LOAD_LAST} and my $f = $this->[SETTINGS]{LAST_FNAME} ) {
        $this->read_file($f) if -f $f;
    }

    Gtk2->main;
}
# }}}
