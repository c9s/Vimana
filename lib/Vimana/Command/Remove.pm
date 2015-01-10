package Vimana::Command::Remove;
use parent qw(App::CLI::Command);
use Vimana::Record;

sub options { 
    ( 
        'v|verbose'           => 'verbose',
        'f|force'             => 'force',
    ) 
}

sub run {
    my ( $self, $package ) = @_;
    Vimana::Record->remove( $package , $self->{force} );


}

1;
__END__


=head1 NAME

Vimana::Command::Remove - removes an previously installed package

=head1 SYNOPSIS

    $ vimana remove [options] [keyword]

=head1 OPTIONS

-f , --force    : force remove

-v , --verbose    : verbose

=cut
