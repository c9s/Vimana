use warnings;
use strict;
package Vimana::Command::Install;
use base qw(App::CLI::Command);
use URI;
use LWP::Simple qw();
use File::Temp qw(tempdir);
use Moose;

require Vimana::VimOnline;
require Vimana::VimOnline::ScriptPage;
use Vimana::AutoInstall;
use Vimana::Logger;
use Vimana::PackageFile;

sub options {
    (
        'd|dry-run'           => 'dry_run',
        'v|verbose'           => 'verbose',
        'y|yes'               => 'assume_yes',
        'ai|auto-install'     => 'auto_install',
        'pi|port-install'     => 'port_install',
        'mi|makefile-install' => 'makefile_install',
    );
}


sub run {
    my ( $self, $package ) = @_;

    my $index = Vimana->index();
    my $info = $index->find_package( $package );

    unless( $info ) {
        $logger->error("Can not found package: $package");
        return 0;
    }

    my $page = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} );

    my $dir = '/tmp' || tempdir( DIR => '/tmp' );

    my $url = $page->{DOWNLOAD};
    my $filename = $page->{FILENAME};
    my $target = File::Spec->join( $dir , $filename );

    $logger->info("Download from: $url");;

    my $pkgfile = Vimana::PackageFile->new(
        file => $target,
        url => $url,
        info => $info ,
        page_info => $page ,
    );

    return unless $pkgfile->download();

    $logger->info("Stored at: $target");

    $pkgfile->detect_filetype();

    if( $pkgfile->is_archive() ) {
        $logger->info("Check if this package contains 'Makefile' file");

        # list arhive file list
        # find Makefile

    }

    $logger->info("Check if we can install this package via port file");
    if( $pkgfile->has_portfile ) {


    }
    else {
        $logger->info( "Can not found port file." );
    }


    $logger->info( "Check if we can auto install this package" );
    my $ret = $pkgfile->auto_install( verbose => $self->{verbose} );
    unless ( $ret ) {
        $logger->warn("Auto-install failed");
        return 0;
    }


    print "Done\n";
}




1;
