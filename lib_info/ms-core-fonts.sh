#!/usr/bin/env bash
#
#

setDirsRoot


INSTALLATION_TYPE='root'
APP_NAME='mscorefonts'


PKG_FILE=""

PKG_URL=''
ICON_URL=''

ONLINE_SIZE=''
HASH_TYPE='sha512'
HASH_VALUE='2458d5010bc825192394283ea02cac525daccd8a640e93a8fcc203f70840a214fbdc4eadc6b89ba6ff5f59392a109cde15a3bbb61330f747bc74db0017568cd3'


function setInfo(){
	if [[ -f /etc/debian_version ]]; then
		PKG_URL='http://ftp.br.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb'
        PKG_FILE="$(getCachePkgs)"/ttf-mscorefonts-installer_3.6_all.deb
	fi 
}



function _uninstall_mscorefonts()
{
	green "Desinstalando ... $APP_NAME"
    echo
}


function _install_mscorefonts_debfile(){
    # https://www.vivaolinux.com.br/dica/Instalando-fontes-da-Microsoft-no-Debian
    # 
    
    checkSha512 $PKG_FILE $HASH_VALUE || return $?
    runApt update
    runApt install "$PKG_FILE"
}



function _install_mscorefonts()
{
    #
    # https://www.linuxcapable.com/pt/install-microsoft-fonts-on-debian-11-bullseye
    #
    #
    
    if [[ -f /etc/debian_version ]]; then
        runApt update
        runApt install ttf-mscorefonts-installer
    else
        printErro "Sistema não suportado."
        return 1
    fi

}





function main()
{
    #

    setInfo

	
	if [[ $1 == 'uninstall' ]]; then
        _uninstall_mscorefonts
    elif [[ $1 == 'install' ]]; then
        _install_mscorefonts
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return 1
    elif [[ $1 == 'install' ]]; then
        isExecutable stacer || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}


# main $@
