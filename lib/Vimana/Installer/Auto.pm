package Vimana::Installer::Auto;
use base qw(Vimana::Installer);
use warnings;
use strict;

# use re 'debug';
use Vimana::Recursive qw(dircopy_files);
use File::Spec;
use File::Path qw'mkpath rmtree';
use Archive::Any;
use File::Find;
use File::Type;
use Vimana::Logger;
use Vimana::Util;
use DateTime;

sub run {
    my ( $self, $pkgfile, $out ) = @_;

    # XXX: try to fill the record spec.
    my $record = {
        install_type => 'auto',
        meta => {} ,
        files => [ ],
    };


    my @files = $self->find_files( '.' );

    print "Archive content:\n";
    for (@files ) {
        print "\t$_\n";
    }

    my @vba = grep /\.vba/,@files;
    if( @vba ) {
        $logger->info( "Found vimball files, try to install vimball files");
        use Vimana::VimballInstall;
        # my @vimballs = find_vimball_files $out;
        Vimana::VimballInstall->install_vimballs( @vba );
    }

    # check directory structure
    {

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

        # XXX: check vim runtime path subdirs , mv to init script
        $logger->info("Initializing vim runtime directories") ;
        Vimana::Util::init_vim_runtime( $self->runtime_path );
        
        $logger->info( "Basepath found: " . $_ ) for ( keys %$nodes );

        my @installed_files = $self->install_from_nodes( $nodes , $self->runtime_path );

        $logger->info("Updating helptags");
        $self->update_vim_doc_tags();

        # record installed file checksum
        print STDERR "Making checksum...\n";
        my @e = Vimana::Record->mk_file_digests( @installed_files );
        Vimana::Record->add( {
                version => 0.2,    # record spec version
                generated_by => 'Vimana-' . $Vimana::VERSION,
                install_type => 'auto',    # auto , make , rake ... etc
                package => $pkgfile->cname,
                files => \@e,

                #            meta => {
                #                author =>  'Cornelius',
                #                email =>  'cornelius.howl@gmail.com',
                #                libpath => '',
                #                name => 'gsession.vim',
                #                script_id => 2885,
                #                type => 'plugin'
                #                version =>  '0.21',
                #                version_from => 'plugin/gsession.vim'
                #                vim_version => '',
                #            },
        } );
    }

    if( $self->cleanup ) {
        $logger->info("Cleaning up temporary directory.");
        rmtree [ $out ] if -e $out;
    }

    return 1;
}

=head2 install_from_nodes

=cut

sub install_from_nodes {
    my ($self , $nodes , $to ) = @_;
    $logger->info("Copying files...");
    my @copied = ();
    use Cwd;
    for my $basedir  ( grep { $nodes->{ $_ } > 1 } keys %$nodes ) {
        $logger->info("$basedir => $to");

        opendir(my $dh, $basedir ) || die "can't opendir $basedir: $!";
        my @dirs = grep { -d File::Spec->join($basedir,$_) and $_ ne '.' and $_ ne '..' } readdir($dh);
        closedir $dh;

        for ( @dirs ) {
            push @copied , dircopy_files( File::Spec->join($basedir,$_), File::Spec->join($to,$_)  );
        }
    }
    return @copied;
}

=head2 find_base_path 

=cut

sub find_base_path {
    my ( $self, $paths ) = @_;
    my $nodes = {};
    for my $p ( @$paths ) {
        if ( $p =~ m{^(.*?/)?(plugin|doc|syntax|indent|colors|autoload|after|ftplugin)/.*?\.(vim|txt)$} ) {
            my $lib = $1 || '.';
            $nodes->{ $lib } ++ if $lib !~ m{after/};
        }
    }
    return $nodes;
}

sub update_vim_doc_tags {
    my $self = shift;
    my $vim = find_vim();
    my $dir = File::Spec->join( $self->runtime_path , 'doc' );
    my $cmd = qq{vim -e -s -c ":helptags $dir" -c ":q"};
    print "\t$cmd\n";
    system( $cmd );
}

sub find_vimball_files {
    my $out = shift;
    my @vimballs;
    File::Find::find(  sub {
            return unless -f $_;
            push @vimballs , File::Spec->join($File::Find::dir , $_ ) if /\.vba$/;
        } , $out );
    return @vimballs;
}

sub find_files {
    my $self = shift;
    my @dirs = @_;
    use File::Find;
    use File::Spec;
    my @files;
    File::Find::find(sub {
        return if m{\.(?:git|svn)};
        return if $File::Find::dir =~ m{\.(git|svn)};
        my $filepath = File::Spec->catfile( $File::Find::dir, $_ );
        push @files, $filepath if -f $_;
    } , @dirs );
    return @files;
}




=head1 AUTHOR

You-An Lin 林佑安 ( Cornelius / c9s ) C<< <cornelius.howl at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 You-An Lin ( Cornelius / c9s ), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1;
