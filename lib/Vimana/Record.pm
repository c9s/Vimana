package Vimana::Record;
use warnings;
use strict;
use Vimana;
use Vimana::Util;
use JSON::PP;
use File::Path;
use Digest::MD5 qw(md5_hex);
use YAML;

sub new_json {
    return JSON::PP->new->allow_singlequote(1);
}

sub record_dir {
    return (  $ENV{VIM_RECORD_DIR} ||
        do {
            my @rtps = get_vim_rtp();
            File::Spec->join($rtps[0],'record');
        }  );
}

sub record_path  {
    my ( $class, $pkgname ) = @_;
    my $record_dir =  $class->record_dir();
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
        installer_type => 'auto',  # auto , make , rake ... etc
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

    open my $fh , '<' , $record_file;
    local $/;
    my $json = <$fh>;
    close $fh;

    my $record;
    eval { $record = new_json()->decode( $json ) };
    if( $@ ) {
        # try to load YAML. (old record file)
        print STDERR $@;
        $record = YAML::LoadFile( $record_file );
        unless( $record ) {
            print STDERR "Can not load record. Use -f or --force option to remove.\n";
            return;
        }
    }
    return $record;
}


sub _remove_record {
    my ($self,$pkgname) = @_;
    my $file = $self->record_path( $pkgname );
    return unlink $file;
}

sub remove {
    my ( $self, $pkgname , $force , $verbose ) = @_;
    my $record = $self->load($pkgname);

    if( !$record and $force ) {
        # force remove record file.
        $self->_remove_record( $pkgname );
        return;
    }

    return unless $record;

    my $files = $record->{files};
    print "Removing package $pkgname\n";
    for my $entry (@$files) {
        # XXX: check digest here
        print "\tRemoving @{[ $entry->{file} ]}\n" if $verbose;
        unlink $entry->{file};
    }
    $self->_remove_record( $pkgname );
}

sub add {
    my ( $class , $record ) = @_;
    my $pkgname = $record->{package};
    unless( $pkgname ) {
        die "Package name is not declared.";
    }

    my $record_file =  $class->record_path( $pkgname );
    return 0 if -f $record_file;

    open my $fh , '>' , $record_file;
    print $fh new_json()->encode( $record );
    close $fh;
    
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
