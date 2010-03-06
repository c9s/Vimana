use warnings;
use strict;
package Vimana::Command::Install;
use base qw(App::CLI::Command);
use URI;
use LWP::Simple qw();
use File::Path qw(rmtree);
use Cwd;

require Vimana::VimOnline;
require Vimana::VimOnline::ScriptPage;
use Vimana::Util;
use Vimana::Record;
use Vimana::VimballInstall;
use Vimana::Logger;
use Vimana::PackageFile;

sub options { (
        'd|dry-run'           => 'dry_run',
        'v|verbose'           => 'verbose',
        'y|yes'               => 'assume_yes',
        'f|force'             => 'force_install',

        # XXX: auto-install should optional and not by default.
        'ai|auto-install'     => 'auto_install', 
        'mi|makefile-install' => 'makefile_install',
        'r|runtime-path=s'    => 'runtime_path',
) }

use Vimana::Installer;

sub run {
    my ( $cmd, $arg ) = @_;
    if( $arg =~ m{^https?://} ) {
        Vimana::Installer->install_from_url( $arg , $cmd );
    }
    elsif( $arg =~ m{^(?:git|svn):} ) {
        Vimana::Installer->install_from_vcs( $arg , $cmd );
    }
    elsif( $arg =~ m{^[a-zA-Z0-9._-]+$} ) {
        Vimana::Installer->install(  $arg , $cmd ); # from vim.org
    }
    elsif( $arg eq '.' or $arg =~ m{file://} ) {
        Vimana::Installer->install_from_path( $arg , $cmd );
    }
}

=pod
sub run {
    my ( $self, $arg ) = @_; 
    # XXX: check if we've installed this package
    # XXX: check if package files conflict

    # XXX: $self->{runtime_path}

    my $verbose = $self->{verbose};

    if( $self->{runtime_path} ) {
        print STDERR <<END;
    You are using runtime path option.

    To load the plugin , you will need to add below configuration to your vimrc file

        :set runtimepath+=@{[ $self->{runtime_path} ]}

    See vim documentation for runtimepath option.

        :help 'runtimepath'

END
    }

    my $rtp = $self->{runtime_path} 
        || Vimana::Util::runtime_path();

    print STDERR "Plugin will be installed to vim runtime path: " . 
                    $rtp . "\n" if $self->{runtime_path};

    if (  $arg =~ m{^git:} or $arg =~ m{^svn:} ) {
        # XXX: check 'git' or 'svn' binary here.
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
        return $self->install_by_strategy( undef, $dir, 
            { cleanup => 1 , 
              runtime_path => $rtp } , $verbose );
    }
    elsif( $arg eq '.' ) {
        return $self->install_by_strategy( undef, '.',
            { cleanup => 0  , 
              runtime_path => $rtp } , $verbose );
    }
    else {
        my $package = $arg;

        use Vimana::Record;
        my $record_file =  Vimana::Record->record_path( $package );
        if( -f $record_file ) {
            my $record = Vimana::Record->load( $package );
            if( $record ) {

                if( $self->{assume_yes} ) {
                    print STDERR "Package $package is installed. removing...\n";
                }
                else {
                    print STDERR "Package $package is installed. reinstall (upgrade) ? (Y/n) ";
                    my $ans; $ans = <STDIN>;
                    chomp( $ans );
                    return if $ans =~ /n/i;
                }

                Vimana::Record->remove( $package , undef , $verbose );
            }
        }

        my $info = Vimana->index->find_package( $package );
        unless( $info ) {
            $logger->error("package $package not found.");
            return 0;
        }
        my $page = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} );

        # XXX: dont use '/tmp', use a better temp dir function.
        my $dir = '/tmp' || Vimana::Util::tempdir();

        my $url = $page->{download};
        my $filename = $page->{filename};
        my $target = File::Spec->join( $dir , $filename );

        print STDERR "Downloading from: $url\n" if $verbose;

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

            # XXX: need to record.
            my $installer = $self->get_installer('text' , { 
                    package => $pkgfile , 
                    runtime_path => $rtp } );
            $ret = $installer->run( $pkgfile );
        }
        elsif( $pkgfile->is_archive ) {

            # extract to a path 
            my $tmpdir = Vimana::Util::tempdir();

            print STDERR "Extracting to $tmpdir.\n" if $verbose;

            $pkgfile->extract_to( $tmpdir );

            print STDERR "Changing directory to $tmpdir.\n" if $verbose;

            $ret = $self->install_by_strategy( $pkgfile, $tmpdir,
                { cleanup => 1, 
                  runtime_path => $rtp } , $verbose );

        }
        unless( $ret ) {
            print "Installation Failed.\n";
            exit 1;
        }

        print "Installation Done.\n";
    }

}
=cut

1;
__END__


=head1 NAME

Vimana::Command::Install - install a vim plugin package.

=head1 SYNOPSIS

    $ vimana install [plugin]

=head1 OPTIONS

    -v    : verbose

    -f    : force install

    -r    : runtime path

=head1 DESCRIPTION


