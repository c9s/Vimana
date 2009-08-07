package Vim::Get::Command::Search;
use warnings;
use strict;

use URI;
use Hash::Merge qw(merge);
use base qw(App::CLI::Command);

sub options {
    (
        'v|verbose'     => 'verbose',
        't|script-type=s' => 'script_type',
        'o|order-by=s',   => 'order_by',
    );
}


sub run {
    my ($self, @args ) = @_;

}



1;
