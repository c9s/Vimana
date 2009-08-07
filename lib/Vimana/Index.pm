package Vimana::Index;
use warnings;
use strict;


use Cache::File;
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

sub find_package {
    my ($self, $findname ) = @_;

    use Vimana::Util;

    my $index = $self->get();
    my $cname = canonical_script_name( $findname );

    return $index->{ $cname } if  defined $index->{ $cname }  ;

    while( my ( $pkg_name , $info ) = each %$index ) {
        return $info if $info->{script}->{text} =~ $findname ;
    }

    return undef;
}


sub update {
    my ($self, $results ) = @_;
    $self->cache->set( 'index' , $results ); # hash ref
}

sub get {
    my $self = shift;
    return $self->cache->get( 'index' );
}



1;
