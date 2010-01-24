package Vimana::Command::Help;
use warnings;
use strict;
use base qw(App::CLI::Command);

sub run {

    print <<END

    Usage:

        \$ vimana [command] [arguments]

    Avaliable Commands:

        update          - update index for searching.
        install (i)     - install package
        remove  (r)     - remove package
        search  (s)     - search packages
        help            - show this help

    
END

}

1;
