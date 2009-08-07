#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Vimana' );
}

diag( "Testing Vimana $Vimana::VERSION, Perl $], $^X" );
