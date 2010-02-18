#!/bin/bash
MIRROR=http://cpan.nctu.edu.tw/
echo "" | perl -MCPAN -e 'mkmyconfig'
echo "o conf prerequisites_policy follow " | cpan
echo "o conf urllist unshift $MIRROR" | cpan
echo "Done"
