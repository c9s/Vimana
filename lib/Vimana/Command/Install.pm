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

        'ai|auto-install'     => 'auto_install', 
                # XXX: auto-install should optional and not by default.
        'mi|makefile-install' => 'makefile_install',
        'r|runtime-path=s'    => 'runtime_path',
) }

use Vimana::Installer::Meta;
use Vimana::Installer::Makefile;
use Vimana::Installer::Rakefile;
use Vimana::Installer::Auto;
use Vimana::Installer::Text;

# XXX: mv this method into Vimana::Installer , maybe

# @args: will pass to Vimana::Installer::* Class.
sub get_installer {
    my ( $self, $type, @args ) = @_;
    my $class = qq{Vimana::Installer::} . ucfirst($type);
    return $class->new( @args );
}

sub check_strategies {
    my ($self,@sts) = @_;
    my @ins_type;

NEXT_ST:
    for my $st ( @sts ) {
        print $st->{name} . ' : ' . $st->{desc} . ' ...';


        if( defined $st->{bin} ) {
            for my $bin ( @{  $st->{bin} } ){
                my $binpath = qx{which $bin};
                chomp $binpath;
                next NEXT_ST unless $binpath;
            }
        }

        my $deps = $st->{deps};
        my $found;
NEXT_DEP_FILE:
        for ( @$deps ) {
            next unless -e $_;
            
            

            push @ins_type , $st->{installer};
            $found = 1;
            last NEXT_DEP_FILE;
        }
        print $found ? "ok\n" : "not ok\n";
    }
    return @ins_type;
}


sub install_by_strategy {
    my ( $self, $pkgfile, $tmpdir, $args , $verbose ) = @_;

    my $prev_dir = getcwd();
    chdir($tmpdir);
    my $ret;
    my @ins_type = $self->check_strategies( 
        {
            name => 'Makefile',
            desc => q{Check if makefile exists.},
            installer => 'Makefile',
            deps => [qw(makefile Makefile)],
        },
        # because Meta file would overwrite "Makefile" file. so put Meta file
        # after Makefile strategy
        {
            name => 'Meta',
            desc => q{Check if 'META' or 'VIMMETA' file exists. support for VIM::Packager.},
            installer => 'Meta',
            deps =>  [qw(VIMMETA META)],
            bin =>  [qw(vim-packager)],
        },
        {
            name => 'Rakefile',
            desc => q{Check if rakefile exists.},
            installer => 'Rakefile',
            deps => [qw(rakefile Rakefile)],
        });

    if( @ins_type == 0 ) {
        $logger->warn( "Package doesn't contain META,VIMMETA,VIMMETA.yml or Makefile file" );
        print "No availiable strategy, try to auto-install.\n" if $verbose;
        push @ins_type,'auto';
    }
    
DONE:
    for my $ins_type ( @ins_type ) {
        # $args: (hashref)
        #   is used for Vimana::Installer::*->new( { args => $args } );
        #   
        #       cleanup (boolean)
        #       runtime_path (string)
        #
        my $installer = $self->get_installer( $ins_type, $args );
        $ret = $installer->run( $pkgfile, $tmpdir );

        last DONE if $ret;  # succeed
        last DONE if ! $installer->_continue;  # not succeed, but we should continue other installation.
    }

    unless( $ret ) {
        print STDERR "Installation failed.\n";
        print STDERR "Vimana does not know how to install this package\n";
        # XXX: provide more usable help message.
        return $ret;
    }

    chdir($prev_dir);
    if( $args->{cleanup} ) {
        print "Cleaning up temporary directory.\n" if $verbose;
        rmtree [ $tmpdir ] if -e $tmpdir;
    }

    print "Installtion Done.";
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

                Vimana::Record->remove( $package );
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


