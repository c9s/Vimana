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

# only add supported archive types
sub is_archive { $_[ 0 ]->filetype =~ m{(?:x-bzip2|x-gzip|x-gtar|zip|rar|tar)} ? 1 : 0; }

sub is_text { $_[ 0 ]->filetype =~ m{octet-stream} ? 1 : 0 }

sub is_vimball {  $_[0]->file =~ m/\.vba$/  }

# known types (depends on the information that vim.org provides.
sub script_type {
    my $self = shift;

    if( $self->info->{type} ) {
        return 'colors' if $self->info->{type} eq 'color scheme' ;
        return undef if $self->info->{type} =~ m/(?:utility|patch)/;
        return $self->info->{type};
    }
    else {
        return undef;
    }
}

sub download {
    my $self = shift;

    my $file_content = LWP::Simple::get( $self->url );
    unless( $file_content ) {
        $logger->error('Can not download file');
        return 0;
    }

    unlink $self->file if -e $self->file;

    print "Saving file to @{[ $self->file ]} \n";
    open FH, ">", $self->file or die $!;
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
    my @files = grep /(?:meta|vimmeta|vimmeta.yml)/i , $self->archive->files();
    return @files if scalar @files;
    return undef;
}


sub has_rakefile {
    my $self = shift;
    my @files = grep /rakefile/i , $self->archive->files();
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

=head2 $pkgfile->copy_to( '/path/to/file' )

=cut

sub copy_to {
    my ( $self , $path ) = @_;
    my $src = $self->file;
    my ( $v, $dir, $file ) = File::Spec->splitpath($path);
    File::Path::mkpath [ $dir ];

    $logger->info( "Copying $src to $path" );
    my $ret = File::Copy::copy( $src => $path );
    if( $ret ) {
        my (@parts)= File::Spec->splitpath( $src );
        return File::Spec->join($path,$parts[2]);
    }

    $logger->error( $! );
    return;
}


=head2 $pkgfile->copy_to_rtp( $dir )

copy to vim runtime path

=cut

sub copy_to_rtp {
    my ( $self, $target ) = @_ ;
    return $self->copy_to($target);
}


use Vimana::Util;

sub extract_to {
    my ( $self, $path ) = @_;
    # my $path ||= Vimana::Util::tempdir();
    rmtree [ $path ] if -e $path;
    mkpath [ $path ];
    print "Extracting to: $path\n";
    return $self->archive->extract($path);
}


1;
