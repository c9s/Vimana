package Vimana::VimOnline::SearchResult;

require Vimana::VimOnline::Search;
require Vimana::VimOnline::ScriptPage;


sub display {
    my ($class , $results ) = @_; 
    while( my ( $script_name , $item ) = each %$results ) {
        printf( "% 20s (%s) - %s -  %s\n" , $script_name , $item->{rating} , $item->{type} ,  $item->{summary}->{text} ); 
    }
}


1;
