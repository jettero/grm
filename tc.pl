#!/usr/bin/perl

use strict;
use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app
use Data::Dump qw(dump);

my $def_color = "#5555aa";

my $vbox = new Gtk2::VBox;
my $window = new Gtk2::Window("toplevel");
   $window->signal_connect( delete_event => sub { Gtk2->main_quit } );
   $window->add($vbox);

my $button = Gtk2::ColorButton->new_with_color(Gtk2::Gdk::Color->new(map {(hex $_)*257} $def_color =~ m/([\d\w]{2})/g));

$vbox->add($button);
$window->show_all;
Gtk2->main;
