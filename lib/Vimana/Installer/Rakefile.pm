package Vimana::Installer::Rakefile;
use parent qw(Vimana::Installer);
use warnings;
use strict;

# XXX: check if we have rake command installed.
sub run {
    my ($self)=@_;
    if ( -e "rakefile" or -e 'Rakefile' ) {
        print "Rakefile found. do rake install.\n";
        my $ret = system( "rake install" );
        return 1 if $ret == 0;
    }
    return 0;
}

1;
