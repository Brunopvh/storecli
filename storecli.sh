#!/usr/bin/env bash
#
#
__version__='2020_08_09_rev3'
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
#


# https://qastack.com.br/programming/263890/how-do-i-find-the-width-height-of-a-terminal-window
#

#=============================================================#
# Verificar requesitos minimos do sistema.
#=============================================================#
# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]]; then
	printf "\033[0;31m Execute este programa apenas em sistemas Linux.\033[m\n"
	exit 1
fi

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	printf "\033[0;31m Usuário não pode ser o [root] execute novamente sem o [sudo]\033[m\n"
	exit 1
fi

# Necessário ter o "sudo" intalado.
if [[ ! -x $(which sudo 2> /dev/null) ]]; then
	printf "\033[0;31m Instale o pacote [sudo] e adicione [$USER] no arquivo [sudoers] para prosseguir\033[m\n"
	exit 1
fi

# Verificar se a arquitetura do Sistema e 64 bits
if ! uname -m | grep '64' 1> /dev/null; then
	printf "\033[0;31m Seu sistema não e 64 bits. Saindo\033[m\n"
	exit 1
fi

#=============================================================#
# Diretórios do usuário
#=============================================================#
directoryUSERbin="$HOME/.local/bin"
directoryUSERicon="$HOME/.local/share/icons"
directoryUSERthemes="$HOME/.themes"
directoryUSERapplications="$HOME/.local/share/applications"
directoryUSERconfig="$HOME/.config/storecli"

mkdir -p "$directoryUSERbin"
mkdir -p "$directoryUSERicon"
mkdir -p "$directoryUSERthemes"
mkdir -p "$directoryUSERapplications"
mkdir -p "$directoryUSERconfig"

#=============================================================#
# Diretórios do root
#=============================================================#
directoryROOTbin='/usr/local/bin'
directoryROOTicon='/usr/share/icons/hicolor'
directoryROOTthemes='/usr/share/themes/'
directoryROOTapplications='/usr/share/applications'

if [[ ! -d "$directoryROOTbin" ]]; then
	printf "%s\n" "Criando o diretório: $directoryROOTbin"
	sudo mkdir "$directoryROOTbin"
fi


if [[ ! -d "$directoryROOTicon" ]]; then
	printf "%s\n" "Criando o diretório: $directoryROOTicon"
	sudo mkdir "$directoryROOTicon"
fi


if [[ ! -d "$directoryROOTthemes" ]]; then
	printf "%s\n" "Criando o diretório: $directoryROOTthemes"
	sudo mkdir "$directoryROOTthemes"
fi


if [[ ! -d "$directoryROOTapplications" ]]; then
	printf "%s\n" "Criando o diretório: $directoryROOTapplications"
	sudo mkdir "$directoryROOTapplications"
fi

#=============================================================#
# Configuração de diretórios para libs, scripts e programas
#=============================================================#
export dirSTORECLIPath=$(dirname $(readlink -f "$0"))
export scriptStorecli=$(readlink -f "$0")
export dirSTORECLIPathLib="$dirSTORECLIPath/lib"
export dirSTORECLIPathScripts="$dirSTORECLIPath/scripts"
export dirSTORECLIPathPython="$dirSTORECLIPath/python"

#=============================================================#
# Definir as Libs e scripts a serem usados
#=============================================================#

# libs.
libColors="$dirSTORECLIPathLib/Colors.sh"
libCliUtils="$dirSTORECLIPathLib/CliUtils.sh"
libPlatform="$dirSTORECLIPathLib/Platform.sh"
libProcessLoop="$dirSTORECLIPathLib/ProcessLoop.sh"
libUninstallPkgs="$dirSTORECLIPathLib/UninstallPkgs.sh"
libArrayUtils="$dirSTORECLIPathLib/ArrayUtils.sh"
libPrograms="$dirSTORECLIPathLib/Programs.sh"
libWget="$dirSTORECLIPathLib/libwget.sh"

# Scripts
scriptConfigPath="$dirSTORECLIPathScripts/conf-path.sh"
scriptAddRepo="$dirSTORECLIPathScripts/addrepo.py"
scritpTorBrowser="$directoryUSERbin/tor-installer.sh"
scriptInstallStoreli="$dirSTORECLIPath/setup.sh"
scriptOhmybashInstaller="$dirSTORECLIPathScripts/ohmybash.run"
GUI="$dirSTORECLIPathScripts/gui.sh"

#=============================================================#
# importar libs
#=============================================================#
source "$libColors"
source "$libCliUtils"
source "$libPlatform"
source "$libProcessLoop"
source "$libUninstallPkgs"
source "$libArrayUtils"
source "$libPrograms"
source "$libWget"

# Criar diretórios para arquivos temporários para descompressão dos
# arquivos baixados e clonar repositórios do github. 
# export TemporaryDirectory=$(mktemp --directory)
export TemporaryDirectory="/tmp/storecli_$USER"
export DirTemp="$TemporaryDirectory/temp"
export DirGitclone="$TemporaryDirectory/gitclone"
export DirUnpack="$TemporaryDirectory/unpack"
export DirDownloads="$HOME/.cache/storecli/downloads"

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
export configFILE="$directoryUSERconfig/requeriments.conf"
export LogFile="$HOME/.cache/storecliLOG.log"
export LogErro="$HOME/.cache/storecliERROLog.log"

touch "$configFILE"
touch "$LogFile"
touch "$LogErro"

"$scriptConfigPath"

_red()
{
	echo -e "[${CRed}!${CReset}] $@"
}

_green()
{
	echo -e "[${CGreen}+${CReset}] $@"
}

_yellow()
{
	echo -e "[${CYellow}+${CReset}] $@"
}


_blue()
{
	echo -e "[${CBlue}+${CReset}] $@"
}


_white()
{
	echo -e "[${CWhite}+${CReset}] $@"
}


_sred()
{
	echo -e "${CSRed}$@${CReset}"
}

_sgreen()
{
	echo -e "${CSGreen}$@${CReset}"
}

_syellow()
{
	echo -e "${CSYellow}$@${CReset}"
}

_sblue()
{
	echo -e "${CSBlue}$@${CReset}"
}

# Função para verifiar se um executável existe no sistema.
is_executable()
{
	if [[ -x $(which "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}

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
	
	echo -en "[>] $@ [${CYellow}s${CReset}/${CRed}n${CReset}]?: "
	read -t 15 -n 1 sn
	echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		_green "${CYellow}A${CReset}bortando"
		return 1
	fi
}


if is_executable tput; then
	columns=$(tput cols)
else
	columns='40'
fi

print_line(){
	local L='='
	num='1'
	while [[ "$num" != "$columns" ]]; do
		L="${L}="
		num="$(($num+1))"
	done
	# echo -ne "$L"
	printf '%s\n' "$L"
}

space_line=$(print_line)

_msg()
{
	print_line
	echo -e " $@"
	print_line
}


_space_text()
{
	if [[ "${#@}" != '2' ]]; then
		_red "Falha: informe apenas 2 argumentos para serem exibidos como string"
		return 1
	fi

	local line='-'
	num="$((45-${#2}))"  
	
	for i in $(seq "$num"); do
		line="${line}-"
	done
	
	echo -e "$1 ${line}> $2"
}

_show_info()
{
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
    Use: $scriptStorecli -b|-c|-d|-I|-h|-l|-s|-v
         $scriptStorecli install <pacote>
         $scriptStorecli remove <pacote>

    Opções:

       -b|--broke                    Remove pacotes quebrados - (usar em sistemas Debian apenas).
       -c|--configure                Instala requerimentos desse script.
       -d|--downloadonly             Apenas baixa os pacotes, quando disponíveis.
       -h|--help                     Mostra ajuda.
       -I|--ignore-cli               Ignora a verificação dos pacotes/dependências deste script.
                                     $scriptStorecli --ignore-cli install <pacote>

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
             $scriptStorecli install etcher sublime-text google-chrome youtube-dl-gui virtualbox

       Instalando uma categoria/grupo de pacotes:
             $scriptStorecli --install Acessorios Desenvolvimento Escritorio Internet

EOF
}

_ping()
{
	printf "%s" "[>] Aguardando conexão: "

	if [[ $(ping -c 1 8.8.8.8) ]]; then
		printf '%s\n' "Conectado"
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

__RMDIR()
{
	# Função para remover diretórios e arquivos, inclusive os arquivos é diretórios
	# que o usuário não tem permissão de escrita, para isso será usado o "sudo".
	#
	# Use:
	#     __RMDIR <diretório> ou
	#     __RMDIR <arquivo>
	[[ -z $1 ]] && return 1

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# A função __sudo__ irá remover o arquivo/diretório.
	while [[ $1 ]]; do
		printf "[>] Removendo: $1 "
		if rm -rf "$1" 2> /dev/null || sudo rm -rf "$1"; then
			_syellow "OK"
		else
			_sred "FALHA"
		fi
		shift
	done
}

_clear_temp_dirs()
{
	cd "$DirTemp" && __RMDIR $(ls)
	cd "$DirUnpack" && __RMDIR $(ls)
	cd "$DirGitclone" && __RMDIR $(ls)

}

_GDEBI()
{
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
	Pid_Python_Aptd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(aptd)' | awk '{print $2}')

	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
		sleep 0.2
	done


	while [[ ! -z $Pid_Apt_Systemd ]]; do 
		_loop_pid "$Pid_Apt_Systemd"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
		sleep 0.2
	done
	
	while [[ ! -z $Pid_Dpkg_Install ]]; do 
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
		sleep 0.2
	done

	if sudo gdebi "$@"; then
		return 0
	else
		_red "(_GDEBI) erro: gdebi $@"
		return 1	
	fi	
}


_DPKG()
{
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
	Pid_Python_Aptd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(aptd)' | awk '{print $2}')

	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
		sleep 0.2
	done


	while [[ ! -z $Pid_Apt_Systemd ]]; do 
		_loop_pid "$Pid_Apt_Systemd"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
		sleep 0.2
	done
	
	while [[ ! -z $Pid_Dpkg_Install ]]; do 
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
		sleep 0.2
	done

	if sudo dpkg "$@"; then
		return 0
	else
		_red "(_DPKG) erro: $@"
		return 1
	fi
}

_APT()
{
	# Antes de proseguir com a instalação devemos verificar se já 
	# existe outro processo de instalação com apt em execução para não
	# causar erros.
	#sudo rm /var/lib/dpkg/lock-frontend 
	#sudo rm /var/cache/apt/archives/lock
	
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')

	# Processo apt install em execução no sistema
	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
		sleep 0.2
	done

	# Processo apt systemd em execução no sistema
	while [[ ! -z $Pid_Apt_Systemd ]]; do
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
		sleep 0.2
	done

	# Processo dpkg install em execução no sistema
	while [[ ! -z $Pid_Dpkg_Install ]]; do
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
		sleep 0.2
	done

	# [[ ! -z $Pid_Apt_Install ]] && _loop_pid "$Pid_Apt_Install"
	# [[ ! -z $Pid_Apt_Systemd ]] && _loop_pid "$Pid_Apt_Systemd"
	# [[ ! -z $Pid_Dpkg_Install ]] && _loop_pid "$Pid_Dpkg_Install"
	[[ -f '/var/lib/dpkg/lock-frontend' ]] && sudo rm -rf '/var/lib/dpkg/lock-frontend'
	[[ -f '/var/cache/apt/archives/lock' ]] && sudo rm -rf '/var/cache/apt/archives/lock'

	if sudo apt "$@"; then
		return 0
	else
		_red "Gerenciador de pacotes [apt] retornou erro"
		_red "Linha de comando: sudo apt $@"
		return 1
	fi
}

#=============================================================#
# Remover pacotes quebrados em sistemas debian.
#=============================================================#
_BROKE()
{
	if [[ ! -x $(command -v apt 2> /dev/null) ]]; then
		_red "(_BROKE) esta opção só está disponível para sistemas baseados em Debian"
		return 0
	fi

	
	_yellow "Executando: dpkg --configure -a"
	_DPKG --configure -a

	_yellow "Executando: apt clean"
	_APT clean

	_yellow "Executando: apt remove"
	_APT remove
	
	_yellow "Executando: apt install -y -f"
	_APT install -y -f

	_yellow "Executando: apt --fix-broken install"
	_APT --fix-broken install
	
	# sudo apt install --yes --force-yes -f 
}


_RPM()
{
	if sudo rpm "$@"; then
		return 0
	else
		_red "_RPM: Erro"
		return 1
	fi
}

_DNF()
{
	if sudo dnf "$@"; then
		return 0
	else
		_red "Gerenciador de pacotes [dnf] retornou erro"
		return 1
	fi
}

_ZYPPER()
{

	pidZypperInstall=$(ps aux | grep 'root.*zypper' | egrep -m 1 '(install)' | awk '{print $2}')

	# Processo zypper install em execução no sistema.
	while [[ ! -z $pidZypperInstall ]]; do
		_loop_pid "$pidZypperInstall"
		pidZypperInstall=$(ps aux | grep 'root.*zypper' | egrep -m 1 '(install)' | awk '{print $2}')
	done

	if sudo zypper "$@"; then
		return 0
	else
		_red "Gerenciador de pacotes [zypper] retornou erro"
		return 1
	fi
}

_PACMAN()
{
	Pid_Pacman_Install=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
	while [[ ! -z $Pid_Pacman_Install ]]; do
		_loop_pid "$Pid_Pacman_Install"
		Pid_Pacman_Install=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
		sleep 0.2
	done

	if sudo pacman "$@"; then
		return 0
	else
		_red "Gerenciador de pacotes [pacman] retornou erro"
		return 1
	fi
}

_PKG()
{
	# FreeBSD
	Pid_Pkg_Install=$(ps aux | grep 'root.*pkg' | egrep -m 1 '(install|update)' | awk '{print $2}')
	[[ ! -z $Pid_Pkg_Install ]] && _loop_pid "$Pid_Pkg_Install"

	if sudo pkg "$@"; then
		return 0
	else
		_red "Gerenciador de pacotes [pkg] retornou erro"
		return 1
	fi
}

_FLATPAK()
{
	if flatpak "$@"; then
		return 0
	else
		_red "Falha: flatpak $@"
		return 1
	fi
}

_pkg_manager_sys()
{
	# Função para instalar os pacotes via linha de comando de acordo 
	# o gerenciador de pacotes de cada sistema.

	#=============================================================#
	# Somente baixar os pacotes caso receber '-d' ou '--downloadonly'
	# na linha de comando.
	#=============================================================#
	if [[ "$DownloadOnly" == 'True' ]] && [[ "$AssumeYes" == 'True' ]]; then 
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install --download-only --yes "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER download "$@" || return 1;;
			fedora) _DNF install --downloadonly -y "$@" || return 1;;
			arch) _PACMAN -S --noconfirm --needed --downloadonly "$@" || return 1;;
		esac
	elif [[ "$DownloadOnly" == 'True' ]]; then
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install --download-only "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER download "$@" || return 1;;
			fedora) _DNF install --downloadonly "$@" || return 1;;
			arch) _PACMAN -S --needed --downloadonly "$@" || return 1;;
		esac
	elif [[ "$AssumeYes" == 'True' ]]; then 
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install --yes "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install -y "$@" || return 1;;
			fedora) _DNF install -y "$@" || return 1;;
			arch) _PACMAN -S --noconfirm --needed "$@" || return 1;;
		esac
	else
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
			[[ -f "$X" ]] && __RMDIR "$X"
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
	
	cd "$DirDownloads"
	_blue "Baixando: $1"

	if is_executable wget; then # Usar wget
		downloader_default='wget'
	elif is_executable curl; then # Usar curl
		downloader_default='curl'
	elif is_executable "$dirSTORECLIPathScripts"/web-cli.py; then # Usar script python local.
		downloader_default='web-cli'
	else
		_red "(__download__) instale o pacote 'wget' ou 'curl'"
		return 1
	fi

	#downloader_default='web-cli'

	while true; do
		if [[ "$downloader_default" == 'web-cli' ]]; then
			"$dirSTORECLIPathScripts"/web-cli.py --url "$url" -o "$path_file" && break
		elif [[ "$downloader_default" == 'wget' ]]; then
			__wget__ "$url" "$path_file" && break
		elif [[ "$downloader_default" == 'curl' ]]; then
			curl -C - -S -L -o "$path_file" "$url" && break
		fi

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
		_pkg_manager_sys git || return 1
	fi

	cd "$DirGitclone"
	dir_repo=$(basename "$1" | sed 's/.git//g')
	if [[ -d "$DirGitclone/$dir_repo" ]]; then
		_yellow "Encontrado: $DirGitclone/$dir_repo"
		if _YESNO "Deseja remover o diretório clonado anteriormente"; then
			__RMDIR "$dir_repo"
		else
			return 0
		fi
	fi

	_blue "Clonando: $1"
	_blue "Destino: $(pwd)"
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
	elif [[ -d "$DirUnpack" ]]; then
		DirUnpack="$DirUnpack"
	else
		_red "(_unpack): nenhum diretório para descompressão foi informado"
		return 1
	fi 
	
	cd "$DirUnpack"
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
		__RMDIR "$path_file"
		return 1
	fi

	printf "%s" "[>] Descomprimindo: $path_file "
	
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
		__RMDIR "$path_file"
		return 1
	fi
}


_pkg_manager_storecli()
{
	# Instalação dos programas
	if [[ -z $1 ]]; then
		usage
		return 1
	fi

	_clear_temp_dirs

	# Se o sistema for LinuxMint, deverá ser tratado como Ubuntu.
	case "$os_codename" in
		tina|tricia) export os_codename='bionic';;
	esac

	_yellow "Sistema: $os_id"

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
			youtube-dl-gui-windows) _youtube_dlgui_windows;;

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
			
			epsxe) _epsxe;;
			epsxe-win) _epsxe_windows;;
			snapd) _snapd;;
			install) ;;
			*) _red "(_pkg_manager_storecli) programa não encontrado: $1";;
		esac
		shift
	done
}

_update_storecli()
{
	# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	local FileConfigUpdate="$directoryUSERconfig/update.conf"; touch "$FileConfigUpdate"
	local tempFileUpdate="$DirTemp/storecli.update"                    	
	local nowDate=$(date +%Y_%m_%d) # Data atual /ano/mês/dia.
	
	# Data de execução da última busca por atualizações.
	local oldDateUpdate=$(grep -m 1 "date_update" "$FileConfigUpdate" | cut -d ' ' -f 2 2> /dev/null) 
	
	if [[ "$nowDate" == "$oldDateUpdate" ]]; then
		return 0
	else
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
	fi
	
	[[ ! -z "$oldDateUpdate" ]] && printf '%s\n' "[+] Data da última busca por atualizações: $oldDateUpdate"
	
	printf "%s" "[>] Verificando atualização no github aguarde "
	wget -q https://raw.github.com/Brunopvh/storecli/master/storecli.sh -O "$tempFileUpdate" || { 
		_sred "FALHA"
		return 1
	}
	_syellow 'OK'	
	OnlineVersion=$(grep -m 1 ^'__version__' "$tempFileUpdate" | sed "s/.*=//g;s/'//g")
	
	_yellow "Versão local ($__version__) - versão online ($OnlineVersion)"
	if [[ "$OnlineVersion" == "$__version__" ]]; then
		_yellow "Scritp storecli está atualizado"
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
		return 0
	fi
	
	_yellow "Instalando nova versão: $OnlineVersion"
	
	if ! "$scriptInstallStoreli"; then
		_red "(_update_storecli) falha"
		return 1
	fi

	[[ -f "$tempFileUpdate" ]] && rm "$tempFileUpdate"
	echo -e "date_update $nowDate" > "$FileConfigUpdate"
	return 0
}

argument_parser()
{
	local num='0'
	export OptArgs=()
	while [ $1 ]; do
		case "$1" in
			-l|--list) shift; _list_applications "$@"; return 0; break;;
			-v|--version) shift; echo -e "$(basename $scriptStorecli) V${__version__}"; return 0; break;;
			-h|--help) shift; usage; return 0; break;;
			-y|--yes) export AssumeYes='True';;
			-d|--downloadonly) export DownloadOnly='True';;
			-I|--ignore-cli) export IgnoreCli='True';;
			*) OptArgs["$num"]="$1"; num="$(($num+1))";;
		esac
		shift
	done

}

main()
{	
	argument_parser "$@"

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

	for ARG in "${OptArgs[@]}"; do
		case "$ARG" in
			-b|--broke) _BROKE;;
			-c|--configure) _run_configuration_dep;;
			-u|--self-update) "$scriptInstallStoreli";;
			install) _pkg_manager_storecli "${OptArgs[@]}"; return "$?"; break;;
			remove)  _uninstall_packages "${OptArgs[@]}"; return "$?";;
			*) _red "(argument_parser) argumento inválido: $ARG"; return 1; break;;
		esac
	done
	return "$?"
}

if [[ -z $1 ]]; then
	if is_executable zenity; then
		_yellow "Necessário instalar zenity"
		_pkg_manager_sys zenity
	fi 
	"$GUI"
else
	main "$@"
fi
