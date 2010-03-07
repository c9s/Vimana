use warnings;
use strict;
package Vimana::Command::Download;
use base qw(App::CLI::Command);
use URI;
use LWP::Simple qw();
require Vimana::VimOnline;
require Vimana::VimOnline::ScriptPage;

sub options { (
    'v|verbose'           => 'verbose',
) }

sub run {
    my ( $self, $package ) = @_;

    my $index = Vimana->index();
    my $info = $index->find_package( $package );

    unless( $info ) {
        print "Can not found package: $package\n";
        return 0;
    }

    my $page = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} );
    my $url      = $page->{download};
    my $filename = $page->{filename};
    my $dir      = tempdir( CLEANUP => 0 );               # download temp dir
    my $target   = File::Spec->join( $dir, $filename );

    print "Downloading from: $url\n";
    Vimana::Installer->download( $url , $target );
    print "Stored at : $target\n";
    print "Done\n";
}




1;
__DATA__


=head1 NAME

Vimana::Command::Download - download a vim plugin package.

=head1 SYNOPSIS

    $ vimana download [plugin]

    $ vimana d [plugin]

=head1 OPTIONS

=head1 DESCRIPTION


