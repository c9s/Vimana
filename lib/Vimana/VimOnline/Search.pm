package Vimana::VimOnline::Search;
use strict;
use warnings;
use utf8;
require LWP::UserAgent;
my $last_pos;

sub parse_columns {
    my $c       = ${ $_[0] };
    my $columns = [];
    if( $c =~ m{<tr class='tableheader'>(.*?)</tr>}gis ) {
        my $column_html = $1;
        while ( $column_html =~ m{<th.*?>(.*?)</th>}g ) {
            my $name = $1;
            $name =~ s{</?.+?>}{}g;
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
        #show_me     => 1000,
        #result_ptr  => 0,
        %param ,
    );

    my $uri = URI->new("http://www.vim.org/scripts/script_search_results.php");
    $uri->query_form( %args ); 
    return $uri;
}



1;
