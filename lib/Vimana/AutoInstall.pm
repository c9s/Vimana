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

use Moose;

has 'package' => ( is => 'rw', isa => 'Vimana::PackageFile' );
has 'options' => ( is => 'rw' , isa => 'HashRef' );

$| = 1;

=head1 NAME

Vimna::AutoInstall

=head1 DESCRIPTION

=head1 FUNCTIONS

=cut

sub inspect_text_content {
    my $self = shift;
    my $content = $self->package->content;
    return 'colors' if $content =~ m/let\s+(g:)?colors_name\s*=/;
    return undef;
}

=head2 run

=cut

#    * if it's archive file:
#        * check directory structure
#        * if it contains makefile
#        * if it contains vimball
#        * others
#
#    * if it's text file:
#        * if it's vimball, install it
#        * inspect file content
#            - known format:
#                * do install
#
#            - unknwon
#                * check script_type 
#                * for knwon script type , do install

sub run {
    my ( $self ) = @_;

    my $pkg = $self->package;

    if( $pkg->is_archive() ) {
        $logger->info('Archive type file');

        return $self->install_from_archive;
    }
    elsif( $pkg->is_text() ) {
        $logger->info('Text type file');

        return $self->install_to( 'colors' )
            if $pkg->script_is('color scheme');

        return $self->install_to( 'syntax' )
            if $pkg->script_is('syntax');

        return $self->install_to( 'indent' )
            if $pkg->script_is('indent');

        return 0;
    }
}

=head2 install_to 

=cut

sub install_to {
    my ( $self , $dir ) = @_;
    my $file = $self->package->file;
    my $target = File::Spec->join( runtime_path(), $dir );
    my $ret = fcopy( $file => $target );
    !$ret ? 
        $logger->error( $! ) :
        $logger->info("Installed");
    $ret;
}

=head2 install_from_archive 

=cut

sub install_from_archive {
    my $self = shift;

    my $options = $self->options;
    my $pkg = $self->package;

    my @files = $pkg->archive->files;

    if( $options->{verbose} ) {
        for (@files ) {
            print "FILE: $_ \n";
        }
    }

    my $out = tempdir( CLEANUP => 1 );
    rmtree [ $out ] if -e $out;
    mkpath [ $out ];
    $logger->info("Temporary directory created: $out") if $options->{verbose};

    $logger->info("Extracting...") if $options->{verbose};
    $pkg->archive->extract( $out );  

    my @subdirs = File::Find::Rule->file->in(  $out );

    # XXX: check vim runtime path subdirs
    $logger->info("Initializing vim runtime path...") if $options->{verbose};
    $self->init_vim_runtime();

    my $nodes = $self->find_runtime_node( \@subdirs );

    unless ( keys %$nodes ) {
        $logger->warn("Can't found base path.");
        return 0;
    }
    
    if( $options->{verbose} ) {
        $logger->info('base path:');
        $logger->info( $_ ) for ( keys %$nodes );
    }

    $self->install_from_nodes( $nodes , runtime_path() );

    $logger->info("Updating helptags");
    $self->update_vim_doc_tags();

    $logger->info("Clean up temporary directory.");
    rmtree [ $out ] if -e $out;

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
    my $self = shift;
    my $paths = [ ];
    for my $subdir ( qw(plugin doc syntax colors after ftplugin indent autoload) ) {
        push @$paths ,File::Spec->join( runtime_path , $subdir );
    }
    mkpath $paths;
}

=head2 install_from_nodes

=cut

sub install_from_nodes {
    my ($self , $nodes , $to ) = @_;
    $logger->info("Copying files...");
    for my $node  ( grep { $nodes->{ $_ } > 1 } keys %$nodes ) {
        $logger->info("$node => $to") if $self->options->{verbose};
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
    my ( $self, $paths ) = @_;
    my $nodes = {};
    for my $p ( @$paths ) {
        if ( $p =~ m{^(.*?/)?(plugin|doc|syntax|indent|colors|autoload|after|ftplugin)/.*?\.(vim|txt)$} ) {
            $nodes->{ $1 || '' } += 2;
        }
    }
    return $nodes;
}

sub find_vim {
    use File::Which;
    return $ENV{VIMPATH} || File::Which::which( 'vim' );
}

sub install_from_vimball {
    my $self = shift;
    my $file = $self->file;
    my $vim = find_vim();
    system( qq|$vim $file -c ":so %" -c q|);
}


sub update_vim_doc_tags {
    my $vim = find_vim();
    my $dir = File::Spec->join( runtime_path() , 'doc' );
    system(qq|$vim -c ':helptags $dir'  -c q |);
}


=head1 AUTHOR

You-An Lin 林佑安 ( Cornelius / c9s ) C<< <cornelius.howl at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 You-An Lin ( Cornelius / c9s ), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
