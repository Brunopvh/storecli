#!/usr/bin/env bash
#




function fetchPackages(){
    #
    #

    if [[ "${#@}" < 1 ]]; then
        printErro "fetchPackages ... parâmetro incorreto"
        return 1
    fi

    printLine
    print "Baixando pacotes"

    while [[ $1 ]]; do
        case "$1" in
            balena-etcher) ConfigBalenaEtcher get;;
            pycharm) ConfigPycharm get;;
            sublime-text) ConfigSublimeText get;;
            virtualbox) ConfigVirtualBox get;;
            appcli) ConfigAppcli get;;
            tor-browser) ConfigTorBrowser get;;
            freetube) ConfigFreetube get;;
            wine) ConfigWine get;;
			stacer) ConfigStacer get;;
            code) ConfigVsCode get;;
            mscorefonts) ConfigMscorefonts get;;
            sqlite3) ConfigSqlite3 get;;
            sqlite-browser) ConfigSqliteBrowser get;;
            poweriso) ConfigPoweriso get;;
            android-studio) ConfigAndroidStudio get;;
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
            balena-etcher) ConfigBalenaEtcher uninstall;;
            pycharm) ConfigPycharm uninstall;;
            sublime-text) ConfigSublimeText uninstall;;
            virtualbox) ConfigVirtualBox uninstall;;
            appcli) ConfigAppcli uninstall;;
            tor-browser) ConfigTorBrowser uninstall;;
            freetube) ConfigFreetube uninstall;;
            wine) ConfigWine uninstall;;
			stacer) ConfigStacer uninstall;;
            code) ConfigVsCode uninstall;;
            mscorefonts) ConfigMscorefonts uninstall;;
            sqlite3) ConfigSqlite3 uninstall;;
            sqlite-browser) ConfigSqliteBrowser uninstall;;
            poweriso) ConfigPoweriso uninstall;;
            android-studio) ConfigAndroidStudio uninstall;;
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
            balena-etcher) ConfigBalenaEtcher install;;
            pycharm) ConfigPycharm install;;
            sublime-text) ConfigSublimeText install;;
            virtualbox) ConfigVirtualBox install;;
            appcli) ConfigAppcli install;;
            tor-browser) ConfigTorBrowser install;;
            freetube) ConfigFreetube install;;
            wine) ConfigWine install;;
			stacer) ConfigStacer install;;
            code) ConfigVsCode install;;
            mscorefonts) ConfigMscorefonts install;;
            sqlite3) ConfigSqlite3 install;;
            sqlite-browser) ConfigSqliteBrowser install;;
            poweriso) ConfigPoweriso install;;
            android-studio) ConfigAndroidStudio install;;
            *) ;;
        esac
        shift
    done    
    
}



function ConfigAndroidStudio(){
    source "${STORECLI_LIB_INFO_PATH}"/android-studio.sh || return $?
    main $@
}



function ConfigPoweriso(){
    source "${STORECLI_LIB_INFO_PATH}"/power-iso.sh || return $?
    main $@
}



function ConfigSqliteBrowser(){
    source "${STORECLI_LIB_INFO_PATH}"/sqlite-browser.sh || return $?
    main $@
}


function ConfigSqlite3(){
    source "${STORECLI_LIB_INFO_PATH}"/sqlite.sh || return $?
    main $@
}



function ConfigMscorefonts(){

    source "${STORECLI_LIB_INFO_PATH}"/ms-core-fonts.sh || return $?
    main $@

}



function ConfigVsCode(){
    source "${STORECLI_LIB_INFO_PATH}"/vscode.sh || return $?
    main $@
}



function ConfigStacer(){
    
    source "${STORECLI_LIB_INFO_PATH}"/stacer.sh || return $?
    main $@
}




function ConfigWine(){
    
    source "${STORECLI_LIB_INFO_PATH}"/wine.sh || return $?
    main $@
}


function ConfigFreetube()
{
    source "${STORECLI_LIB_INFO_PATH}"/freetube.sh || return $?
    main $@ 
}


function ConfigTorBrowser(){
    # arg 1 = install | uninstall | get | installed
    #
   
    source "${STORECLI_LIB_INFO_PATH}"/tor-browser.sh || return $?
    main $@
}


function ConfigAppcli(){
    # arg 1 = install | uninstall | get | installed
    #
   
    source "${STORECLI_LIB_INFO_PATH}"/appcli.sh || return $?
    main $@
}


#===================================================================#
# VirtualBox
#===================================================================#
function ConfigVirtualBox(){
    # arg 1 = install | uninstall | get | installed
    # 
    # install   - Instala o pacote
    # get       - Baixa o pacote
    # uninstall - Desinstala o pacote
    # installed - Verifica se o pacote está instalado.
    #

    source "${STORECLI_LIB_INFO_PATH}"/virtualbox.sh || return $?
    main $@
    
}



#===================================================================#
# Instalar os pacotes
#===================================================================#
function ConfigVirtualBoxExtPack()
{
    echo
}

function ConfigBalenaEtcher(){
    # arg 1 = install | uninstall | get | installed
    #

    source "${STORECLI_LIB_INFO_PATH}"/balena-etcher.sh || return $?
    main $@
}

function ConfigPycharm(){
    # arg 1 = install | uninstall | get | installed
    #
    #   install - Instala o pycharm
    #   uninstall - Desinstala o pycharm
    #   get  - Baixa o pycharm
    #   installed - verifica se o pycharm está instalado, se estiver instalado retorna 0, se não retorna 1.
    #              
    
    source "${STORECLI_LIB_INFO_PATH}"/pycharm.sh || return $?
    main $@
}



function ConfigSublimeText(){
    # arg 1 = install | uninstall | get | installed
    #

    source "${STORECLI_LIB_INFO_PATH}"/sublime-text.sh || return $?
    main $@
}






