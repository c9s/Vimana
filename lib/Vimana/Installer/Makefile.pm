package Vimana::Installer::Makefile;
use base qw(Vimana::Installer);
use Vimana::Logger;
use warnings;
use strict;

sub run {
    my ($self,$pkgfile,$path)=@_;

    my $makefile;
    for(qw(Makefile Makefile.pure)) {
        $makefile = $_ if -e $_ ;
    }
    if ( $make ) {
        $logger->info( "Makefile found. do make install.") ;
        my $ret = system( "make install -f $makefile" );
        return 1 if $ret == 0;
    }

    $logger->error( 'Makefile install failed.' );
    return 0;
}

1;
