package Vimana::AutoInstall;
use warnings;
use strict;

# use re 'debug';
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Spec;
use File::Path qw'mkpath rmtree';
use Archive::Any;
use File::Find::Rule;
use File::Type;
use File::Temp qw(tempdir);

$| = 1;

=head1 NAME

Vimna::AutoInstall

=head1 DESCRIPTION

=head1 FUNCTIONS

=head2 can_autoinstall

=cut

sub can_autoinstall {
    my ( $class, $cmd , $file, $info , $page ) = @_;

    if( is_archive_file( $file ) ) {
        my $archive = Archive::Any->new($file);
        my @files = $archive->files;
        my $nodes = $class->find_runtime_node( \@files );
        return i_know_what_to_do( $nodes );
    }
    elsif( is_text_file( $file ) ) {
        return 1 if $info->{type} eq 'color scheme'
                        or $info->{type} eq 'syntax'
                        or $info->{type} eq 'indent';
        return 0;
    }
}

sub inspect_text_content {
    my $file = shift;
    local $/;
    open my $fh , "<" , $file;
    my $content = <$fh>;
    close $fh;

    return 'colors' if $content =~ m/let\s+(g:)?colors_name\s*=/;
    return undef;
}

=head2 install

=cut

sub install {
    my ( $class , %args ) = @_;
    # my ( $class, $cmd, $file, $info, $page ) = @_;

    if( is_archive_file( $args{target} ) ) {
        return $class->install_from_archive( %args );
    }
    elsif( is_text_file( $args{target} ) ) {

        return $class->install_to( $args{target} , 'colors' )
            if $args{info}->{type} eq 'color scheme' ;

        return $class->install_to( $args{target} , 'syntax' )
            if $args{info}->{type} eq 'syntax' ;

        return $class->install_to( $args{target} , 'indent' )
            if $args{info}->{type} eq 'indent' ;

    }
}

=head2 install_to 

=cut

sub install_to {
    my ( $class , $file , $dir ) = @_;
    fcopy( $file => File::Spec->join( runtime_path(), $dir ) );
}

=head2 install_from_archive 

=cut

sub install_from_archive {
    my ( $class , %args ) = @_;
    my ( $cmd, $file, $info )
        = ( $args{command}, $args{target}, $args{info} );

    # XXX: make sure is archive file
    my $archive = Archive::Any->new( $file );
    my @files = $archive->files;

    if( $cmd->{verbose} ) {
        for (@files ) {
            print "FILE: $_ \n";
        }
    }

    print "Creating temporary directory.\n" if $cmd->{verbose};

    my $out = tempdir( CLEANUP => 1 );
    rmtree [ $out ] if -e $out;
    mkpath [ $out ];

    print "Extracting...\n" if $cmd->{verbose};
    $archive->extract( $out );  

    my @subdirs = File::Find::Rule->file->in(  $out );

    # XXX: check vim runtime path subdirs
    print "Initializing vim runtime path...\n" if $cmd->{verbose};
    $class->init_vim_runtime();

    my $nodes = $class->find_runtime_node( \@subdirs );
    
    print "Runtime path in extracted directory\n" if $cmd->{verbose};
    print join("\n" , keys %$nodes ) . "\n" if $cmd->{verbose};

    print "Installing...\n" if $cmd->{verbose};
    $class->install_from_nodes( $nodes );


    return 1;
}

=head2 runtime_path

You can export enviroment variable VIMANA_RUNTIME_PATH to override default
runtime path.

=cut

sub runtime_path {
    # return File::Spec->join( $ENV{HOME} , 'vim-test' );
    return $ENV{VIMANA_RUNTIME_PATH} || File::Spec->join( $ENV{HOME} , '.vim' );
}


sub get_mine_type {
    my $type = File::Type->new->checktype_filename( $_[ 0 ] );
    die "can not found file type from @{[ $_[0] ]}" unless $type;
    return $type;
}

=head2 is_archive_file

=cut

sub is_archive_file {
    my $type = get_mine_type( $_[ 0 ] );
    return 1 if $type =~ m{(x-bzip2|x-gzip|x-gtar|zip|rar|tar)};
    return 0;
}

=head2 is_text_file

=cut

sub is_text_file {
    my $type = get_mine_type( $_[ 0 ] );
    return 1 if $type =~ m{octet-stream};
    return 0;
}

=head2 init_vim_runtime 

=cut

sub init_vim_runtime {
    my $class = shift;
    my $paths = [ ];
    for my $subdir ( qw(plugin doc syntax colors after ftplugin indent autoload) ) {
        push @$paths ,File::Spec->join( runtime_path , $subdir );
    }
    mkpath $paths;
}

=head2 install_from_nodes

=cut

sub install_from_nodes {
    my ($class , $nodes) = @_;
    for my $node  ( grep { $nodes->{ $_ } > 1 } keys %$nodes ) {
        my (@ret) = dircopy($node, runtime_path );
    }
}

=head2 i_know_what_to_do

=cut

sub i_know_what_to_do {
    my $nodes = shift;
    for my $v ( values %$nodes ) {
        return 1 if $v > 1;
    }
    return 0;  # i am not sure
}


=head2 find_runtime_node 

=cut

sub find_runtime_node {
    my ( $class, $paths ) = @_;
    my $nodes = {};
    for my $p ( @$paths ) {
        if ( $p =~ m{^(.*?/)?(plugin|doc|syntax|indent|colors|autoload|after|ftplugin)/.*?\.(vim|txt)$} ) {
            $nodes->{ $1 || '' } += 2;
        }
    }
    return $nodes;
}


=head1 AUTHOR

You-An Lin 林佑安 ( Cornelius / c9s ) C<< <cornelius.howl at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 You-An Lin ( Cornelius / c9s ), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
