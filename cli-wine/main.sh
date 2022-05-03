#!/usr/bin/env bash
#
# 

#clear

readonly __file__=$(readlink -f $0)
readonly dir_of_project=$(dirname $__file__)
readonly WINECLI_LIB_PATH="${dir_of_project}"/lib
readonly _workdir=$(pwd)

# Setar o diretório SHELL_LIBS
function set_libs_path(){
	#
	# 
	cd $dir_of_project
	cd ../
	if [[ -d ./shell-libs ]]; then
		export SHELL_LIBS=$(pwd)/shell-libs
	elif [[ -d ~/.local/lib/shell-libs ]]; then
		export SHELL_LIBS=~/.local/lib/shell-libs
	elif [[ -d /usr/local/lib/shell-libs ]]; then
		export SHELL_LIBS=/usr/local/lib/shell-libs
	else
		echo -e "ERRO ... SHELL_LIBS não encontrado"
		exit 1
	fi

	cd $_workdir
}

if [[ -z $SHELL_LIBS ]]; then
	set_libs_path || exit 1
fi


# Importar módulos
source "${SHELL_LIBS}"/core.sh
source "${dir_of_project}"/lib/common.sh
source "${dir_of_project}"/lib/show.sh
source "${dir_of_project}"/lib/version.sh
source "${dir_of_project}"/lib/apps.sh



function usage(){
cat << EOF
    Use: storecli --install|--uninstall|--download-only|--yes

    -i|--install    Instala um ou mais pacotes
    -u|--uninstall  Desistala um ou mais pacotes.
    -l|--list       Exibe os pacotes que podem ser instalados.
    -v|--version    Mostra versão
    -h|--help       Mostra ajuda.

    --force         Força a instalação
    --installed     Exibe os Apps instalados.
    --info <app>    Exibe informações sobre um pacote.

EOF

}



function createDirs()
{
    mkdir -p $(getCacheDir)    
    mkdir -p $(getCachePkgs)
    mkdir -p $(getConfigDir)
}



function _parseOpts(){

    for option in "$@"; do
        if [[ $option == '-y' ]] || [[ $option == '--yes' ]]; then
            export AssumeYes='True'
        elif [[ $option == '-d' ]] || [[ $option == '--download-only' ]]; then
            export DownloadOnly='True'
        elif [[ $option == '--force' ]]; then
            export forceInstall='True'
        fi
    done

}


function main()
{

    createDirs 
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
    elif [[ $1 == '--info' ]]; then
        shift
        appInfo $@
        return 0
    elif [[ "$1" == '-i' ]] || [[ $1 == '--install' ]]; then
        shift
        InstallPackages "$@"
    elif [[ "$1" == '-u' ]] || [[ $1 == '--uninstall' ]]; then
        shift
        UninstallPackages "$@"
    elif [[ $1 == '--installed' ]]; then
        showInstalledApps
        return
    fi


}


 main $@
