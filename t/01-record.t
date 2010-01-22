#!/usr/bin/env perl 
use lib 'lib';
use Test::More tests => 6;
use File::Path;

BEGIN {
    use_ok('Vimana::Record');
    $ENV{VIM_RECORD_DIR} = '/tmp/vimana_test'
}

File::Path::mkpath [ $ENV{VIM_RECORD_DIR} ];

my $ret;
$ret = Vimana::Record->add({
    package => "test.vim",
    files => [ qw(
        plugin/xxx
        plugin/aaa
    )],
});
ok( $ret );

$ret = Vimana::Record->add({
    package => "test2.vim",
    files => [ qw(
        plugin/asdf
        plugin/zcxv
    )],
});
ok( $ret );

$ret = Vimana::Record->add({
    package => "test2.vim",
    files => [ qw(
        plugin/asdf
        plugin/zcxv
    )],
});
ok( ! $ret );

my $record = Vimana::Record->load('test.vim');
ok( $record );

is_deeply( $record, {
            'files' => [ 'plugin/xxx', 'plugin/aaa' ],
            'package' => 'test.vim'
        });

END {
    File::Path::rmtree [ $ENV{VIM_RECORD_DIR} ];
}
