package Vimana::VimOnline::Search;
use strict;
use warnings;
use utf8;
require LWP::UserAgent;
use HTML::Entities;
use Web::Scraper;
use URI;

my $last_pos;
my $vimonline_search_url = "http://www.vim.org/scripts/script_search_results.php";

sub parse_columns {
    my $c       = ${ $_[0] };
    my $columns = [];
    if( $c =~ m{<tr class='tableheader'>(.*?)</tr>}gis ) {
        my $column_html = $1;
        while ( $column_html =~ m{<th.*?>(.*?)</th>}g ) {
            my $name = $1;
            $name = decode_entities( $name );
            utf8::encode $name;
            push @$columns,lc $name;
        }
    }
    $last_pos = pos $c;
    return $columns;
}


use Vimana::Util;

sub parse_rows {
    my $c = ${ $_[0] };
    my $column_names = $_[1];
    pos($c) = $last_pos;
    # my $rows = [];
    my $results = {};
ROW_END:
    while ( $c =~ m{<tr>(.*?)</tr>}gsi ) {
        my $tr = $1;
        last ROW_END if( $tr =~ m{<font color='gray'>prev</font>} );

        my $col_index = 0;
        my $cols;
        my $script_id;
        while ( $tr =~ m{<td.*?>(.*?)</td>}gsi ) {
            my $td = $1;
            if( my ( $link, $text ) = ( $td =~ m{<a href="(.+?)">(.+?)</a>}i )  ) {
                $text =~ s{&nbsp;}{ }g; # windows don't have 0xA0.
                $text = decode_entities( $text );
                utf8::encode $text;
                ($script_id) = ( $link =~ /script_id=(\d+)/ );
                $cols->{ $column_names->[ $col_index ] } = { text => $text, link => $link };
            }
            else {
                $cols->{ $column_names->[ $col_index ] } = $td;
            }
            $col_index++;
        }
        my $name = canonical_script_name( $cols->{script}->{text} );
        # my $name = $script_id || $cols->{script}->{text};
        $cols->{script_id} = $script_id;
        $results->{ $name } = $cols;
    }
    return $results;
}


sub has_result {
    my $c = ${ $_[0] };
    return (  $c =~ /Your search returned no results/ ) ? 0 : 1;
}


use Vimana;

sub fetch {
    my $class = shift;
    my %param = @_;

    my $uri = $class->build_search_uri( %param );
    my $content;
    unless( $content ) {
        my $ua = LWP::UserAgent->new;
        $ua->env_proxy;
        my $response = $ua->get( $uri );
        # XXX: catch exception 

        die 'page query failed ' unless ($response->is_success);

        $content = $response->decoded_content;
    }
    return $class->parse( $content );
}

sub parse {
    my ( $class , $c ) = @_;
    if( has_result( \$c ) ) {
        my $columns = parse_columns( \$c );
        return parse_rows( \$c , $columns );
    }
    else {
        return undef;
    }
}

sub build_search_uri {
    my $class = shift;
    my %param = @_;
    my %args = (
        keywords    => '',
        order_by    => 'rating',
        %param ,
    );

    my $uri = URI->new($vimonline_search_url);
    $uri->query_form( %args ); 
    return $uri;
}

sub all_vim_plugins {
    my $class = shift;
    my $scraper = scraper {
        process '/html/body/table[2]/tr/td[3]/table/tr/td/table/tr/td[2]/b[3]', 'total' => 'TEXT';
    };
    return $scraper->scrape(URI->new($vimonline_search_url))->{total};
}


1;
