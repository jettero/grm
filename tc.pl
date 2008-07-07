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

my $button = Gtk2::Button->new_with_label($def_color);
   $button->signal_connect( clicked => sub {
       my $cp = new Gtk2::ColorSelectionDialog("test color");
          $cp->set_default_response("ok");
          $cp->colorsel->set_current_color(Gtk2::Gdk::Color->new(map {(hex $_)*257} $button->get_label =~ m/([\d\w]{2})/g));

       my $res = $cp->run;

       if( $res eq "ok" ) {
           my $c = $cp->colorsel->get_current_color;
           my @rgb = map {int( $c->$_() / 257 )} qw(red green blue);

           $button->set_label( sprintf '#%02x%02x%02x', @rgb );
           print dump({res=>$res, rgb=>\@rgb}), "\n";
       }

       $cp->destroy;
   });

$vbox->add($button);
$window->show_all;
Gtk2->main;
