#!/usr/bin/perl

use strict;
use strict;
use Glib qw(TRUE FALSE);
use Gtk2 -init; # -init tells import to ->init() your app
use Data::Dump qw(dump);

my $vbox = new Gtk2::VBox;
my $window = new Gtk2::Window("toplevel");
   $window->signal_connect( delete_event => sub { Gtk2->main_quit } );
   $window->add($vbox);

my $button = Gtk2::Button->new_with_label("test");
   $button->signal_connect( clicked => sub {
       my $cp = new Gtk2::ColorSelectionDialog("test color");
          $cp->set_default_response("ok");
        # $cp->colorsel->set_current_color("0000aa"); # has to be a gdk color
          $cp->show;

       my $res = $cp->run;

       if( $res eq "ok" ) {
           my $c = $cp->colorsel->get_current_color;
           my $t = $c->to_string;

           $button->set_label($t);
           print dump({res=>$res, c=>$c, t=>$t}), "\n";
       }

       $cp->destroy;
   });

$vbox->add($button);
$window->show_all;
Gtk2->main;
