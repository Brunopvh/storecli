#!/usr/bin/env bash
#
#

setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='appcli'
DESTINATION_DIR="${DIR_OPTIONAL}"/appcli

PKG_FILE="$(getCachePkgs)"/appcli.zip
SCRIPT_FILE="${DIR_BIN}"/appcli

LINK_FILE=None
APP_VERSION='0.2.4'
PKG_URL='https://gitlab.com/bschaves/app-cli/-/archive/v0.2.4/app-cli-v0.2.4.zip'
ONLINE_SIZE='None'

HASH_TYPE='sha256'
HASH_VALUE='48f4adb99e707d845099b70063c9d8a3b6dda0a0e55c07677a414b220c7c48bc'

function __uninstall_appcli()
{
	green "Desinstalando ... $APP_NAME"
    rm -rf $DESTINATION_DIR
    rm -rf $SCRIPT_FILE
    return 0
}


function __install_appcli_req()
{
    # Instalar dependências do appcli.
    if isFile '/etc/debian_version'; then
        runApt update
        runApt install python3 python3-pip
    fi
    
}


function __install_appcli()
{

	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi

    checkSha256 $PKG_FILE $HASH_VALUE || return $?
    local _tmp_dir=$(mktemp -d)
    
    #             Arquivo    Destion da descompressão.
    __install_appcli_req
    printLine
    unpackArchive $PKG_FILE $_tmp_dir || return $?

    green "Entrando no diretório ... $_tmp_dir"
    cd $_tmp_dir || return $?
    mv app-cli* app-cli
    cd app-cli

    ./setup.sh

    rm -rf $_tmp_dir
}

function main()
{
	if [[ $1 == 'uninstall' ]]; then
        __uninstall_appcli
    elif [[ $1 == 'install' ]]; then
        
        __install_appcli
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}

# main $@