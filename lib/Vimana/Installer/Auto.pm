package Vimana::Installer::Auto;
use base qw(Vimana::Installer);
use warnings;
use strict;
use Vimana::AutoInstall;
sub run {
    my ($class,$pkgfile) = @_;
    my $auto = Vimana::AutoInstall->new( { package => $pkgfile, options => {} } );
    return $auto->run();  # XXX: dry_run , verbose
}

1;
