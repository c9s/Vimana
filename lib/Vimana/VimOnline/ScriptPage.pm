package Vimana::VimOnline::ScriptPage;
use warnings;
use strict;
use URI;
use LWP::Simple qw();
use Text::Table;
use HTML::Entities;
# use Lingua::ZH::Wrap qw(wrap $columns $overflow);
use Text::Wrap qw(wrap $columns $huge);

$columns  = 72;             # Change columns
$huge = 'overflow';
# $overflow = 1;              # Chinese char may occupy 76th col

sub fetch {
    my ($class,$id) = @_;
    my $uri = page_uri( $id );
    my $html = LWP::Simple::get( $uri );
    return $class->parse( $html );

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





#    my @urls = (
#        find_urls( $info->{DESCRIPTION} ),
#        find_urls( $info->{INSTALL_DETAILS} ),
#    );

    print <<INFO;

 TITLE:           @{[ $info->{TITLE} ]}              
 TYPE:            @{[ $info->{TYPE} ]}
 VERSION:         @{[ $info->{VERSION} ]}
 VIM VERSION:     @{[ $info->{VIMVER} ]}

 CREATE DATE:     @{[ $info->{DATE} ]}

 AUTHOR NAME:     @{[ $info->{AUTHOR_NAME} ]}
 AUTHOR PROFILE:  @{[ $base_uri . $info->{AUTHOR_URL} ]}

 DESCRIPTION:

 @{ [ wrap( ' ' x 4, '  ', $info->{DESCRIPTION} ) ] }

 INSTALL DETAILS:

 @{ [ wrap( ' ' x 4, '  ', $info->{INSTALL_DETAILS} ) ] }

 FILENAME:   @{ [ $info->{FILENAME} ] }

 DOWNLOAD:   @{ [ $base_uri . $info->{DOWNLOAD} ] }

INFO
    
}

# it's very dirty
sub parse {
    my ( $class , $content ) = @_;

    my %info = ();
    $content =~ m{<title>(?<TITLE>.*?)\s:\svim online</title>}gsi;
    %info = ( %info , %- );

    $content =~ m{<tr><td class="prompt">created by</td></tr>
<tr><td><a href="(?<AUTHOR_URL>.*?)">(?<AUTHOR_NAME>.*?)</a></td></tr>}gsi;
    %info = ( %info , %- );

    $content =~ m{<tr><td class="prompt">script type</td></tr>
<tr><td>(?<TYPE>.*?)</td></tr>}gsi;
    %info = ( %info , %- );

    $content =~ m{<tr><td class="prompt">description</td></tr>
.*?<tr><td>(?<DESCRIPTION>.*?)</td></tr>}gsi;
    %info = ( %info , %- );


    $content =~ m{<tr><td class="prompt">install details</td></tr>.*?
<tr><td>(?<INSTALL_DETAILS>.*?)</td></tr>}gsi;
    %info = ( %info , %- );

    $content =~ m{\s*<td class="rowodd" valign="top" nowrap><a href="(?<DOWNLOAD>.*?)">(?<FILENAME>.*?)</a></td>
\s*<td class="rowodd" valign="top" nowrap><b>(?<VERSION>.*?)</b></td>
\s*<td class="rowodd" valign="top" nowrap><i>(?<DATE>.*?)</i></td>
\s*<td class="rowodd" valign="top" nowrap>(?<VIMVER>.*?)</td>
\s*<td class="rowodd" valign="top"><i><a href="(?<AUTHOR_URL>.*?)">(?<AUTHOR_NAME>.*?)</a></i></td>}gsi;
    %info = ( %info , %- );

    map {
            $info{$_}->[0] =~ s{<br/?>}{\n}g;
            $info{$_}->[0] =~ s{</?.+?>}{}g;
            $info{$_} = $info{$_}->[0];
    }  keys %info;
    map { $info{$_} = decode_entities( $info{$_} )  }  keys %info;

    return \%info;

}

1;
