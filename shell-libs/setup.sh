#!/usr/bin/env bash
#

file_setup=$(readlink -f $0)
dir_of_project=$(dirname $file_setup)

source "${dir_of_project}"/common/version.sh


if [[ $(id -u) == 0 ]]; then
    PREFIX='/usr/local/lib'
else
    PREFIX=~/.local/lib
    SCRIPT_USER_PATH=~/.local/bin/user-path
    mkdir -p $PREFIX
fi

SHELL_LIBS="${PREFIX}/shell-libs"


function createDir(){

    mkdir -p "$SHELL_LIBS"

}



function installFiles(){
    echo -e "Instalando ... $__appname__ V${__version__} em $SHELL_LIBS"
    rm -rf "${SHELL_LIBS}"
    createDir
    
    cp -R "${dir_of_project}"/core.sh "${SHELL_LIBS}"/ 
    cp -R "${dir_of_project}"/__init__.sh "${SHELL_LIBS}"/
    cp -R "${dir_of_project}"/setup.sh "${SHELL_LIBS}"/ 
    cp -R "${dir_of_project}"/request "${SHELL_LIBS}"/ 
    cp -R "${dir_of_project}"/common "${SHELL_LIBS}"/   
    cp -R "${dir_of_project}"/system "${SHELL_LIBS}"/
    cp -R "${dir_of_project}"/scripts "${SHELL_LIBS}"/    
    echo "OK"
}



function add_script_user_path()
{
    #
    #

    [[ $(id -u) == 0 ]] && return 1
    mkdir -p ~/.local/bin 
    chmod +x "${SHELL_LIBS}"/scripts/user-path.sh
    ln -sf "${SHELL_LIBS}"/scripts/user-path.sh "${SCRIPT_USER_PATH}"

}



function add_shell_lib_rc()
{
    [[ $(id -u) == 0 ]] && return

    #echo "" > ~/.shell-libs.rc
    echo -e "export SHELL_LIBS=${SHELL_LIBS}" > ~/.shell-libs.rc
}




function main(){
    installFiles
    add_shell_lib_rc
    add_script_user_path
}



main $@





