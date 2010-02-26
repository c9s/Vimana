#!/bin/bash
pp -P -cd _deps_cache -I lib -o vimana-macosx bin/vimana 
./vimana-macosx search rail
./vimana-macosx update
./vimana-macosx install snipmate
read -p 'SCP?'
scp vimana-macosx oulixe.us:/var/www/vimana-macosx
