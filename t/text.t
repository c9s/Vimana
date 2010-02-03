#!/usr/bin/env perl
use warnings;
use strict;
use Test::More tests => 2;
use File::Path qw(mkpath rmtree);

use Vimana::PackageFile;
use Vimana::Installer::Text;

mkpath [ File::Spec->join(qw(test plugin)) ];

my $pkgfile = Vimana::PackageFile->new( {
        cname      => 'gist.vim',
        file      => 't/data/gist.vim',
        url       => "",
        info      => { },
        page_info => { },
} );

my $installer = Vimana::Installer::Text->new( { package => $pkgfile, runtime_path => 'test' } );
my $ret = $installer->run( $pkgfile );
ok( $ret );

ok( -e File::Spec->join(qw(test plugin gist.vim)));
rmtree [ 'test' ];
