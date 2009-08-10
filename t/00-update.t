#!/usr/bin/env perl 
use warnings;
use strict;
use Test::More tests => 16;
use Vimana::VimOnline::Search;
my $result = Vimana::VimOnline::Search->fetch(
    keyword => '',
    show_me => 20,
    order_by => 'creation_date',
    direction => 'ascending'
);
ok( $result );
is( ref $result , 'HASH' );
is( scalar keys %$result  , 20 );


my ($name , $info) = each %$result;
require Vimana::VimOnline::ScriptPage;
my $script_info = Vimana::VimOnline::ScriptPage->fetch(  $info->{script_id}  ) ;
ok( $script_info );
is( ref $script_info , 'HASH' );
ok( defined $script_info->{$_} ) for qw(author_name author_url date version vimver description install_details filename title type download);
