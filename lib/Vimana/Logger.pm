package Vimana::Logger;
use strict;
use warnings;

if (eval {
        require Log::Log4perl;
        Log::Log4perl->import(':levels');
        1;
    } ) {
    my $level = lc($ENV{VIMANA_LOGLEVEL} || "info");
    $level = { map { $_ => uc $_ } qw( debug info warn error fatal ) }
        ->{ $level } || 'INFO';

    my $conf_file = $ENV{VIMANA_LOGCONFFILE};
    my $conf;
    if ( defined($conf_file) and -e $conf_file ) {
        my $fh;
        open $fh, $conf_file or die $!;
        local $/;
        $conf = <$fh>;
        close $fh;
    }
    #warn $conf unless $Log::Log4perl::Logger::INITIALIZED;
    $conf ||= qq{
        log4perl.rootLogger=$level, Screen
        log4perl.appender.Screen = Log::Log4perl::Appender::Screen
        log4perl.appender.Screen.stderr = 0
        log4perl.appender.Screen.layout = PatternLayout
        log4perl.appender.Screen.layout.ConversionPattern = %m%n
    };

    # ... passed as a reference to init()
    Log::Log4perl::init( \$conf ) unless Log::Log4perl->initialized;
    *get_logger = sub { Log::Log4perl->get_logger(@_) };
}
else {
    *get_logger = sub { 'Vimana::Logger::Compat' };
}


sub import {
  my $class = shift;
  my $var = shift || 'logger';
  
  # it's ok if people add a sigil; we can get rid of that.
  $var =~ s/^\$*//;
  
  # Find out which package we'll export into.
  my $caller = caller() . ''; 

  (my $name = $caller) =~ s/::/./g;
  my $logger = get_logger(lc($name));
  {
    # As long as we don't use a package variable, each module we export
    # into will get their own object. Also, this allows us to decide on 
    # the exported variable name. Hope it isn't too bad form...
    no strict 'refs';
    *{ $caller . "::$var" } = \$logger;
  }
}


package Vimana::Logger::Compat;
require Carp;

my $current_level;
my $level;

BEGIN {
    my $i;
    $level = { map { $_ => ++$i } reverse qw( debug info warn error fatal ) };
    $current_level = $level->{lc($ENV{VIMANA_LOGLEVEL} || "info")} || $level->{info};

    my $ignore  = sub { return };
    my $warn = sub {
        shift;
        my $s = join "", @_;
        chomp $s;
        print "$s\n";
    };
    my $die     = sub { shift; die $_[0]."\n"; };
    my $carp    = sub { shift; goto \&Carp::carp };
    my $confess = sub { shift; goto \&Carp::confess };
    my $croak   = sub { shift; goto \&Carp::croak };

    *debug      = $current_level >= $level->{debug} ? $warn : $ignore;
    *info       = $current_level >= $level->{info}  ? $warn : $ignore;
    *warn       = $current_level >= $level->{warn}  ? $warn : $ignore;
    *error      = $current_level >= $level->{warn}  ? $warn : $ignore;
    *fatal      = $die;
    *logconfess = $confess;
    *logdie     = $die;
    *logcarp    = $carp;
    *logcroak   = $croak;
}

1;
__END__
=head1 NAME

Vimana::Logger - logging framework for Vimana

=head1 SYNOPSIS

  use Vimana::Logger;
  
  $logger->warn('foo');
  $logger->info('bar');
  
or 

  use Vimana::Logger '$foo';
  
  $foo->error('bad thingimajig');

=head2 DESCRIPTION

Vimana::Logger is a wrapper around Log::Log4perl. When using the module, it
imports into your namespace a variable called $logger (or you can pass a
variable name to import to decide what the variable should be) with a
category based on the name of the calling module.

this class is from L<SVK::Logger>;

=cut
