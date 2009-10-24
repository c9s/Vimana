#!/usr/bin/env perl 
use lib 'lib';
use Test::More tests => 8;
# use Test::More skip_all => "skip";
use File::Path;

BEGIN {
    use_ok('Vimana::Record');
    $ENV{VIMANA_BASE} = '/tmp/vimana_test'
}

File::Path::mkpath [ $ENV{VIMANA_BASE} ];

my $ret ;
$ret = Vimana::Record->add({
    cname => "test.vim",
    files => [ qw(
        plugin/xxx
        plugin/aaa
    )],
});
ok( $ret );

$ret = Vimana::Record->add({
    cname => "test2.vim",
    files => [ qw(
        plugin/asdf
        plugin/zcxv
    )],
});
ok( $ret );

$ret = Vimana::Record->add({
    cname => "test2.vim",
    files => [ qw(
        plugin/asdf
        plugin/zcxv
    )],
});
ok( ! $ret );

my $record = Vimana::Record->load();
ok( $record );

is_deeply( $record, {
        'test.vim' => {
            'files' => [ 'plugin/xxx', 'plugin/aaa' ],
            'cname' => 'test.vim'
        },
        'test2.vim' => {
            cname => "test2.vim",
            files => [ qw(
                plugin/asdf
                plugin/zcxv
            )],
        }
    } );
my $find = Vimana::Record->find('test.vim');
ok( $find );

my $find = Vimana::Record->find('test2.vim');
ok( $find );

File::Path::rmtree [ $ENV{VIMANA_BASE} ];
