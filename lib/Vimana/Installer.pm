package Vimana::Installer;
use base qw(Vimana::Accessor);
use warnings;
use strict;
use Vimana::Logger;

use constant _continue => 0;

__PACKAGE__->mk_accessors( qw(package args) );

sub run { }

1;

