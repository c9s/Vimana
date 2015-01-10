package Vimana::Command::Update;
use warnings;
use strict;

use URI;
use parent qw(App::CLI::Command);
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
__END__

=head1 NAME

Vimana::Command::Update - Update index for searching

=head1 SYNOPSIS

    $ vimana update [options]

=head1 OPTIONS

-v , --verbose    : verbose

=cut
