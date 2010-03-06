package Vimana::Installer;
use base qw(Vimana::Accessor);
use warnings;
use strict;
use Vimana::Logger;
use constant _continue => 0;

__PACKAGE__->mk_accessors( qw(package cleanup runtime_path) );

sub run { }


sub runtime_path_warn {
    my ($self,$cmd) = @_;
    print <<END;
    You are using runtime path option.

    To load the plugin , you will need to add below configuration to your vimrc file

        :set runtimepath+=@{[ $cmd->{runtime_path} ]}

    See vim documentation for runtimepath option.

        :help 'runtimepath'

END
}

use Vimana::Record;

sub install {
    my ( $self, $arg, $cmd ) = @_;
    my $package = $arg;
    my $verbose = $cmd->{verbose};
    if( $cmd->{runtime_path} ) {
        $class->runtime_path_warn( $cmd );
    }

    my $rtp = $cmd->{runtime_path} 
                || Vimana::Util::runtime_path();

    print STDERR "Plugin will be installed to vim runtime path: " . 
                    $rtp . "\n" if $cmd->{runtime_path};

    my $record = Vimana::Record->load( $package );
    if( $record ) {
        if( $cmd->{assume_yes} ) {
            print STDERR "Package $package is installed. removing...\n";
        }
        else {
            print STDERR "Package $package is installed. reinstall (upgrade) ? (Y/n) ";
            my $ans; $ans = <STDIN>;
            chomp( $ans );
            return if $ans =~ /n/i;
        }
        Vimana::Record->remove( $package , undef , $verbose );
    }


}

=pod

    Vimana::Installer->install( 'package name' );
    Vimana::Installer->install_from_url( 'url' );
    Vimana::Installer->install_from_rcs( 'git:......' );
    Vimana::Installer->install_from_dir( '/path/to/plugin' );

    " Script type: plugin
    " Script dependency:
    "   foo1 > 0.1
    "   bar2 > 0.2
    " 
    " Description:
    "   ....

=cut

1;

