package Vimana::Util;
use warnings;
use strict;
use base qw(Exporter::Lite);
use File::Type;
our @EXPORT = qw(canonical_script_name find_vim get_vim_rtp);
our @EXPORT_OK = qw(findbin find_vim runtime_path);

sub canonical_script_name {
    my $name = shift;
    $name = lc $name;
    $name =~ s/\s+/-/g;
    $name =~ s/-?\(.*\)$//;
    $name =~ s{[!]}{}g;
    $name =~ tr/_<>[],{/-/;
    $name =~ s/-+/-/g;
    $name;
}

sub get_mine_type {
    my $type = File::Type->new->checktype_filename( $_[ 0 ] );
    die "can not found file type from @{[ $_[0] ]}" unless $type;
    return $type;
}

sub findbin {
    my $which = shift;
    my $path = $ENV{PATH};
    my @paths = split /:/,$path;
    for ( @paths ) {
        my $bin = $_ . '/' . $which;
        return $bin if( -x $bin ) ;
    }
}

sub find_vim {
    return $ENV{VIMPATH} || findbin('vim');
}

sub get_vim_rtp {
    my $file = 'rtp.tmp';
    # XXX: check vim binary

    system(qq{vim -c "redir > $file" -c "echo &rtp" -c "q" });
    open FILE, "<" , $file;
    local $/;
    my $content = <FILE>;
    close FILE;
    $content =~ s{[\n\r]}{}g;
    unlink $file;
    return split /,/,$content;
}

sub runtime_path {
    my @rtps = get_vim_rtp();
    return $ENV{VIMANA_RUNTIME_PATH} || $rtps[0];
}

use File::Spec;
use File::Path qw'mkpath rmtree';
sub init_vim_runtime {
    my $runtime_path = shift || runtime_path();
    map { File::Path::mkpath([ File::Spec->join( $runtime_path , $_ )])  }
        (qw(after autoload colors
                compiler doc ftplugin indent
                keymap lang plugin print
                spell syntax tutor)); 
}


=head2 runtime_path

You can export enviroment variable VIMANA_RUNTIME_PATH to override default
runtime path.

=head2 init_vim_runtime 

=cut

1;
