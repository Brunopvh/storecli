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
# LinuxMint 19.3, 
# ArchLinux - GNOME.
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
# https://github.com/Brunopvh/storecli
#



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
if ! uname -m | grep -q "64$"; then
	printf "\033[0;31m Seu sistema não é 64 bits saindo.\033[m\n"
	exit 1
fi

#=============================================================#
# Diretórios do usuário
#=============================================================#
source ~/.bashrc 1> /dev/null 2>&1
source ~/.shmrc 1> /dev/null 2>&1

[[ ! -d $HOME ]] && HOME=~/
[[ ! -w $HOME ]] && {
	printf "\033[0;31mVocê não tem permissão de escrita [-w] em ... $HOME\033[m\n"
	exit 1
}

__version__='2021_03_04'
__author__='Bruno Chaves'
__appname__='storecli'	

# Controle do status de saida ao longo do script.
export STATUS_OUTPUT='0'
export WORK_DIR=$(pwd)

export URL_RAW_REPO_MASTER='https://raw.github.com/Brunopvh/storecli/master'
export URL_RAW_REPO_DEVELOPMENT='https://raw.github.com/Brunopvh/storecli/development'
export GLOBAL_SCRIPT_ONLINE_VERSION="$URL_RAW_REPO_DEVELOPMENT/storecli.sh"


# Configuração de diretórios usados por este programa
readonly export __script__=$(readlink -f "$0") # Este arquivo.
readonly export dir_of_executable=$(dirname "$__script__") # Diretório raiz deste arquivo.
readonly export path_local_libs="$dir_of_executable/lib"
readonly export dir_local_scripts="$dir_of_executable/scripts"
readonly export dir_local_python="$dir_of_executable/python"

#=============================================================#
# Importação de módulos externos.
#=============================================================#
# Repositório no github.
# https://github.com/Brunopvh/bash-libs
#
# Instalação do gerenciador de pacotes para módulos externos.
# sudo bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)" 
# sudo bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)"

function show_import_erro()
{
	echo "ERRO módulo não encontrado ... $@"
	if [[ -x $(command -v wget) ]]; then
		echo "Execute ... bash -c \"\$(wget -q -O- https://raw.github.com/Brunopvh/storecli/master/setup.sh)\""
	elif [[ -x $(command -v curl) ]]; then
		echo "Execute ... bash -c \"\$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)\""
	elif [[ -x $(command -v aria2c) ]]; then
		echo -e "Execute ... aria2c https://raw.github.com/Brunopvh/storecli/master/setup.sh -o setup.sh; bash setup.sh; rm setup.sh"
	fi
	sleep 1
	return 1
}

function check_external_modules()
{
	# Verificar se todos os módulos externos necessários estão disponíveis para serem importados.
	[[ ! -f $config_path ]] && { 
		show_import_erro "config_path"; return 1
	}

	[[ ! -f $crypto ]] && {
		show_import_erro "crypto"; return 1
	}

	[[ ! -f $files_programs ]] && { 
		show_import_erro "files_programs"; return 1
	}

	[[ ! -f $os ]] && { 
		show_import_erro "os"; return 1 
	}

	[[ ! -f $requests ]] && { 
		show_import_erro "requests"; return 1
	}

	[[ ! -f $utils ]] && { 
		show_import_erro "utils"; return 1 
	}
	
	[[ ! -f $pkgmanager ]] && { 
		show_import_erro "pkgmanager"; return 1 
	}
	
	[[ ! -f $print_text ]]&& {
		show_import_erro "print_text"; return 1
	}
	
	[[ ! -f $platform ]] && {
		show_import_erro "platform"; return 1
	}

	return 0
}

check_external_modules || {
	# Verificar se os módulos externos estão instalados no sistema.
	cd "$dir_of_executable"
	if [[ ! -f setup.sh ]]; then
		chmod +x ./setup.sh
		./setup.sh
	elif [[ -x $(command -v wget) ]]; then
		bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	elif [[ -x $(command -v curl) ]]; then
		bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	elif [[ -x $(command -v aria2c) ]]; then
		_tmpfile=$(mktemp -u)
		aria2c 'https://raw.github.com/Brunopvh/storecli/master/setup.sh' -d $(diraname "$_tmpfile") -o $(basename "$_tmpfile") 1> /dev/null
		bash "$_tmpfile"
		rm -rf "$_tmpfile" 2> /dev/null
		unset _tmpfile
	else
		echo "Instale curl ou wget"
		exit 1
	fi

	source ~/.bashrc 1> /dev/null 2>&1
	shm update
	shm --upgrade --install platform print_text pkgmanager utils requests os files_programs crypto config_path
	exit 1
}

#=============================================================#
# Criar diretórios para arquivos temporários para descompressão dos
# arquivos baixados, e clone(s) de repositórios do github. 
#=============================================================#
#readonly export TemporaryDirectory="/tmp/storecli_$USER"
export readonly TemporaryDirectory="$(mktemp -u)-$__appname__" 
export readonly DirTemp="$TemporaryDirectory/temp"
export readonly DirGitclone="$TemporaryDirectory/gitclone"
export readonly DirUnpack="$TemporaryDirectory/unpack"
export readonly DIR_CONFIG_USER=~/.config/"$__appname__"

if [[ $(id -u) == 0 ]]; then
	export readonly DirDownloads="/var/cache/$__appname__/downloads"
else
	export readonly DirDownloads="$HOME/.cache/$__appname__/downloads"
fi

mkdir -p "$TemporaryDirectory"
mkdir -p "$DirTemp"
mkdir -p "$DirGitclone"
mkdir -p "$DirUnpack"
mkdir -p "$DirDownloads"
mkdir -p "$DIR_CONFIG_USER"

#=============================================================#
# Arquivos de configuração e Log.
#=============================================================#
export ConfigFile="$DIR_CONFIG_USER/requeriments.conf"
export LogFile="$HOME/.cache/$__appname__/storecli.log"
export LogErro="$HOME/.cache/$__appname__/storecli.err"
export OutputDevice="$HOME/.cache/$__appname__/storecli-output.log"

echo '' > "$OutputDevice"
touch "$ConfigFile"
touch "$LogFile"
touch "$LogErro"


#=============================================================#
# Importar modulos externos - VER o arquivo ~/.shmrc
#=============================================================#
source $config_path
source $print_text
source $os
source $pkgmanager
source $files_programs
source $requests
source $utils
source $crypto

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

_get_storecli_online_version()
{
	# Verificar a ultima versão deste programa disponível no github.
	# https://raw.github.com/Brunopvh/storecli/master/storecli.sh
	local FILE_UPDATE=$(mktemp -u)
	local OnlineVersion=$__version__

	download "$GLOBAL_SCRIPT_ONLINE_VERSION" "$FILE_UPDATE" 1> /dev/null || return 1
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
	if ! ./setup.sh; then
	    sred "FALHA na execução do script setup.sh"
	    return 1
	fi
	
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
	etcher
	gnome-disk
	microsoft-teams
	storecli-gui
	veracrypt
	woeusb
	)

programs_development=(
	android-studio
	codeblocks
	idea
	java
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
		_list_applications
		return 1
	fi

	echo -e ".... $(date +%H:%M:%S) $__app_name__ V$__version__ ...."
	_clear_temp_dirs

	# Se o sistema for LinuxMint tricia, deverá ser tratado como Ubuntu bionic.
	case "$VERSION_CODENAME" in
		tina|tricia) export VERSION_CODENAME='bionic';;
	esac

	while [[ $1 ]]; do
		[[ -z $1 ]] && return 0 
		case "$1" in 
			Acessorios) _Acessory_All;;
			etcher) _etcher;;
			gnome-disk) _gnome_disk;;
			microsoft-teams) _microsoft_teams;;
			plank) _plank;;
			storecli-gui) _install_storecli;;
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

			Desenvolvimento) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			codeblocks) _codeblocks;;
			java) _java;;
			idea) _idea_ic;;
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

if [[ $1 == '--module' ]]; then # Para usar este programa como módulo use a opção --module. source storecli.sh --module.
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




