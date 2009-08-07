package Vim::Get::Index;
use warnings;
use strict;


use Cache::File;
use base qw(Class::Accessor::Fast);
__PACKAGE__->mk_accessors( qw(cache) );

sub init {
    my $self = shift;
    my $cache = Cache::File->new(
        cache_root      => '/var/vim.get',
        lock_level      => Cache::File::LOCK_LOCAL(),
        default_expires => '3 hours'
    );
    $self->cache( $cache );
}


sub update {
    my ($self, $results ) = @_;




}



1;
