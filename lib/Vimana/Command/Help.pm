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

            install [plugin]

        remove  (r)     - remove package
            
            remove [plugin] 

        search  (s)     - search packages

            search [keyword]

        help            - show this help

            help [command]
            help [topic]

    Help Topics:

    
END

}

1;
