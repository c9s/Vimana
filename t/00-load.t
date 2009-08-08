#!perl
use lib 'lib';

use Test::More tests => 7;

BEGIN {
	use_ok( 'Vimana' );
    use_ok( 'Vimana::VimOnline');
    use_ok( 'Vimana::PackageFile');
    use_ok( 'Vimana::Index');
    use_ok( 'Vimana::Logger');
    use_ok( 'Vimana::AutoInstall');
    use_ok( 'Vimana::Util');
}

diag( "Testing Vimana $Vimana::VERSION, Perl $], $^X" );
