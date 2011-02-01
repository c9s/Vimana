use strict;
use warnings;

use Test::More;
plan skip_all => "Data::Util is required for this test" unless eval "use Data::Util qw/:check/; 1";

use Path::Class;
use URI;
use Regexp::Common qw(URI);

use lib 'lib';

use_ok('Vimana::VimOnline::ScriptPage');

# page_uri 

my $script_uri = "http://www.vim.org/scripts/script.php";
my $uri_queried = Vimana::VimOnline::ScriptPage::page_uri("1234");
is($uri_queried->as_string, "$script_uri?script_id=1234");


# find_urls 

my @urls = Vimana::VimOnline::ScriptPage::find_urls(<<CONTENT);
http://google.com
htt://google.com
ttp://google.com
https://google.com
ftp://google.com
tp://google.com
CONTENT

is(scalar @urls, 3, "find_urls scrape content to get urls");


# scrape

my $info = Vimana::VimOnline::ScriptPage::scrape(URI->new("http://www.vim.org/scripts/script.php?script_id=2620"));

while ( my ($key, $value) = each %$info ) {
  ok(is_string($value), "all values should be scraped as string");

  if ( $key eq 'download' || $key eq 'author_url' ) {
    like($value, qr/$RE{URI}{HTTP}/, "$key should be url");
  }
}

done_testing;
