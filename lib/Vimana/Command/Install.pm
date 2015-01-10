use warnings;
use strict;
package Vimana::Command::Install;
use parent qw(App::CLI::Command);
use URI;
use LWP::Simple qw();
use File::Path qw(rmtree);
use Cwd;

require Vimana::VimOnline;
require Vimana::VimOnline::ScriptPage;
use Vimana::Util;
use Vimana::Record;
use Vimana::Logger;

sub options { (
        'd|dry-run'           => 'dry_run',
        'v|verbose'           => 'verbose',
        'y|yes'               => 'assume_yes',
        'c|cleanup'           => 'cleanup',

        # when not installing plugin from vim.org. (eg, from git or svn or local filepath)
        'n|name=s'              => 'package_name',

        't|type=s'            => 'script_type',

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
        # parse repo name as package name:
        my ($name) = ($arg =~ m{([^/]+)$});
        $cmd->{package_name} ||= $name;
        Vimana::Installer->install_from_vcs( $arg , $cmd );
    }
    elsif( $arg =~ m{^(?:github|gh):([^/]+)/([^/]+)} ) {
        print "Installing from GitHub...\n";
        my ($id,$repo) = ($1,$2);
        my $gh_uri = "git:https://github.com/$id/$repo.git";
        print $gh_uri . "\n";
        my $name   = "$id-$repo";
        $cmd->{package_name} ||= $name;
        Vimana::Installer->install_from_vcs( $gh_uri , $cmd );
    }
    elsif( -f $arg or -d $arg ) {  # is a file or directory
        Vimana::Installer->install_from_path( $arg , $cmd );
    }
    else {
        Vimana::Installer->install( $arg , $cmd ); # from vim.org
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

    -t , --type    : script type (plugin,ftplugin,syntax ...)

=head1 USAGE

Normally, script type will be detected by script detector.

But you can also specify the script type to a script:

    $ vimana install calendar.vim --type plugin

To install snipmate package:

    $ vimana install snipmate

To install rails.vim package:

    $ vimana install rails.vim

To install packages from git or svn:

    $ vimana install git:git://github.com/c9s/hypergit.vim.git
    $ vimana install git:git@github.com:c9s/hypgergit.vim.git
    $ vimana install svn:svn+ssh://path/to/your/repo

To install from GitHub:

    $ vimana install gh:c9s/perlomni.vim

To install snipmate package to another runtime path:

    $ vimana i snipmate -r ~/.vim-other-rtp

=cut
