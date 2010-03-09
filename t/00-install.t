#!/usr/bin/env perl 
use strict;
use warnings;
use lib 'lib';

use Test::More tests => 14;

BEGIN {
    $ENV{VIMANA_RUNTIME_PATH} = '/tmp/vimana-test';
	use_ok( 'Vimana' );
    use_ok( 'Vimana::VimOnline');
    use_ok( 'Vimana::Index');
    use_ok( 'Vimana::Logger');
    use_ok( 'Vimana::Command::Install');
}

use File::Spec;
use File::Path qw(mkpath rmtree);
my $path = '/tmp/vimana-test' ;

SKIP :
{

    my $ret = qx( vim --version );
    skip '' , 8  unless 0;
    skip 'vim not found' , 8  unless $ret =~ /^VIM - Vi IMproved/ ;
    # autoinstall
    {
        mkpath [ $path ];
        Vimana::Util::init_vim_runtime();

        my $cmd = Vimana::Command::Install->new;
        my $ret = $cmd->run( 'rails.vim' );   
        ok( $ret );

        # inspect directory
        ok( -e File::Spec->join( $path, 'doc',      'rails.txt' ) );
        ok( -e File::Spec->join( $path, 'autoload', 'rails.vim' ) );
        ok( -e File::Spec->join( $path, 'plugin',   'rails.vim' ) );

        rmtree [ $path ];
    }



# vimball install
    {
        mkpath [ $path ];
        Vimana::Util::init_vim_runtime();

        my $cmd = Vimana::Command::Install->new;
        my $ret = $cmd->run( 'ctags-highlighting' );   # smart install
        ok( $ret );

        # inspect directory , vimball install scripts into user's home vim direcotyr
        ok( -e File::Spec->join( $ENV{HOME} , '.vim' , 'plugin',   'ctags_highlighting.vim' ) );

        rmtree [ $path ];
    }

# colorscheme install
    {
        mkpath [ $path ];
        Vimana::Util::init_vim_runtime();
        my $cmd = Vimana::Command::Install->new;
        my $ret = $cmd->run( 'montz.vim' );   # smart install
        ok( $ret );
        ok( -e File::Spec->join( $path, 'colors', 'montz.vim' ) );
        rmtree [ $path ];
    }




}
