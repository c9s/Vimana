

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
    'Cache::File'           => 0,
    'File::Copy::Recursive' => 0,
    'File::Find::Rule'      => 0,
    'File::Path'            => 0,
    'File::Spec'            => 0,
    'File::Temp'            => 0,
    'Getopt::Long'          => 0,
    'LWP::UserAgent'        => 0,
    'LWP::Simple'           => 0,
    'Text::Table'           => 0,
    'URI'                   => 0,
    'Class::Accessor::Fast' => 0;

include('ExtUtils::AutoInstall');
auto_install();
auto_provides();
WriteAll( sign => 0 );


__END__

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Vimana',
    AUTHOR        => 'Cornelius <cornelius@cpan.org>',
    VERSION_FROM  => 'lib/Vimana.pm',
    ABSTRACT_FROM => 'lib/Vimana.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Vimana-*' },
);
