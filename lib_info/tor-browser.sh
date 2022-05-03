#!/usr/bin/env bash
#
#


setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='tor-browser'
DESTINATION_DIR="${DIR_OPTIONAL}"/torbrowser-x86_64
#ICON_FILE="${DIR_HICOLOR}"/128x128/apps/
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/start-tor-browser.desktop
PKG_FILE="$(getCachePkgs)"/tor-browser-linux64-11.0.10_en-US.tar.xz
SCRIPT_FILE="${DIR_BIN}"/torbrowser
LINK_FILE=None

APP_VERSION='11.0.10'
PKG_URL='https://dist.torproject.org/torbrowser/11.0.10/tor-browser-linux64-11.0.10_en-US.tar.xz'
ONLINE_SIZE='83M'

HASH_TYPE='sha256'
HASH_VALUE='97de4c7bd84a7ca892d2c3eeea99941a78b3abf3fdfced269cf0a4b502d869c8'



function updateValues()
{
    echo
}

function _uninstall_tor_browser()
{
	green "Desinstalando ... $APP_NAME"
    print "Removendo ... $DESTINATION_DIR"; rm -rf $DESTINATION_DIR
    print "Removendo ... $SCRIPT_FILE"; rm -rf $SCRIPT_FILE
    print "Removendo ... $DESKTOP_FILE"; rm -rf $DESKTOP_FILE
    return $?
}


function _install_tor_browser()
{

	isRoot && {
		printErro "Você não pode ser o root."
		return 1
	}


	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi

    # Verificar integridade.
    checkSha256 $PKG_FILE $HASH_VALUE || return $?

    local _tmp_dir=$(mktemp -d)
    
    #             Arquivo    Destion da descompressão.
    unpackArchive $PKG_FILE $_tmp_dir || return $?
    sleep 0.1

    green "Entrando no diretório ... $_tmp_dir"
    cd $_tmp_dir || return $?
    mv tor-* tor-browser
    cd tor-browser

    green "Copiando arquivos"
    mkdir -p "$DESTINATION_DIR"
    cp -R . "${DESTINATION_DIR}"/.
    
    green "Configurando ... $APP_NAME"
    cd $DESTINATION_DIR
    ./start-tor-browser.desktop --register-app

    echo -e "#!/bin/sh\n" > "$SCRIPT_FILE"
    {
        echo -e "cd ${DESTINATION_DIR}/Browser\n"
        echo -e "./start-tor-browser \$@" 
    } >> "$SCRIPT_FILE"

    chmod +x "$SCRIPT_FILE"
    chmod +x "${DESTINATION_DIR}/Browser/start-tor-browser"

    addFileInDesktopDir "$DESKTOP_FILE"
    chmod 777 $DESKTOP_FILE
    
    rm -rf $_tmp_dir
    __open_tor_browser
    return 0
}


function __open_tor_browser()
{
    if ! isExecutable torbrowser; then return 1; fi
    printLine
    question "Deseja abrir o Tor Browser agora" || return 1
    torbrowser &
}



function main()
{	
	
    updateValues
	
	if [[ $1 == 'uninstall' ]]; then
        _uninstall_tor_browser 
    elif [[ $1 == 'install' ]]; then
        _install_tor_browser
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return $?
    elif [[ $1 == 'installed' ]]; then
        isExecutable torbrowser || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return $?	
}

# main $@