package Vimana::Command::Upgrade;
use warnings;
use strict;
use base qw(App::CLI::Command);
use Vimana::Record;
use Vimana::Installer;


# XXX: implement this
sub run {
    my ($self,$name) = @_;

    # find installation record.
    # remove old install
    # install new one.
    Vimana::Record->remove( $name );
    Vimana::Installer->install( $name );
}



1;
