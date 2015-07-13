#!/usr/bin/env perl
use warnings;
use strict;
use lib 'lib';
use Test::More tests => 4;

sub inst {
    my $type = shift;
    my $cls = 'Vimana::Installer::' . ucfirst( $type );
    use_ok( $cls );
}

inst( $_ ) for qw(text makefile rakefile vimball);

