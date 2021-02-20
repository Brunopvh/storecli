#!/usr/bin/env bash
#
#
__version__='2021_02_20'
__author__='Bruno Chaves'
__appname__='storecli'	
#
#=============================================================#
# INFO
#=============================================================#
#    Este programa serve para instalar os aplicativos comumente mais
# usados em um computador com Linux. Como por exemplo: Codecs de mídia
# reprodutores de vídeo, navegadores de internet, IDEs entre outras
# ferramentas.
#   Testado nos seguintes sistemas: Debian 10 - GNOME, Fedora 31/32 - GNOME
# Ubuntu 18.04/20.04 - GNOME, LinuxMint 19.3, ArchLinux - GNOME.
#
# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#
#=============================================================#
# GitHub
#=============================================================#
# https://github.com/Brunopvh/storecli


#=============================================================#
# Verificar requisitos minimos do sistema.
#=============================================================#
# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]]; then
	printf "\033[0;31m Execute este programa apenas em sistemas Linux.\033[m\n"
	exit 1
fi

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	printf "\033[0;31m Usuário não pode ser o 'root' execute novamente sem o [sudo].\033[m\n"
	exit 1
fi

# Necessário ter o "sudo" intalado.
if [[ ! -x $(command -v sudo) ]]; then
	printf "\033[0;31m Instale o pacote 'sudo' e adicione [$USER] no arquivo 'sudoers' para prosseguir.\033[m\n"
	exit 1
fi

# Verificar se a arquitetura do Sistema e 64 bits
if ! uname -m | grep '64' 1> /dev/null; then
	printf "\033[0;31m Seu sistema não é 64 bits saindo.\033[m\n"
	exit 1
fi

#=============================================================#
# Diretórios do usuário
#=============================================================#
[[ -f ~/.bashrc ]] && source ~/.bashrc 2> /dev/null
[[ -f ~/.shmrc ]] && source ~/.shmrc
[[ ! -d $HOME ]] && HOME=~/
[[ ! -w $HOME ]] && {
	printf "\033[0;31mVocê não tem permissão de escrita [-w] em ... $HOME\033[m\n"
	exit 1
}

#=============================================================#
# Importação de módulos externos.
#=============================================================#
# Repositório no github.
# https://github.com/Brunopvh/bash-libs
#
# Instalação.
# sudo sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)" 
# sudo sh -c "$(wget -q -O- https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)"
#
#

function show_import_erro()
{
	echo "ERRO: $@"
	read -p 'Pressione enter para continuar... ' -t 3 Input
	echo
}

function check_local_modules()
{
	#
	[[ -z $config_path ]] && return 1
	[[ -z $crypto ]] && return 1
	[[ -z $file_programs ]] && return 1
	[[ -z $os ]] && return 1
	[[ -z $requests ]] && return 1
	[[ -z $utils ]] && return 1
	[[ -z $pkgmanager ]] && return 1
	[[ -z $print_text ]] && return 1
	[[ -z $platform ]] && return 1
	return 1
}

check_local_modules || {
	show_import_erro "Necessário instalar alguns módulos externos."
	TempSetupFile=$(mktemp)
	if [[ -x $(command -v wget) ]]; then
		wget -q -O "$TempSetupFile" https://raw.github.com/Brunopvh/bash-libs/main/setup.sh || exit 1
	elif [[ -x $(command -v curl) ]]; then
		curl -fsSL -o "$TempSetupFile" https://raw.github.com/Brunopvh/bash-libs/main/setup.sh || exit 1
	else
		echo "Instale curl ou wget para prosseguir"
		exit 1
	fi

	chmod +x "$TempSetupFile"
	"$TempSetupFile"
	exit 1
}

#=============================================================#
# Criar diretórios para arquivos temporários para descompressão dos
# arquivos baixados, e clone(s) de repositórios do github. 
#=============================================================#
#readonly export TemporaryDirectory="/tmp/storecli_$USER"
export readonly TemporaryDirectory="$(mktemp -u)-$__appname__"; mkdir "$TemporaryDirectory"
export readonly DirTemp="$TemporaryDirectory/temp"
export readonly DirGitclone="$TemporaryDirectory/gitclone"
export readonly DirUnpack="$TemporaryDirectory/unpack"
export readonly DirDownloads="$HOME/.cache/$__appname__/downloads"
export readonly HtmlTemporaryFile="$DirTemp/Temp.html"
export readonly DIR_CONFIG_USER=~/.config/"$__appname__"

mkdir -p "$DirTemp"
mkdir -p "$DirGitclone"
mkdir -p "$DirUnpack"
mkdir -p "$DirDownloads"
mkdir -p "$DIR_CONFIG_USER"

#=============================================================#
# Arquivos de configuração e Log.
#=============================================================#
export configFILE="$DIR_CONFIG_USER/requeriments.conf"
export LogFile="$HOME/.cache/$__appname__/storecli.log"
export LogErro="$HOME/.cache/$__appname__/storecli.err"
export OutputDevice="$HOME/.cache/$__appname__/storecli-output.log"

echo '' > "$OutputDevice"
touch "$configFILE"
touch "$LogFile"
touch "$LogErro"

#=============================================================#
# Diretórios do root
#=============================================================#
DIR_BIN_ROOT='/usr/local/bin'
DIR_ICON_ROOT='/usr/share/icons/hicolor'
DIR_THEME_ROOT='/usr/share/themes/'
DIR_DESKTOP_ROOT='/usr/share/applications'

if [[ ! -d "$DIR_BIN_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_BIN_ROOT"
	sudo mkdir "$DIR_BIN_ROOT"
fi


if [[ ! -d "$DIR_ICON_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_ICON_ROOT"
	sudo mkdir "$DIR_ICON_ROOT"
fi


if [[ ! -d "$DIR_THEME_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_THEME_ROOT"
	sudo mkdir "$DIR_THEME_ROOT"
fi


if [[ ! -d "$DIR_DESKTOP_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_DESKTOP_ROOT"
	sudo mkdir "$DIR_DESKTOP_ROOT"
fi

# Controle do status de saida ao longo do script.
export STATUS_OUTPUT='0'

# Configuração de diretórios usados por este programa
readonly export __script__=$(readlink -f "$0") # Este arquivo.
readonly export dir_of_executable=$(dirname "$__script__") # Diretório raiz deste arquivo.
readonly export path_bash_libs="$dir_of_executable/lib"
readonly export dir_local_scripts="$dir_of_executable/scripts"
readonly export dir_local_python="$dir_of_executable/python"

#=============================================================#
# Importar Libs
#=============================================================#
source "$path_bash_libs/destination_programs.sh"
source "$path_bash_libs/list_programs.sh"
source "$path_bash_libs/utils.sh"
source "$path_bash_libs/installer_utils.sh"
source "$path_bash_libs/requeriments.sh"
source "$path_bash_libs/UninstallPkgs.sh"
source "$path_bash_libs/programs.sh"
source "$path_bash_libs/wineutils.sh"
source "$path_bash_libs/gui.sh"

# Definir os scripts locais.
SCRIPT_CONFIG_PATH="$dir_local_scripts/conf-path.sh"
SCRIPT_ADD_REPO="$dir_local_scripts/addrepo.py"
SCRIPT_TORBROWSER_INSTALLER="$DIR_BIN/tor-installer"
SCRIPT_STORECLI_INSTALLER="$dir_of_executable/setup.sh"
SCRIPT_OHMYBASH_INSTALLER="$dir_local_scripts/ohmybash.run"
SCRIPT_WINETRICKS_LOCAL="$dir_local_scripts/winetricks.sh"

# Sempre verificar a configuração do PATH do usuário ao iniciar.
"$SCRIPT_CONFIG_PATH"

usage()
{
cat << EOF
    Use: $__script__ -b|-c|-d|-I|-h|-l|-v
         $__script__ install <pacote>
         $__script__ remove <pacote>

    Opções:

       -b|--broke                    Remove pacotes quebrados - (usar em sistemas Debian apenas).
       -c|--configure                Instala requerimentos desse script.
       -d|--downloadonly             Apenas baixa os pacotes, quando disponíveis.
       -h|--help                     Mostra ajuda.
       -I|--ignore-cli               Ignora a verificação dos pacotes/dependências deste script.
                                     $__script__ --ignore-cli install <pacote>

       -l|--list                     Lista aplicativos disponíveis para instalação, ou aplicativos
                                     de uma categoria, argumentos:
                                     --list Acessorios|Desenvolvimento|Escritorio|Navegadores|Internet|Sistema
                                     |Preferencias|GnomeShell.

       -u|--self-update              Instala ultima versão desse script disponível no github.
       -v|--version                  Mostra versão.
       -y|--yes                      Assume sim para maioria da indagações.
                                     
     Argumentos:
       remove <remove>             Remove um pacote.
       install <pacote>            Instala um pacote.

       Instalando vários pacotes:
             $__script__ install etcher sublime-text google-chrome youtube-dl-gui virtualbox

       Instalando uma categoria/grupo de pacotes:
             $__script__ --install Acessorios Desenvolvimento Escritorio Internet

EOF
}

function _resolution()
{
	if is_executable xdpyinfo; then
		# Resolution=$(xdpyinfo | grep -A 3 "screen #0" | grep dimensions | awk '{print $4}' | sed 's/(//g')
		Resolution=$(xdpyinfo | grep -A 3 "screen #0" | grep dimensions | tr -s " " | cut -d" " -f 3)
		ResolutionX=$(echo $Resolution | cut -d 'x' -f 1)
		ResolutionY=$(echo $Resolution | cut -d 'x' -f 2)
	fi
	
	if [[ -z $Resolution ]]; then
		SetResolutionX=130
		SetResolutionY=30
	else
		SetResolutionX="$(($ResolutionX/2))"
		SetResolutionY="$(($ResolutionY/2))"
	fi

	SetGeometry="${SetResolutionX}x${SetResolutionY}"
}

main()
{	
	for ARG in "$@"; do
		case "$ARG" in
			-y|--yes) export AssumeYes='True';;
			-d|--downloadonly) export DownloadOnly='True';;
			-I|--ignore-cli) export IgnoreCli='True';;
			-l) shift; _list_applications "$@"; return 0; break;;
			-h|--help) usage; return 0; break;;
			-u|--self-update) "$SCRIPT_STORECLI_INSTALLER"; return 0; break;;
			-v|--version) echo -e "$(basename $__script__) V${__version__}"; return 0; break;;
		esac
	done

	# Se a string 'requeriments OK' não estiver no arquivo de configuração significa 
	# que a função de configuração do sistema ainda não foi executada no sistema atual, 
	# ou seja, se o GREP abaixo retornar status diferente de '0' a 
	# função de configuração será invocada.
	if [[ "$IgnoreCli" != 'True' ]]; then
		if ! grep -q 'requeriments OK' "$configFILE"; then
			_install_requeriments || return 1
		fi
	fi
	
	# Verificar se todos os utilitários de linha de comando estão instalados 
	# esta operação será IGNORADA caso a opção '--ignore-cli' ou '-I' estiver 
	# na linha de comando.
	# Exemplos:  
	#   storecli --ignore-cli install <pacote>
	#   storecli -I install <pacote>
	if [[ "$IgnoreCli" != 'True' ]] && [[ "$1" != '--configure' ]] && [[ "$1" != '-c' ]]; then
		check_requeriments_cli || return 1
	fi

	_update_storecli

	# Se nenhum argumento for passado na linha de comando, será aberto o GUI gráfico com o zenity.
	if [[ -z $1 ]]; then
		main_menu
		return "$?"
	fi

	while [[ $1 ]]; do
		case "$1" in
			-b|--broke) _BROKE;;
			-c|--configure) _install_requeriments;;
			install) shift; _pkg_manager_storecli "$@" || STATUS_OUTPUT=1; break;;
			remove)  shift; _uninstall_packages "$@" || STATUS_OUTPUT=1; break;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			-I|--ignore-cli) ;;
			*) _red "(main) argumento inválido: $ARG"; STATUS_OUTPUT='1'; break;;
		esac
		shift
	done
	return "$STATUS_OUTPUT"
}

main "${@}" && STATUS_OUTPUT=0

# Remover diretórios e subdiretórios temporários ao encerrar o programa.
__rmdir__ "$TemporaryDirectory" 1> /dev/null

if [[ "$STATUS_OUTPUT" == 0 ]]; then
	exit 0
else
	exit 1
fi




