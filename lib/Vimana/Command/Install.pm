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

#    my $ua = LWP::UserAgent->new;
#    my $response = $ua->get( $script_uri );
    require Vimana::VimOnline::ScriptPage;

    my $index = Vimana->index();
    my $info = $index->find_package( $package );
    use Data::Dumper; warn Dumper( $info );

    my $script_info = Vimana::VimOnline::ScriptPage->fetch( $info->{script_id} ) ;
    use Data::Dumper; warn Dumper( $script_info );




    
    # get script filename 
    # get download url

    # downlaod as 


}


1;
