#!/usr/bin/env perl
use warnings;
use strict;
use lib 'lib';
use Test::More tests => 6;
use File::Spec;

sub inst {
    my $type = shift;
    my $cls = 'Vimana::Installer::' . ucfirst( $type );
    use_ok( $cls );
}

inst( $_ ) for qw(text makefile rakefile vimball);

{
    my $tmpdir   = File::Spec->tmpdir;
    my $filename = 'hoge.vim';
    my $target   = File::Spec->join($tmpdir, $filename);

    my $installer = Vimana::Installer->get_installer('text',
        package_name => $filename,
        target       => $target,
        runtime_path => $tmpdir,
    );

    my $file_content = "foo\nbar\nbaz";
    open my $fh, '>', $target or die $!;
    print $fh $file_content;
    close $fh;

    subtest "read_text" => sub {
        is( $installer->read_text, $file_content, 'file content read ok' );
    };

    subtest "copy_to" => sub {
        my $path = File::Spec->join($tmpdir, 'colors');
        my $ret = $installer->copy_to($path);

        ok( -e File::Spec->join( $path, $filename ), 'file copy ok' );
    };
}
