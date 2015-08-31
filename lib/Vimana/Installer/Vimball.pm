package Vimana::Installer::Vimball;
use warnings;
use strict;
use parent qw(Vimana::Installer);
use File::Temp qw(tempfile);
use Vimana::Util;
use Vimana::Logger;
use Vimana::Record;

sub scan_vimball {
    my ($self,$file) = @_;
    open my $fh, '<' , $file;
    my @lines = <$fh>;
    close $fh;
    my @filelist = ();
    for my $line ( @lines ) {
        if( $line =~ m{^(.*?)\s\[\[\[\d} ) {
            push @filelist,$1;
        }
    }
    return @filelist;
}


sub run {
    my $self = shift;
    my $verbose = $self->verbose;
    my $file = $self->target;
    # my $vim = find_vim();

    # The first runtime path will be the location that vimball install to. 
    # vim -c "redir > rtp" -c "echo &rtp" -c "q"
    # /Users/c9s/.vim,/opt/local/share/vim/vimfiles,/opt/local/share/vim/vim72,/opt/local/share/vim/vimfiles/after,/Users/c9s/.vim/after
    my @rtps = get_vim_rtp();


    my @filelist = $self->scan_vimball( $file );

    # XXX: check file conflicts.
    #
    #

    my $fh = File::Temp->new( TEMPLATE => 'tempXXXXXX', 
                SUFFIX => '.log' , UNLINK => 0 );
    # my $logfile = $fh->filename;
    my $logfile = "vimana-@{[ $self->package_name ]}-log";
    print "Installing Vimball File: $file\n";
    system( qq|vim $file -c "redir > $logfile" -c ":so %" -c 'sleep 500ms' -c q|);

    print "Vimball Installation Log: $logfile\n";
    if( $verbose ) {
        print "======== VimBall Installation Log Start ======";
        open my $fh, '<',$logfile;
        local $/;
        print <$fh>;
        close $fh;
        print "======== VimBall Installation Log End ========";
    }


    # pre-append vim runtime path
    @filelist = map { File::Spec->join( $rtps[0], $_ )  } @filelist ;

    my @e = Vimana::Record->mk_file_digests( @filelist );
    Vimana::Record->add( {
            version => 0.3,    # record spec version
            package => $self->package_name, 
            generated_by => 'Vimana-' . $Vimana::VERSION,
            installer_type =>  $self->installer_type ,
            files => \@e 
    } );
}

1;
