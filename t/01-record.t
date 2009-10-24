use lib 'lib';
use Test::More tests => 4;
# use Test::More skip_all => "skip";
use File::Path;

BEGIN {
    use_ok('Vimana::Record');
    $ENV{VIMANA_BASE} = '/tmp/vimana_test'
}

File::Path::mkpath [ $ENV{VIMANA_BASE} ];

Vimana::Record->add({
    cname => "test.vim",
    files => [ qw(
        plugin/xxx
        plugin/aaa
    )],
});


my $record = Vimana::Record->load();
ok( $record );

is_deeply( $record, {
        'test.vim' => {
            'files' => [ 'plugin/xxx', 'plugin/aaa' ],
            'cname' => 'test.vim'
        } } );

my $find = Vimana::Record->find('test.vim');
ok( $find );

File::Path::rmtree [ $ENV{VIMANA_BASE} ];
