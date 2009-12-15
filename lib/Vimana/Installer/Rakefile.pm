package Vimana::Installer::Rakefile;
use base qw(Vimana::Installer);
use warnings;
use strict;

# XXX: check if we have rake command installed.
sub run {
    my $self = shift;
    my $path = shift;
    if ( -e "rakefile" or -e 'rakefile' ) {
        print "Rakefile found. do rake install.\n";
        my $ret = system( "rake install" );
        return 1 if $ret == 0;
    }
    return 0;
}

1;
