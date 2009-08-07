package Vim::Get::Command::Search;
use warnings;
use strict;
use base qw(App::CLI::Command);

sub options {
    (
        'v|verbose' => 'verbose',
    );
}


sub run {
    my ( $self, $arg ) = @_;

    use Data::Dumper; warn Dumper( \@_ );

}


1;
