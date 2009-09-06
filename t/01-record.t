
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
ok( $recordset , 'get record set' );
is( ref($recordset) , 'HASH' , 'hash' );

my $record = Vimana::Record->get_record( 'test' );
ok( $record , 'get record' );
is( ref($record) , 'HASH' );

is_deeply( $recordset->{test} , $record , 'test record' );
