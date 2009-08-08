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
use Moose;

has scripttype => ( is => 'rw', isa => 'Str' );
has filetype  => ( is => 'rw', isa => 'Str' );

sub options {
    (
        'v|verbose'     => 'verbose',
        'y|yes'         => 'assume_yes',
    );
}


sub is_archive_file {
    my $self = shift;
    return 1 if $self->filetype =~ m{(x-bzip2|x-gzip|x-gtar|zip|rar|tar)};
    return 0;
}

sub is_text_file {
    my $self = shift;
    return 1 if $self->filetype =~ m{octet-stream};
    return 0;
}


sub detect_filetype {
    my ( $self , $file ) = @_;
    my $type = Vimana::Util::get_mine_type( $file );
    $self->filetype( $type );
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

    $logger->info("Download from: $url");;
    my $file_content = LWP::Simple::get( $url );

    die 'can not download file' unless $file_content ;

    open FH , ">" , $target or die 'can not create file handle';
    print FH $file_content;
    close FH;
    print "Stored at: $target\n";

    $self->detect_filetype( $target );

    if( $self->is_archive_file() ) {
        $logger->info("Check if this package contains 'Makefile' file");

    }

    $logger->info("Check if we can install this package via port file");

#    if( Vimana::PortInstall->has_portfile ) {
#
#    }
    print "Check if we can auto install this package\n";
    if( Vimana::AutoInstall->can_autoinstall( $self , $target , $info , $page ) ) {
        $logger->info("Auto install $target");
        my $ret = Vimana::AutoInstall->install( 
                    command => $self , 
                    target => $target ,
                    info => $info ,
                    page => $page );

        unless ( $ret ) {
            $logger->error("Auto install failed");
            die;
        }
    }

    print "Done\n";
}


1;
