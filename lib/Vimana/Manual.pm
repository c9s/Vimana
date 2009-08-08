=begin

=encoding utf8

=head1 NAME

Vimana::Manual - Getting started 

=head1 INTRODUCTION

Vimana provides varied kinds of installation strategy. To install a vim plugin,
Vimana downloads the file from vim.org , then detects the downloaded file type.
if the downloaded file is a Vimball script, then call Vim to run the Vimball
script to install. if it's a colorscheme or syntax file , then copy the
files into your ~/.vim/colors/ or ~/.vim/syntax/ directory.

If it's an archive file (zip, bzip,rar .. etc) , Vimana looks into the archive
file , see if it contains a 'Makefile' file, then use the Makefile file to
install a plugin.

if it doesn't contain a 'Makefile' file.  Vimana looks into the directory tree, 
see if it contains 'doc','plugin','syntax' directories, if so , copy these
files into your vim runtime directory recursivly.

* if the downloaded file is not a Vimball script and not a colorscheme or syntax
file and doesn't contains a Makefile file or 'doc','plugin','syntax',
Vimana will ask you to install the plugin manually.

=head1 REQUIREMENT

To install Vimana , please make sure you are in unix-like system.  Vimana 
supports Unix-like system only, such like Linux , Mac OS , BSD .. etc. these 
perl-installed system.

* Windows is not supported yet.

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

To see more information about rails.vim

    $ vimana info rails.vim

    ... skip

To install rails.vim package:

    $ vimana install rails.vim

Check your F<~/.vim/> directory , rails plugin is installed.

    $ vimana install rails.vim -v

    Download from: http://www.vim.org/scripts/download_script.php?src_id=10297
    Stored at: /tmp/rails.zip
    Check if this package contains 'Makefile' file
    Check if we can install this package via port file
    Check if we can auto install this package
    Archive type file
    FILE: autoload/rails.vim 
    FILE: plugin/rails.vim 
    FILE: doc/rails.txt 
    Temporary directory created: /var/folders/4o/4omYKsGdFEyBuGRUVlwuNU+++TM/-Tmp-/rlBtGJkMZN
    Extracting...
    Initializing vim runtime path...
    base path:
    /var/folders/4o/4omYKsGdFEyBuGRUVlwuNU+++TM/-Tmp-/rlBtGJkMZN/
    Copying files...
    /var/folders/4o/4omYKsGdFEyBuGRUVlwuNU+++TM/-Tmp-/rlBtGJkMZN/ => /Users/c9s/.vim
    Updating helptags
    Clean up temporary directory.
    Done
    
    $


=head1 AUTHOR

You-An Lin 林佑安 ( Cornelius / c9s ) C<< <cornelius.howl at gmail.com> >>

=head1 COPYRIGHT & LICENSE

Copyright 2007 You-An Lin 林佑安 ( Cornelius / c9s ), all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

=cut
