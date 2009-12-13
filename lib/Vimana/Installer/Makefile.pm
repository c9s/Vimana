package Vimana::Installer::Makefile;
use base qw(Vimana::Installer);
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
    return 0;
}

1;
