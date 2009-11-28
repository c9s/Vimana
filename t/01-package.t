#!perl
use lib 'lib';
use Test::More tests => 4;

BEGIN {
    use_ok('Vimana::PackageFile');
}

{
    my $pkgfile = Vimana::PackageFile->new({
        file => "test",
        url =>  "http://www.google.com.tw/",
        info => { } ,
        page_info => { } ,
    });
    ok( $pkgfile );

    is( $pkgfile->file , "test" );
    is( $pkgfile->url , "http://www.google.com.tw/" );
}

{
    my $pkgfile = Vimana::PackageFile->new({
            file => 't/data/rails.zip',
            info => {} ,
            page_info => {} });
    ok( $pkgfile );

    $pkgfile->detect_filetype();
    $pkgfile->preprocess( );

    my @files = $pkgfile->archive->files();
    ok( @files );
    is_deeply(
        [ sort @files ]
        , [ sort ( 'autoload/rails.vim', 'plugin/rails.vim', 'doc/rails.txt' ) ] 
        , 'file list ok');
}




