use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Vim::Get',
    AUTHOR              => 'Cornelius <cornelius@cpan.org>',
    VERSION_FROM        => 'lib/Vim/Get.pm',
    ABSTRACT_FROM       => 'lib/Vim/Get.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
        'Web::Scraper' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'Vim-Get-*' },
);
