=begin

=encoding utf8

=head1 NAME

Vimana::Manual - Getting started 

=head1 INTRODUCTION

Vimana is an easy to use system for searching , installing, and downloading vim
script.

Vimana provides a command-line interface such like C<aptitude> programe on
Debian linux, for you to search , download , install , upgrade scripts from
L<http://www.vim.org> (vimonline site).

Vimana can install a vim script package to your vim runtime path automatically
by inspecting the content of archive file or vim script. For example , if an
archive file contains 'syntax','plugin','indent' directory , then these files
should be installed to F<~/.vim/> directory (default vim runtime directory).   
if it's a vim color scheme , then it should be put into F<~/.vim/colors/>,
or Vimana will inspect the script type tag in script file.

=head1 REQUIREMENT

To install Vimana , please make sure you are in Unix-Like system.  Vimana 
supports Unix-like system only. for example, Linux , Mac OS , BSD .. etc. these
perl-installed system.

=head1 INSTALLATION

At first , please make sure that you have L<CPAN> or L<CPANPLUS> installed.

Install Vimana via L<CPAN> , please type following commands:

    $ sudo cpan Vimana

Or you can also install Vimana via L<CPANPLUS>:

    $ sudo cpanp i Vimana

=head1 USAGE

To update index from vim.org:

    $ vimana update 

To search script or plugin:

    $ vimana search rails ruby

    rails.vim          - Ruby on Rails: easy file navigation, enhanced syntax highlighting, and more
    vividchalk.vim     - A colorscheme strangely reminiscent of Vibrant Ink for a certain OS X editor
    rubytest.vim       - Run ruby tests in vim
    ncss.vim           - Syntax File for NCSS
    dark-ruby          - A dark-background color scheme for ruby/rails.
    txtfmt             - Highlight plain text in Vim! (Beautify your documents with colors and formats.)
    ruby-imaps         - Textmate like Ruby snippets for Vim
    apidock.vim        - Plugin that searches <a target="_blank" href="http://apidock.com">http://apidock.com
    rubycomplete.vim   - ruby omni-completion
    fastgrep           - FastGrep for a string using native linux commands in Ruby on Rails projects.
    ruby-snippets      - Some abbreviations to use with Ruby

    $ _

To see more information about "rails.vim" plugin

    $ vimana info rails.vim

    ... skip

To install "rails.vim" package:

    $ vimana i rails.vim

Check your F<~/.vim/> directory , rails plugin should be installed.

To install "rails.vim" package and enable verbose messages:

    $ vimana i rails.vim -v
    $ vimana i autocomplpop

To install from a git repository:

    $ vimana i git:git://path/to/git/repository

To install from current directory:

    $ git clone git://path/to/git/repo.git
    $ cd repo
    $ vimana i .  


=head1 Environment Variables

    VIMANA_TEMP
    VIMANA_RUNTIMEPATH

=head1 AUTHOR

You-An Lin 林佑安 ( Cornelius / c9s ) C<< <cornelius.howl at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 You-An Lin 林佑安 ( Cornelius / c9s ), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

=cut
