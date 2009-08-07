package Vimana::VimOnline::SearchResult;

require Vimana::VimOnline::Search;
require Vimana::VimOnline::ScriptPage;

sub display {
    my ($class , $results ) = @_; 

    my $columns = 18;
    while( my ( $script_name , $item ) = each %$results ) {
        print $script_name;
        print ' ' x ( $columns - length $script_name);
        print " - " . $item->{summary}->{text} . "\n";
        # printf( "%s (%s) - %s -  %s\n" , 
        # $script_name , $item->{rating} , 
        # $item->{type} ,  $item->{summary}->{text} ); 
    }

}


1;
