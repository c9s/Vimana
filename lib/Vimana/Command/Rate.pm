package Vimana::Command::Rate;
use warnings;
use strict;
use base qw(App::CLI::Command);
use LWP::Simple;
sub options {
    ();
}

sub run {
    my ($cmd,$package_name,$rate_nr) = @_;
    if( $rate_nr < 0 or $rate_nr > 2 ) {
        print "Available Rating Number is (0-2).\n";
        print " 0: unfulfilling , 1: helpful, 2: life changing\n";
        return;
    }
    
    my @rate = qw(unfulfilling helpful life_changing);
    my $info = Vimana->index->find_package( $package_name );
    my $url = 
        sprintf('http://www.vim.org/scripts/script.php?script_id=%d&rating=%s',
                $info->{script_id} , $rate[ $rate_nr ] );

    print "Rating - " . ucfirst($rate[ $rate_nr ]) . "\n";
    LWP::Simple::get( $url );
    print "Done\n";
}


1;
