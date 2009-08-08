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
use Vimana::Logger;


$| = 1;

=head1 NAME

Vimna::AutoInstall

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut

=head2 can_autoinstall

=cut

sub can_autoinstall {
    my ( $class, $cmd , $file, $info , $page ) = @_;

    if( $cmd->is_archive_file( ) ) {
        my $archive = Archive::Any->new($file);
        my @files = $archive->files;
        my $nodes = $class->find_runtime_node( \@files );
        return i_know_what_to_do( $nodes );
    }
    elsif( $cmd->is_text_file( ) ) {
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
    my $cmd = $args{command};

    if( $cmd->is_archive_file() ) {
        return $class->install_from_archive( %args );
    }
    elsif( $cmd->is_text_file() ) {

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

    my $out = tempdir( CLEANUP => 1 );
    rmtree [ $out ] if -e $out;
    mkpath [ $out ];
    $logger->info("Temporary directory created: $out") if $cmd->{verbose};

    $logger->info("Extracting...") if $cmd->{verbose};
    $archive->extract( $out );  

    my @subdirs = File::Find::Rule->file->in(  $out );

    # XXX: check vim runtime path subdirs
    $logger->info("Initializing vim runtime path...") if $cmd->{verbose};
    $class->init_vim_runtime();

    my $nodes = $class->find_runtime_node( \@subdirs );
    
    if( $cmd->{verbose} ) {
        $logger->info('Install base path:');
        $logger->info( $_ ) for ( keys %$nodes );
    }

    $class->install_from_nodes( $cmd, $nodes , runtime_path() );

    $class->update_vim_doc_tags();

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
    my ($class , $cmd , $nodes , $to ) = @_;
    $logger->info("Copying files...");
    for my $node  ( grep { $nodes->{ $_ } > 1 } keys %$nodes ) {
        $logger->info("$node => $to") if $cmd->{verbose};
        my (@ret) = dircopy($node, $to );

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


sub update_vim_doc_tags {
    $logger->info("Updating helptags");
    my $dir = File::Spec->join( runtime_path() , 'doc' );
    system(qq| vim -c ':helptags $dir'  -c q |);
}


=head1 AUTHOR

You-An Lin 林佑安 ( Cornelius / c9s ) C<< <cornelius.howl at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 You-An Lin ( Cornelius / c9s ), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
