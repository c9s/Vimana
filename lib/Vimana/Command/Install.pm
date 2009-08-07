package Vimana::Command::Install;
use warnings;
use strict;
use URI;
require Vimana::VimOnline;
use Vimana::AutoInstall;
use Vimana::Logger;
use base qw(App::CLI::Command);
use LWP::Simple qw();
use File::Temp qw(tempdir);

sub options {
    (
        'v|verbose'     => 'verbose',
        'y|yes'         => 'assume_yes',
    );
}


sub run {
    my ( $self, $package ) = @_;


    my $index = Vimana->index();
    my $info = $index->find_package( $package );

    my $page = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} ) ;

    my $dir = '/tmp' || tempdir( DIR => '/tmp' );

    my $url = $page->{DOWNLOAD};
    my $filename = $page->{FILENAME};
    my $target = File::Spec->join( $dir , $filename );

    print "Download as $target\n";
    LWP::Simple::getstore( $url , $target  );

    if( Vimana::AutoInstall->can_autoinstall( $target , $info , $page ) ) {
        my $ret = Vimana::AutoInstall->install( $target , $info , $page );
    }
}


1;
