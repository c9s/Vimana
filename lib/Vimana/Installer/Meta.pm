package Vimana::Installer::Meta;
use base qw(Vimana::Installer);
use warnings;
use strict;


sub run {
    my $self = shift;
    my $path = shift;

    # try to require VIM::Packager
    eval(q|require VIM::Packager;|);
    if( $@ ) {
        $logger->info( "It seems you dont have VIM::Packager installed." );
        $logger->info( "meta file can't be translated to makefile." );
        return 0;
    }

    my $ret;
    $ret = system( 'vim-packager build' );

    $ret = system( 'make install' );


}

1;
