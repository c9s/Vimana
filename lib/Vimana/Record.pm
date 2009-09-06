package Vimana::Record;
use warnings;
use strict;
use Vimana;
use Storable;

sub get_recordset {
    my $c = Vimana->cache->get( 'record' ) ;
    return Storable::thaw( $c ) if $c;
    return { };
}

sub set_recordset {
    my $class = shift;
    my $set = shift;
    Vimana->cache->set( 'record' ,  Storable::freeze $set );
}

sub get_record {
    my ($class , $cname) = @_;
    my $set = get_recordset();
    return $set->{ $cname } if defined $set->{ $cname };
    return ;
}

sub set_record {
    my $class = shift;
    my %args = @_;
    my $recordset = $class->get_recordset();
    $recordset->{ $args{cname} } = {
        cname => $args{cname} , 
        files => [ ],
        %args,
    };
    $class->set_recordset( $recordset );
}


1;
