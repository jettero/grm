# vi:syntax=perl:

# NOTE: I'm intending to one day split this module out into something like
# Gtk2::Ex::SimpleOnePageForm It's not finished-enough to release that way, so
# I'm just storing it here until I get further with it.  If you'd like to use
# this elsewhere, lemme know and I'll finish it.
#
# -Paul

package Games::RolePlay::MapGen::Editor::_MForm;

use strict;
use Gtk2;
use Gtk2::SimpleList;
use Glib qw(TRUE FALSE);
use Data::Dump qw(dump);

use base 'Exporter';
our @EXPORT_OK = qw(make_form $default_restore_defaults);
our $default_restore_defaults = sub {
        my ($button, $reref) = @_;

        $button->signal_connect( clicked => sub {
            for my $k (keys %$reref) {
                my ($item, $widget) = @{ $reref->{$k} };

                next unless exists $item->{default} or exists $item->{defaults};

                my $type = $item->{type};
                if( $type eq "choice" or $type eq "bool" ) {
                    my ($d_i) = grep {$item->{choices}[$_] eq $item->{default}} 0 .. $#{ $item->{choices} };
                    $widget->set_active( $d_i );

                } elsif( $type eq "text" ) {
                    $widget->set_text( $item->{default} );

                } elsif( $type eq "choices" ) {
                    my $def = {map {($_=>1)} @{ $item->{defaults} }};
                    my $d = $item->{choices};
                    my @s = grep {$def->{$d->[$_]}} 0 .. $#$d;

                    $widget->get_selection->unselect_all;
                    $widget->select( @s );

                } else { die "no handler for default of type $type" }
            }
        });
    };

sub make_form {
    my $this = shift;
    my ($parent_window, $i, $options, $extra_buttons) = @_;

    my $dialog = new Gtk2::Dialog("Map Generation Options", $parent_window, [], 'gtk-cancel' => "cancel", 'gtk-ok' => "ok");
    my $table = Gtk2::Table->new(scalar @{$options->[0]}*2, scalar @$options, FALSE);

    my $reref = {};

    my $c_n = 0;
    my @req;
    for my $column (@$options) {
        my $y = 0;

        for my $item (@$column) {
            my $x = 2*$c_n;

            my $label = Gtk2::Label->new_with_mnemonic($item->{mnemonic} || die "no mnemonic?");
               $label->set_alignment(1, 0.5);
               $label->set_tooltip_text( $item->{desc} ) if exists $item->{desc};

            my $my_req = @req;

            my ($widget, $attach);
            my $z = 1;
            my $IT = $item->{type};
            if( $IT eq "text" ) {
                $attach = $widget = new Gtk2::Entry;
                $widget->set_text(exists $i->{$item->{name}} ? $i->{$item->{name}} : $item->{default})
                    if exists $item->{default} or exists $i->{$item->{name}};

                $widget->set_tooltip_text( $item->{desc} ) if exists $item->{desc};
                $widget->signal_connect(changed => sub {
                    my $text = $widget->get_text;
                    my $chg = 0;
                    for my $fix (@{ $item->{fixes} }) {
                        $chg ++ if $fix->($text);
                    }
                    $widget->set_text($text) if $chg;
                    $req[$my_req] = 1;
                    for my $match (@{ $item->{matches} }) {
                        $req[$my_req] = 0 unless $text =~ $match;
                    }

                    $dialog->set_response_sensitive( ok => (@req == grep {$_} @req) );
                });

                $item->{extract} = sub { $widget->get_text };
              # $widget->signal_connect(changed => sub { warn "test!"; }); # [WORKS FINE]

            } elsif( $IT eq "choice" ) {
                $attach = $widget = Gtk2::ComboBox->new_text;
                my $d = $i->{$item->{name}} || $item->{default};
                my $i = 0;
                my $d_i;
                for(@{$item->{choices}}) {
                    $widget->append_text($_);
                    $d_i = $i if $_ eq $d;
                    $i++;
                }
                $widget->set_active($d_i) if defined $d_i;
                $widget->set_tooltip_text( $item->{desc} ) if exists $item->{desc};

                $item->{extract} = sub { $widget->get_active_text };
              # $widget->signal_connect(changed => sub { warn "test!"; }); # [WORKS FINE]

                if( exists $item->{descs} and exists $item->{desc} ) {
                    $widget->signal_connect(changed => my $si = sub {
                        if( exists $item->{descs}{ my $at = $widget->get_active_text } ) {
                            $widget->set_tooltip_text( "$at - $item->{descs}{$at}" );

                        } else {
                            $widget->set_tooltip_text( $item->{desc} );
                        }
                    });

                    $si->();
                }

            } elsif( $IT eq "choices" ) {
                my $def = $i->{$item->{name}};
                   $def = $item->{defaults} unless $def;
                   $def = {map {($_=>1)} @$def};

                my $d = $item->{choices};
                my @s = grep {$def->{$d->[$_]}} 0 .. $#$d;

                $widget = Gtk2::SimpleList->new( plugin_name_unseen => "text" );
                $widget->set_headers_visible(FALSE);
                $widget->set_data_array($d);
                $widget->get_selection->set_mode('multiple');
                $widget->select( @s );

                # NOTE: $widget->{data} = $d -- doesn't work !!!! fuckers you
                # have to use @{$widget->{data}} = @$d, so I chose to just use
                # the set_data_array() why even bother trying to do the scope
                # hack... pfft.

                $attach = Gtk2::ScrolledWindow->new;

                my $vp  = Gtk2::Viewport->new;
                $attach->set_policy('automatic', 'automatic');
                $attach->add($vp);
                $vp->add($widget);

                $z = (exists $item->{z} ? $item->{z} : 2);

                $item->{extract} = sub { [map {$d->[$_]} $widget->get_selected_indices] };
              # $widget->get_selection->signal_connect(changed => sub { warn "test!"; }); # [WORKS FINE]

            } elsif( $IT eq "bool" ) {
                $attach = $widget = new Gtk2::CheckButton;
                $widget->set_active(exists $i->{$item->{name}} ? $i->{$item->{name}} : $item->{default})
                    if exists $item->{default} or exists $i->{$item->{name}};

                $widget->set_tooltip_text( $item->{desc} ) if exists $item->{desc};
                $item->{extract} = sub { $widget->get_active ? 1:0 };
              # $widget->signal_connect(toggled => sub { warn "test!"; }); # [WORKS FINE]
            }

            else { die "unknown form type: $item->{type}" }

            $reref->{$item->{name}} = [ $item, $widget ];

            $label->set_mnemonic_widget($widget);
            $table->attach_defaults($label,  $x, $x+1, $y, $y+1);  $x ++;
            $table->attach_defaults($attach, $x, $x+1, $y, $y+$z); $y += $z;
        }

        $c_n ++;
    }

    for my $column (@$options) {
        for my $item (@$column) {
            if( my $d = $item->{disable} ) {
                my $this_e = $reref->{$item->{name}};
                my $this_type = $this_e->[0]{type};

                unless( $this_type eq "choice" or $this_type eq "text" ) {
                    warn "not prepared to deal with TreeViews in the disable code (yet) ... skipping";
                    next
                }

                for my $k (keys %$d) {
                    my $that_e = $reref->{$k};
                    my $that_type = $that_e->[0]{type};

                    if( $that_type eq "choice" or $that_type eq "text") {
                        $that_e->[1]->signal_connect( changed => my $f = sub {
                            my $sensitive = ($d->{$k}->( $that_e->[0]{extract}->() ) ? FALSE : TRUE);
                             
                            $this_e->[1]->set_sensitive($sensitive)
                        });

                        $f->();
                    }
                    
                    else { die "unhandled disabler: $k/$that_type" }
                }
            }
    }}

    if( ref $extra_buttons ) {
        for my $eba (@$extra_buttons) {
            my $aa = $dialog->action_area;
            my $button = new Gtk2::Button($eba->[0]);
               $button->set_tooltip_text($eba->[2]) if defined $eba->[2];

            $aa->add( $button );
            $aa->set_child_secondary( $button, TRUE );

            if( ref (my $cb = $eba->[1]) eq "CODE" ) {
                $cb->( $button, $reref );
            }
        }
    }

    $dialog->vbox->pack_start($table,0,0,4);
    $dialog->set_response_sensitive( ok => TRUE );
    $dialog->show_all;

    my ($ok_button) = grep {$_->can("get_label") and $_->get_label =~ m/ok/} $dialog->action_area->get_children;

    # This is better than nothing if we can't find the ok button with the grep...
    # It makes it so OK is selected when we tab to the action area.
    # (We're likely to always find the ok button, but for edification purposes,
    #  this is what we'd do if we didn't...)
    # Second thought, let's just set this anyway...
    $dialog->set_default_response('ok');

    if( $ok_button )  {
        # set_default_response() doesn't seem to be enough oomph...
        # It sets the ok button default, but lets the first entry in the Table get the actual focus
        $ok_button->grab_focus;
    }

    my $o = {};
    my $r = $dialog->run;

    if( $r eq "ok" ) {
        for my $c (@$options) {
            for my $e (@$c) {
                if( $reref->{$e->{name}}[1]->is_sensitive() ) {

                    $o->{$e->{name}} = $e->{extract}->();
                }
            }
        }
    }

    ## DEBUG ## warn dump($r, $o);

    $dialog->destroy;
    return ($r,$o);
}
