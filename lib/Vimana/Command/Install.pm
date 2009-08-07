package Vimana::Command::Install;
use warnings;
use strict;
use URI;
require LWP::UserAgent;
# require Vimana::VimOnline;
use base qw(App::CLI::Command);


sub options {
    (
        'v|verbose'     => 'verbose',
        'y|yes'         => 'assume_yes',
    );
}

sub run {
    my ( $self, $package ) = @_;

    my $ua = LWP::UserAgent->new;
    my $response = $ua->get( $script_uri );
    
    # get script filename 

    # get download url

    # downlaod as 


}


1;
