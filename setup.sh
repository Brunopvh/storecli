#!/usr/bin/env bash
#
#

file_setup=$(readlink -f $0)
dir_of_project=$(dirname $file_setup)

source "${dir_of_project}"/lib/version.sh


# shell-libs
[[ -f "$dir_of_project"/shell-libs/setup.sh ]] && {

    chmod +x "$dir_of_project"/shell-libs/setup.sh
    "$dir_of_project"/shell-libs/setup.sh
}



# cli-wine
[[ -f "$dir_of_project"/cli-wine/setup.sh ]] && {

    chmod +x "$dir_of_project"/cli-wine/setup.sh
    "$dir_of_project"/cli-wine/setup.sh
}



if [[ $(id -u) == 0 ]]; then
    PREFIX='/opt'
    DIR_BIN='/usr/local/bin'
else
    PREFIX=~/.local/opt
    DIR_BIN=~/.local/bin
    
fi

DEST_DIR="${PREFIX}"/storecli
SCRIPT="${DIR_BIN}/storecli"


function create_dirs()
{
    #
    mkdir -p $DEST_DIR
    [[ $(id -u) == 0 ]] && return 0
    mkdir -p ~/.local/bin
     
}



function setup()
{
    
    create_dirs
    
    echo -ne "Instalando $__appname__ V${__version__} em ... $DEST_DIR "
    cd $dir_of_project
    cp -R -u * "${DEST_DIR}"/
    chmod +x "${DEST_DIR}"/scripts/check.sh
    chmod +x "${DEST_DIR}"/scripts/update.sh

    ln -sf "${DEST_DIR}"/main.sh "$SCRIPT"

    echo OK
}



setup $@

