package Vimana::Command::Help;
use warnings;
use strict;
use parent qw(App::CLI::Command);

sub run {
    my ($self,$topic) = @_;

    # if $arg is topic

    # if $arg is command
    if (my $cmd = eval { Vimana::Command->get_cmd ($topic) }) {
        $cmd->usage(1);
    }
    else {

        print <<END;

Usage:

    \$ vimana [command] [arguments]

Avaliable Commands:

    update          - update index for searching.

    install (i)     - install package

        install [options] [plugin name]

        Options:

            -r,--runtime-path [path]      
                install to [path] runtime path.
                you might need to add 'runtimepath' option 
                in your .vimrc file.

            -v,--verbose                  
                verbose message

            -y,--yes                      
                assume yes

            -f,--force                    
                force install

    installed       - list installed packages.

    remove  (r)     - remove package
        
        remove [options] [plugin] 


        Options:

            -f,--force
                force remove

    search  (s)     - search packages

        search [keyword]

    help            - show this help

        help [command]
        help [topic]

Help Topics:

END
    }

}

1;
