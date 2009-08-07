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

    print "Download from: $url\n";
    my $file_content = LWP::Simple::get( $url );

    die 'can not download file' unless $file_content ;

    open FH , ">" , $target or die 'can not create file handle';
    print FH $file_content;
    close FH;
    print "Stored at: $target\n";


    print "Check port file\n";
#    if( Vimana::PortInstall->has_portfile ) {
#
#    }

    print "Check if we can auto install this package\n";
    if( Vimana::AutoInstall->can_autoinstall( $self , $target , $info , $page ) ) {
        print "Auto install $target\n";
        my $ret = Vimana::AutoInstall->install( $self , $target , $info , $page );
        unless ( $ret ) {
            print "Auto install failed\n";
        }
    }

    print "Done\n";
}


1;
