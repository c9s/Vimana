package Vimana::Index;
use warnings;
use strict;
use File::Path;
use Vimana::Util;
use Mouse;

has cache =>
    is => 'rw';

sub init {
    my $self = shift;

}


sub find_package_like {
    my ( $self, $findname ) = @_;
    my $index = $self->read_index();
    while( my ( $pkg_name , $info ) = each %$index ) {
        if ( $pkg_name =~ $findname  ) {
            # XXX: should return LIST
            return $info ;
        }
    }
    return;
}

sub find_package {
    my ($self, $findname ) = @_;
    my $index = $self->read_index();
    my $cname = canonical_script_name( $findname );
    return defined $index->{ $cname } ? $index->{ $cname } : undef;
}


sub index_file {
    my $dir = $ENV{HOME} . "/.vimana";
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

        chomp $v->{summary}->{text};
        $v->{summary}->{text} =~ s/^\s*//g;
        $v->{summary}->{text} =~ s/[\n\r\s]*$//g;

        print $fh join("\t", $plugin_name , $v->{script_id} , $v->{type} , $v->{summary}->{text} )."\n";
    }
    close $fh;
    print "\nindex updated\n";
}


=head2 read_index 

read_index return package informations , which is a hashref

    {
        plugin_name => {
            plugin_name => 
            script_id   => 
            type        => 
            description => 
        },

        plugin_name => {
            plugin_name => 
            script_id   => 
            type        => 
            description => 
        },
    }

=cut

sub read_index {
    my $self = shift;
    my $index_file = $self->index_file;

    return unless -e $index_file;

    my $result;
    open my $fh , "<" , $index_file or die $@;
    while( my $line = <$fh> ) {
        chomp $line;
        my ( $plugin_name , $script_id , $type , $description ) = split(/\t/,$line);

        $result->{$plugin_name} = {
            plugin_name => $plugin_name,
            script_id   => $script_id,
            type        => $type,
            description => $description,
        };

    }
    close $fh;
    return $result;
}

sub get {
    my $self = shift;
    return $self->read_index();
}

1;
