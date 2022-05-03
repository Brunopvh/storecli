#!/usr/bin/env bash
#
#


# Setar diretórios do root por padrão.
source "${SHELL_LIBS}"/system/_appdirs_root.sh


function setDirsRoot(){
    source "${SHELL_LIBS}"/system/_appdirs_root.sh
}


function setDirsUser(){
    if [[ $(id -u) == 0 ]]; then
        printErro "setDirsUser: você não poder ser o root para executar essa ação."
        return
    fi

    source "${SHELL_LIBS}"/system/_appdirs_user.sh

    #createUserDirs
}
