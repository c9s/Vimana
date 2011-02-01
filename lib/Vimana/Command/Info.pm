package Vimana::Command::Info;
use warnings;
use strict;
use parent qw(App::CLI::Command);

sub options {
    ();
}


sub run {
    my ( $self, $package ) = @_;
    my $index = Vimana->index;
    my $info = $index->find_package( $package );
    unless ( $info->{script_id} ) {
        warn "No script named $package. Trying $package.vim ..";
        $info = $index->find_package( "$package.vim" );
        die "Unknown script named $package" unless $info;
    }
    require Vimana::VimOnline::ScriptPage;

    my $script_info = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} ) ;
    Vimana::VimOnline::ScriptPage->display( $script_info );
}



1;
