#!perl
use lib 'lib';
use Test::More tests => 4;

BEGIN {
    use_ok('Vimana::PackageFile');
}


my $pkgfile = Vimana::PackageFile->new({
       file => "test",
       url =>  "http://www.google.com.tw/",
       info => { } ,
       page_info => { } ,
 });
ok( $pkgfile );

is( $pkgfile->file , "test" );
is( $pkgfile->url , "http://www.google.com.tw/" );
