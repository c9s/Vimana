package Vimana::Command::Installed;
use warnings;
use strict;
use base qw(App::CLI::Command);
use YAML;
use Vimana::Logger;
use Vimana::PackageFile;
use File::Find;

=head2 run

find installed packages.

=cut

sub run {
    my $self = shift;
    my $dir = File::Spec->join( $ENV{HOME}  , '.vim' , 'record' );
    my @list;
    File::Find::find( sub { 
        return unless -f $_;
        my $file = $_;
        my $record = YAML::LoadFile($file);
        if( $record->{package} ) {
            push @list,$record->{package};
        }
        elsif ( $record->{meta} ) {
            push @list,$record->{meta}{name};
=pod
version 0.1 record format (from VIM::Packager)
          'files' => [
                     '/Users/c9s/.vim/ftplugin/vim/omni.vim'
                   ],
          'meta' => {
                    'repository' => 'git://....../',
                    'version' => '0.1',
                    'name' => 'vimomni.vim',
                    'author' => 'Cornelius',
                    'version_from' => 'ftplugin/vim/omni.vim',
                    'libpath' => '.',
                    'email' => 'cornelius.howl@gmail.com',
                    'vim_version' => {
                                     'version' => '7.2',
                                     'op' => '>='
                                   },
                    'type' => 'ftplugin'
                  }
=cut
        }
        else {
            print STDERR "Unknown record.\n";

        }

    } , $dir);
    for my $item ( @list ) {
        print $item . "\n";
    }
}



1;
