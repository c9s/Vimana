package Vimana::Index;
use warnings;
use strict;

use Cache::File;
use Storable;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors( qw(cache) );

sub init {
    my $self = shift;
    my $cache = Cache::File->new(
        cache_root      => $ENV{VIMANA_CACHE_DIR} || '/tmp/vim.get',
        lock_level      => Cache::File::LOCK_LOCAL(),
        default_expires => '3 hours'
    );
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
    return defined $index->{ $cname }  ? $index->{ $cname } : undef;
}


sub update {
    my ($self, $results ) = @_;
    my $f = Storable::freeze( $results );
    die unless $f;
    $self->cache->set( 'index' , $f );
}

sub get {
    my $self = shift;
    my $ret = $self->cache->get( 'index' );
    return Storable::thaw $ret if $ret;
    return undef;
}



1;
