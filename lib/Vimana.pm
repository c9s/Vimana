package Vimana;

use warnings;
use strict;
use LWP::UserAgent;

use vars qw($INDEX);

=head1 NAME

Vimana - vim script port manager

=head1 VERSION

Version 0.03

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS


=head1 FUNCTIONS

=cut

use Vimana::Index;
sub index {
    return $INDEX if $INDEX;
    $INDEX ||= Vimana::Index->new;
    $INDEX->init();
    unless ( $INDEX->get() ) {
        require Vimana::Command::Update;
        my $index = Vimana::Command::Update->fetch_index();
        $INDEX->update( $index );
    }
    return $INDEX;
}


=head1 AUTHOR

Cornelius ( You-An Lin ) C<< <cornelius at cpan.org> >>

=head2 Git Repository 

C<http://github.com/c9s/Vimana/tree/master>

=head1 BUGS

Please report any bugs or feature requests to C<bug-vim-get at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Vim-Get>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 TODOS

* auto rating

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Vimana


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

1; # End of Vimana
