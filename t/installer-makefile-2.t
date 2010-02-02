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

open FH, ">" , "Makefile";
print FH "install:\n";
print FH "\t\t\@echo 1\n";
close FH;

ok( -e 'Makefile' );

use Vimana::Installer::Makefile;
my $installer = Vimana::Installer::Makefile->new();

my $ret = $installer->run( $tmppath );
ok( $ret );

chdir $dir;
rmtree [ $tmppath ];
