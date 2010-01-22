package Vimana::Record;
use warnings;
use strict;
use Vimana;
use File::Path;
use YAML;


sub record_path  {
    my ($class,$pkgname) = @_;
    my $record_dir =  $ENV{VIM_RECORD_DIR} || File::Spec->join($ENV{HOME},'.vim','record') ;
    if( ! -e $record_dir ) {
        File::Path::mkpath( $record_dir );
    }
    return File::Spec->join( $record_dir , $pkgname );
}

=head2 load

load package record , returns a hashref which contains:

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
        print "Package $pkgname record can not found.\n";
        return ;
    }

    my $record = YAML::LoadFile( $record_file );
    unless( $record ) {
        print STDERR "Can not load record\n";
        return ;
    }
    return $record;
}

sub add {
    my ( $class , $record ) = @_;
    my $pkgname = $record->{package};
    unless( $pkgname ) {
        warn "Package name is not declared.";
    }

    my $record_file =  $class->record_path( $pkgname );
    return 0 if -f $record_file;
    return YAML::DumpFile( $record_file , $record  );
}

1;
