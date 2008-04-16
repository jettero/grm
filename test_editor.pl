#!/usr/bin/perl
use warnings;
use strict;
use Glib qw/TRUE FALSE/;
use Gtk2 -init;

# this is what you probably want to use a a general
# method. It uses a configure and expose event on
# the drawing area, so that you can resize the mainwindow
# and have the pixmap recreated and set again as a
# background pixmap. However, this does erase what
# was shown before the reconfigure, so before I do
# any drawing, I make the main window non-resizeable
# in the sub draw{}. This is useful if you want to
# use the pixmap to draw a graph, which requires 
# x-y scaling, or persistence of data.
# Without a size freeze, you would need to save the
# plotted data and replot it after a configure event,
# according to the new scale.


# gtk2 pixmaps (on linux ?) have a current limit 
# of short unsigned INT , highest pixels is 
# 32767 is (8bit int max) -1     
my $xsize = 2400; # maxsize = 32767
my $ysize = 100;
my $xsizenew;
my $ysizenew;

my $pixmap     = undef;
my $gc         = undef;
my $colormap   = undef;
 
my %allocated_colors;
my ($x0,$y0,$x1,$y1,$width,) = (0,0,0,0);

# Create the window
my $window = new Gtk2::Window ( "toplevel" );
$window->signal_connect ("delete_event", sub { Gtk2->main_quit; });
$window->set_border_width (10);
$window->set_size_request(640,480);
$window->set_position('center');

my $vbox = Gtk2::VBox->new( 0, 0 );
$window->add($vbox);
$vbox->set_border_width(2);

my $hbox = Gtk2::HBox->new( 0, 0 );
$vbox->pack_start($hbox,1,1,0);
$hbox->set_size_request(320,240);
$hbox->set_border_width(2);

my $hbox1 = Gtk2::HBox->new( 0, 0 );
$vbox->pack_start($hbox1,0,0,0);
$hbox1->set_border_width(2);

my $button1 = Gtk2::Button->new('Draw');
$hbox1->pack_start( $button1, FALSE, FALSE, 2);
$button1->signal_connect( clicked => \&draw);

my $button2 = Gtk2::Button->new('Quit');
$hbox1->pack_start( $button2, FALSE, FALSE, 2);
$button2->signal_connect( clicked => sub{ exit; });

my $button3 = Gtk2::Button->new('Save Viewable');
$hbox1->pack_start( $button3, FALSE, FALSE, 2);
$button3->signal_connect( clicked => \&save_it);

my $button4 = Gtk2::Button->new('Save All');
$hbox1->pack_start( $button4, FALSE, FALSE, 2);
$button4->signal_connect( clicked => \&save_all);

my $scwin = Gtk2::ScrolledWindow->new();
my $ha1  = $scwin->get_hadjustment;
$scwin->set_policy('always','never');

# you would think we could add the DrawingArea directing
# to the scrolled window, so we need a viewport
# typical warning
# Gtk-WARNING **: gtk_scrolled_window_add(): cannot add non 
# scrollable widget use gtk_scrolled_window_add_with_viewport() 
# we create a viewport

my $vp = Gtk2::Viewport->new (undef,undef);
$scwin->add($vp);
$hbox->pack_start($scwin,1,1,0);

# Create the drawing area.
my $area = new Gtk2::DrawingArea; #don't confuse with Gtk2::Drawable
$area->size ($xsize, $ysize);
$vp->add($area);

$area->set_events ([qw/exposure-mask
         	       leave-notify-mask
		       button-press-mask
		       pointer-motion-mask
		       pointer-motion-hint-mask/]);

$area->signal_connect (button_press_event => \&button_press_event);
# Signals used to handle backing pixmap
$area->signal_connect( expose_event    => \&expose_event );
$area->signal_connect( configure_event => \&configure_event );


$window->show_all;

Gtk2->main;
###########################################
sub draw{
 
# get current window size and freeze it, so x y scaling is constant
# in the pixmap
my (undef, undef, $width0, $height0, undef) = $window->window->get_geometry;
$window->set_size_request($width0,$height0);
$window->set_resizable(0);

(undef, undef, $xsizenew, $ysizenew, undef) = $area->window->get_geometry;
print "$xsizenew  $ysizenew\n";

start_drawing($pixmap); 
}
#######################################
sub get_color {
    my ($colormap, $name) = @_;
    my $ret;

    if ($ret = $allocated_colors{$name}) {
        return $ret;
    }

    my $color = Gtk2::Gdk::Color->parse($name);
    $colormap->alloc_color($color,TRUE,TRUE);

    $allocated_colors{$name} = $color;

    return $color;
}
########################################

sub draw_line {
    my($widget,$line,$color) = @_;
   # see Gdk::Gdk::Window, Gtk2::Gdk::Drawable, Gtk2::Gdk::GC

    my $colormap = $widget->get_colormap;

    my $gc = $widget->{gc} || new Gtk2::Gdk::GC $widget;
    $gc->set_foreground(get_color($colormap, $color));

    $widget->draw_line($gc, @$line);
}

#######################################

sub draw_rect {
    my($widget,$coords,$color) = @_;
   # see Gdk::Gdk::Window, Gtk2::Gdk::Drawable, Gtk2::Gdk::GC

    my $colormap = $widget->get_colormap;

    my $gc = $widget->{gc} || new Gtk2::Gdk::GC $widget;
    $gc->set_foreground(get_color($colormap, $color));

    $widget->draw_rectangle($gc,1, @$coords);
}

#######################################
sub draw_poly {
    my($widget,$points,$color) = @_;
   # see Gdk::Gdk::Window, Gtk2::Gdk::Drawable, Gtk2::Gdk::GC

    my $colormap = $widget->get_colormap;

    my $gc = $widget->{gc} || new Gtk2::Gdk::GC $widget;
    $gc->set_foreground(get_color($colormap, $color));

    $widget->draw_polygon($gc,1, @$points);
}

########################################
# Draw a line in the expose callback
sub start_drawing {
        my $pixmap = shift;
	
        &draw_line($pixmap, [200,30, 30,100], 'blue');
        &draw_line($pixmap, [0,200, 2400,300], 'pink');
	&draw_poly($pixmap, [10,10,20,20,10,30],'green');
        &draw_rect($pixmap, [100,100,100,130],'pink');         
        &draw_ptext($pixmap);

#without this line the screen won't be updated until a screen action
    $area->queue_draw;                                                      
}
######################################
sub draw_ptext{ 

  my($widget) = @_;
  # see Gdk::Gdk::Window, Gtk2::Gdk::Drawable, Gtk2::Gdk::GC

  my $drawable = $widget;

 my $gc =  new Gtk2::Gdk::GC ($drawable);
 my $pango_layout = $area->create_pango_layout("");
 my $font_desc = Gtk2::Pango::FontDescription->from_string("Arial Bold 14");                          
 $pango_layout->set_font_description($font_desc);        
 $pango_layout->set_markup ("<span foreground=\"yellow1\" 
   size=\"40000\">Label with</span><s><big> Tango </big></s> Pango
   <span background = 'black' foreground= 'green' size ='30000'><i>markup</i></span>");

    $drawable->draw_layout($gc,200,100, $pango_layout);

    my $ts = time;
    $pango_layout->set_markup("<span background = '#000000' foreground = '#FF0000' 
    size = '20000' weight ='heavy'>Exact time:\n</span><span background = '#000000' 
    foreground= '#00FF00' size='30000' weight = 'ultralight'><i><u>$ts</u></i></span>");
    $drawable->draw_layout($gc,200,200, $pango_layout);

    $ts = time;

    $pango_layout->set_markup("<span  foreground = '#FF0000' size = '20000' 
    weight ='heavy'>Exact time:\n</span><span  foreground= '#00FF00' size='30000' weight = 'ultralight'><i><u>$ts</u></i></span>");
    $drawable->draw_layout($gc,300,300, $pango_layout);

# test out of view writing
    $drawable->draw_layout($gc,2000,300, $pango_layout);

#    $area->queue_draw;                                                      
}
#######################################
sub button_press_event {
  my $widget = shift;	# GtkWidget      *widget
  my $event = shift;	# GdkEventButton *event

  if ($event->button == 1) {
    print join ' ', $event->coords,"\n";
  }
  return TRUE;
}
######################################
sub save_it{

my ($width, $height) = $vp->window->get_size();

print "$width $height\n";

# create blank pixbuf to hold the whole viewable area
 my $lpixbuf = Gtk2::Gdk::Pixbuf->new ('rgb',
                    0,
                    8,
                    $width,
                    $height);


 $lpixbuf->get_from_drawable ($vp->window, 
             undef, 0, 0, 0, 0, $width, $height);

 #only jpeg and png is supported !!!! it's 'jpeg', not 'jpg'
 $lpixbuf->save ("$0-area.jpg", 'jpeg', quality => 100);

return FALSE;
}


######################################
sub save_all{

my ($width, $height) = $pixmap->get_size();

print "$width $height\n";

# create blank pixbuf to hold the whole pixmap
 my $lpixbuf = Gtk2::Gdk::Pixbuf->new ('rgb',
                    0,
                    8,
                    $width,
                    $height);


 $lpixbuf->get_from_drawable ($pixmap, 
             undef, 0, 0, 0, 0, $width, $height);

 #only jpeg and png is supported !!!! it's 'jpeg', not 'jpg'
 $lpixbuf->save ("$0-all.jpg", 'jpeg', quality => 100);

return FALSE;
}

##########################################
# Create a new backing pixmap of the appropriate size
sub configure_event {
   my $widget = shift;    # GtkWidget         *widget
   my $event  = shift;    # GdkEventConfigure *event

   $pixmap = Gtk2::Gdk::Pixmap->new(
      $widget->window,
      $widget->allocation->width,
      $widget->allocation->height, -1
   );

   $pixmap->draw_rectangle(
      $widget->style->white_gc,    # or black_gc
      TRUE,
      0, 0,
      $widget->allocation->width,
      $widget->allocation->height
   );

   $gc       = Gtk2::Gdk::GC->new( $pixmap );
   $colormap = $pixmap->get_colormap;

# set a default foreground
   $gc->set_foreground( get_color( $colormap, 'red' ) );

   return TRUE;
}
##########################################
# Redraw the screen from the backing pixmap
sub expose_event {
   my $widget = shift;    # GtkWidget      *widget
   my $event  = shift;    # GdkEventExpose *event

   $widget->window->draw_drawable(
      $widget->style->fg_gc( $widget->state ), $pixmap,
      $event->area->x,                         $event->area->y,
      $event->area->x,                         $event->area->y,
      $event->area->width,                     $event->area->height
   );

   return FALSE;
}

##########################################
