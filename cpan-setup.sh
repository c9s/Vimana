#!/bin/bash
echo "" | perl -MCPAN -e 'mkmyconfig'
echo "o conf prerequisites_policy follow " | cpan
echo "o conf urllist unshift http://cpan.nctu.edu.tw/" | cpan
echo "Done"
