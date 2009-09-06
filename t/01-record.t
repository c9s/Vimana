
use lib 'lib';
use Test::More tests => 6;
BEGIN {
    use_ok('Vimana::Record');
}

Vimana::Record->set_record(
    cname => 'test',
    files => [ qw(123 foo bar) ],
);

my $recordset = Vimana::Record->get_recordset();
ok( $recordset );
is( ref($recordset) , 'HASH' );

my $record = Vimana::Record->get_record( 'test' );
ok( $record );
is( ref($record) , 'HASH' );

is_deeply( $recordset->{test} , $record );

