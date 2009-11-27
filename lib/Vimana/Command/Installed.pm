package Vimana::Command::Installed;
use warnings;
use strict;
use base qw(App::CLI::Command);
use Vimana::Logger;
use Vimana::PackageFile;
use File::Find;

=head2 run

find installed packages.

=cut

sub run {
    my $self = shift;
    my @dir = ( File::Spec->join( $ENV{HOME}  , '.vim' , 'record' ) );
    File::Find::find( sub { 

    # $File::Find::dir is the current directory name,
    # $_ is the current filename within that directory
    # $File::Find::name is the complete pathname to the file.
    # 
    # follow VIM::Packager META data
    # 
        my $record = YAML::LoadFile($_);
        unless( $record ) {
            print STDERR "ERROR: Record $_ load failed.\n";
            return;
        }
        unless( $record->{meta} ) {
            print STDERR "ERROR: Record $_ doesn't contain meta record.\n";
            return;
        }

        unless( $record->{meta}{name} ) {
            print STDERR "ERROR: Record $_ meta doesn't have package name.\n";
            return;
        }
        print $record->{meta}{name} . "\n";

    } , @dir);
}



1;
