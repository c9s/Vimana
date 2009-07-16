package Vim::Get;

use warnings;
use strict;
use LWP::UserAgent;

=head1 NAME

Vim::Get - The great new Vim::Get!

=head1 VERSION

Version 0.01

=cut

our $VERSION = '0.01';


=head1 SYNOPSIS

Quick summary of what the module does.

Perhaps a little code snippet.

    use Vim::Get;

    my $foo = Vim::Get->new();
    ...

=head1 EXPORT

=over 4
=item base_url
=back
=cut

our $base_url = 'http://www.vim.org/scripts/script_search_results.php';

=head1 FUNCTIONS

=head2 new

=cut

sub new {
    my $class = shift;
    my $self = { };
    bless $self,$class;
    return $self;
}

=head2 search

=cut

sub search {
    my $self = shift;
    my $args = shift;


}

sub _build_query {
    my $self = shift;
    my $args = shift;

}


sub _init_index {
    my $self = shift;
    my %param = (
        order_by    => 'rating',
        direction   => 'descending',
        search      => 'search',
        show_me     => 3500,
        result_ptr  => 0
    );

    my $query = $base_url . '?';
    map { $query .= "$_=$param{$_}&" if ( defined $param{$_} ); } keys %param;
    print 'Query:' . $query;

    my $ua = LWP::UserAgent->new;
    $ua->timeout(10);
    $ua->env_proxy;

    my $response = $ua->get( $query );
    if ( $response->is_success ) {
        print $response->content;    # or whatever
    }
    else {
        die $response->status_line;
    }
}

sub _auto_rating {
    my $self = shift;
    
}

=head1 AUTHOR

Cornelius, C<< <cornelius at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-vim-get at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Vim-Get>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Vim::Get


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Vim-Get>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Vim-Get>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Vim-Get>

=item * Search CPAN

L<http://search.cpan.org/dist/Vim-Get>

=back


=head1 ACKNOWLEDGEMENTS


=head1 COPYRIGHT & LICENSE

Copyright 2007 Cornelius, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.


=cut

1; # End of Vim::Get
