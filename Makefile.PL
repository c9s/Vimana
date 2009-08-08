

use strict;
use inc::Module::Install;
name 'Vimana';
author 'You-An Lin <cornelius.howl@gmail.com>';
abstract 'Vim script port manager';
license 'perl';
version_from 'lib/Vimana.pm';
install_script 'bin/vimana';
requires
    'Test::More'            => 0,
    'App::CLI'              => 0.08,
    'File::Type'            => 0,
    'Archive::Any'          => 0,
    'Cache::File'           => 2.04,
    'File::Copy::Recursive' => 0.38,
    'File::Find::Rule'      => 0.30,
    'File::Path'            => 2.07,
    'File::Spec'            => 0,
    'File::Temp'            => 0,
    'Storable'              => 0,
    'Getopt::Long'          => 0,
    'LWP::UserAgent'        => 0,
    'LWP::Simple'           => 0,
    'URI'                   => 1.37,
    'Exporter::Lite'        => 0,
    'File::Which' => 0,
    'Moose' => 0;

include('ExtUtils::AutoInstall');
auto_install();
auto_provides();

my $ret = qx( vim --version );
die "Can not found Vim , Please install Vim on your system" unless $ret =~ /^VIM - Vi IMproved/ ;

print "Vim found:\n" . '-' x 10 . "\n";
my @lines = split("\n", $ret );
print join( "\n" , splice(  @lines , 0 , 3 ) ) , "\n";
print '-' x 10 . "\n";

WriteAll( sign => 0 );

1;
