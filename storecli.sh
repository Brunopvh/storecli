#!/usr/bin/env bash
#
#
__version__='2020_10_08'
__author__='Bruno Chaves'
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
# Verificar requesitos minimos do sistema.
#=============================================================#

# Controlo do status de saida ao longo do script
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
# Imprimir textos com formatação e cores.
#=============================================================#
_red()
{
	# Não imprimir nada se a opção -s|--silent estiver na linha de comando.
	[[ "$silent" == 'True' ]] && return 0
	echo -e "[${CRed}!${CReset}] $@"
}

_green()
{
	# Não imprimir nada se a opção -s|--silent estiver na linha de comando.
	[[ "$silent" == 'True' ]] && return 0
	echo -e "[${CGreen}+${CReset}] $@"
}

_yellow()
{
	[[ "$silent" == 'True' ]] && return 0
	echo -e "[${CYellow}+${CReset}] $@"
}


_blue()
{
	[[ "$silent" == 'True' ]] && return 0
	echo -e "[${CBlue}+${CReset}] $@"
}

_white()
{
	[[ "$silent" == 'True' ]] && return 0
	echo -e "[${CWhite}+${CReset}] $@"
}

_sred()
{
	[[ "$silent" == 'True' ]] && return 0
	echo -e "${CSRed}$@${CReset}"
}

_sgreen()
{
	[[ "$silent" == 'True' ]] && return 0
	echo -e "${CSGreen}$@${CReset}"
}

_syellow()
{
	[[ "$silent" == 'True' ]] && return 0
	echo -e "${CSYellow}$@${CReset}"
}

_sblue()
{
	[[ "$silent" == 'True' ]] && return 0
	echo -e "${CSBlue}$@${CReset}"
}

_println()
{
	# Imprimir mensagens com printf sem quebrar linhas.
	[[ "$silent" == 'True' ]] && return 0
	printf "[>] $@"
}

_print()
{
	# Imprimir texto com formatação e quebra de linha.
	[[ "$silent" == 'True' ]] && return 0
	printf '%s\n' "[>] $@"
}

if is_executable tput; then
	columns=$(tput cols)
else
	columns='45'
fi

print_line(){
	# Função para imprimir um caractere que preencha todo espaço horizontal do terminal.

	local L='-' # Caractere que será impresso ocupando todas as colunas do terminal.
	num='1'
	while [[ "$num" != "$columns" ]]; do
		L="${L}-"
		num="$(($num+1))"
	done
	[[ "$silent" == 'True' ]] && return 0
	printf '%s\n' "$L"
}

_msg()
{
	[[ "$silent" == 'True' ]] && return 0
	print_line
	echo -e " $@"
	print_line
}


# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]]; then
	_red "Execute este programa apenas em sistemas Linux."
	exit 1
fi

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	_red "Usuário não pode ser o [root] execute novamente sem o [sudo]"
	exit 1
fi

# Necessário ter o "sudo" intalado.
if [[ ! -x $(which sudo 2> /dev/null) ]]; then
	_red "Instale o pacote [sudo] e adicione [$USER] no arquivo [sudoers] para prosseguir"
	exit 1
fi

# Verificar se a arquitetura do Sistema e 64 bits
if ! uname -m | grep '64' 1> /dev/null; then
	_red "Seu sistema não e 64 bits. Saindo"
	exit 1
fi

#=============================================================#
# Configuração de diretórios para libs, scripts e programas
#=============================================================#
export app_name='storecli'
export __script__=$(readlink -f "$0") # Este arquivo.
export dir_of_executable=$(dirname "$__script__")
export path_libs="$dir_of_executable/lib"
export dir_local_scripts="$dir_of_executable/scripts"
export dir_local_python="$dir_of_executable/python"

# Definir os scripts locais.
scriptConfigPath="$dir_local_scripts/conf-path.sh"
scriptAddRepo="$dir_local_scripts/addrepo.py"
scritpTorBrowser="$dir_local_scripts/tor-installer.sh"
scriptInstallStoreli="$dir_of_executable/setup.sh"
scriptOhmybashInstaller="$dir_local_scripts/ohmybash.run"
scriptWinetricks="$dir_local_scripts/winetricks_script.sh"
GUI="$dir_local_scripts/gui.sh"

#=============================================================#
# Diretórios do usuário
#=============================================================#
DIR_BIN_USER="$HOME/.local/bin"
DIR_ICON_USER="$HOME/.local/share/icons"
DIR_THEMES_USER="$HOME/.themes"
DIR_DESKTOP_USER="$HOME/.local/share/applications"
DIR_CONFIG_USER="$HOME/.config/$app_name"

mkdir -p "$DIR_BIN_USER"
mkdir -p "$DIR_ICON_USER"
mkdir -p "$DIR_THEMES_USER"
mkdir -p "$DIR_DESKTOP_USER"
mkdir -p "$DIR_CONFIG_USER"

#=============================================================#
# Diretórios do root
#=============================================================#
DIR_BIN_ROOT='/usr/local/bin'
DIR_ICON_ROOT='/usr/share/icons/hicolor'
DIR_THEME_ROOT='/usr/share/themes/'
DIR_DESKTOP_ROOT='/usr/share/applications'

if [[ ! -d "$DIR_BIN_ROOT" ]]; then
	_print "Criando o diretório: $DIR_BIN_ROOT"
	sudo mkdir "$DIR_BIN_ROOT"
fi


if [[ ! -d "$DIR_ICON_ROOT" ]]; then
	_print "Criando o diretório: $DIR_ICON_ROOT"
	sudo mkdir "$DIR_ICON_ROOT"
fi


if [[ ! -d "$DIR_THEME_ROOT" ]]; then
	_print "Criando o diretório: $DIR_THEME_ROOT"
	sudo mkdir "$DIR_THEME_ROOT"
fi


if [[ ! -d "$DIR_DESKTOP_ROOT" ]]; then
	_print "Criando o diretório: $DIR_DESKTOP_ROOT"
	sudo mkdir "$DIR_DESKTOP_ROOT"
fi

#=============================================================#
# Importar Libs
#=============================================================#
source "$path_libs/colors.sh"
source "$path_libs/requeriments.sh"
source "$path_libs/platform.sh"
source "$path_libs/pkg_manager.sh"
source "$path_libs/UninstallPkgs.sh"
source "$path_libs/ArrayUtils.sh"
source "$path_libs/programs.sh"
source "$path_libs/wineutils.sh"

# Criar diretórios para arquivos temporários para descompressão dos
# arquivos baixados, e clone(s) de repositórios do github. 
export TemporaryDirectory=$(mktemp --directory)
#export TemporaryDirectory="/tmp/${USER}_storecli"
export DirTemp="$TemporaryDirectory/temp"
export DirGitclone="$TemporaryDirectory/gitclone"
export DirUnpack="$TemporaryDirectory/unpack"
export DirDownloads="$HOME/.cache/$app_name/downloads"

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
export LogFile="$HOME/.cache/storecliLOG.log"
export LogErro="$HOME/.cache/storecliERROLog.log"

touch "$configFILE"
touch "$LogFile"
touch "$LogErro"

# Sempre verificar a configuração do PATH do usuário ao iniciar.
"$scriptConfigPath"

_YESNO()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do programa, em que a resposta deve ser do tipo SIM ou NÃO (s/n)
	# esta função é para automatizar esta indagação.
	#
	#   se teclar "s" -----------------> retornar 0  
	#   se teclar "n" ou nada ---------> retornar 1.
	#
	# $1 = Mensagem a ser exibida para o usuário reponder SIM ou NÃO (s/n).
	
	_println "$@ [${CYellow}s${CReset}/${CRed}n${CReset}]?: "
	read -t 15 -n 1 sn
	echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		_green "${CYellow}A${CReset}bortando"
		return 1
	fi
}

_show_info()
{
	# Função para exibir mensagens padrão, como erro generico durante a instalação de um 
	# programa ou um mensagem generica de sucesso.
	[[ "$silent" == 'True' ]] && return 0
	case "$1" in
		AddFileDestktop) _green "Criando arquivo (.desktop)";;
		DownloadOnly) _green "Feito somente download";;
		PkgInstalled) _green "($2) está instalado";;
		SuccessInstalation) _green "($2) instalado com sucesso";;
		InstalationFailed) _red "Falha ao tentar instalar ($2)";;
		ProgramNotFound) _red "Programa indisponível para o seu sistema: $2";;
	esac
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
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Escritorio)
					printf "%s\n" "  Escritorio: "
					for APP in "${programs_office[@]}"; do
						printf "%s\n" "      $APP"
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
			*)
				printf "\n"
				_red "(_list_applications) categoria inválida: $arg"
				printf "\n"
					;;
		esac
		shift
	done	
}

usage()
{
cat << EOF
    Use: $__script__ -b|-c|-d|-I|-h|-l|-s|-v
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
	_println "Aguardando conexão: "

	if [[ $(ping -c 1 8.8.8.8) ]]; then
		_print "Conectado"
		return 0
	else
		_sred 'FALHA'
		_red "AVISO: você está OFF-LINE"
		sleep 2
		return 1
	fi
}

__sudo__()
{
	# Função para executar comandos com o "sudo" e retornar '0' ou '1'.
	printf "[>] Autênticação necessária para executar: sudo ${@}\n"
	if sudo "$@"; then
		return 0
	else
		_red "Falha: sudo $@"
		return 1
	fi
}

__rmdir__()
{
	# Função para remover diretórios e arquivos, inclusive os arquivos é diretórios
	# que o usuário não tem permissão de escrita, para isso será usado o "sudo".
	#
	# Use:
	#     __rmdir__ <diretório> ou
	#     __rmdir__ <arquivo>
	[[ -z $1 ]] && return 1

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# o comando de remoção será com 'sudo'.
	dir_content_file=$(dirname "$1")
	cd "$dir_content_file"
	_print "Entrando no diretório ... $(pwd)"
	
	while [[ $1 ]]; do
		if ls "$1" 1> /dev/null 2>&1; then
			_yellow "Removendo ... $1"; sleep 0.04
			rm -rf "$1" 2> /dev/null || sudo rm -rf "$1"
		else
			_red "Não encontrado ... $1"
		fi
		shift
	done
}

_clear_temp_dirs()
{
	# Limpar diretórios temporários.
	cd "$DirTemp" && __rmdir__ $(ls)
	cd "$DirUnpack" && __rmdir__ $(ls)
	cd "$DirGitclone" && __rmdir__ $(ls)
}

__pkg__()
{
	# Função para instalar os pacotes via linha de comando de acordo 
	# o gerenciador de pacotes de cada sistema.

	#=============================================================#
	# Somente baixar os pacotes caso receber '-d' ou '--downloadonly'
	# na linha de comando.
	#=============================================================#
	_msg "Instalando ... $@"

	if [[ "$DownloadOnly" == 'True' ]] && [[ "$AssumeYes" == 'True' ]]; then 
		# Somente baixar os pacotes e assumir yes para indagações.
		if [[ $(uname -s) == 'FreeBSD' ]]; then 
			_PKG install -y "$@" || return 1
		elif [[ -f /etc/debian_version ]] && [[ -x $(which apt 2> /dev/null) ]]; then
			_APT install --download-only --yes "$@" || return 1
		elif [[ -f /etc/fedora-release ]] && [[ -x $(which dnf 2> /dev/null) ]]; then
			_DNF install --downloadonly -y "$@" || return 1
		elif [[ "$os_id" == 'opensuse-leap' ]] || [[ "$os_id" == 'opensuse-tumbleweed' ]]; then
			_ZYPPER download "$@" || return 1
		elif [[ "$os_id" == 'arch' ]]; then
			_PACMAN -S --noconfirm --needed --downloadonly "$@" || return 1
		else
			_red "(__pkg__) Erro: $@"
			return 1
		fi
		return "$?"
	
	elif [[ "$DownloadOnly" == 'True' ]]; then
		# Somente baixar os pacotes.
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install "$@"; return; fi
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install --download-only "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER download "$@" || return 1;;
			fedora) _DNF install --downloadonly "$@" || return 1;;
			arch) _PACMAN -S --needed --downloadonly "$@" || return 1;;
		esac
	elif [[ "$AssumeYes" == 'True' ]]; then 
		# Assumir yes para indagações durante a instalação, equivalênte ao comando
		# apt install -y / aptitude install -y em sistemas debian.
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install -y "$@"; return; fi
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install --yes "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install -y "$@" || return 1;;
			fedora) _DNF install -y "$@" || return 1;;
			arch) _PACMAN -S --noconfirm --needed "$@" || return 1;;
		esac
	else
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install "$@"; return; fi
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install "$@" || return 1;;
			fedora) _DNF install "$@" || return 1;;
			arch) _PACMAN -S --needed "$@" || return 1;;
		esac
	fi
}

__gpg__()
{
	printf "%s" "[>] Verificando integridade "
	if gpg "$@" 1> /dev/null 2> /dev/null; then  
		_syellow "OK"
	else
		_sred "FALHA"
		for X in "${@}"; do
			[[ -f "$X" ]] && __rmdir__ "$X"
		done
		return 1
	fi
	return 0
}

__shasum__()
{
	# Esta função compara a hash de um arquivo local no disco com
	# uma hash informada no parametro "$2" (hash original). 
	#   Ou seja "$1" é o arquivo local e "$2" é uma hash

	if [[ ! -f "$1" ]]; then
		_red "(__shasum__) arquivo inválido: $1"
		return 1
	fi

	if [[ -z "$2" ]]; then
		_red "(__shasum__) use: __shasum__ <arquivo> <hash>"
		return 1
	fi

	_white "Gerando hash do arquivo: $1"
	local hash_file=$(sha256sum "$1" | cut -d ' ' -f 1)
	
	echo -ne "[>] Comparando valores "
	if [[ "$hash_file" == "$2" ]]; then
		echo -e "${CYellow}OK${CReset}"
		return 0
	else
		_sred 'FALHA'
		rm -rf "$1"
		_red "(__shasum__) o arquivo inseguro foi removido: $1"
		return 1
	fi
}

__curl__()
{
	# Função para baixar arquivos usando a ferramenta 'curl'.
	url="$1"
	path_file="$2"
	if [[ -z $2 ]]; then
		curl -C - -S -L -O "$url" || {
			_red "Falha: curl -S -L -O"
			return 1
		}
		return 0
	elif [[ $2 ]]; then
		_blue "Destino: $path_file"
		curl -C - -S -L -o "$path_file" "$url" || {
			_red "Falha: curl -S -L -o"
			rm "$path_file" 2> /dev/null
			return 1
		}
		return "$?"
	fi

}

__download__()
{
	if [[ -f "$2" ]]; then
		_blue "Arquivo encontrado: $2"
		return 0
	fi

	url="$1"
	path_file="$2"
	
	_yellow "Entrando no diretório ... $DirDownloads"
	cd "$DirDownloads"
	_blue "Conectando ... $1"

	while true; do
		if is_executable wget; then
			wget -c "$url" -O "$path_file" && break
		elif is_executable curl; then
			curl -C - -S -L -o "$path_file" "$url" && break
		else
			return 1
			break
		fi

		_red "Falha no download"
		if _YESNO "Deseja tentar baixar novamente"; then
			continue
		else
			return 1
			break
		fi
	done
	[[ "$?" != '0' ]] && return 1
	return 0
}

_gitclone()
{
	if [[ -z $1 ]]; then
		_red "(_gitclone) use: _gitclone <repo.git>"
		return 1
	fi

	if ! is_executable git; then
		_yellow "Necessário instalar o pacote 'git"
		__pkg__ git || return 1
	fi

	_green "Entrando no diretório ...$DirGitclone" 
	cd "$DirGitclone"
	dir_repo=$(basename "$1" | sed 's/.git//g')
	if [[ -d "$DirGitclone/$dir_repo" ]]; then
		_yellow "Encontrado: $DirGitclone/$dir_repo"
		if _YESNO "Deseja remover o diretório clonado anteriormente"; then
			__rmdir__ "$dir_repo"
		else
			return 0
		fi
	fi

	_blue "Clonando ... $1"
	if ! git clone "$1"; then
		_red "(_gitclone): falha"
		return 1
	fi
	return 0
}

_unpack()
{
	# Obrigatório informar um arquivo no argumento $1.
	if [[ ! -f "$1" ]]; then
		_red "(_unpack) nenhum arquivo informado como argumento"
		return 1
	fi

	# Destino para descompressão.
	if [[ -d "$2" ]]; then 
		DirUnpack="$2"
	elif [[ -z "$DirUnpack" ]]; then
		_red "(_unpack): o diretório de descompressão e 'nulo'."
		return 1
	fi

	if [[ ! -d "$DirUnpack" ]]; then
		_yellow "(_unpack): criando o diretório ... $DirUnpack"
		mkdir -p "$DirUnpack"
	fi
	
	_yellow "Entrando no diretório ... $DirUnpack"
	cd "$DirUnpack"
	__rmdir__ $(ls)
	path_file="$1"

	# Detectar a extensão do arquivo.
	if [[ "${path_file: -6}" == 'tar.gz' ]]; then    # tar.gz - 6 ultimos caracteres.
		type_file='tar.gz'
	elif [[ "${path_file: -7}" == 'tar.bz2' ]]; then # tar.bz2 - 7 ultimos carcteres.
		type_file='tar.bz2'
	elif [[ "${path_file: -6}" == 'tar.xz' ]]; then  # tar.xz
		type_file='tar.xz'
	elif [[ "${path_file: -4}" == '.zip' ]]; then    # .zip
		type_file='zip'
	elif [[ "${path_file: -4}" == '.deb' ]]; then    # .deb
		type_file='deb'
	else
		_red "(_unpack) arquivo não suportado: $path_file"
		__rmdir__ "$path_file"
		return 1
	fi

	_println "Descomprimindo: $path_file "
	
	# Descomprimir.	
	case "$type_file" in
		'tar.gz') tar -zxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		'tar.bz2') tar -jxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		'tar.xz') tar -Jxf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		zip) unzip "$path_file" -d "$DirUnpack" 1> /dev/null 2>&1;;
		deb) ar -x "$path_file" --output="$DirUnpack" 1> /dev/null 2>&1;;
		*) return 1;;
	esac

	if [[ "$?" == '0' ]]; then
		_syellow "OK"
		return 0
	else
		_sred "FALHA"
		_red "(_unpack) erro: $path_file"
		__rmdir__ "$path_file"
		return 1
	fi
}


_pkg_manager_storecli()
{
	# Instalação dos programas, esta função recebe como parâmetro os pacotes a serem instalados
	# aluguns desses pacotes são instalados diretamente pelo gerenciador de pacotes da sua distro.
	# Enquanto outros são instalados seguindo um processo de download, descompressão e configuração.
	if [[ -z $1 ]]; then
		usage
		return 1
	fi

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
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

			Desenvolvimento) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			codeblocks) _codeblocks;;
			java) _java;;
			pycharm) _pycharm;;
			sublime-text) _sublime_text;;
			vim) _vim;;
			vscode) _vscode;;
			python37-windows-portable) _python37_windows32_portable;;
			python37-windows) _python37_windows32;;

			Escritorio) _Office_All;;
			atril) _atril;;
			'fontes-ms') _fontes_microsoft;;
			libreoffice) _libreoffice;;
			libreoffice-appimage) _libreoffice_appimage;;

			Navegadores) _Browser_All;;
			chromium) _chromium;;
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
			compactadores) _compactadores;;
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
			
			wine) _install_wine;;
			winetricks) _install_script_winetricks;;
			epsxe-win) _epsxe_windows;;
			youtube-dl-gui-windows) _youtube_dlgui_windows;;
			install) ;;
			*) _red "(_pkg_manager_storecli) programa não encontrado: $1"; return 1; break;;
		esac
		shift
	done
	return "$?"
}

_update_storecli()
{
	# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	local FileConfigUpdate="$DIR_CONFIG_USER/update.conf"; touch "$FileConfigUpdate"
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
	
	[[ ! -z "$oldDateUpdate" ]] && printf '%s\n' "[+] Data da última busca por atualizações: $oldDateUpdate"
	
	_println "Verificando atualização no github aguarde "
	wget -q https://raw.github.com/Brunopvh/storecli/master/storecli.sh -O "$tempFileUpdate" || { 
		_sred "FALHA"
		return 1
	}
	_syellow 'OK'	
	OnlineVersion=$(grep -m 1 ^'__version__' "$tempFileUpdate" | sed "s/.*=//g;s/'//g")
	
	_yellow "Versão local ($__version__)" 
	_yellow "Versão online ($OnlineVersion)"
	if [[ "$OnlineVersion" == "$__version__" ]]; then
		_yellow "Scritp storecli está atualizado"
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
		return 0
	fi
	
	_yellow "Atualizando para versão ... $OnlineVersion"
	
	if ! "$scriptInstallStoreli"; then
		_red "(_update_storecli) falha"
		return 1
	fi

	[[ -f "$tempFileUpdate" ]] && rm "$tempFileUpdate"
	echo -e "date_update $nowDate" > "$FileConfigUpdate"
	return 0
}

main()
{	
	for ARG in "$@"; do
		case "$ARG" in
			-y|--yes) export AssumeYes='True';;
			-d|--downloadonly) export DownloadOnly='True';;
			-I|--ignore-cli) export IgnoreCli='True';;
			-s|--silent) export silent='True';;
			-h|--help) usage; return 0; break;;
			-v|--version) echo -e "$(basename $__script__) V${__version__}"; return 0; break;;
		esac
	done

	# Verificar se todos os utilitários de linha de comando estão instalados 
	# esta operação será IGNORADA caso a opção '--ignore-cli' ou '-I' estiver 
	# na linha de comando.
	# Exemplos:  
	#   storecli --ignore-cli install <pacote>
	#   storecli -I install <pacote>
	
	if [[ "$IgnoreCli" != 'True' ]]; then
		check_requeriments_sys 
	fi

	# Se a string 'requeriments OK' não estiver no arquivo de configuração
	# significa que a função de configuração (_run_configuration_dep) ainda não foi
	# executada no sistema atual, ou seja, se o GREP abaixo retornar status
	# diferente de '0' a função _run_configuration_dep será invocada.
	if [[ "$IgnoreCli" != 'True' ]]; then
		grep -q 'requeriments OK' "$configFILE" || {
			_run_configuration_dep || return 1
		}
	fi

	_update_storecli

	while [[ $1 ]]; do
		case "$1" in
			-b|--broke) _BROKE;;
			-c|--configure) _run_configuration_dep;;
			-l) shift; _list_applications "$@"; return 0; break;;
			-u|--self-update) "$scriptInstallStoreli"; break;;
			install) shift; _pkg_manager_storecli "$@"; return "$?"; break;;
			remove)  shift; _uninstall_packages "$@" || return 1 && break;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			-I|--ignore-cli) ;;
			*) _red "(main) argumento inválido: $ARG"; STATUS_OUTPUT='1'; break;;
		esac
		shift
	done
	return "$?"
}

if [[ -z $1 ]]; then
	if ! is_executable zenity; then
		_yellow "Necessário instalar zenity"
		__pkg__ zenity
	fi 
	"$GUI"
else
	# Executar a função main passando todos os argumentos recebidos na linha de comando.
	main "${@}" || STATUS_OUTPUT='1'

	# Remover diretórios e subdiretórios temporários.
	silent='True'
	__rmdir__ "$TemporaryDirectory"

	if [[ "$STATUS_OUTPUT" == '1' ]]; then
		exit 1
	else
		exit 0
	fi
fi



