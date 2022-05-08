#!/usr/bin/env bash
#
# https://sqlitestudio.pl/
#
# https://absam.io/blog/como-instalar-a-usar-o-sqlite-no-ubuntu-20-04/
#
#

INSTALLATION_TYPE='user'
APP_NAME='sqlite'
DESTINATION_DIR="${DIR_OPTIONAL}"/sqlite
ICON_FILE="${DIR_HICOLOR}"/64x64/apps/sqlite.svg
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/sqlite.desktop
PKG_FILE="$(getCachePkgs)"/sqlitestudio-3.3.3.tar.xz
SCRIPT_FILE="${DIR_BIN}"/sqlite
LINK_FILE=None

APP_VERSION='3.3.3'
PKG_URL='https://github.com/pawelsalawa/sqlitestudio/releases/download/3.3.3/sqlitestudio-3.3.3.tar.xz'
ONLINE_SIZE=''

HASH_TYPE='sha256'
HASH_VALUE=''


function _uninstall_sqlite()
{
	green "Desinstalando ... $APP_NAME"
    # Instalar o sqlite.
    if [[ -f /etc/debian_version ]]; then
        runApt remove sqlite3
    else
        printErro "Sistema não suportado"
        return 1
    fi
    return 0
}


function _install_sqlite()
{
	# Instalar o sqlite.
	if [[ -f /etc/debian_version ]]; then
        runApt install sqlite3
    else
        printErro "Sistema não suportado"
        return 1
    fi
    return 0
}


function main()
{	
	#setDirsUser
	
	if [[ $1 == 'install' ]]; then
        _install_sqlite 
    elif [[ $1 == 'uninstall' ]]; then
        _uninstall_sqlite
    elif [[ $1 == 'get' ]]; then
        #download $PKG_URL $PKG_FILE || return $?
        return 0
    elif [[ $1 == 'installed' ]]; then
        isExecutable sqlite3 || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return $?	
}


# main $@