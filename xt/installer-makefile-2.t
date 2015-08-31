#!/usr/bin/env perl
use warnings;
use strict;

use Test::More tests => 2;
use File::Temp qw(tempdir);
use File::Path qw(mkpath rmtree);

my $dir = tempdir(  CLEANUP => 1 );
mkpath [ $dir ];
chdir $dir;

open my $fh, ">" , "Makefile";
print $fh "install:\n";
print $fh "\t\t\@echo 1\n";
close $fh;

ok( -e 'Makefile' );

use Vimana::Installer::Makefile;
my $installer = Vimana::Installer::Makefile->new();

my $ret = $installer->run( $dir );
ok( $ret );
