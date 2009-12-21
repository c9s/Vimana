# REQUIRES=(App::CLI DateTime::Format::DateParse Exporter::Lite File::Basename File::Copy File::Find File::Path File::Spec Getopt::Long LWP::UserAgent YAML)
TODAY=`date +%Y-%m-%d`
REPO=/tmp/vimana-$TODAY
BIN=/tmp/vimana-$TODAY.bin

if [[ -e $REPO ]] ; then
    echo Found previsou repository: $REPO 
    echo Cleaning up
    rm -rf $REPO
fi

echo Repository: $REPO

shipwright create -r git:file://$REPO

export SHIPWRIGHT_REPOSITORY="git:file://$REPO"

shipwright import git:/Users/c9s/mygit/vimana

# echo "importing dependencies"
# for req in ${REQUIRES[*]} ; do 
#     echo $req
#     shipwright import cpan:$req > /dev/null
# done

CO_PATH=/tmp/vimana-build
if [[ -e $CO_PATH ]] ; then
    rm -rf $CO_PATH
fi

echo "checking out"
git clone $REPO $CO_PATH
cd $CO_PATH
# ./bin/shipwright-builder



echo "# one argument per line
--skip-man-pages
--skip-test
--install-base=~/vimana
" > __default_builder_options 
./bin/shipwright-utility --generate-tar-file $BIN

echo bin: $BIN
