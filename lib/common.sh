#!/usr/bin/env bash
#
#


function updateIconCache()
{
    if ! isExecutable gtk-update-icon-cache; then return 1; fi
    gtk-update-icon-cache
}

function addFileInDesktopDir()
{
    # arg 1 = file.desktop
    #
    # Copia um arquivo .desktop para Área de Trabalho do Sistema.
    #
    [[ $(id -u) == 0 ]] && return
    [[ ! -f $1 ]] && return 1

    [[ -w $1 ]] && chmod 777 "$1"

    cp -u "$1" ~/'Área de Trabalho'/ 2> /dev/null && chmod +x ~/'Área de Trabalho'/"$1" 2> /dev/null
    cp -u "$1" ~/'Área de trabalho'/ 2> /dev/null && chmod +x ~/'Área de trabalho'/"$1" 2> /dev/null
    cp -u "$1" ~/Desktop/ 2> /dev/null && chmod +x ~/'Desktop'/"$1" 2> /dev/null 
    
    updateIconCache
    return 0
}




function removeFileDesktop()
{
    # arg 1 = file.desktop
    #
    # apaga um arquivo .desktop em ~/Área de Trabalho e ~/.local/share/applications/file.desktop.
    #
    
    [[ $(id -u) == 0 ]] && return
    #[[ ! -f $1 ]] && return 1
    #if [[ ! -w $1 ]]; then echo -e "ERRO ... você não tem permissão de escrita em ... $1"; return 1; fi

    local file_name=$(basename $1)

    echo -e "Deletando ... $1"
    rm ~/'Área de Trabalho'/"$file_name" 2> /dev/null
    rm ~/'Desktop'/"$file_name" 2> /dev/null
    rm ~/'Área de trabalho'/"$file_name" 2> /dev/null
    rm "$1" 2> /dev/null  # DIR_DESKTOP_ENTRY = ~/.local/share/applications

    updateIconCache
    return 0
}


#

# Verificar requisitos do sistema.
function checkSysReq(){
    return 0
}

function getCacheDir(){ # string/path
    # Retorna um diretório cache para guardar arquivos deste APP.
    #echo -e $STORECLI_CACHE_DIR
    echo -e ~/".cache/storecli"
}

function getConfigDir()
{
	echo -e ~/".config/storecli"
}

function getCachePkgs()
{
    # rtype string/dir
    #
    # Retorna o diretório onde os pacotes são baixados.
    #
    echo -e "$(getCacheDir)"/downloads
}
