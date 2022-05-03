#!/usr/bin/env bash
#
#
#=============================================================#
# USO
#=============================================================#
# ./storecli.sh --help
# ./storecli.sh install <app>
# ./storecli.sh remove <app>
# ./storecli.sh --configure
# ./storecli.sh --list
#
#
#
#
#=============================================================#
# INFO
#=============================================================#
#    Este programa serve para instalar os aplicativos comumente mais
# usados em um computador com Linux. 
#    Exemplos: 
# Codecs de mídia, reprodutores de vídeo, navegadores de internet, IDEs entre outras
# ferramentas.
#   Testado nos seguintes sistemas: 
# Debian 10 - GNOME
# Fedora 31/32 - GNOME
# Ubuntu 18.04/20.04 - GNOME, 
# LinuxMint 19.3 
# ArchLinux - GNOME.
# 
#  Use em outras distros por sua propria conta em risco.
#
#=============================================================#
# Instalação 
#=============================================================#
# Gnu wget
# bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#
# cURL
# bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#
#=============================================================#
# GitHub
#=============================================================#
# https://github.com/Brunopvh/storecli -> Repositório deste programa.
# https://github.com/Brunopvh/bash-libs -> Repositório das libs usadas por este programa.
#

__version__='2.1'
__author__='Bruno Chaves'
__appname__='storecli'

#=============================================================#
# Verificar requisitos minimos do sistema.
#=============================================================#
# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]]; then
	printf "\033[0;31m Execute este programa apenas em sistemas Linux.\033[m\n"
	exit 1
fi

# Usuário não pode ser o root.
if [[ $(id -u) == 0 ]]; then
	printf "\033[0;31m Usuário não pode ser o 'root' execute novamente sem o [sudo].\033[m\n"
	exit 1
fi

# Necessário ter o "sudo" intalado.
if [[ ! -x $(command -v sudo) ]]; then
	printf "\033[0;31m Instale o pacote 'sudo' e adicione [$USER] no arquivo 'sudoers' para prosseguir.\033[m\n"
	exit 1
fi

# Verificar se a arquitetura do Sistema e 64 bits
if ! uname -m | grep -q "64$"; then
	printf "\033[0;31m Seu sistema não é 64 bits saindo.\033[m\n"
	exit 1
fi

#=============================================================#
# Setar o arquivo de configuração bashrc/zshrc para importar as
# configurações do usuario $(whoami)
#=============================================================#
USER_SHELL=$(basename $SHELL)

if [[ $USER_SHELL == 'zsh' ]]; then
	if [[ -f ~/.zshrc ]]; then
		__shell_config_file__=~/.zshrc
	elif [[ -f /etc/zsh/zshrc ]]; then
		__shell_config_file__=/etc/zsh/zshrc
	else
		echo "ERRO ... arquivo de configuração zshrc não encontrado"
		sleep 1
	fi
elif [[ $USER_SHELL == 'bash' ]]; then
	if [[ -f ~/.bashrc ]]; then
		__shell_config_file__=~/.bashrc
	elif [[ -f /etc/bash.bashrc ]]; then
		__shell_config_file__=/etc/bash.bashrc
	else
		echo "ERRO ... arquivo de configuração bashrc não encontrado"
		sleep 1
	fi
fi

# [[ -f ~/.shmrc ]] && source ~/.shmrc

[[ ! -d $HOME ]] && HOME=~/
[[ ! -w $HOME ]] && {
	printf "\033[0;31mVocê não tem permissão de escrita [-w] em ... $HOME\033[m\n"
	exit 1
}
	

# Controle do status de saida ao longo do script.
export STATUS_OUTPUT='0'
export WORK_DIR=$(pwd)

export URL_RAW_REPO_MASTER='https://raw.github.com/Brunopvh/storecli/master'
export URL_RAW_REPO_DEVELOPMENT='https://raw.github.com/Brunopvh/storecli/development'
export URL_SCRIPT_STORECLI="$URL_RAW_REPO_MASTER/storecli.sh"

# Configuração e diretórios usados por este programa
readonly export __script__=$(readlink -f "$0") # Este arquivo.
readonly export dir_of_executable=$(dirname "$__script__") # Diretório pai deste arquivo.
readonly export path_local_libs="$dir_of_executable/lib"
readonly export dir_local_scripts="$dir_of_executable/scripts"
readonly export dir_local_python="$dir_of_executable/python"
readonly export PATH_BASH_LIBS="${dir_of_executable}"/bash-libs/libs


#=============================================================#
# Importação de módulos externos.
#=============================================================#
# Repositório github: https://github.com/Brunopvh/bash-libs
#
# Instalação do gerenciador de pacotes para módulos externos(shm-> ~/.local/bin/shm - /usr/local/bin/shm).
# sudo bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)" 
# sudo bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)"

function show_import_erro()
{
	# Exibir erro generico se a importação módulos falhar.
	echo "$__appname__ ERRO módulo não encontrado ... $@"
	sleep 1
	return 1
}

function check_external_modules() # retorna 0 ou 1.
{
	# Verificar se todos os módulos externos necessários estão disponíveis para serem importados.

	[[ ! -d "$PATH_BASH_LIBS" ]] && {
		echo "$__appname__ ERRO ... diretório PATH_BASH_LIBS não encontrado."
		return 1
	}

	[[ ! -f $PATH_BASH_LIBS/config_path.sh ]] && { 
		show_import_erro "config_path"; return 1
	}

	[[ ! -f $PATH_BASH_LIBS/crypto.sh ]] && {
		show_import_erro "crypto"; return 1
	}

	[[ ! -f $PATH_BASH_LIBS/files_programs.sh ]] && { 
		show_import_erro "files_programs"; return 1
	}

	[[ ! -f $PATH_BASH_LIBS/os.sh ]] && { 
		show_import_erro "os"; return 1 
	}

	[[ ! -f $PATH_BASH_LIBS/requests.sh ]] && { 
		show_import_erro "requests"; return 1 
	}

	[[ ! -f $PATH_BASH_LIBS/utils.sh ]] && { 
		show_import_erro "utils"; return 1 
	}
	
	[[ ! -f $PATH_BASH_LIBS/pkgmanager.sh ]] && { 
		show_import_erro "pkgmanager"; return 1 
	}
	
	[[ ! -f $PATH_BASH_LIBS/print_text.sh ]]&& {
		show_import_erro "print_text"; return 1
	}
	
	[[ ! -f $PATH_BASH_LIBS/platform.sh ]] && {
		show_import_erro "platform"; return 1
	}

	return 0
}

function install_external_modules() 
{
	# Ao executar esta função ela instala as dependências deste programa apartir de um script online.
	cd "$dir_of_executable"
	echo "Aguarde"
	if [[ -f setup.sh ]]; then
		chmod +x ./setup.sh
		./setup.sh
	elif [[ -x $(command -v wget) ]]; then
		bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	elif [[ -x $(command -v curl) ]]; then
		bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	elif [[ -x $(command -v aria2c) ]]; then
		_tmpfile=$(mktemp -u)
		aria2c 'https://raw.github.com/Brunopvh/storecli/master/setup.sh' -d $(dirname "$_tmpfile") -o $(basename "$_tmpfile") 1> /dev/null
		bash "$_tmpfile"
		rm -rf "$_tmpfile" 2> /dev/null
		unset _tmpfile
	else
		echo "(install_external_modules) ERRO ... Instale curl ou wget para prosseguir."
		sleep 1
		exit 1
	fi

	# Depois de executar o intalador, teremos o gerenciador de módulos bash(shm) disponível.
	# basta proseguir com a instalação dos módulos requeridos.
	if [[ -x ~/.local/bin/shm ]]; then
		local path_script_shm=~/'.local/bin/shm'
	elif [[ -x /usr/local/bin/shm ]]; then
		local path_script_shm='/usr/local/bin/shm'
	else
		echo "(install_external_modules) ERRO ... script shm não instalado."
		return 1
	fi

	"$path_script_shm" update 
	"$path_script_shm" --upgrade --install platform print_text pkgmanager utils requests os files_programs crypto config_path
	exit 1 # Não remova.
}

# Setar o diretório pai com os módulos bash ou baixar/configurar se  necessário.
# o caminho para PATH_BASH_LIBS pode ser passado como argumento da opção --lib
if [[ "$1" == "--lib" ]]; then
	if [[ ! -d "$2" ]]; then
		echo "ERRO ... o diretório não existe ... $2"
		sleep 0.5
		exit 1
	fi
	export PATH_BASH_LIBS="$2"
	echo "Usando módulos em ... $PATH_BASH_LIBS"
	shift
	shift
	sleep 0.5
	check_external_modules || exit 1
fi

[[ -d "$PATH_BASH_LIBS" ]] || source $__shell_config_file__ 2> /dev/null
check_external_modules || { install_external_modules; exit 1; }

#=============================================================#
# Criar diretórios para arquivos temporários para descompressão dos
# arquivos baixados, e clone(s) de repositórios do github. 
#=============================================================#
#readonly export TemporaryDirectory="/tmp/storecli_$USER"
export readonly TemporaryDirectory=$(mktemp -d) 
export readonly DirTemp="$TemporaryDirectory/temp"
export readonly DirGitclone="$TemporaryDirectory/gitclone"
export readonly DirUnpack="$TemporaryDirectory/unpack"
export readonly DIR_CONFIG_USER=~/.config/"$__appname__"
export readonly DIR_CACHE_USER=~/.cache/"$__appname__"

if [[ $(id -u) == 0 ]]; then
	export readonly DirDownloads="/var/cache/$__appname__/downloads"
else
	#export readonly DirDownloads=~/".cache/$__appname__/downloads"
	export readonly DirDownloads=~/".cache/appcli/downloads"
fi

mkdir -p "$TemporaryDirectory"
mkdir -p "$DirTemp"
mkdir -p "$DirGitclone"
mkdir -p "$DirUnpack"
mkdir -p "$DirDownloads"
mkdir -p "$DIR_CONFIG_USER"
mkdir -p "$DIR_CACHE_USER"

#=============================================================#
# Arquivos de configuração e Log.
#=============================================================#
export ConfigFile="$DIR_CONFIG_USER/requeriments.conf"
export LogFile="$DIR_CACHE_USER/storecli.log"
export LogErro="$DIR_CACHE_USER/storecli.err"
export OutputDevice="$DIR_CACHE_USER/storecli-output.log"

echo '' > "$OutputDevice"
touch "$ConfigFile"
touch "$LogFile"
touch "$LogErro"

#=============================================================#
# Importar modulos externos - VER o arquivo ~/.shmrc ou /root/.shmrc
#=============================================================#
source $PATH_BASH_LIBS/config_path.sh
source $PATH_BASH_LIBS/print_text.sh
source $PATH_BASH_LIBS/os.sh
source $PATH_BASH_LIBS/pkgmanager.sh
source $PATH_BASH_LIBS/files_programs.sh
source $PATH_BASH_LIBS/requests.sh
source $PATH_BASH_LIBS/utils.sh
source $PATH_BASH_LIBS/crypto.sh

#=============================================================#
# Importar Módulos locais
#=============================================================#
source "$path_local_libs/requeriments.sh"
source "$path_local_libs/uninstall_apps.sh"
source "$path_local_libs/programs.sh"
source "$path_local_libs/wineutils.sh"
source "$path_local_libs/gui.sh"


# Sempre verificar a configuração do PATH do usuário ao iniciar.
if [[ $(id -u) != 0 ]]; then
	config_bashrc
	config_zshrc
fi

# Definir os scripts locais.
SCRIPT_ADD_REPO="$dir_local_scripts/addrepo.py"
SCRIPT_TORBROWSER_INSTALLER="$DIR_BIN/tor-installer"
SCRIPT_STORECLI_INSTALLER="$dir_of_executable/setup.sh"
SCRIPT_OHMYBASH_INSTALLER="$dir_local_scripts/ohmybash.run"
SCRIPT_WINETRICKS_LOCAL="$dir_local_scripts/winetricks.sh"

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


  
     -v|--version                  Mostra versão.
     -y|--yes                      Assume sim para maioria da indagações.


     --lib <path_bash_libs>        Informar o diretório pai com os módulos bash necessários para execução deste programa.
                                     é OBRIGATÓRIO que ARG1 seja --lib e ARG2 seja o diretório contendo as libs/módulos.      
                                     se não usar esta opção será usado o diretório default.


   Argumentos:
     remove <remove>             Remove um ou mais pacotes.
     install <pacote>            Instala um ou mais pacotes.

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

_get_storecli_online_version()
{
	# Verificar a ultima versão deste programa disponível no github.
	# https://raw.github.com/Brunopvh/storecli/master/storecli.sh
	local FILE_UPDATE=$(mktemp -u)
	local OnlineVersion=$__version__

	download "$URL_SCRIPT_STORECLI" "$FILE_UPDATE" 1> /dev/null 2>&1 || return 1
	OnlineVersion=$(grep -m 1 '^__version__=' "$FILE_UPDATE" | sed "s/.*=//g;s/'//g")
	rm -rf "$FILE_UPDATE" 1> /dev/null 2>&1
	echo -e "$OnlineVersion"
}

check_storecli_update()
{
	[[ "$IgnoreCli" == 'True' ]] && return 0
	
	local COLUMNS=$(tput cols)
	local FileConfigUpdate="$DIR_CONFIG_USER/update.conf"                   	
	local nowDate=$(date +%Y_%m_%d) # Data atual /ano/mês/dia. 
	touch "$FileConfigUpdate"
	
	# Data de execução da última busca por atualizações.
	local oldDateUpdate=$(grep -m 1 "date_update" "$FileConfigUpdate" | cut -d ' ' -f 2 2> /dev/null) 
	
	if [[ "$nowDate" == "$oldDateUpdate" ]]; then
		# Atualização já foi executada no dia atual.
		return 0
	else
		# Atualização ainda não foi executada no dia atual, gravar a data atual
		# no arquivo de configuração de atualizações e prosseguir.
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
	fi
	
	print_line
	[[ ! -z "$oldDateUpdate" ]] && printf "Data da última busca por atualizações ... $oldDateUpdate\n"
	
	__ping__ || return 1
	printf "Verificando atualização no github aguarde\n"	
	OnlineVersion=$(_get_storecli_online_version)
	echo -e "Versão local / Versão online ... $__version__ / $OnlineVersion"
	
	if [[ "$OnlineVersion" == "$__version__" ]]; then
		printf "Você está usando a ultima versão deste programa\n"
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
		return 0
	fi
	
	echo -e "Atualizando para versão ... $OnlineVersion"
	cd "$dir_of_executable"
	./setup.sh || { sred "FALHA na execução do script setup.sh"; return 1; }
	shm --upgrade --install platform print_text pkgmanager utils requests os files_programs crypto config_path
	
	echo -e "date_update $nowDate" > "$FileConfigUpdate"
	print_line
	return 0
}

_clear_temp_dirs()
{
	# Limpar diretórios temporários.
	cd "$DirTemp" && __rmdir__ $(ls)
	cd "$DirUnpack" && __rmdir__ $(ls)
	cd "$DirGitclone" && __rmdir__ $(ls)
}


#=============================================================#
# Listagem de todos os pacotes disponíveis para instalação.
#=============================================================#
programs_acessory=(
	coin-qt-gui
	electrum
	etcher
	gnome-disk
	microsoft-teams
	veracrypt
	woeusb
	)

programs_development=(
	android-studio
	brmodelo
	codeblocks
	intellij
	java
	netbeans
	nodejs
	pycharm
	sublime-text
	vim
	vscode
	python37-windows
	python37-windows-portable
	)

programs_office=(
	atril
	fontes-ms
	libreoffice
	libreoffice-appimage
	)

programs_browser=(
	chromium
	edge
	firefox
	google-chrome
	opera-stable
	torbrowser
	)

programs_internet=(
	clipgrab
	electron-player
	freetube
	megasync
	proxychains
	qbittorrent
	skype
	teamviewer
	telegram
	tixati
	uget
	youtube-dl
	youtube-dl-gui
	youtube-dl-qt
	)


programs_midia=(
	celluloid
	cinema
	codecs
	spotify
	gnome-mpv
	parole
	smplayer
	totem
	vlc
	)

programs_system=(
	archlinux-installer
	bluetooth
	compactadores
	cpu-x
	genymotion
	google-earth
	gparted
	peazip
	refind
	stacer
	shm
	timeshift
	virtualbox
	virtualbox-additions
	virtualbox-extensionpack
	)

programs_preferences=(
	ohmybash
	ohmyzsh
	papirus
	sierra
	)

programs_gnomeshell=(
	dash-to-dock
	drive-menu
	gnome-backgrounds
	gnome-tweaks
	topicons-plus
	)


programs_wine=(
	wine
	winetricks
	epsxe-win
	python37-windows
	python37-windows-portable
	youtube-dl-gui-windows
	)



_list_applications()
{
	# Função para listar os programas disponíveis para instalação no sistema
	# também lista programas de uma categoria especifica, bastando informar essa
	# categoria como argumento.
	# EXEMPLO:
	#   storecli -l Acessorios  -> Lista somente a categoria acessorios

	if [[ -z $1 ]]; then
		printf "%s\n" "  Acessorios: " # Acessorios
		for APP in "${programs_acessory[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Desenvolvimento: " # Desenvolvimento
		for APP in "${programs_development[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Escritorio: " # Escritório
		for APP in "${programs_office[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Navegadores: " # Navegadores
		for APP in "${programs_browser[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Internet: " # Internt
		for APP in "${programs_internet[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Midia: " # Midia
		for APP in "${programs_midia[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Sistema: " # Sistema
		for APP in "${programs_system[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Preferencias: " # Preferências
		for APP in "${programs_preferences[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Gnome Shell: " # Gnome Shell
		for APP in "${programs_gnomeshell[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Wine: " # Gnome Shell
		for APP in "${programs_wine[@]}"; do
			printf "%s\n" "      $APP"
		done
		printf "\n"

		return 0
	fi

	for arg in "${@}"; do
		case "$arg" in
			Acessorios)
					printf "%s\n" "  Acessorios: "
					for APP in "${programs_acessory[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Desenvolvimento)
					printf "%s\n" "  Desenvolvimento: "
					for APP in "${programs_development[@]}"; do
						printf "%s\n" "     $APP"
					done
					printf "\n"
					;;
			Escritorio)
					printf "%s\n" "  Escritorio: "
					for APP in "${programs_office[@]}"; do
						printf "%5s%s\n" " " "$APP"
					done
					printf "\n"
					;;
			Navegadores)
					printf "%s\n" "  Navegadores: "
					for APP in "${programs_browser[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Internet)
					printf "%s\n" "  Internet: "
					for APP in "${programs_internet[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Midia)
					printf "%s\n" "  Midia: "
					for APP in "${programs_midia[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Sistema)
					printf "%s\n" "  Sistema: "
					for APP in "${programs_system[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Preferencias)
					printf "%s\n" "  Preferencias: "
					for APP in "${programs_preferences[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			GnomeShell)
					printf "%s\n" "  Gnome Shell: "
					for APP in "${programs_gnomeshell[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Wine)
					printf "%s\n" "  Wine: "
					for APP in "${programs_wine[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			*)
				printf "\n"
				red "(_list_applications) categoria inválida: $arg"
				printf "\n"
					;;
		esac
		shift
	done	
}

storecli_apps_installer()
{
	# Instalação dos programas, esta função recebe como parâmetro os pacotes a serem instalados
	# aluguns desses pacotes são instalados diretamente pelo gerenciador de pacotes da sua distro
	# Enquanto outros são instalados, seguindo um processo de download, descompressão e configuração.
	if [[ -z $1 ]]; then
		usage
		return 1
	fi

	[[ $(id -u) == 0 ]] && return 1
	echo -e ".... $(date +%H:%M:%S) $__appname__ V$__version__ ...."
	_clear_temp_dirs

	# Se o sistema for LinuxMint tricia, deverá ser tratado como Ubuntu bionic.
	case "$VERSION_CODENAME" in
		tina|tricia) export VERSION_CODENAME='bionic';;
	esac

	while [[ $1 ]]; do
		[[ -z $1 ]] && return 0 
		case "$1" in 
			Acessorios) _Acessory_All;;
			coin-qt-gui) _coin_qt_gui;;
			electrum) _install_electrum;;
			etcher) _etcher;;
			gnome-disk) _gnome_disk;;
			microsoft-teams) _microsoft_teams;;
			plank) _plank;;
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

			Desenvolvimento) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			brmodelo) _br_modelo;;
			codeblocks) _codeblocks;;
			java) _java;;
			eclipse) _eclipse;;
			intellij) _intellij;;
			netbeans) _netbeans;;
			nodejs) _nodejs_lts;;
			pycharm) _pycharm;;
			sublime-text) _sublime_text;;
			vim) _vim;;
			vscode) _vscode;;

			Escritorio) _Office_All;;
			atril) _atril;;
			'fontes-ms') _fontes_microsoft;;
			libreoffice) _libreoffice;;
			libreoffice-appimage) _libreoffice_appimage;;

			Navegadores) _Browser_All;;
			chromium) _chromium;;
			edge) _edge;;
			firefox) _firefox;;
			'google-chrome') _google_chrome;;
			'opera-stable') _opera_stable;;
			torbrowser) _torbrowser;;

			Internet) _Internet_All;;      # Instalar todos da catgória Internet.
			clipgrab) _clipgrab_appimage;;
			electron-player) _electron_player;;
			freetube) _freetube;;
			megasync) _megasync;;
			proxychains) _proxychains;;
			qbittorrent) _qbittorrent;;
			skype) _skype;;
			teamviewer) _teamviewer;;
			telegram) _telegram;;
			tixati) _tixati;;
			uget) _uget;;
			youtube-dl) _youtube_dl;;
			youtube-dl-gui) _youtube_dlgui;;
			youtube-dl-qt) _youtube_dl_qt;;
		
			Midia) _Midia_All;;
			blender) _blender;;
			celluloid) _celluloid;;
			cinema) _cinema;;
			codecs) _codecs;;
			'gnome-mpv') _gnome_mpv;;
			smplayer) _smplayer;;
			spotify) _spotify;;
			parole) _parole;;
			totem) _totem;;
			vlc) _vlc;;

			Sistema) _System_All;;
			archlinux-installer) _archlinux_installer;;
			bluetooth) _bluetooth;;
			bspwm) _bspwm;;
			cpu-x) _cpux;;
			compactadores) _compactadores;;
			genymotion) _genymotion;;
			google-earth) _google_earth;;
			gparted) _gparted;;
			peazip) _peazip;;
			refind) _refind;;
			stacer) _stacer;;
			shm) _shm;;
			timeshift) _timeshift;;
			virtualbox) _virtualbox;;
			virtualbox-additions) _virtualbox_additions;;
			virtualbox-extensionpack) _virtualbox_extension_pack;; 

			ohmybash) _ohmybash;;			
			ohmyzsh) _ohmyzsh;;
			papirus) _papirus;;
			sierra) _sierra;;
		
			'dash-to-dock') _dashtodock;;
			'drive-menu') _drive_menu;;
			'gnome-backgrounds') _gnome_backgrounds;;
			'gnome-tweaks') _gnome_tweaks;;
			'topicons-plus') _topicons_plus;;
			
			Wine) _Wine_All;;
			wine) _install_wine;;
			winetricks) _install_script_winetricks;;
			epsxe-win) _epsxe_windows;;
			python37-windows-portable) _python37_windows32_portable;;
			python37-windows) _python37_windows32;;
			youtube-dl-gui-windows) _youtube_dlgui_windows;;
			install) ;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			-I|--ignore-cli) ;;
			*) red "(storecli_apps_installer) programa não encontrado: $1"; return 1; break;;
		esac
		shift
	done
	return "$?"
}

main()
{	
	for ARG in "$@"; do
		case "$ARG" in
			-y|--yes) export AssumeYes='True';;
			-d|--downloadonly) export DownloadOnly='True';;
			-I|--ignore-cli) export IgnoreCli='True';;
			-l|--list) shift; _list_applications "$@"; return 0; break;;
			-h|--help) usage; return 0; break;;
			-v|--version) echo -e "$(basename $__script__) V${__version__}"; return 0; break;;
			-u|--self-update) 
					"$SCRIPT_STORECLI_INSTALLER"
					shm --upgrade --install platform print_text pkgmanager utils requests os files_programs crypto config_path
					return 0
					break
						;;
		esac
	done

	# Se a string 'requeriments OK' não estiver no arquivo de configuração significa 
	# que a função de configuração do sistema ainda não foi executada no sistema atual, 
	# ou seja, se o GREP abaixo retornar status diferente de '0' a 
	# função de configuração será invocada.
	if [[ "$IgnoreCli" != 'True' ]]; then
		if ! grep -q 'requeriments OK' "$ConfigFile"; then
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

	check_storecli_update

	# Se nenhum argumento for passado na linha de comando, será aberto o GUI gráfico com o zenity.
	if [[ -z $1 ]]; then
		main_menu
		return "$?"
	elif [[ $1 == '--module' ]]; then
		return 0
	fi

	while [[ $1 ]]; do
		case "$1" in
			-b|--broke) _BROKE;;
			-c|--configure) _install_requeriments;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			-I|--ignore-cli) ;;
			install) shift; storecli_apps_installer "$@" || STATUS_OUTPUT=1; break;;
			remove)  shift; _uninstall_packages "$@" || STATUS_OUTPUT=1; break;;
			*) red "(main) argumento inválido: $ARG"; STATUS_OUTPUT='1'; break;;
		esac
		shift
	done
	return "$STATUS_OUTPUT"
}

main "${@}" && STATUS_OUTPUT=0

# Para usar este programa como módulo use a opção --module. source storecli.sh --module.
if [[ $1 == '--module' ]]; then 
	cd $WORK_DIR
else
	# Remover diretórios e subdiretórios temporários ao encerrar o programa.
	export AssumeYes='True'
	__rmdir__ "$TemporaryDirectory" 1> /dev/null
	if [[ "$STATUS_OUTPUT" == 0 ]]; then
		exit 0
	else
		exit 1
	fi
fi




