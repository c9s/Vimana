package Vimana::Command::Upgrade;
use warnings;
use strict;
use parent qw(App::CLI::Command);
use Vimana::Record;
use Vimana::Installer;

sub run {
    my ($self,$name) = @_;
    # find installation record.
    # remove old install
    # install new one.

    # XXX: check plugin version.
    Vimana::Record->remove( $name );
    Vimana::Installer->install( $name );
}



1;
