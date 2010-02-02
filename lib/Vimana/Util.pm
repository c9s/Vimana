package Vimana::Util;
use warnings;
use strict;
use base qw(Exporter::Lite);
use File::Type;
our @EXPORT = qw(canonical_script_name find_vim);
our @EXPORT_OK = qw(findbin find_vim runtime_path tempdir);

sub canonical_script_name {
    my $name = shift;
    $name = lc $name;
    $name =~ s/\s+/-/g;
    $name =~ s/-?\(.*\)$//;
    $name =~ tr/_<>[],{/-/;
    $name =~ s/-+/-/g;
    $name;
}

sub tempdir {
    return  "/tmp/vimana-" . join '',map { [ 'a' .. 'z' ]->[ int rand(26) ] }  1 .. 6;
}

sub get_mine_type {
    my $type = File::Type->new->checktype_filename( $_[ 0 ] );
    die "can not found file type from @{[ $_[0] ]}" unless $type;
    return $type;
}

sub findbin {
    my $which = shift;
    my $path = $ENV{PATH};
    my @paths = $^O eq 'MSWin32' ? split /;/,$path : split /:/,$path;
    for ( @paths ) {
        my $bin = $_ . '/' . $which;
        $bin .= '.exe' if $^O eq 'MSWin32';
        return $bin if( -x $bin ) ;
    }
}

sub find_vim {
    return $ENV{VIMPATH} || findbin('vim');
}


=head2 runtime_path

You can export enviroment variable VIMANA_RUNTIME_PATH to override default
runtime path.

=cut

sub runtime_path {
    # return File::Spec->join( $ENV{HOME} , 'vim-test' );
    return $ENV{VIMANA_RUNTIME_PATH} || File::Spec->join( $ENV{HOME} , '.vim' );
}

=head2 init_vim_runtime 

=cut

use File::Spec;
use File::Path qw'mkpath rmtree';
sub init_vim_runtime {
    my $runtime_path = shift || runtime_path() ;
    my $paths = [ ];

#   filetype.vim
#   scripts.vim
#   menu.vim
    push @$paths , File::Spec->join( $runtime_path , $_ )
        for ( qw(
                after
                autoload
                colors
                compiler
                doc
                ftplugin
                indent
                keymap
                lang
                plugin
                print
                spell
                syntax
                tutor    ) );

    mkpath $paths;
}


1;
