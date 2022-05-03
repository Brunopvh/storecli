#!/usr/bin/env bash
#
#

setDirsRoot

INSTALLATION_TYPE='root'
APP_NAME='wine'



function _install_wine_debian_10()
{
    # https://wiki.winehq.org/Debian
    # https://duzeru.org/pt/blog/instalar-o-wine-5-no-debian-10-debian-9-ubuntu-e-mint
    #
    #
    
    local _temp_key=$(mktemp -u)
    local _temp_file_repo=$(mktemp -u)

    _install_wine_requeriments || return $?
    webRequest 'https://dl.winehq.org/wine-builds/winehq.key' | tee $_temp_key 1> /dev/null   
    webRequest 'https://dl.winehq.org/wine-builds/debian/dists/buster/winehq-buster.sources' | tee $_temp_file_repo 1> /dev/null  

    sudoCommand mkdir -p /usr/share/keyrings
    sudoCommand mv $_temp_key /usr/share/keyrings/winehq-archive.key
    sudoCommand mv $_temp_file_repo /etc/apt/sources.list.d/winehq-buster.sources

    runApt install --install-recommends winehq-stable

}



function _install_wine_debian_11()
{
    # https://wiki.winehq.org/Debian
    # https://duzeru.org/pt/blog/instalar-o-wine-5-no-debian-10-debian-9-ubuntu-e-mint
    #
    #
    
    local _temp_key=$(mktemp -u)
    local _temp_file_repo=$(mktemp -u)

    _install_wine_requeriments || return $?
    webRequest 'https://dl.winehq.org/wine-builds/winehq.key' | tee $_temp_key 1> /dev/null   
    webRequest 'https://dl.winehq.org/wine-builds/debian/dists/bullseye/winehq-bullseye.sources' | tee $_temp_file_repo 1> /dev/null  


    sudoCommand mkdir -p /usr/share/keyrings
    sudoCommand mv $_temp_key /usr/share/keyrings/winehq-archive.key
    sudoCommand mv $_temp_file_repo /etc/apt/sources.list.d/winehq-buster.sources
    runApt update

    runApt install --install-recommends winehq-stable

}


function _install_wine_requeriments()
{
    #
    #

    if [[ -f /etc/debian_version ]]; then
        sudo dpkg --add-architecture i386
        runApt install apt-transport-https
        runApt update
    else
        return 1
    fi
}


function _install_wine_base_debian(){
    # https://forum.winehq.org/viewtopic.php?f=8&t=32192
    #
    #

    # Verificar versão
    if [[ $ID == 'debian' ]] || [[ "$VERSION_ID" == 10 ]]; then
        _install_wine_debian_10
    elif [[ $ID == 'debian' ]] || [[ "$VERSION_ID" == 11 ]]; then
        _install_wine_debian_11
    elif [[ $ID == 'linuxmint' ]] || [[ "$VERSION_ID" == 5 ]]; then
        _install_wine_debian_11
    else
        printErro "Sistema não suportado"
        return 1
    fi

}



function installWine(){
    # https://www.blogopcaolinux.com.br/2018/01/Instalando-o-WineHQ-no-Debian-e-Ubuntu.html
    #
   
    if [[ -f /etc/debian_version ]]; then
        _install_wine_base_debian
    else
        printErro "Sistema não suportado."
        return  1
    fi
}


function main()
{
	if [[ $1 == 'install' ]]; then
       installWine 
    elif [[ $1 == 'uninstall' ]]; then
        echo Falta código
    elif [[ $1 == 'get' ]]; then
        echo -e "\r"
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}
