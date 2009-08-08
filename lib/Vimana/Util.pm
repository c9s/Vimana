package Vimana::Util;
use warnings;
use strict;
use base qw(Exporter::Lite);
our @EXPORT = qw(canonical_script_name);

sub canonical_script_name {
    my $name = shift;
    $name = lc $name;
    $name =~ s/\s+/-/g;
    $name =~ s/-?\(.*\)$//;
    $name =~ tr/_<>[],{/-/;
    $name =~ s/-+/-/g;
    $name;
}

sub get_mine_type {
    my $type = File::Type->new->checktype_filename( $_[ 0 ] );
    die "can not found file type from @{[ $_[0] ]}" unless $type;
    return $type;
}

use File::Which;
sub find_vim {
    return $ENV{VIMPATH} || File::Which::which( 'vim' );
}

1;
