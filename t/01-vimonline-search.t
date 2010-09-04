use strict;
use warnings;

use Test::More;
use lib 'lib';

use_ok('Vimana::VimOnline::Search');

my $total = Vimana::VimOnline::Search->all_vim_plugins;
note $total;
ok($total =~ /\d+/, "all_vim_plugins should return number");

done_testing;
