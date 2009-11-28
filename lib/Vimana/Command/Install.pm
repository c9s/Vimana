use warnings;
use strict;
package Vimana::Command::Install;
use base qw(App::CLI::Command);
use URI;
use LWP::Simple qw();

require Vimana::VimOnline;
require Vimana::VimOnline::ScriptPage;
use Vimana::Record;
use Vimana::AutoInstall;
use Vimana::VimballInstall;
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


use Vimana::Installer::Meta;
use Vimana::Installer::Makefile;
use Vimana::Installer::Auto;

# XXX: mv this method into Vimana::Installer , maybe
sub get_installer {
    my ( $self, $type, @args ) = @_;
    my $class = qq{Vimana::Installer::$type};
    return $class->new(@args);
}




sub install_text_type_ {
    my ($self, $pkgfile) = @_;

    if( $pkgfile->is_vimball ) {
        $logger->info("Found Vimball File");
        my $install = Vimana::VimballInstall->new({ package => $pkgfile });
        $install->run();
        return 1;
    }

    # guess text filetype here.  (colorscheme, ftplugin ...etc)

    return 0;
}

sub install_archive_type {
    my ($self, $pkgfile) = @_;
    my $files = $pkgfile->archive_files();

    my $ret;
    # find meta file
    $logger->info("Check 'META' or 'VIMMETA' file for VIM::Packager.");
    if( $pkgfile->has_metafile ) {
        # ensure that we have VIM::Packager installed.

        $ret = $self->metafile_install( $pkgfile );

        return $ret if $ret;
    }

    # find Makefile
    $logger->info("Check Makefile.");
    if( $pkgfile->has_makefile() ) {
        $ret = $pkgfile->makefile_install(); # XXX: mv this method out

        return $ret if $ret;
    }

    $logger->info( "Check detect directory structure." );
    my $ret = $pkgfile->auto_install( verbose => $self->{verbose} );
    return $ret if $ret;

    $logger->warn("Install failed");
    $logger->warn("Reason: package doesn't contain META,VIMMETA,VIMMETA.yml or Makefile file");
    $logger->warn("Vimana does not know how to install this package");
    return 0;

    # add record:
    # Vimana::Record->add( {
    #     cname => $pkgfile->cname,
    #     url  => $pkgfile->url,
    #     filetype => $pkgfile->filetype,
    #     files => $files,
    # });
}


sub run {
    my ( $self, $package ) = @_;  # $package is a canonicalized name

    # XXX: check if we've installed this package

    # XXX: check if package files conflict

    my $info = Vimana->index->find_package( $package );

    unless( $info ) {
        $logger->error("Can not found package: $package");
        return 0;
    }

    my $page = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} );

    my $dir = '/tmp' || Vimana::Util::tempdir();

    my $url = $page->{download};
    my $filename = $page->{filename};
    my $target = File::Spec->join( $dir , $filename );

    $logger->info("Download from: $url");;

    my $pkgfile = Vimana::PackageFile->new( {
            cname      => $package,
            file      => $target,
            url       => $url,
            info      => $info,
            page_info => $page,
    } );

    return unless $pkgfile->download();

    $logger->info("Stored at: $target");

    $pkgfile->detect_filetype();
    $pkgfile->preprocess( );

=pod

    4. guess what to do

       if it's archive file:
        * have vim meta file ?
        * have makefile ?
        * check directory structure
        * others

       if it's text file:
        * vimball
        * dont know ?
           * check script_type 
           * inspect text content
            - known format:
            * do install
=cut

    # if it's vimball, install it
    my $ret;
    if( $pkgfile->is_text ) {
        $ret = $self->install_text_type( $pkgfile );

    }
    elsif( $pkgfile->is_archive ) {
        $ret = $self->install_archive_type( $pkgfile );
    }

    unless( $ret ) {
        print "FAIL\n";
        exit 1;
    }

    print "Done\n";
}




1;
