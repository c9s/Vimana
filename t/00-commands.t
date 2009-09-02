#!perl
use lib 'lib';
use Test::More tests => 6;
BEGIN {

    use_ok( 'Vimana::Command::Download' );
    use_ok( 'Vimana::Command::Info' );
    use_ok( 'Vimana::Command::Install' );
    use_ok( 'Vimana::Command::Search' );
    use_ok( 'Vimana::Command::Update' );
    use_ok( 'Vimana::Command::Upgrade' );

}

