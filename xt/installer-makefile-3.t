#!/usr/bin/env perl
use warnings;
use strict;
use Test::More tests => 2;

use File::Path qw(mkpath rmtree);

mkpath [ '/tmp/test' ];
chdir '/tmp/test';

open FH, ">" , "makefile";
print FH "no_install:\n";
print FH "\t\t\@echo 1\n";

ok( -e 'makefile' );

use Vimana::Installer::Makefile;
my $installer = Vimana::Installer::Makefile->new();

my $ret = $installer->run( '/tmp/test' );
ok( ! $ret );


rmtree [ '/tmp/test' ];
