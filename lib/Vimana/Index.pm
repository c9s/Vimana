package Vimana::Index;
use warnings;
use strict;

use Cache::File;
use Moose;
use Storable;
use Vimana::Logger;

has cache => ( is => 'rw' , isa => 'Cache::File' );

sub init {
    my $self = shift;
    $logger->debug("cache::file init");
    my $cache = Cache::File->new(
        cache_root      => $ENV{VIMANA_CACHE_DIR} || '/tmp/vim.get',
        lock_level      => Cache::File::LOCK_LOCAL(),
        default_expires => '3 hours'
    );
    $logger->debug("cache::file done");
    $self->cache( $cache );
}


sub find_package_like {
    my ( $self, $findname ) = @_;
    my $index = $self->get();
    while( my ( $pkg_name , $info ) = each %$index ) {
        if ( $info->{script}->{text} =~ $findname  ) {
            warn " '@{[ $info->{script}->{text} ]}' looks like '$findname'.\n" ;
            return $info ;
        }
    }
    return undef;
}

use Vimana::Util;
sub find_package {
    my ($self, $findname ) = @_;
    my $index = $self->get();
    my $cname = canonical_script_name( $findname );
    $logger->info( "Canonical name: $cname" );
    return defined $index->{ $cname }  ? $index->{ $cname } : undef;
}


sub update {
    my ($self, $results ) = @_;
    $logger->debug('freezing...');
    my $f = Storable::freeze( $results );
    $logger->debug('done');
    die unless $f;
    $self->cache->set( 'index' , $f );
}

sub get {
    my $self = shift;
    my $ret = $self->cache->get( 'index' );
    $logger->debug('thawing...');
    $ret = Storable::thaw $ret;
    $logger->debug('done');
    return $ret if $ret;
    return undef;
}



1;
