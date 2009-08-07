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


1;
