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

    # known types (depends on the information that vim.org provides.
    return $pkgfile->copy_to_rtp( File::Spec->join( $self->runtime_path ,  'colors' ) )
        if $pkgfile->script_is('color scheme');

    return $pkgfile->copy_to_rtp( File::Spec->join( $self->runtime_path ,  'syntax' ) )
        if $pkgfile->script_is('syntax');

    return $pkgfile->copy_to_rtp( File::Spec->join( $self->runtime_path , 'indent' ) )
        if $pkgfile->script_is('indent');

    return $pkgfile->copy_to_rtp( File::Spec->join( $self->runtime_path , 'ftplugin' ) )
        if $pkgfile->script_is('ftplugin');

    # guess text filetype here.  (colorscheme, ftplugin ...etc)

    $logger->info( "Inspecting file content for script type." );
    my $type = $self->inspect_text_content;
    if ($type) {
        $logger->info("Script type found: $type.");
        $logger->info("Installing..");
        $self->copy_to_rtp( File::Spec->join( $self->runtime_path, $type ) );
        $logger->info("Done.");
        return 1;
    }

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
        # return $type if $type =~ m{(?:plugin|ftplugin|ftdetect|syntax|compiler|)};
    }

    return 'colors'   if $content =~ m/^let\s+(g:)?colors_name\s*=/;
    return 'syntax'   if $content =~ m/^syn[tax]* (?:match|region|keyword)/;
    return 'compiler' if $content =~ m/^let\s+current_compiler\s*=/;
    return 'indent'   if $content =~ m/^let\s+b:did_indent/;

    return 0;
}


1;
