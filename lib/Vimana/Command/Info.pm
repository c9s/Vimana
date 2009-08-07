package Vimana::Command::Info;
use warnings;
use strict;
use base qw(App::CLI::Command);

sub options {
    ();
}


sub run {
    my ( $self, $package ) = @_;
    my $index = Vimana->index;
    my $info = $index->find_package( $package );
    require Vimana::VimOnline::ScriptPage;

    my $script_info = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} ) ;
    Vimana::VimOnline::ScriptPage->display( $script_info );


}



1;
