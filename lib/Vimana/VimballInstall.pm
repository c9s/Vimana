package Vimana::VimballInstall;
use strict;
use warnings;

use Vimana::Util;
use Vimana::Logger;
use base qw/Class::Accessor::Fast/;
__PACKAGE__->mk_accessors( qw(package) );

sub run {
    my $self = shift;
    $self->install_vimballs( $self->package->file );
}

sub install_vimballs {
    my $self = shift;
    my @files = @_;
    my $vim = find_vim();
    for my $vimball ( @files ) {
        $logger->info( "Installing Vimball: $vimball" );
        system( qq|$vim $vimball -c ":so %" -c q|);
    }
}

1;
