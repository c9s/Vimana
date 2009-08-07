package Vim::Get::VimOnline::Search;

sub parse_columns {
    my $c       = ${ $_[0] };
    warn $c;
    my $columns = [];
    if( $c =~ m{<tr class='tableheader'>(.*?)</tr>}gis ) {
        my $column_html = $1;
        warn $1;
        while ( $column_html =~ m{<th.*?>(.*?)</th>}g ) {
            my $name = $1;
            $name =~ s{</?.+?>}{}g;
            push @$columns,lc $name;
        }
    }
    $last_pos = pos $c;
    return $columns;
}

sub parse_rows {
    my $c = ${ $_[0] };
    my $column_names = $_[1];
    pos($c) = $last_pos;
    my $rows = [];
ROW_END:
    while ( $c =~ m{<tr>(.*?)</tr>}gsi ) {
        my $tr = $1;
        last ROW_END if( $tr =~ m{<font color='gray'>prev</font>} );

        my $col_index = 0;
        my $cols;
        while ( $tr =~ m{<td.*?>(.*?)</td>}gsi ) {
            my $td = $1;
            if( my ( $link, $text ) = ( $td =~ m{<a href="(.+?)">(.+?)</a>}i )  ) {
                $link = $base_uri . $link;
                $cols->{ $column_names->[ $col_index ] } = { text => $text, link => $link };
            }
            else {
                $cols->{ $column_names->[ $col_index ] } = $td;
            }
            $col_index++;
        }
        push @$rows,$cols;
    }
    return $rows;
}

sub has_result {
    my $c = ${ $_[0] };
    return (  $c =~ /Your search returned no results/ ) ? 0 : 1;
}

sub parse {
    my ( $self , $c ) = @_;
    if( has_result( \$c ) ) {
        my $columns = parse_columns( \$c );
        return parse_rows( \$c , $columns );
    }
    else {
        return undef;
    }
}

1;
