package Vimana::Record;
use warnings;
use strict;
use Vimana;
use JSON;
use File::Path;
use Digest::MD5 qw(md5_hex);
#use YAML;

sub record_path  {
    my ( $class, $pkgname ) = @_;
    my $record_dir =  $ENV{VIM_RECORD_DIR} || File::Spec->join($ENV{HOME},'.vim','record') ;
    if( ! -d $record_dir ) {
        File::Path::mkpath( $record_dir );
    }
    return File::Spec->join( $record_dir , $pkgname );
}

=head2 load

load package record , returns a hashref which contains:

spec:
    {
        version => 0.1,
        generated_by => 'Vimana [Version]'
        install_type => 'auto',  # auto , make , rake ... etc
        meta => {
            author: Cornelius
            email: cornelius.howl@gmail.com
            libpath: ./
            name: gsession.vim
            script_id: 2885
            type: plugin
            version: 0.21
            version_from: plugin/gsession.vim
            vim_version:
        },
        files => [
            { file => "/Users/c9s/.vim/plugin/gsession.vim", checksum => "md5checksum" }
        ]
    }

=cut

sub load {
    my ( $class, $pkgname ) = @_;
    my $record_file =  $class->record_path( $pkgname );

    if( ! -e $record_file ) {
        print STDERR "Package $pkgname is not installed.\n";
        return ;
    }

    open FH , "<" , $record_file;
    local $/;
    my $json = <FH>;
    close FH;

    #YAML::LoadFile( $record_file );
    my $record = from_json( $json );
    unless( $record ) {
        print STDERR "Can not load record\n";
        return ;
    }
    return $record;
}

sub remove {
    my ( $class , $pkgname ) = @_;
    my $record = $class->load( $pkgname );
    return unless $record;

    my $files = $record->{files};
    print "Removing package $pkgname\n";
    for my $entry ( @$files ) {
        # XXX: check digest here
        print "\tRemoving @{[ $entry->{file} ]}\n";
        unlink $entry->{file};
    }

    print "Removing record\n";
    my $file = $class->record_path( $pkgname );
    unlink $file;
    print "Done\n";
}

sub add {
    my ( $class , $record ) = @_;
    my $pkgname = $record->{package};
    unless( $pkgname ) {
        die "Package name is not declared.";
    }

    my $record_file =  $class->record_path( $pkgname );
    return 0 if -f $record_file;

    open FH , ">" , $record_file;
    print FH to_json( $record );
    close FH;
    
    #return YAML::DumpFile( $record_file , $record  );
}

sub mk_file_digest {
    my ($self,$file) = @_;
    open my $fh , "<" , $file;
    binmode $fh,':bytes';
    local $/;
    my $content = <$fh>;
    close $fh;
    return md5_hex( $content );
}

sub mk_file_digests {
    my $self = shift;
    my @files = @_;
    my @e = ();
    for my $f ( @files ) {
        my $ctx = $self->mk_file_digest( $f );
        # print " $ctx: $f\n";
        push @e, { file => $f , checksum => $ctx };
    }
    return @e;
}

1;
