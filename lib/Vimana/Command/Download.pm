use warnings;
use strict;
package Vimana::Command::Download;
use base qw(App::CLI::Command);
use URI;
use LWP::Simple qw();
use Moose;

require Vimana::VimOnline;
require Vimana::VimOnline::ScriptPage;
use Vimana::Logger;
use Vimana::PackageFile;

sub options {
    (
        'v|verbose'           => 'verbose',
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

    $logger->info("Download from: $url");;

    my $pkgfile = Vimana::PackageFile->new(
        file      => $filename,
        url       => $url,
        info      => $info,
        page_info => $page,
    );

    return unless $pkgfile->download();
    $logger->info("Stored at: $filename");
    print "Done\n";
}




1;
