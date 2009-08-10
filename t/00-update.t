#!/usr/bin/env perl 
use warnings;
use strict;
use Test::More tests => 3;
use Vimana::VimOnline::Search;
my $result = Vimana::VimOnline::Search->fetch(
    keyword => '',
    show_me => 20,
    order_by => 'creation_date',
    direction => 'ascending'
);
ok( $result );
is( ref $result , 'HASH' );
is( scalar keys %$result  , 20 )
