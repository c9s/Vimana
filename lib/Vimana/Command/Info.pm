package Vimana::Command::Info;
use warnings;
use strict;
use base qw(App::CLI::Command);

sub options {
    ();
}


sub run {
    my ( $self, $package ) = @_;
    $index = Vimana->index;
    my $info = $index->find_package( $package );
    use Data::Dumper; warn Dumper( $info );
}



1;
