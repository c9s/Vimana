package Vimana::Command::Update;
use warnings;
use strict;

use URI;
use base qw(App::CLI::Command);
use Vimana::Logger;

sub options {
    (
        'v|verbose'     => 'verbose',
    );
}


require Vimana::VimOnline;

sub fetch_index {
    return Vimana::VimOnline::Search->fetch(
        keyword => '',
        show_me => Vimana::VimOnline::Search->all_vim_plugins,
        order_by => 'creation_date',
        direction => 'ascending'
    );
}


sub run {
    my ($self, @args ) = @_;
    $logger->info("Fetching...");
    my $results = fetch_index();

    my $index = Vimana->index();
    $index->update( $results );

    # XXX: check installed packages , calcuate outdated items
}



1;
