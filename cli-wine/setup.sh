#!/usr/bin/env bash
#
#

file_setup=$(readlink -f $0)
dir_of_project=$(dirname $file_setup)

source "${dir_of_project}"/lib/version.sh


if [[ $(id -u) == 0 ]]; then
    PREFIX='/opt'
    DIR_BIN='/usr/local/bin'
else
    PREFIX=~/.local/opt
    DIR_BIN=~/.local/bin
	mkdir -p $DIR_BIN
fi


SCRIPT="${DIR_BIN}"/cli-wine
DEST_DIR="${PREFIX}"/cli-wine


function create_dirs()
{
    mkdir -p $DEST_DIR
}

function setup()
{
    create_dirs
    
    echo -e "Instalando $__appname__ V${__version__} em ... $DEST_DIR"
    cd $dir_of_project
    cp -R -u * "${DEST_DIR}"/
    ln -sf "${DEST_DIR}"/main.sh "$SCRIPT"
    echo OK
}



setup $@

