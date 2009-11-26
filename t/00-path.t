use lib 'lib';
use Test::More tests => 1;

use Vimana::Util;

my $path = Vimana::Util::findbin('ls');
ok( $path );

1;
