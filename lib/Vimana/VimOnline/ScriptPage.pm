package Vimana::VimOnline::ScriptPage;
use warnings;
use strict;
use URI;
use LWP::Simple qw();
use HTML::Entities;
use Regexp::Common qw(URI);

use Web::Scraper;

use utf8;
# use Lingua::ZH::Wrap qw(wrap $columns $overflow);
use Text::Wrap qw(wrap $columns $huge);

$columns  = 72;             # Change columns
$huge = 'overflow';
# $overflow = 1;              # Chinese char may occupy 76th col

sub fetch {
    my ( $class, $id ) = @_;
    my $uri  = page_uri($id);
    my $info = scrape($uri);
    unless( $info ) {
        die "Can't retrieve vim.org content.\n";
    }
    return $info;
}

sub page_uri {
    my $id = shift;
    my $uri = URI->new("http://www.vim.org/scripts/script.php");
    $uri->query_form( script_id => $id );
    return $uri;
}

sub find_urls {
    my $content = shift;
    my @urls = ($content =~ /$RE{URI}{HTTP}{-scheme => '(https|http)'}|$RE{URI}{FTP}/g);
    return @urls;
}

sub display {
    my ( $class, $info ) = @_;

    if ($^O eq 'MSWin32') {
        eval { require "Win32/API.pm" };
        unless ($@) {
            Win32::API->Import('kernel32', 'UINT GetACP()');
            my $cp = "cp".GetACP();
            binmode STDOUT, ":encoding($cp)";
        }
    }

    print <<INFO;

 @{[ $info->{title} ]}              

 TYPE:            @{[ $info->{type} ]}
 VERSION:         @{[ $info->{version} ]}
 VIM VERSION:     @{[ $info->{vimver} ]}

 CREATE DATE:     @{[ $info->{date} ]}

 AUTHOR NAME:     @{[ $info->{author_name} ]}
 AUTHOR PROFILE:  @{[ $info->{author_url} ]}

 DESCRIPTION:

 @{ [ wrap( ' ', '  ', $info->{description} ) ] }

 INSTALL DETAILS:

 @{ [ wrap( ' ', '  ', $info->{install_details} ) ] }

 FILENAME:   @{ [ $info->{filename} ] }

 DOWNLOAD:   @{ [ $info->{download} ] }

INFO
}

#
# We can use Web::Scraper with XPath.
#
sub scrape {
    my $uri = shift;

    my $scraper = scraper {
        process "/html/body/table[2]/tr/td[3]/table/tr/td", info => scraper {
            process "//span[1]", title => sub {
                if ( $_->as_text =~ /(.+) : / ) {
                    return $1;
                }
            };
            process "//p/table/tr[2]/td/a[1]", author_name => 'TEXT', author_url => '@href';

            process "//p/table/tr[5]/td[1]", type => 'TEXT';
            process "//p/table/tr[8]/td[1]", description => 'TEXT';
            process "//p/table/tr[11]/td[1]", install_details => 'TEXT';

            process "//p[3]/table/tr[2]/td[1]/a", download => '@href', filename => 'TEXT';
            process "//p[3]/table/tr[2]/td[2]", version => 'TEXT';
            process "//p[3]/table/tr[2]/td[3]", date => 'TEXT';
            process "//p[3]/table/tr[2]/td[4]", vimver => 'TEXT';
        };
        result 'info';
    };

    my $info = $scraper->scrape($uri);
    $info->{author_url} = $info->{author_url}->as_string;
    $info->{download} = $info->{download}->as_string;

    return $info;
}
