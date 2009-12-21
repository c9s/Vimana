package Vimana::Command::Remove;
use base qw(App::CLI::Command);
use Vimana::Logger;
use Vimana::PackageFile;

sub options { ( 'v|verbose'           => 'verbose') }

sub run {
    my ( $self, $package ) = @_;
    # my $index = Vimana->index();
    # my $info = $index->find_package( $package );

}

1;
