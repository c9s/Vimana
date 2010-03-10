package Vimana::Installer::Text;
use warnings;
use strict;
use base qw(Vimana::Installer);
use Vimana::Record;

sub read_text {
    my $self =shift;
    local $/;
    open IN , "<" , $self->target;
    my $text = <IN>;
    close IN;
    return $text;
}

sub script_type {
    my $self = shift;
    if( $self->script_info->{type} ) {
        return 'colors' if $self->script_info->{type} eq 'color scheme' ;
        return undef if $self->script_info->{type} =~ m/(?:utility|patch)/;
        return $self->script_info->{type};
    }
    else {
        return undef;
    }
}


use File::Path qw(rmtree mkpath);

sub copy_to {
    my ( $self , $path ) = @_;
    my $src = $self->target;

    my ( $v, $dir, $file ) = File::Spec->splitpath($path);
    File::Path::mkpath [ $dir ];

    my $ret = File::Copy::copy( $src => $path );
    if( $ret ) {
        my (@parts)= File::Spec->splitpath( $src );
        return File::Spec->join($path,$parts[2]);
    }
    print STDERR $! if $!;
    return;
}

sub copy_to_rtp {
    my ( $self, $to ) = @_ ;
    return $self->copy_to($to);
}

sub run {
    my $self = shift;
    my $verbose = $self->verbose;
    my $text_content = $self->read_text();

    # XXX: try to use rebless.
    if( $self->target =~ m/\.vba$/ ) {
        print "Found Vimball File\n";
        my $installer = $self->get_installer( 'vimball',
            package_name => $self->package_name,
            target       => $self->target,
            verbose      => $self->verbose
        );
        $installer->run();
        return 1;
    }


    print "Inspecting script content.\n";
    my $arg = $self->inspect_text_content( $text_content );
    my $type = $self->script_type();


    if ( $arg->{version} ) {
        # XXX: check version from record.

    }

    if ( $arg->{deps} ) {
        print "Script dependency tag found. Installing script dependencies.\n";
        for my $dep ( @{ $arg->{deps} } ) {
            print "Installing $dep\n";
            Vimana::Installer->install( $dep );
        }
    }
    
    my $target;
    if( $type ) {
        $target = $self->copy_to_rtp( 
                File::Spec->join( $self->runtime_path , $type ));
        print "Installing script to " . File::Spec->join( $self->runtime_path , $type ) . "\n";
    }
    else {
        # Can't found script ype,
        # inspect text filetype here.  (colorscheme, ftplugin ...etc)
        $type = $arg->{type};

        if ($type) {
            print "Script type found: $type.\n";
            print "Installing..\n";
            $target = $self->copy_to_rtp( 
                    File::Spec->join( $self->runtime_path, $type ));
        }
        else {
            die "Can't script type not found.";
            # XXX: more useful message.
        }
    }

    if( $type and $target ) {
        # make record:
        my @e = Vimana::Record->mk_file_digests( $target );
        Vimana::Record->add( {
                version => 0.3,    # record spec version
                package => $self->package_name, 
                generated_by => 'Vimana-' . $Vimana::VERSION,
                # Installer type:
                #   auto , make , rake, text ... etc
                installer_type =>  $self->installer_type ,
                files => \@e 
        } );
    }
    return $target;
}

=head2 inspect_text_content

you can add something like this to your vim script file:

    " script type: plugin

    " ScriptType: plugin

    " Script Type: plugin

then the file will be installed into ~/.vim/plugin/

=cut

sub inspect_text_content {
    my ($self,$content) = @_;
    my $arg =  {};
    if( $content =~ m{^"\s*script\s*type:\s*(\w+)}im  ){
        my $type = $1;
        $arg->{type} = $type;
    }
    else {
        $arg->{type} = 'colors'   if $content =~ m/^let\s+(g:)?colors_name\s*=/;
        $arg->{type} = 'syntax'   if $content =~ m/^syn[tax]* (?:match|region|keyword)/;
        $arg->{type} = 'compiler' if $content =~ m/^let\s+current_compiler\s*=/;
        $arg->{type} = 'indent'   if $content =~ m/^let\s+b:did_indent/;
        # XXX: inspect more types.
    }

    if( $content =~ m{^"\s*(?:script\s*)?(?:deps|dependency|dependencies):\s*(.*)}im ) {
        my $deps_str = $1;
        my @deps = split /\s*,\s*/,$deps_str;
        $arg->{deps} = \@deps;
    }

    if( $content =~ m{^"\s*(?:script\s*)?version:\s*([.0-9]+)}im ) {
        $arg->{version} = $1;
    }

    return $arg;
}

1;
