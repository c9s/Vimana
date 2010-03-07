#!/usr/bin/env perl
use lib 'lib';
use Test::More tests => 3;
require Vimana::Installer::Text;


{
    my $content = <<END;
" script deps:  the-nerd-tree, foo1, bar1
" version: 0.1
" author:  Cornelius
" script type:  plugin
END

    my $arg = Vimana::Installer::Text->inspect_text_content($content);
    is_deeply(
        $arg,
        {
            'type' => 'plugin',
            'version' => '0.1',
            'deps' => [ 'the-nerd-tree', 'foo1', 'bar1' ] } );
}

{
    my $content = <<END;
" scriptdeps:  the-nerd-tree, foo1, bar1
" script version: 0.1
" author:  Cornelius
" scripttype:  plugin
END

    my $arg = Vimana::Installer::Text->inspect_text_content($content);
    is_deeply(
        $arg,
        {
            'type' => 'plugin',
            'version' => '0.1',
            'deps' => [ 'the-nerd-tree', 'foo1', 'bar1' ] } );
}

{
    my $content = <<END;
" Script Dependencies:  the-nerd-tree, foo1, bar1
" version: 0.1
" author:  Cornelius
" Script Type:  plugin
END

    my $arg = Vimana::Installer::Text->inspect_text_content($content);
    is_deeply(
        $arg,
        {
            'type' => 'plugin',
            'version' => '0.1',
            'deps' => [ 'the-nerd-tree', 'foo1', 'bar1' ] } );
}


