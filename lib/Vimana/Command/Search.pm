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

    my $index = Vimana->index();
    my $plugins = $index->read_index();

    unless( $plugins ) {
        print "Can not found index. Fetching..\n";
        my $result = Vimana::VimOnline::Search->fetch(
                keyword => '',
                show_me => 3000,
                order_by => 'creation_date',
                direction => 'ascending'
        );
        $index->update( $result );
        $plugins = $index->read_index();
        print "Done\n";
    }


    my $keyword = $keywords[0]; # FIXME:
    my @result = map { ( $_->{description} =~ /$keyword/ or $_->{plugin_name} =~ /$keyword/ ) ? $_ : ()  } values %$plugins;

    my $max_width = 6;
    map { $max_width = length $_->{plugin_name} if length $_->{plugin_name} > $max_width }  @result;
    $max_width += 1;

    for ( @result ) {
        print $_->{plugin_name};
        print ' ' x ( $max_width - length $_->{plugin_name} );
        print " - " . $_->{description} . "\n";
    }


    # XXX: Search from Index
#    my $results = Vimana::VimOnline::Search->fetch(
#        keywords     => join(' ' , @keywords) ,
#        result_ptr => 0,
#        show_me => 100,
#        ( $self->{script_type} ? ( script_type => $self->{script_type} ) : () ),
#        ( $self->{order_by} ? ( order_by => $self->{order_by} )  : () ),
#    );
    # Vimana::VimOnline::SearchResult->display( $results );
}



1;
