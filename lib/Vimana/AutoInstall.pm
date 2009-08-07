package Vimana::AutoInstall;

use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Spec;
use File::Path qw'mkpath rmtree';
use Archive::Any;
use File::Find::Rule;


# XXX:
sub run {

    # my $archive_file = 'postmail.zip';
    my $archive_file = 'nerdtree.zip';

    my $archive = Archive::Any->new($archive_file);
    my @files = $archive->files;
    use Data::Dumper; warn Dumper( \@files );

    rmtree [ 'output' ] if -e 'output';
    mkpath [ 'output' ];
    $archive->extract( "output" );  # XXX: use File::Temp

    my @subdirs = File::Find::Rule->file->in( "output" );
    use Data::Dumper; warn Dumper( \@subdirs );

    init_vim_runtime();
    my $nodes = find_runtime_node( \@subdirs );

    use Data::Dumper; warn Dumper( $nodes );

    install_from_nodes( $nodes );

}

sub runtime_path {
    return 'vim2';
    return File::Spec->join( $ENV{HOME} , '.vim' );
}

sub init_vim_runtime {
    my $paths = [ ];
    for my $subdir ( qw(plugin doc syntax colors after ftplugin indent autoload) ) {
        push @$paths ,File::Spec->join( runtime_path , $subdir );
    }
    use Data::Dumper; warn Dumper( $paths );

    mkpath $paths;
}

sub install_from_nodes {
    my $nodes = shift;
    for my $node  ( grep { $nodes->{ $_ } > 1 } keys %$nodes ) {
        warn $node;
        my (@ret) = dircopy($node, runtime_path );
        use Data::Dumper; warn Dumper( \@ret );
    }
}

sub find_runtime_node {
    my $paths = shift;
    my $nodes = {};
    for my $p ( @$paths ) {
        if ( $p =~ m{^(.*?)/(plugin|doc|syntax|indent|colors|autoload|after|ftplugin)/.*?\.(vim|txt)$} ) {
            $nodes->{ $1 } += 2;
        }
    }
    return $nodes;
}


1;
