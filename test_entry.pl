#! /usr/bin/perl

use strict;
use Glib qw/TRUE FALSE/;
use Gtk2 'init';

my $window = Gtk2::Dialog->new('Dialog & Entry Demo',
                              undef,
                              [qw/modal destroy-with-parent/],
                              'gtk-undo'     => 'reject',
			      'gtk-save'     => 'accept',
			      );
			      
$window->set_response_sensitive ('reject', FALSE);
$window->set_response_sensitive ('accept', FALSE);

$window->signal_connect('delete-event'=> sub {Gtk2->main_quit()});
$window->set_position('center-always');

&fill_dialog($window);

$window->show();
Gtk2->main();

sub fill_dialog {

my ($window) = @_;

my $vbox = $window->vbox;
$vbox->set_border_width(5);
	#-------------------------------------
	my $table = Gtk2::Table->new (1, 2, FALSE);
		my $label = Gtk2::Label->new_with_mnemonic("_Value of entry: ");
		#$misc->set_alignment ($xalign, $yalign) 
		$label->set_alignment(1,0.5);
	$table->attach_defaults ($label, 0, 1, 0,1);
		my $entry = Gtk2::Entry->new();
		#get the original value 
		my $ent_orig = &get_init_val();
		$entry->set_text($ent_orig);
		
		 $entry->signal_connect (changed => sub {
		# desensitize the save button if the entry is empty or blank
     			my $text = $entry->get_text;
			$window->set_response_sensitive ('accept', $text !~ m/^\s*$/);
			$window->set_response_sensitive ('reject', TRUE);
      		});
		
		$label->set_mnemonic_widget ($entry);
	$table->attach_defaults($entry,1,2,0,1);
	#---------------------------------------
$vbox->pack_start($table,0,0,4);


	#this is a nifty thing :) from the documentation:
	#response (Gtk2::Dialog, integer) - thus the second element generated during the signal emitting
	#will be the button's name
	$window->signal_connect(response => sub {
		print "YOU CLICKED: ".$_[1]."\n";
		#if the person clicked save, we show a message
		if($_[1] =~ m/accept/){
			my $new_val = $entry->get_text();
			&show_message_dialog($window,'info',"Old value: $ent_orig\nNew value: $new_val");
			Gtk2->main_quit;
		}
		#if the person clicked undo, we reload the original value, and gray out
		#the undo button
		if($_[1] =~ m/reject/){
			$entry->set_text($ent_orig);
			$window->set_response_sensitive ('reject', FALSE);
			$window->set_response_sensitive ('accept', FALSE);
		}
	});

	$vbox->show_all();
return $vbox;
}


sub get_init_val {
	my $init_val = "The_Original_Value";
	return $init_val;
}

sub show_message_dialog {
#you tell it what to display, and how to display it
#$icon can be one of the following:	a) 'info'
#					b) 'warning'
#					c) 'error'
#					d) 'question'
#$text can be pango markup text, or just plain text, IE the message
my ($parent,$icon,$text) = @_;
 
my $dialog = Gtk2::MessageDialog->new_with_markup ($parent,
					[qw/modal destroy-with-parent/],
					$icon,
					'ok',
					sprintf "$text");
				
		$dialog->run;
		$dialog->destroy;
		
}