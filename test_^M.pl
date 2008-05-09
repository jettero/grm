#!/usr/bin/perl

use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app

my $window = new Gtk2::Window("toplevel");
my $vbox   = new Gtk2::VBox;
my $button = new Gtk2::Button("Choose");
my $label  = new Gtk2::Label("n/a");

$window->set_size_request(300,100);
$window->signal_connect( delete_event => sub { $window->quit } );
$window->add($vbox);
$vbox->add($button);
$vbox->add($label);

$button->signal_connect( clicked => sub {
    my $file_chooser = Gtk2::FileChooserDialog->new("Test", $window, 'open', 'gtk-cancel' => 'cancel', 'gtk-ok' => 'ok');
       $file_chooser->set_default_response('ok');

    if( $file_chooser->run eq "ok" ) {
        my $filename = $file_chooser->get_filename;
        $label->set_text( $filename );
    }

    $file_chooser->destroy;
});

$window->show_all;

Gtk2->main;
