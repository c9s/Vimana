package Vimana::Installer::Vimball;
use warnings;
use strict;
use base qw(Vimana::Installer);
use Vimana::Util;
use Vimana::Logger;
use Vimana::Record;
use Vimana::VimballInstall;

sub run {
    my $self = shift;
    my $file = $self->target;
    my $vim = find_vim();
    print "Installing Vimball File: $file\n";
    system( qq|$vim $vimball -c ":so %" -c q|);

    # XXX: get vimball files and translate to record.



}

1;
