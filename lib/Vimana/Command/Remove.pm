package Vimana::Command::Remove;
use base qw(App::CLI::Command);
use Vimana::Logger;
use Vimana::PackageFile;

sub options { ( 'v|verbose'           => 'verbose') }

sub run {
    my ( $self, $package ) = @_;
    Vimana::Record->remove( $package );
}

1;
