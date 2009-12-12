package Vimana::PackageFile;
use warnings;
use strict;
use Vimana::Logger;
use Vimana::Util;
use Archive::Any;
use LWP::Simple qw();
use File::Spec;
use File::Path;
use File::Copy;
use base qw(Vimana::Accessor);
__PACKAGE__->mk_accessors( qw(
    cname
    file 
    url 
    filetype 
    info 
    page_info 
    archive
) );


=head1 FUNCTIONS

=head2 is_archive

=head2 is_text

=head2 is_vimball

=head2 script_type

=head2 script_is

=head2 download

=head2 preprocess

=head2 postprocess

=cut

sub is_archive { $_[ 0 ]->filetype =~ m{(x-bzip2|x-gzip|x-gtar|zip|rar|tar)} ? 1 : 0; }

sub is_text { $_[ 0 ]->filetype =~ m{octet-stream} ? 1 : 0 }

sub is_vimball {  $_[0]->file =~ m/\.vba$/  }

sub script_type { $_[ 0 ]->info->{type}   }

sub script_is { $_[ 0 ]->script_type eq $_[1] }

sub download {
    my $self = shift;

    my $file_content = LWP::Simple::get( $self->url );
    unless( $file_content ) {
        $logger->error('Can not download file');
        return 0;
    }

    unlink $self->file if -e $self->file;

    print "Saving file to " . $self->file . "\n";
    open FH, ">", $self->file or die $@;
    print FH $file_content;
    close FH;

    return 1;
}


sub preprocess {
    my $self = shift;
    $self->detect_filetype unless $self->filetype;
    if( $self->filetype and $self->is_archive ) {
        $self->archive( Archive::Any->new( $self->file ) );
        die "Can not read archive file: @{[ $self->file ]}" unless $self->archive;
    }
}

sub DESTROY {
    my $self = shift;
    # clean up myself
    # unlink $self->file if $self->file;
}

sub detect_filetype { 
    my $self = shift;
    $self->filetype( 
        Vimana::Util::get_mine_type( $self->file )
    );

}

sub archive_files {
    my $self = shift;
    $self->{_archive_files} ||= [ $self->archive->files ];
    return $self->{_archive_files} if $self->{_archive_files};
}

sub content {
    my $self = shift;
    local $/;
    open my $fh , "<" , $self->file;
    my $content = <$fh>;
    close $fh;
    return $content;
}

sub has_metafile {
    my $self = shift;
    my @files = grep /makefile/i , $self->archive->files();
    return @files if scalar @files;
    return undef;
}

sub has_makefile {
    my $self = shift;
    my @files = grep /makefile/i , $self->archive->files();
    return @files if scalar @files;
    return undef;
}

sub has_vimball {
    my $self = shift;
    my @files = $self->archive->files();
    @files = grep /\.vba$/i , @files;
    return @files if scalar @files;
    return undef;
}

sub auto_install {
    my $self = shift;
    my %args = @_;

    require Vimana::AutoInstall;
    my $auto = Vimana::AutoInstall->new( { package => $self , options => \%args } );
    return $auto->run();  # XXX: dry_run , verbose

}

=head2 $pkgfile->copy_to( '/path/to/file' )

=cut

sub copy_to {
    my ( $self , $path ) = @_;
    my $src = $self->file;
    my ( $v, $dir, $file ) = File::Spec->splitpath($path);
    File::Path::mkpath [ $dir ];

    $logger->info( "Copying $src to $path" );
    my $ret = File::Copy::copy( $src => $path );
    $ret 
        ?  $logger->info("Done")
        :  $logger->error( $! ) ;
    $ret;
}


=head2 $pkgfile->copy_to_rtp( $type )

copy to vim runtime path

=cut

sub copy_to_rtp {
    my ( $self, $type ) = @_ ;
    my $target = File::Spec->join( runtime_path(), $type );
    return $self->copy_to($target);
}


use Vimana::Util;
sub extract_to {
    my ($self,$path) = @_;
    my $out = Vimana::Util::tempdir();
    rmtree [ $out ] if -e $out;
    mkpath [ $out ];
    $logger->info("Temporary directory created: $out");
    $logger->info("Extracting to: $out");
    $pkg->archive->extract( $out );  
    return $out;
}


1;
