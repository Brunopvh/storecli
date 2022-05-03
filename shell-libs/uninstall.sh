#!/usr/bin/env bash
#


if [[ $(id -u) == 0 ]]; then
    PREFIX='/usr/local/lib'
else
    PREFIX=~/.local/lib
fi

SHELL_LIBS="${PREFIX}/shell-libs"


function uninstallFiles(){
    echo -e "Desinstalando ... $SHELL_LIBS"
    rm -rf "${SHELL_LIBS}"
    echo OK
}


function main(){
    uninstallFiles
}



main $@





