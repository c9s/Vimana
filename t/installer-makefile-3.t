#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 2;
use Cwd;
use File::Path qw(mkpath rmtree);
use File::Temp qw(tempdir);

my $dir = getcwd;
my $tmppath = tempdir();
mkpath [ $tmppath ];
chdir $tmppath;

open FH, ">" , "makefile";
print FH "no_install:\n";
print FH "\t\t\@echo 1\n";
close FH;

ok( -e 'makefile' );

use Vimana::Installer::Makefile;
my $installer = Vimana::Installer::Makefile->new();

my $ret = $installer->run( $tmppath );
ok( ! $ret );

chdir $dir;
rmtree [ $tmppath ];
