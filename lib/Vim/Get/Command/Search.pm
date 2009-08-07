package Vim::Get::Command::Search;
use warnings;
use strict;
use URI;
use Hash::Merge qw(merge);
use Web::Scraper;
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
    use Data::Dumper; warn Dumper( \@_ );

    my $uri = $self->build_search_uri(
        keyword => $keyword,
        ( $self->{script_type} ? ( script_type => $self->{script_type} ) : ()  ),
        ( $self->{order_by}    ? ( order_by => $self->{order_by} ) : () ),
    );
    print $uri;
    my $scraper = $self->scraper_schema();

    my $res = $tweets->scrape( URI->new("http://twitter.com/miyagawa") );
}


sub scraper_schema {
    my $self = shift;
    return scraper {
        process "li.status", "tweets[]" => scraper {
            process ".entry-content",    body => 'TEXT';
            process ".entry-date",       when => 'TEXT';
            process 'a[rel="bookmark"]', link => '@href';
        };
    };
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
        %param ,
    );

    my $uri = URI->new("http://www.vim.org/scripts/script_search_results.php");
    $uri->query_form( %args ); 
    return $uri;
}



1;
