use warnings;
use strict;
use inc::Module::Install;
name 'Vimana';
author 'You-An Lin <cornelius.howl@gmail.com>';
abstract 'Vim script port manager';
license 'perl';
version_from 'lib/Vimana.pm';
install_script 'bin/vimana';
install_script 'bin/vim_record';
requires
    'App::CLI'         => 0.08,
    'Archive::Extract' => 0,
    'Archive::Zip' => 0,
    'DateTime'         => 0,
    'Exporter::Lite'   => 0,
    'File::Path'       => 2.07,
    'File::Spec'       => 0,
    'Path::Class'      => 0,
    'File::Type'       => 0,
    'File::Temp'       => 0,
    'Getopt::Long'     => 0,
    'LWP::Simple'      => 0,
    'LWP::UserAgent'   => 0,
    'URI'              => 1.37,
    'YAML'             => 0,
    'Digest::MD5'      => 0,
    'JSON::PP'         => 0,
    'HTTP::Lite'       => 0,
    'HTML::Entities'   => 0,
    'Mouse'            => 0,
    'Text::Wrap'       => 0,
    'Regexp::Common'   => 0,
    'Web::Scraper'     => 0,
    'Regexp::Common'   => 0,
    'parent'           => 0,
    'Web::Scraper'     => 0;


test_requires 
    'Test::More' => 0.92;

include('ExtUtils::AutoInstall');
auto_install();
auto_provides();

my $ret = qx( vim --version );
die "Could not find Vim, Please install Vim on your system" unless $ret =~ /^VIM - Vi IMproved/ ;

print "Vim found:\n" . '-' x 10 . "\n";
my @lines = split("\n", $ret );
print join( "\n" , splice(  @lines , 0 , 3 ) ) , "\n";
print '-' x 10 . "\n";

repository 'http://github.com/c9s/Vimana';

WriteAll( sign => 0 );
1;
