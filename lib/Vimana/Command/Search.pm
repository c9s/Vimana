package Vimana::Command::Search;
use warnings;
use strict;
use URI;
require LWP::UserAgent;
require Vimana::VimOnline;
use base qw(App::CLI::Command);

sub options {
    (
        'v|verbose'     => 'verbose',
        't|script-type=s' => 'script_type',
        'o|order-by=s',   => 'order_by',
    );
}


sub run {
    my ( $self, @keywords ) = @_;

    unless( @keywords ) {
        warn "Please specify keyword";
        exit 0; 
    }

    # Search from Index
    my $results = Vimana::VimOnline::Search->fetch(
        keywords     => join(' ' , @keywords) ,
        ( $self->{script_type} ? ( script_type => $self->{script_type} ) : () ),
        ( $self->{order_by} ? ( order_by => $self->{order_by} )  : () ),
    );

    Vimana::VimOnline::SearchResult->display( $results );
}



1;
