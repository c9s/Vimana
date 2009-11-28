#!perl
use lib 'lib';
use Test::More tests => 9;

BEGIN {
    use_ok('Vimana::PackageFile');
}


diag "basic";
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


diag "directory detection";
{
    my $pkgfile = Vimana::PackageFile->new({
            file => 't/data/rails.zip',
            info => {} ,
            page_info => {} });
    ok( $pkgfile );

    $pkgfile->preprocess( );

    ok( $pkgfile->is_archive );

    my @files = $pkgfile->archive->files();
    ok( @files );
    is_deeply(
        [ sort @files ]
        , [ sort ( 'autoload/rails.vim', 'plugin/rails.vim', 'doc/rails.txt' ) ] 
        , 'file list ok');
}


diag "makefile";
{
    my $pkgfile = Vimana::PackageFile->new({
            file => 't/data/rails.zip',
            info => {} ,
            page_info => {} });
    ok( $pkgfile );
    $pkgfile->detect_filetype();
    $pkgfile->preprocess( );

}


diag "metafile";

