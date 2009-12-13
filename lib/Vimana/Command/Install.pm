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
use Vimana::Installer::Text;

# XXX: mv this method into Vimana::Installer , maybe
sub get_installer {
    my ( $self, $type, @args ) = @_;
    $type = ucfirst($type);
    my $class = qq{Vimana::Installer::$type};
    return $class->new( @args );
}


sub check_strategies {
    my $self = shift;
    my $pkg = shift;
    my @sts = @_;
    my @ins_type;
    for my $st ( @sts ) {
        print $st->{name} . ' : ' . $st->{desc} . ' ...';
        my $method = $st->{method};
        if( $pkg->$method ) {
            print " [ found ]\n" ;
            push @ins_type , $st->{installer};
        }
        else {
            print " [ not found ]\n";
        }
    }
    return @ins_type;
}

sub install_archive_type {
    my ($self, $pkgfile) = @_;

    # extract to a path 
    my $tmpdir = Vimana::Util::tempdir();

    $logger->info( "Extracting to $tmpdir." );
    $pkgfile->extract_to( $tmpdir );

    # chdir
    $logger->info("Changing directory to $tmpdir.");
    chdir $tmpdir;

    my $files = $pkgfile->archive_files();

    my $ret;
    my @ins_type = $self->check_strategies( $pkgfile ,
        {
            name => 'Meta',
            desc => q{Check if 'META' or 'VIMMETA' file exists. support for VIM::Packager.},
            installer => 'meta',
            method => 'has_metafile',
        },
        {
            name => 'Makefile',
            desc => q{Check if makefile exists.},
            installer => 'Makefile',
            method => 'has_makefile',
        },
        {
            name => 'Rakefile',
            desc => q{Check if rakefile exists.},
            installer => 'Rakefile',
            method => 'has_rakefile',
        },
    );

    if( @ins_type == 0 ) {
        $logger->warn( "Package doesn't contain META,VIMMETA,VIMMETA.yml or Makefile file" );
        $logger->info( "No availiable strategy, try to auto-install." );
        push @ins_type,'auto';
    }
    

DONE:
    for my $ins_type ( @ins_type ) {
        my $installer = $self->get_installer( $ins_type , { package => $pkgfile } );
        $ret = $installer->run( $tmpdir );

        last DONE if $ret;  # succeed
        last DONE if ! $installer->_continue;  # not succeed, but we should continue other installation.
    }

    unless( $ret ) {
        $logger->warn("Installation failed.");

        $logger->warn("Vimana does not know how to install this package");
        return $ret;
    }

    $logger->info( "Succeed." );
    return $ret;

    # add record:
    # Vimana::Record->add( {
    #     cname => $pkgfile->cname,
    #     url  => $pkgfile->url,
    #     filetype => $pkgfile->filetype,
    #     files => $files,
    # });
}


sub run {
    my ( $self, $package ) = @_; 
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

    $logger->info("Downloading from: $url");;

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


    # if it's vimball, install it
    my $ret;
    if( $pkgfile->is_text ) {
        my $installer = $self->get_installer('text' , { package => $pkgfile });
        $ret = $installer->run( $pkgfile );
    }
    elsif( $pkgfile->is_archive ) {
        $ret = $self->install_archive_type( $pkgfile );
    }

    unless( $ret ) {
        print "Installation Failed.\n";
        exit 1;
    }

    print "Installation Done.\n";
}




1;
