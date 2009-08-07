use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME          => 'Vim::Get',
    AUTHOR        => 'Cornelius <cornelius@cpan.org>',
    VERSION_FROM  => 'lib/Vim/Get.pm',
    ABSTRACT_FROM => 'lib/Vim/Get.pm',
    PL_FILES      => {},
    PREREQ_PM     => {
        'Test::More'                 => 0,
        # 'Web::Scraper'               => 0,
        'App::CLI'                   => 0.08,
        'File::Type'                 => 0,
        'Archive::Any'               => 0,
        'Cache::File'                => 0,
        'File::Copy::Recursive '     => 0,
        'File::Find::Rule'           => 0,
        'File::Path '                => 0,
        'File::Spec'                 => 0,
        'File::Temp'                 => 0,
        'Getopt::Long '              => 0,
        'LWP::UserAgent'             => 0,
        'URI'                        => 0,
        'App::CLI App::CLI::Command' => 0,
        'App::CLI::Command'          => 0,
        'Class::Accessor::Fast'      => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES    => 'Vim-Get-*' },
);
