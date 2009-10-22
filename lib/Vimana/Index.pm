package Vimana::Index;
use warnings;
use strict;

use Cache::File;
use Vimana::Logger;
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors( qw(cache) );

sub init {
    my $self = shift;
    $logger->debug("cache::file init");
    my $cache = Vimana->cache;
    $logger->debug("cache::file done");
    $self->cache( $cache );
}


sub find_package_like {
    my ( $self, $findname ) = @_;
    my $index = $self->get();
    while( my ( $pkg_name , $info ) = each %$index ) {
        if ( $info->{script}->{text} =~ $findname  ) {
            warn " '@{[ $info->{script}->{text} ]}' looks like '$findname'.\n" ;
            return $info ;
        }
    }
    return undef;
}

use Vimana::Util;
sub find_package {
    my ($self, $findname ) = @_;
    my $index = $self->get();
    my $cname = canonical_script_name( $findname );
    $logger->info( "Canonical name: $cname" );
    return defined $index->{ $cname }  ? $index->{ $cname } : undef;
}

use File::Path;

sub index_file {
    my $dir = "/usr/local/share/vimana";
    File::Path::mkpath [ $dir ];
    return $dir . "/index";
}

=head2 update( $plugins )

update index . $plugins is a hashref contains :

    'rsl.vim' => {
        'downloads' => '408',
        'script'    => {
            'link' => 'script.php?script_id=1297',
            'text' => 'rsl.vim'
        },
        'summary' => {
            'link' => 'script.php?script_id=1297',
            'text' => 'Basic syntax for RSL (droidarena.net).'
        },
        'type'      => 'syntax',
        'script_id' => '1297',
        'rating'    => '2'
    }

=cut

sub update {
    my ($self, $plugins ) = @_;

    my $index_file = $self->index_file;

    # merge results
    # [ name | script_id | type | description ]
    $|++;
    my $cnt = 0;
    open my $fh , ">" , $index_file or die $@;
    for my $plugin_name ( keys %$plugins ) {
        print "\rupdating index: ";
        print $cnt++;

        my $v = $plugins->{ $plugin_name };
        print $fh join("\t", $plugin_name , $v->{script_id} , $v->{type} , $v->{summary}->{text} )."\n";
    }
    close $fh;
    print "\nindex updated\n";
}

sub get {
    my $self = shift;
    my $ret = $self->cache->get( 'index' );
    $logger->debug('thawing...');
    $ret = Storable::thaw $ret;
    $logger->debug('done');
    return $ret if $ret;
    return undef;
}



1;
