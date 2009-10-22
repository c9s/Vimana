package Vimana::Record;
use warnings;
use strict;
use Vimana;


=pod
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

=cut


1;
