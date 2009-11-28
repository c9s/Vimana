#!perl
use Test::More tests => 6;
use lib 'lib';

package Orz;
use base qw(Vimana::Accessor);
__PACKAGE__->mk_accessors(qw(f1 f2 xxx));


package main;
my $o = Orz->new({ f1 => 123 , f2 => 'zxcv' });
ok( $o );
ok( $o->f1 );
is( $o->f1 , 123 );
is( $o->f2 , 'zxcv' );
ok( ! $o->xxx );

$o->xxx( 'zzzz' );

is( $o->xxx , 'zzzz');
