#!/bin/bash
pp -cd _deps_cache -P -I lib -o vimana bin/vimana 
scp vimana oulixe.us:/var/www/vimana
