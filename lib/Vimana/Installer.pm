package Vimana::Installer;
use warnings;
use strict;
use Vimana::Logger;
use File::Temp 'tempdir';
use File::Type;
use File::Path qw(rmtree);
use Cwd;
use Mouse;
use Archive::Extract;

use Vimana::Installer::Vimball;
# use Vimana::Installer::Meta;
use Vimana::Installer::Makefile;
use Vimana::Installer::Rakefile;
use Vimana::Installer::Auto;
use Vimana::Installer::Text;
use Vimana::Util;

use constant _continue => 0;

has package_name =>
    is => 'rw',
    isa => 'Str';

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
    use HTTP::Lite;
    my $savetofile = sub {
        my ( $self, $dataref, $cbargs ) = @_;
        print STDERR ".";
        print $cbargs $$dataref;
        return undef;
    };
    my $http = new HTTP::Lite;
    $http->proxy( $ENV{HTTP_PROXY} ) if $ENV{HTTP_PROXY};
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
    my $verbose = $args{verbose};
    my $ret;

    # XXX: migrate this to Installer::*
    my @ins_type = $self->check_strategies( 
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
        print "Package doesn't contain Rakefile or Makefile file\n" if $verbose;
        print "No available strategy, Try to auto-install.\n" if $verbose;
        push @ins_type, 'auto';
    }
    
DONE:
    for my $ins_type ( @ins_type ) {
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


    return $ret;
}

sub check_strategies {
    my ($self,@sts) = @_;
    my @ins_type;

    NEXT_ST:
    for my $st ( @sts ) {
        print ' - ' . $st->{name} . ' : ' . $st->{desc} . ' ...';
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

sub prompt_for_removing_record {
    my ( $self, $package_name, $yes , $verbose ) = @_;
    my $record = Vimana::Record->load( $package_name );
    if( $record ) {
        if( $yes ) {
            print STDERR "Package $package_name is installed. removing...\n";
        }
        else {
            print STDERR "Package $package_name is installed. reinstall (upgrade) ? (Y/n) ";
            my $ans; $ans = <STDIN>;
            chomp( $ans );
            return if $ans =~ /n/i;
        }
        Vimana::Record->remove( $package_name , undef , $verbose );
    }
}


#########################################
#         Command Interface
#########################################


sub install_from_url {
    my ($self,$url,$cmd) = @_;





}

sub install_from_vcs {
    my ($self,$vcs_path,$cmd) = @_;
    $cmd ||= {};
    my $verbose = $cmd->{verbose};
    if( $cmd->{runtime_path} ) {
        $self->runtime_path_warn( $cmd );
    }
    my @rtps = get_vim_rtp();
    my $rtp = $cmd->{runtime_path} 
                || $rtps[0];

    print STDERR "Plugin will be installed to vim runtime path: " . 
                    $rtp . "\n" if $cmd->{runtime_path};

    return if $vcs_path !~ m{^(svn|git|hg):} ;

    my $vcs = $1;
    $vcs_path =~ s{^(svn|git|hg):}{};
    my $dir = tempdir( CLEANUP => 0 );

    if( $vcs eq 'git' ) {
        print "Git clone to $dir\n";
        system( qq{$vcs clone $vcs_path $dir} );
    }
    elsif ( $vcs eq 'svn' ) {
        print "SVN checkout to $dir\n";
        system( qq{$vcs checkout $vcs_path $dir} );
    }
    elsif ( $vcs eq 'hg' ) {
        system( qq{$vcs checkout $vcs_path $dir} );
    }
    else {
        die;
    }

    $self->_install_from_path( $dir , $cmd , $rtp , $vcs );
}

sub install_from_path {
    my ($self,$path,$cmd) = @_;
    $cmd ||= {};
    my $verbose = $cmd->{verbose};
    if( $cmd->{runtime_path} ) {
        $self->runtime_path_warn( $cmd );
    }
    my @rtps = get_vim_rtp();
    my $rtp = $cmd->{runtime_path} 
                || $rtps[0];

    print STDERR "Plugin will be installed to vim runtime path: " . 
                    $rtp . "\n" if $cmd->{runtime_path};
    $self->_install_from_path( $path , $cmd , $rtp , 'file' );
}

sub _install_from_path {
    my ( $self, $path, $cmd , $rtp , $pkg_prefix ) = @_;
    my $verbose = $cmd->{verbose};
    my $cwd = getcwd();

    chdir $path;
    use Cwd;
    use File::Basename;

    # XXX: try to find package name from Meta file.
    # my $basename = dirname( getcwd() );
    # $basename =~ tr{/\.!}{};

    unless( $cmd->{package_name} ) {
        die "please specify package name.\n";
    }

    my $package_name =  $pkg_prefix . '-' . $cmd->{package_name};

    $self->prompt_for_removing_record( $package_name , $cmd->{assume_yes} , $verbose  );

    my $ret = $self->install_by_strategy(
        package_name => $package_name,
        target       => $path,
        runtime_path => $rtp,
        verbose      => $verbose,
    );

    chdir $cwd;
    if( $cmd->{cleanup} ) {
        print "Cleaning up.\n" if $verbose;
        $self->cleanup( $path );
    }

    print "Done\n";
}

=head1 todo

XXX: some checking method for file-based or dir-based install for
install_from_path function.  to let this work:

      vimana install path/to/zencoding.vim --name zencoding  
              # package name could be parsed from script file content
      vimana install path/to/dir   --name zencoding

=cut

sub _file_install { }
sub _dir_install {  }

sub install {
    my ( $self, $package , $cmd ) = @_;
    $cmd ||= {};
    my $verbose = $cmd->{verbose};
    if( $cmd->{runtime_path} ) {
        $self->runtime_path_warn( $cmd );
    }

    my @rtps = get_vim_rtp();
    my $rtp = $cmd->{runtime_path} 
                || $rtps[0];

    print STDERR "Plugin will be installed to runtime path: $rtp\n";

    $self->prompt_for_removing_record( $package , $cmd->{assume_yes} , $verbose  );

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
    print "Downloading plugin\n";
    print "\tfrom $url\n"  if $verbose;
    print "\tto $target\n" if $verbose;

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
            script_type  => $cmd->{script_type},  # pass script_type
        )->run();

        if( $cmd->{cleanup} ) {
            print "Cleaning up.\n" if $verbose;
            $self->cleanup( $target );
        }
    }
    elsif ( $filetype =~ m{(?:x-bzip2|x-gzip|x-gtar|zip|rar|tar)} ) {
        my $install_temp = tempdir( CLEANUP => 0 );  # extract temp dir
        my $ae = Archive::Extract->new( archive => $target );

        my $ok = $ae->extract(  to => $install_temp )
            or die( $ae->error );

        my $files = $ae->files;

        # some script is archived with only one file.
        # just treat them as text file to install. 
        if ( scalar(@$files) == 1 ) {
            my $extract_file = File::Spec->join( $install_temp , $files->[0] );
            my $installer = $self->get_installer('text',
                package_name => $package,
                target       => $extract_file, 
                runtime_path => $rtp,
                script_info  => $info,
                script_page  => $page,
            )->run();
        }
        else {
            my $cwd = getcwd();
            chdir $install_temp;

            my $ret = $self->install_by_strategy(
                package_name => $package,
                target       => $install_temp,
                runtime_path => $rtp,
                verbose      => $verbose,
            );

            chdir $cwd;
            if( $cmd->{cleanup} ) {
                print "Cleaning up.\n" if $verbose;
                $self->cleanup( $install_temp );
            }
        }
    }

    print "Done\n";
}


sub cleanup {
    my ($self,$path) = @_;
    rmtree [ $path ] if -e $path;
}


sub installer_type {
    my $self = shift;
    if( ref($self) =~ m/(\w+)$/ ) {
        return lc($1);
    }
}

1;

