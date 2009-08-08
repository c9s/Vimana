#!perl
use lib 'lib';

use Test::More tests => 11;

BEGIN {
    $ENV{VIMANA_RUNTIME_PATH} = '/tmp/vimana-test';
	use_ok( 'Vimana' );
    use_ok( 'Vimana::VimOnline');
    use_ok( 'Vimana::PackageFile');
    use_ok( 'Vimana::Index');
    use_ok( 'Vimana::Logger');
    use_ok( 'Vimana::AutoInstall');
    use_ok( 'Vimana::Command::Install');
}

use File::Path qw(mkpath rmtree);
my $path = '/tmp/vimana-test' ;
mkpath [ $path ];
my $cmd = Vimana::Command::Install->new;
my $ret = $cmd->run( 'rails.vim' );   # smart install
ok( $ret );

# inspect directory
ok( -e File::Spec->join( $path, 'doc',      'rails.txt' ) );
ok( -e File::Spec->join( $path, 'autoload', 'rails.vim' ) );
ok( -e File::Spec->join( $path, 'plugin',   'rails.vim' ) );


rmtree [ $path ];



