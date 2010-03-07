package Vimana::Installer;
use base qw(Vimana::Accessor);
use warnings;
use strict;
use Vimana::Logger;
use File::Temp 'tempdir';
use File::Type;
use Cwd;
use Mouse;
use HTTP::Lite;
use Archive::Extract;
use Vimana::Installer::Meta;
use Vimana::Installer::Makefile;
use Vimana::Installer::Rakefile;
use Vimana::Installer::Auto;
use Vimana::Installer::Text;

use constant _continue => 0;


# should clean up after installing.
has cleanup =>
    is => 'rw',
    isa => 'Bool';

# For text type installer , target is a file path.
# For other type installer , target is a directory path.
has target =>
    is => 'rw',
    isa => 'Str';

# runtime path to install to.
has runtime_path =>
    is => 'rw',
    isa => 'Str';

# Command Object (command options)
has cmd =>
    is => 'rw';

# verbose 
has verbose =>
    is => 'rw';

# script info from vim.org (optional)
has script_info =>
    is => 'rw';

# script page info from vim.org (optional)
has script_page =>
    is => 'rw';

=pod

    Vimana::Installer->install( 'package name' );
    Vimana::Installer->install_from_url( 'url' );
    Vimana::Installer->install_from_rcs( 'git:......' );
    Vimana::Installer->install_from_dir( '/path/to/plugin' );


For Text type installer, inspect content like this:

    " Script type: plugin
    " Script dependency:
    "   foo1 > 0.1
    "   bar2 > 0.2
    " 
    " Description:
    "   ....

=cut

sub download {
    my ( $self, $url, $target ) = @_;
    my $savetofile = sub {
        my ( $self, $dataref, $cbargs ) = @_;
        print STDERR ".";
        print $cbargs $$dataref;
        return undef;
    };
    my $http = new HTTP::Lite;
    open my $dl, ">", $target or die $!;
    my $res = $http->request( $url, $savetofile, $dl );
    close $dl;
    print "\n";
}

sub get_installer {
    my $self = shift;
    my $type = shift;
    my $class = qq{Vimana::Installer::} . ucfirst($type);
    return $class->new( @_ );
}

sub install_by_strategy {
    my ( $self, %args ) = @_;

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
        print "Package doesn't contain META,VIMMETA,VIMMETA.yml or Makefile file\n";
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
        my $installer = $self->get_installer( $ins_type, %args );
        $ret = $installer->run();

        last DONE if $ret;  # succeed
        last DONE if ! $installer->_continue;  # not succeed, but we should continue other installation.
    }

    unless( $ret ) {
        print "Installation failed.\n";
        print "Vimana does not know how to install this package\n";
        # XXX: provide more usable help message.
        return $ret;
    }

#     if( $args->{cleanup} ) {
#         print "Cleaning up temporary directory.\n" if $verbose;
#         rmtree [ $tmpdir ] if -e $tmpdir;
#     }

    return $ret;
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

# sub stdlize_uri {
#     my $uri = shift;
#     if( $uri =~ s{^(git|svn):}{} )  { 
#         return $1,$uri;
#     }
#     return undef;
# }

sub runtime_path_warn {
    my ($self,$cmd) = @_;
    print <<END;
    You are using runtime path option.

    To load the plugin , you will need to add below configuration to your vimrc file

        :set runtimepath+=@{[ $cmd->{runtime_path} ]}

    See vim documentation for runtimepath option.

        :help 'runtimepath'

END
}

use Vimana::Record;

sub install_from_url { }
sub install_from_vcs { }
sub install_from_path { }

sub install {
    my ( $self, $package , $cmd ) = @_;
    $cmd ||= {};

    my $verbose = $cmd->{verbose};
    if( $cmd->{runtime_path} ) {
        $self->runtime_path_warn( $cmd );
    }

    my $rtp = $cmd->{runtime_path} 
                || Vimana::Util::runtime_path();

    print STDERR "Plugin will be installed to vim runtime path: " . 
                    $rtp . "\n" if $cmd->{runtime_path};

    my $record = Vimana::Record->load( $package );
    if( $record ) {
        if( $cmd->{assume_yes} ) {
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

    my $info = Vimana->index->find_package( $package );
    unless( $info ) {
        print STDERR "Package $package not found.\n";
        return 0;
    }
    my $page = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} );

    my $dir = tempdir( CLEANUP => 0 ); # download temp dir

    my $url = $page->{download};
    my $filename = $page->{filename};
    my $target = File::Spec->join( $dir , $filename );

    # Download File
    print "Downloading plugin from $url\n" if $verbose;
    $self->download(  $url , $target );

    my $filetype = File::Type->new->checktype_filename( $target );

    # text filetype
    if( $filetype =~ m{octet-stream} ) {
        # XXX: need to record.
        my $installer = $self->get_installer('text',
            package_name => $package,
            target       => $target, 
            runtime_path => $rtp,
            script_info  => $info,
            script_page  => $page,
            cleanup      => 0,
        )->run();
    }
    elsif ( $filetype =~ m{(?:x-bzip2|x-gzip|x-gtar|zip|rar|tar)} ) {
        my $install_temp = tempdir( CLEANUP => 1 );  # extract temp dir
        my $ae = Archive::Extract->new( archive => $target );
        my $ok = $ae->extract(  to => $install_temp )
            or die( $ae->error );

        my $cwd = getcwd();
        chdir $install_temp;

        my $ret = $self->install_by_strategy(
            package_name => $package,
            target       => $install_temp,
            cleanup      => 1,
            runtime_path => $rtp,
            verbose      => $verbose,
        );

        chdir $cwd;
    }

    print "Done";
}

1;

