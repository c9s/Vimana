package Vimana::Record;
use warnings;
use strict;
use Vimana;
use File::Path;
BEGIN {
    eval 'use YAML::Syck;';
    if( $@ ) {
        use YAML;
    }
}

sub record_dir { return ( $ENV{VIMANA_BASE} || $ENV{HOME} ) . '/.vimana'; }

sub record_file {  $_[0]->record_dir . '/index' }

sub load {
    my $class = shift;
    my $path =  $class->record_dir;
    if( ! -e $path ) {
        File::Path::mkpath( $path );
    }

    my $record_file =  $class->record_file;
    my $record = LoadFile( $record_file ) if -e $record_file;
    return $record || {};
}

sub save {
    my ($class,$new_record)= @_;
    my $record_file = $class->record_file;
    DumpFile( $record_file , $new_record );
}


sub find {
    my ($class,$cname) = @_;
    my $record = $class->load();
    return $record->{$cname} if defined $record->{ $cname };
}

sub add {
    my ( $class, $info ) = @_;
    my $record = $class->load;

    if( defined $record->{ $info->{cname} } ) {
        return 0;
    }

    $record->{  $info->{cname}  } = $info;
    $class->save( $record );
    return $record;
}

=pod

    # XXX: check if cname conflicts
    sub set {
        my $class = shift;
        my %args = @_;
        my $recordset = $class->get_recordset();
        $recordset->{ $args{cname} } = {
            cname => $args{cname} , 
            files => [ ],
            type  => undef,
            install_date  => undef,
            %args,
        };
        $class->set_recordset( $recordset );
    }

=cut


1;
