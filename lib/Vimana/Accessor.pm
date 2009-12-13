package Vimana::Accessor;
use strict;
use warnings;

=head2 new

 ->new( {  } );

=cut

sub new {
    my ( $class, $ref ) = @_;
    my $self = bless { }, $class;
    while( my ($col,$v) = each %$ref ) {
        $self->$col( $v );
    }
    return $self;
}

sub mk_accessors {
    my $class = shift;
    my @cols = @_;
    no strict 'refs';
    for my $col ( @cols ) {
        my $l = $class . '::' . $col;
        *{ $l } = sub {
            my $s = $_[0];
            $s->{"_private_$col"} = $_[1] if $_[1];
            return $s->{"_private_$col"};
        };
    }
}

1;
