package Vimana::VimOnline::ScriptPage;
use warnings;
use strict;
use URI;
use LWP::Simple qw();
use HTML::Entities;
use utf8;
# use Lingua::ZH::Wrap qw(wrap $columns $overflow);
use Text::Wrap qw(wrap $columns $huge);

$columns  = 72;             # Change columns
$huge = 'overflow';
# $overflow = 1;              # Chinese char may occupy 76th col

sub fetch {
    my ( $class, $id ) = @_;
    my $uri  = page_uri($id);
    my $html = LWP::Simple::get($uri);
    unless( $html ) {
        die "Can't retrieve vim.org content.\n";
    }
    return $class->parse($html);
}

sub page_uri {
    my $id = shift;
    my $uri = URI->new("http://www.vim.org/scripts/script.php");
    $uri->query_form( script_id => $id );
    $uri;
}

sub find_urls {
    my $content = shift;
    my @urls = ();
    while ( my ( $url ) = ($content  =~ m{([htf]tps?://\S.*)}g ) ) {
        push @urls , $url;
    }
    return @urls;
}

my $base_uri = 'http://www.vim.org';

sub display {
    my ( $class, $info ) = @_;

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
# vimonline website sucks , i can't found any elemetn class or to scraper by
# Web::Scraper.
#
# so.. it's very dirty
sub parse {
    my ( $class , $content ) = @_;

    use Encode qw(decode);
    $content = decode('utf-8' , $content );
    # map { $info{$_} = decode( 'iso-8859-1' ,  $info{$_} )  }  keys %info;

    my %info = ();
    ( $info{title} ) = 
        $content =~ m{<title>(.*?)\s:\svim online</title>}gsi;

    ( $info{author_url} , $info{author_name} ) = 
        $content =~ m{<tr><td class="prompt">created by</td></tr>\s*<tr><td><a href="(.*?)">(.*?)</a></td></tr>}gsi;

    ( $info{type} ) = 
        $content =~ m{<tr><td class="prompt">script type</td></tr>\s*<tr><td>(.*?)</td></tr>}gsi;

    ( $info{description} ) = 
        $content =~ m{<tr><td class="prompt">description</td></tr>
.*?<tr><td>(.*?)</td></tr>}gsi;

    ( $info{install_details} ) = 
        $content =~ m{<tr><td class="prompt">install details</td></tr>.*?
<tr><td>(.*?)</td></tr>}gsi;

    ( $info{download} , $info{filename} , $info{version} , $info{date} , $info{vimver} , $info{author_url} , $info{author_name} ) =
        $content =~ m{\s*<td class="rowodd" valign="top" nowrap><a href="(.*?)">(.*?)</a></td>
\s*<td class="rowodd" valign="top" nowrap><b>(.*?)</b></td>
\s*<td class="rowodd" valign="top" nowrap><i>(.*?)</i></td>
\s*<td class="rowodd" valign="top" nowrap>(.*?)</td>
\s*<td class="rowodd" valign="top"><i><a href="(.*?)">(.*?)</a></i></td>}gsi;


    map {
            $info{$_} =~ s{<br/?>}{\n}g;
            $info{$_} =~ s{</?.+?>}{}g;
            $info{$_} =~ s{\s*$}{}g;
            $info{$_} =~ s{^\s*}{}g;
            $info{$_} =~ s{&nbsp;}{ }g; # windows don't have 0xA0.
    }  keys %info;


    map { $info{$_} = decode_entities( $info{$_} )  }  keys %info;

    $info{author_url} = $base_uri . $info{author_url};
    $info{download}   = $base_uri . '/scripts/' . $info{download};

    return \%info;

}

1;
