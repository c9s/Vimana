package Vimana::VimOnline::SearchResult;

require Vimana::VimOnline::Search;
require Vimana::VimOnline::ScriptPage;

use Text::Table;

sub display {
    my ($class , $results ) = @_; 

    my $tb = Text::Table->new( "name", "rating", 'type', "description" );


    while( my ( $script_name , $item ) = each %$results ) {
        $tb->add(
            $script_name , 
            $item->{rating},
            $item->{type},
            $item->{summary}->{text},
        );
        # printf( "%s (%s) - %s -  %s\n" , 
        # $script_name , $item->{rating} , 
        # $item->{type} ,  $item->{summary}->{text} ); 
    }

    print $tb;
}


1;
