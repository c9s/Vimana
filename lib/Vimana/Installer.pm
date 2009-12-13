package Vimana::Installer;
use base qw(Vimana::Accessor);
use warnings;
use strict;
use Vimana::Logger;

__PACKAGE__->mk_accessors( qw(package) );

sub run { }

1;

