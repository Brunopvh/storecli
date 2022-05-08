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

    chmod 777 "$1"
    cp -u "$1" ~/'Área de Trabalho'/ 2> /dev/null && chmod +x ~/'Área de Trabalho'/"$1" 2> /dev/null
    cp -u "$1" ~/'Área de trabalho'/ 2> /dev/null && chmod +x ~/'Área de Trabalho'/"$1" 2> /dev/null
    cp -u "$1" ~/Desktop/ 2> /dev/null && chmod +x ~/'Área de Trabalho'/"$1" 2> /dev/null 
    
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
    echo -e ~/".cache/winecli"
}

function getConfigDir()
{
	echo -e ~/".config/winecli"
}

function getCachePkgs()
{
    # rtype string/dir
    #
    # Retorna o diretório onde os pacotes são baixados.
    #
    echo -e "$(getCacheDir)"/downloads
}


function getDataBaseFile(){ # -> string/path
    # Obter o arquivo de configurção para os pacotes instalados.
    local _file=$(getConfigDir)/installed.txt

    [[ ! -d $(getConfigDir) ]] && mkdir -p $(getConfigDir)
    touch $_file
    echo -e "$_file"
}


function wine_app_is_installed() # -> int -> bool/0-1
{
    # Verifica se um app está instalado.
    [[ -z $1 ]] && return 1

    local app=$1
    local _status=$(grep "^${app}" $(getDataBaseFile) | cut -d '>' -f 2 | sed 's/ //g')

    [[ $_status == 'True' ]] && return 0
    return 1 
}

#===================================================================#
# GERENCIAR OS PACOTES
#===================================================================#

function fetchPackages(){
    #
    #

    if [[ "${#@}" < 1 ]]; then
        printErro "fetchPackages ... parâmetro incorreto"
        return 1
    fi

    printLine
    green "Baixando pacotes"

    while [[ $1 ]]; do
        case "$1" in
            ms-core-fonts) ConfigMsCoreFonts get;;
            firefox) ConfigFirefox get;;
            pycharm) ConfigPycharm get;;
            python3) ConfigPython3 get;;
            npp) ConfigNotepad_plus_plus get;;
            torbrowser) ConfigTorBrowser get;;
            revo-uninstaller) ConfigRevoUninstaller get;;
            *) ;;
        esac
        shift
    done

}



function UninstallPackages()
{
    # $@ strings - pkg1 pkg2 pkg3 ...

    if [[ "${#@}" < 1 ]]; then
        printErro "UninstallPackages ... parâmetro incorreto"
        return 1
    fi

    
    # Instalar os pacotes
    while [[ $1 ]]; do
        case "$1" in
            ms-core-fonts) ConfigMsCoreFonts uninstall;;
            firefox) ConfigFirefox uninstall;;
            pycharm) ConfigPycharm uninstall;;
            python3) ConfigPython3 uninstall;;
            npp) ConfigNotepad_plus_plus uninstall;;  
            torbrowser) ConfigTorBrowser uninstall;;
            revo-uninstaller) ConfigRevoUninstaller uninstall;;
            *) ;;
        esac
        shift
    done    


}



#===================================================================#
# Instalar os pacotes
#===================================================================#
function InstallPackages()
{
    # $@ strings - pkg1 pkg2 pkg3 ...


    if [[ "${#@}" < 1 ]]; then
        printErro "InstallPackages ... parâmetro incorreto"
        return 1
    fi

    # Baixar os pacotes
    fetchPackages "$@"

    if [[ $DownloadOnly == 'True' ]]; then
        printInfo "Feito somente download"
        printLine
        return 0
    fi

    # Instalar os pacotes
    while [[ $1 ]]; do
        case "$1" in
            ms-core-fonts) ConfigMsCoreFonts install;;
            firefox) ConfigFirefox install;;
            pycharm) ConfigPycharm install;;
            python3) ConfigPython3 install;;
            npp) ConfigNotepad_plus_plus install;;
            torbrowser) ConfigTorBrowser install;;
            revo-uninstaller) ConfigRevoUninstaller install;;
            *) ;;
        esac
        shift
    done    
    
}
