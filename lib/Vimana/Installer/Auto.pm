package Vimana::Installer::Auto;
use base qw(Vimana::Installer);
use warnings;
use strict;

# use re 'debug';
use File::Copy::Recursive qw(fcopy rcopy dircopy fmove rmove dirmove);
use File::Spec;
use File::Path qw'mkpath rmtree';
use Archive::Any;
use File::Find;
use File::Type;
use Vimana::Logger;
use Vimana::Util;
use DateTime;


sub find_vimball_files {
    my $out = shift;
    my @vimballs;
    File::Find::find(  sub {
            return unless -f $_;
            push @vimballs , File::Spec->join($File::Find::dir , $_ ) if /\.vba$/;
        } , $out );
    return @vimballs;
}

sub run {
    my $self = shift;
    my $out = shift;
    my $pkg = $self->package;

    my @files = $pkg->archive->files;

    for (@files ) {
        print "\t$_\n";
    }

    if( $pkg->has_vimball() ) {
        $logger->info( "vimball files found, trying to install vimballs");
        use Vimana::VimballInstall;
        my @vimballs = find_vimball_files $out;
        Vimana::VimballInstall->install_vimballs( @vimballs );
    }

    # check directory structure
    {

        # XXX: check vim runtime path subdirs , mv to init script
        $logger->info("Initializing vim runtime directories") ;
        Vimana::Util::init_vim_runtime();

        my @files;
        File::Find::find(  sub {
                return unless -f $_;
                push @files , File::Spec->join( $File::Find::dir , $_ ) if -f $_;
            } , $out );

        my $nodes = $self->find_base_path( \@files );
        unless ( keys %$nodes ) {
            $logger->warn("Can't found base path.");
            return 0;
        }
        
        $logger->info( "Basepath found: " . $_ ) for ( keys %$nodes );

        $self->install_from_nodes( $nodes , runtime_path() );

        $logger->info("Updating helptags");
        $self->update_vim_doc_tags();
    }

    $logger->info("Cleaning up temporary directory.");

    rmtree [ $out ] if -e $out;

    return 1;
}

=head2 install_from_nodes

=cut

sub install_from_nodes {
    my ($self , $nodes , $to ) = @_;
    $logger->info("Copying files...");
    for my $node  ( grep { $nodes->{ $_ } > 1 } keys %$nodes ) {
        $logger->info("$node => $to");
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


=head2 find_base_path 

=cut

sub find_base_path {
    my ( $self, $paths ) = @_;
    my $nodes = {};
    for my $p ( @$paths ) {
        if ( $p =~ m{^(.*?/)?(plugin|doc|syntax|indent|colors|autoload|after|ftplugin)/.*?\.(vim|txt)$} ) {
            $nodes->{ $1 || '' } ++;
        }
    }
    return $nodes;
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
