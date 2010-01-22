use warnings;
use strict;
package Vimana::Command::Install;
use base qw(App::CLI::Command);
use URI;
use LWP::Simple qw();

require Vimana::VimOnline;
require Vimana::VimOnline::ScriptPage;
use Vimana::Record;
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
use Vimana::Installer::Rakefile;
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
    my ($self,@sts) = @_;
    my @ins_type;
    for my $st ( @sts ) {
        print $st->{name} . ' : ' . $st->{desc} . ' ...';
        my $deps = $st->{deps};
        my $found;
NEXT_TYPE:
        for ( @$deps ) {
            if ( -e $_ ) {
                push @ins_type , $st->{installer};
                $found = 1;
                last NEXT_TYPE;
            }
        }
        print $found ? "[found]\n" : "[not found]\n";
    }
    return @ins_type;
}

sub install_archive_type {
    my ($self, $pkgfile) = @_;

    # extract to a path 
    my $tmpdir = Vimana::Util::tempdir();

    $logger->info( "Extracting to $tmpdir." );
    $pkgfile->extract_to( $tmpdir );
    $logger->info("Changing directory to $tmpdir.");

    chdir $tmpdir;
    return $self->install_by_strategy( $pkgfile, $tmpdir , { cleanup => 1 } );
}

sub install_by_strategy {
    my ($self,$pkgfile,$tmpdir,$args) = @_;
    my $ret;
    my @ins_type = $self->check_strategies( 
        {
            name => 'Meta',
            desc => q{Check if 'META' or 'VIMMETA' file exists. support for VIM::Packager.},
            installer => 'Meta',
            deps =>  [qw(VIMMETA META)],
        },
        {
            name => 'Makefile',
            desc => q{Check if makefile exists.},
            installer => 'Makefile',
            deps => [qw(makefile Makefile)],
        },
        {
            name => 'Rakefile',
            desc => q{Check if rakefile exists.},
            installer => 'Rakefile',
            deps => [qw(rakefile Rakefile)],
        });

    if( @ins_type == 0 ) {
        $logger->warn( "Package doesn't contain META,VIMMETA,VIMMETA.yml or Makefile file" );
        $logger->info( "No availiable strategy, try to auto-install." );
        push @ins_type,'auto';
    }
    
DONE:
    for my $ins_type ( @ins_type ) {
        my $installer = $self->get_installer( $ins_type , { args => $args } );
        $ret = $installer->run( $pkgfile, $tmpdir );

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
}

sub stdlize_uri {
    my $uri = shift;
    if( $uri =~ s{^(git|svn):}{} )  { 
        return $1,$uri;
    }
    return undef;
}


sub run {
    my ( $self, $arg ) = @_; 
    # XXX: check if we've installed this package
    # XXX: check if package files conflict
    if (  $arg =~ m{^git:} or $arg =~ m{^svn:} ) {
        my ( $rcs, $uri ) = stdlize_uri $arg;
        my $dir = Vimana::Util::tempdir();
        my $cmd;
        if( $rcs eq 'git' )  { 
            $cmd = 'git clone';
        }
        elsif( $rcs eq 'svn' ) {
            $cmd = 'svn co';
        }
        system(qq{$cmd $uri $dir});
        chdir $dir;
        return $self->install_by_strategy( undef, $dir, { cleanup => 1 } );
    }
    elsif( $arg eq '.' ) {
        chdir '.';
        return $self->install_by_strategy( undef, '.', { cleanup => 0 } );
    }
    else {
        my $package = $arg;

        use Vimana::Record;
        my $record = Vimana::Record->load( $package );
        if( $record ) {
            print STDERR "Package $package is installed. reinstall (upgrade) ? (Y/n) ";
            my $ans; $ans = <STDIN>;
            chomp( $ans );
            if( $ans =~ /n/i ) {
                return;
            }
            else {
                Vimana::Record->remove( $package );
            }
        }

        my $info = Vimana->index->find_package( $package );
        unless( $info ) {
            $logger->error("package $package not found.");
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

}




1;
