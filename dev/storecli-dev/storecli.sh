#!/usr/bin/env bash
#
#
__version__='2020_12_03'
__author__='Bruno Chaves'
__app_name__='storecli'
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
if [[ ! -x $(which sudo 2> /dev/null) ]]; then
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
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

[[ ! -d $HOME ]] && HOME=~/

DIR_BIN_USER="$HOME/.local/bin"
DIR_ICON_USER="$HOME/.local/share/icons"
DIR_THEMES_USER="$HOME/.themes"
DIR_DESKTOP_USER="$HOME/.local/share/applications"
DIR_CONFIG_USER="$HOME/.config/$__app_name__"

mkdir -p "$DIR_BIN_USER"
mkdir -p "$DIR_ICON_USER"
mkdir -p "$DIR_THEMES_USER"
mkdir -p "$DIR_DESKTOP_USER"
mkdir -p "$DIR_CONFIG_USER"

#=============================================================#
# Criar diretórios para arquivos temporários para descompressão dos
# arquivos baixados, e clone(s) de repositórios do github. 
#=============================================================#
#export TemporaryDirectory="/tmp/storecli_$USER"
export TemporaryDirectory=$(mktemp --directory)
export DirTemp="$TemporaryDirectory/temp"
export DirGitclone="$TemporaryDirectory/gitclone"
export DirUnpack="$TemporaryDirectory/unpack"
export DirDownloads="$HOME/.cache/$__app_name__/downloads"
export HtmlTemporaryFile="$DirTemp"/Temp.html

mkdir -p "$TemporaryDirectory"
mkdir -p "$DirTemp"
mkdir -p "$DirGitclone"
mkdir -p "$DirUnpack"
mkdir -p "$DirDownloads"

#=============================================================#
# Arquivos de configuração e Log.
#=============================================================#
# O arquivo de configuração e gravado apenas quando a instalação
# dos requirimentos são instaladas no sistema. Quando o programa 
# inicia ele irá procurar por este arquivo é também irá verificar
# se o conteudo do arquivo tem uma linha com as seguintes informações: requeriments OK 
export configFILE="$DIR_CONFIG_USER/requeriments.conf"
export LogFile="$HOME/.cache/storecli/storecli.log"
export LogErro="$HOME/.cache/storecli/storecli.err"
export OutputDevice="$HOME/.cache/storecli/storecli-output.log"

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

is_executable()
{
	# Função para verificar se um executável existe no PATH do sistema.
	if [[ -x $(which "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}

#=============================================================#
# Configuração de diretórios usados por este programa para ler
# libs e executar scripts.
#=============================================================#
export __script__=$(readlink -f "$0") # Este arquivo.
export dir_of_executable=$(dirname "$__script__") # Diretório raiz deste arquivo.
export path_libs="$dir_of_executable/lib"
export dir_local_scripts="$dir_of_executable/scripts"
export dir_local_python="$dir_of_executable/python"

#=============================================================#
# Importar Libs
#=============================================================#
source "$path_libs/print_text.sh"
source "$path_libs/ArrayUtils.sh"
source "$path_libs/lib_storecli.sh"
source "$path_libs/requeriments.sh"
source "$path_libs/pkg_manager.sh"
source "$path_libs/UninstallPkgs.sh"
source "$path_libs/programs.sh"
source "$path_libs/wineutils.sh"
source "$path_libs/gui.sh"

# Definir os scripts locais.
SCRIPT_CONFIG_PATH="$dir_local_scripts/conf-path.sh"
SCRIPT_ADD_REPO="$dir_local_scripts/addrepo.py"
SCRIPT_TORBROWSER_INSTALLER="$dir_local_scripts/tor.sh"
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

_ping()
{
	printf "Aguardando conexão ... "

	if ping -c 1 8.8.8.8 1> /dev/null 2>&1; then
		printf "Conectado\n"
		return 0
	else
		printf "\033[0;31mFALHA\033[m\n"
		printf "\033[0;31mAVISO: você está OFF-LINE\033[m\n"
		sleep 1
		return 1
	fi
}

_get_storecli_online_version()
{
	local URL_STORECLI_MASTER='https://raw.github.com/Brunopvh/storecli/master/storecli.sh'
	local TEMP_DIR_UPDATE="$(mktemp --directory)-storecli-update"
	local FILE_UPDATE='storecli.update'

	__download__ "$URL_STORECLI_MASTER" "$TEMP_DIR_UPDATE/$FILE_UPDATE" 1> /dev/null || return 1

	local OnlineVersion=$(grep -m 1 '^__version__=' "$TEMP_DIR_UPDATE/$FILE_UPDATE" | sed "s/.*=//g;s/'//g")
	echo -e "$OnlineVersion"
	rm -rf "$TEMP_DIR_UPDATE/$FILE_UPDATE" 1> /dev/null 2>&1
}

_update_storecli()
{
	[[ "$IgnoreCli" == 'True' ]] && return 0
	# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	# sh -c "$(wget -q -O- https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	
	local COLUMNS=$(tput cols)
	local FileConfigUpdate="$DIR_CONFIG_USER/update.conf"
	touch "$FileConfigUpdate"
	local tempFileUpdate="$DirTemp/storecli.update"                    	
	local nowDate=$(date +%Y_%m_%d) # Data atual /ano/mês/dia. 
	
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
	
	_ping || return 1
	printf "Verificando atualização no github aguarde\n"	
	OnlineVersion=$(_get_storecli_online_version)
	printf "%-17s%-10s\n" "Versão local" "$__version__" 
	printf "%-17s%-10s\n" "Versão online" "$OnlineVersion"
	
	if [[ "$OnlineVersion" == "$__version__" ]]; then
		printf "Você está usando a ultima versão deste programa\n"
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
		return 0
	fi
	
	printf "%-25s%-10s\n" "Atualizando para versão" "$OnlineVersion"
	
	cd "$dir_of_executable"
	if ! sh setup.sh; then
	    _sred "FALHA na execução do script setup.sh"
	    return 1
	fi
	
	[[ -f "$tempFileUpdate" ]] && rm "$tempFileUpdate"
	echo -e "date_update $nowDate" > "$FileConfigUpdate"
	print_line
	return 0
}


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
				_red "(_list_applications) categoria inválida: $arg"
				printf "\n"
					;;
		esac
		shift
	done	
}


_pkg_manager_storecli()
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
	case "$os_codename" in
		tina|tricia) export os_codename='bionic';;
	esac

	while [[ $1 ]]; do
		[[ -z $1 ]] && return 0 
		case "$1" in 
			Acessorios) _Acessory_All;;
			etcher) _etcher;;
			gnome-disk) _gnome_disk;;
			plank) _plank;;
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

			Desenvolvimento) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			codeblocks) _codeblocks;;
			java) _java;;
			idea) _idea_ic;;
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
			bluetooth) _bluetooth;;
			bspwm) _bspwm;;
			cpu-x) _cpux;;
			compactadores) _compactadores;;
			google-earth) _google_earth;;
			gparted) _gparted;;
			peazip) _peazip;;
			refind) _refind;;
			stacer) _stacer;;
			virtualbox) _virtualbox;;

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
			*) _red "(_pkg_manager_storecli) programa não encontrado: $1"; return 1; break;;
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


# Executar a função main passando todos os argumentos recebidos na linha de comando.
main "${@}" && STATUS_OUTPUT=0

# Remover diretórios e subdiretórios temporários ao encerrar o programa.
__rmdir__ "$TemporaryDirectory" 1> /dev/null

if [[ "$STATUS_OUTPUT" == 0 ]]; then
	exit 0
else
	exit 1
fi




