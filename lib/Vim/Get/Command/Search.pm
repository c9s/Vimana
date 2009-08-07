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
    my ( $self, $keyword ) = @_;
    # use Data::Dumper; warn Dumper( \@_ );

    unless( $keyword ) {
        warn "Please specify keyword";
        exit 0; 
    }

    my $uri = $self->build_search_uri(
        keyword => $keyword,
        ( $self->{script_type} ? ( script_type => $self->{script_type} ) : ()  ),
        ( $self->{order_by}    ? ( order_by => $self->{order_by} ) : () ),
    );
    # my $scraper = $self->scraper_schema();


    require LWP::UserAgent;
    require Vim::Get::VimOnline;

    my $ua = LWP::UserAgent->new;
    my $response = $ua->get( $uri );
    my $c = $response->decoded_content;

    my $results = Vim::Get::VimOnline::Search->parse( $c );
    Vim::Get::VimOnline::SearchResult->display( $results );
}

sub build_search_uri {
    my $self = shift;
    my %param = @_;
    my %args = (
        keywords    => '',
        script_type => '',
        direction   => 'descending',
        order_by    => 'rating',
        search      => 'search',
        #show_me     => 1000,
        #result_ptr  => 0,
        %param ,
    );

    my $uri = URI->new("http://www.vim.org/scripts/script_search_results.php");
    $uri->query_form( %args ); 
    print $uri;
    return $uri;
}



1;
