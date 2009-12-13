package Vimana::Installer::Makefile;
use base qw(Vimana::Installer);
use Vimana::Logger;
use warnings;
use strict;

sub run {
    my $self = shift;
    my $path = shift;
    if ( -e "Makefile" or -e 'makefile' ) {
        $logger->info( "Makefile found. do make install.") ;
        my $ret = system( "make install" );
        return 1 if $ret == 0;
    }

    $logger->error( 'Makefile install failed.' );
    return 0;
}

1;
