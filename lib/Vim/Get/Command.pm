package Vim::Get::Command;
use warnings;
use strict;

use base qw(App::CLI App::CLI::Command);
use Getopt::Long qw(:config no_ignore_case bundling);

sub invoke {
    my ($pkg , $cmd,  @args) = @_;
    my ($ret);

    local *ARGV = [$cmd, @args];

    $ret = eval {
        $pkg->dispatch();
    };

    # $logger->info( $ret) if $ret && $ret !~ /^\d+$/;
#    if ($@ && !ref($@)) {
#        $logger->info("$@");
#    }    
    # $ret = 1 if ($ret ? $ret !~ /^\d+$/ : $@); 
    warn $@ if $@;

    return ($ret || 0);
}


1;


