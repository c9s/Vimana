package Vimana::Record;
use warnings;
use strict;
use Vimana;
use Storable;

=head1 FUNCTIONS

=head2 get_all 

=cut

sub get_all {
    my $c = Vimana->cache->get( 'record' ) ;
    return Storable::thaw( $c ) if $c;
    return { };
}

=head2 set_all

=cut

sub set_all {
    my $class = shift;
    my $set = shift;
    Vimana->cache->set( 'record' ,  Storable::freeze $set );
}

sub get {
    my ($class , $cname) = @_;
    my $set = get_recordset();
    return $set->{ $cname } if defined $set->{ $cname };
    return ;
}

=head2 set %PARAM

cname : Canonicalized name

    cname => String
    files => ArrayRef

=cut

# XXX: check if cname conflicts
sub set {
    my $class = shift;
    my %args = @_;
    my $recordset = $class->get_recordset();
    $recordset->{ $args{cname} } = {
        cname => $args{cname} , 
        files => [ ],
        type  => undef,
        install_date  => undef,
        %args,
    };
    $class->set_recordset( $recordset );
}


1;
