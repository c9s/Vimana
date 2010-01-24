package Vimana::Installer::Text;
use warnings;
use strict;
use base qw(Vimana::Installer);
use Vimana::Logger;
use Vimana::VimballInstall;

sub run {
    my ( $self, $pkgfile ) = @_;

    if( $pkgfile->is_vimball ) {
        $logger->info("Found Vimball File");
        my $install = Vimana::VimballInstall->new({ package => $pkgfile });
        $install->run();
        return 1;
    }

    my $installed;  # boolean
    my $type = $pkgfile->script_type();
    if( $type ) {
        $installed = $pkgfile->copy_to_rtp( 
            File::Spec->join( $self->runtime_path ,  $type ) );
    }
    else {
        # can't found script ype,
        # inspect text filetype here.  (colorscheme, ftplugin ...etc)
        $logger->info( "Inspecting file content for script type." );
        my $type = $self->inspect_text_content;
        if ($type) {
            $logger->info("Script type found: $type.");
            $logger->info("Installing..");
            $installed = $self->copy_to_rtp(
                File::Spec->join( $self->runtime_path, $type ) );
        }
        else {
            $logger->info("Can't guess script type.");
        }
    }
    return $installed;
}


=head2 inspect_text_content

you can add something like this to your vim script file:

    " script type: plugin

then the file will be installed into ~/.vim/plugin/

=cut

sub inspect_text_content {
    my $self = shift;
    my $content = $self->package->content;

    if( $content =~ m{^"\s*(?:script\s+type):\s*(\w+)}i ) {
        my $type = $1;
        return $type;
    }

    return 'colors'   if $content =~ m/^let\s+(g:)?colors_name\s*=/;
    return 'syntax'   if $content =~ m/^syn[tax]* (?:match|region|keyword)/;
    return 'compiler' if $content =~ m/^let\s+current_compiler\s*=/;
    return 'indent'   if $content =~ m/^let\s+b:did_indent/;

    # XXX: inspect more types.

    return 0;
}


1;
