#!/usr/bin/env bash
#
#
#


#clear

__script__=$(readlink -f $0)
dir_of_project=$(dirname $__script__)

DIR_APPS_INFO="$dir_of_project"/lib_info
STORECLI_LIB_PATH="${dir_of_project}"/lib
STORECLI_LIB_INFO_PATH="${dir_of_project}"/lib_info

AssumeYes=False
DownloadOnly=False

# Importar shell-libs

[[ -z $SHELL_LIBS ]] && {
    if [[ -d "${dir_of_project}"/shell-libs ]]; then
        export SHELL_LIBS="${dir_of_project}"/shell-libs
    elif [[ -d ~/.local/lib/shell-libs ]]; then
        export SHELL_LIBS=~/.local/lib/shell-libs
    elif [[ -d /usr/local/lib/shell-libs ]]; then
        export SHELL_LIBS=/usr/local/lib/shell-libs
    else
        echo -e "ERRO ... SHELL_LIBS não encontrado."
        exit 1
    fi

}


source "${SHELL_LIBS}"/core.sh
source "$STORECLI_LIB_PATH"/version.sh
source "$STORECLI_LIB_PATH"/manager.sh
source "$STORECLI_LIB_PATH"/show.sh
source "$STORECLI_LIB_PATH"/common.sh
source "$STORECLI_LIB_PATH"/requeriments.sh



function _startApp(){

    if [[ ! -x "${SHELL_LIBS}"/scripts/user-path.sh ]]; then
        [[ -w "${SHELL_LIBS}"/scripts/user-path.sh ]] && chmod +x "${SHELL_LIBS}"/scripts/user-path.sh
    fi


    # Configurar o PATH do usuário.
    "${SHELL_LIBS}"/scripts/user-path.sh


    # Checar dependências
    "${dir_of_project}"/scripts/check.sh || {
            
            InstallSysRequeriments
            return 1
        }
}


function createStorecliDirs()
{
    mkdir -p $(getCacheDir)    
    mkdir -p $(getCachePkgs)
    mkdir -p $(getConfigDir)
}

function usage(){
cat << EOF
    Use: storecli --install|--uninstall|--download-only|--yes

    -i|--install        Instala um ou mais pacotes
    -u|--uninstall      Desistala um ou mais pacotes.
    
    -l|--list           Exibe os pacotes que podem ser instalados.
    -v|--version        Mostra versão
    
    -U|--self-update    Atualiza esta programa para ultima versão.
    -h|--help           Mostra ajuda.

    --info <app>        Exibe informações sobre um pacote.
  
EOF

}


function _parseOpts(){

    for option in "$@"; do
        if [[ $option == '-y' ]] || [[ $option == '--yes' ]]; then
            export AssumeYes='True'
        elif [[ $option == '-d' ]] || [[ $option == '--download-only' ]]; then
            export DownloadOnly='True'
        fi
    done

}

function self_update(){
    local script_update="${dir_of_project}"/scripts/update.sh

    chmod +x "${script_update}"
    "$script_update"
}


function main()
{

    _startApp || return 1

    createStorecliDirs 
    _parseOpts $@

   
    if [[ "$1" == '-h' ]] || [[ $1 == '--help' ]]; then
        usage
        return
    elif [[ "$1" == '-v' ]] || [[ $1 == '--version' ]]; then
        echo -e "$__appname__ V${__version__}"
        return
    elif [[ "$1" == '-l' ]] || [[ $1 == '--list' ]]; then
        showApps
        return 0
    elif [[ "$1" == '-U' ]] || [[ $1 == '--self-update' ]]; then
        self_update
        return 0
    elif [[ "$1" == '-i' ]] || [[ $1 == '--install' ]]; then
        shift
        InstallPackages "$@"
    elif [[ "$1" == '-u' ]] || [[ $1 == '--uninstall' ]]; then
        shift
        UninstallPackages "$@"
    elif [[ $1 == '--info' ]]; then
        shift
        appInfo $@
        return 0
    fi


}


main $@


