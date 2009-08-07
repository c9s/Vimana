package Vim::Get::Command::Update;
use warnings;
use strict;

use URI;
use base qw(App::CLI::Command);

sub options {
    (
        'v|verbose'     => 'verbose',
    );
}


require Vim::Get::VimOnline;
sub run {
    my ($self, @args ) = @_;
    my $index = Vim::Get->index();

    my $results = Vim::Get::VimOnline::Search->run(
        keyword => '',
        show_me => 3000,
        order_by => 'creation_date',
        direction => 'ascending'
    );
    my $cnt = scalar keys %$results;
    print "Index updated: $cnt items.\n";
    $index->update( $results );

}



1;
