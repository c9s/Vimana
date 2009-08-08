package Vimana::Command::Update;
use warnings;
use strict;

use URI;
use base qw(App::CLI::Command);

sub options {
    (
        'v|verbose'     => 'verbose',
    );
}


require Vimana::VimOnline;
require Vimana::VimOnline::Search;
require Vimana::VimOnline::ScriptPage;

sub fetch_index {
    return Vimana::VimOnline::Search->fetch(
        keyword => '',
        show_me => 3000,
        order_by => 'creation_date',
        direction => 'ascending'
    );
}

sub run {
    my ($self, @args ) = @_;

    print "Updating....\n";
    my $results = fetch_index();
    my $cnt = scalar keys %$results;
    print "Index updated: $cnt items.\n";

    my $index = Vimana->index();
    $index->update( $results );
}



1;
