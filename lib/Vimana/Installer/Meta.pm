package Vimana::Installer::Meta;
use parent qw(Vimana::Installer);
use Vimana::Logger;
use warnings;
use strict;

use constant _continue => 1;

sub run {
    my ($self,$pkgfile,$path)=@_;

    # try to require VIM::Packager
    eval { require VIM::Packager; };
    if( $@ ) {
        $logger->info( "It seems you don't have VIM::Packager installed." );
        $logger->info( "meta file can't be translated to makefile." );
        return 0;
    }

    my $ret;
    $ret = system( 'vim-packager build' );

    return 0 if $ret != 0;

    $ret = system( 'make install -f Makefile.vimp' );
    return 1 if $ret == 0;
}

1;
