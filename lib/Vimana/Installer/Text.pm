package Vimana::Installer::Text;
use warnings;
use strict;
use base qw(Vimana::Installer);
use Vimana::Logger;
use Vimana::VimballInstall;

sub new { bless {}, shift; }

sub run {
    my ( $class, $pkgfile ) = @_;

    if( $pkgfile->is_vimball ) {
        $logger->info("Found Vimball File");
        my $install = Vimana::VimballInstall->new({ package => $pkgfile });
        $install->run();
        return 1;
    }

    # known types (depends on the information that vim.org provides.
    return $pkgfile->install_to( 'colors' )
        if $pkgfile->script_is('color scheme');

    return $pkgfile->install_to( 'syntax' )
        if $pkgfile->script_is('syntax');

    return $pkgfile->install_to( 'indent' )
        if $pkgfile->script_is('indent');

    return $pkgfile->install_to( 'ftplugin' )
        if $pkgfile->script_is('ftplugin');

    # guess text filetype here.  (colorscheme, ftplugin ...etc)

}

1;
