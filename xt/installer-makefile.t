#!/usr/bin/env perl
use warnings;
use strict;
use Test::More tests => 2;
use File::Path qw(mkpath rmtree);

mkpath [ '/tmp/test' ];
chdir '/tmp/test';

open FH, ">" , "Makefile";
print FH "install:\n";
print FH "\t\t\@echo 1\n";

ok( -e 'Makefile' );

use Vimana::Installer::Makefile;
my $installer = Vimana::Installer::Makefile->new();

my $ret = $installer->run( undef, '/tmp/test' );
ok( $ret );

rmtree [ '/tmp/test' ];
