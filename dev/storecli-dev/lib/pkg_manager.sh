#!/usr/bin/env bash

_loop_pid()
{
	# Esta função serve para executar um loop enquanto um determinado processo
	# do sistema está em execução, por exemplo um outro processo de instalação
	# de pacotes, como o "apt install" ou "pacman install" por exemplo, o pid
	# deve ser passado como argumento $1 da função. Enquanto esse processo existir
	# o loop ira bloquar a execução deste script, que será retomada assim que o
	# processo informado for encerrado.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"

	while true; do
		ALL_PROCS=$(ps aux)
		if [[ $(echo -e "$ALL_PROCS" | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]]; then 
			break
		fi

		Char="${array_chars[$num_char]}"		
		echo -ne "Aguardando processo com pid [$Pid] finalizar [${Char}]\r" # $(date +%H:%M:%S)
		sleep 0.15
		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	echo -e "Aguardando processo com pid [$Pid] ${CYellow}finalizado${CReset} [${Char}]"	
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

	_print "Executando ... sudo gdebi $@"
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

	_msg "Executando ... sudo dpkg $@"
	if sudo dpkg "$@"; then
		return 0
	else
		_sred "(_DPKG): Erro sudo dpkg $@"
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

	[[ -f '/var/lib/dpkg/lock-frontend' ]] && sudo rm -rf '/var/lib/dpkg/lock-frontend'
	[[ -f '/var/cache/apt/archives/lock' ]] && sudo rm -rf '/var/cache/apt/archives/lock'

	_msg "Executando ... sudo apt $@"
	if sudo apt "$@"; then
		return 0
	else
		_sred "(_APT): Erro sudo apt $@"
		return 1
	fi
}

_apt_key_add()
{
	if [[ -f "$1" ]]; then
		printf "(_apt_key_add) Adicionando key apartir do arquivo ... $1 "
		sudo apt-key add "$1" || return 1
	else 
		if ! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/'; then
			_red "(_apt_key_add): url inválida $1"
			return 1
		fi

		# Obter key apartir do url $1.
		local temp_dir_key=$(mktemp --directory)
		local temp_file_key="temp.key"
		printf "Adicionando key apartir do url ... $1 "
		if [[ -x $(command -v aria2c 2> /dev/null) ]]; then
			aria2c "$1" -d "$temp_dir_key" -o "$temp_file_key" 1> /dev/null
		elif [[ -x $(command -v curl 2> /dev/null) ]]; then
			curl -sSL "$1" -o "$temp_dir_key/$temp_file_key"
		elif [[ -x $(command -v wget 2> /dev/null) ]]; then
			wget -q "$1" -O "$temp_dir_key/$temp_file_key"
		else
			_sred "FALHA"
			return 1
		fi

		# Adicionar key
		if [[ $? == 0 ]]; then
			sudo apt-key add "$temp_dir_key/$temp_file_key" || return 1
			return 0
		else
			_sred "FALHA"
			return 1
		fi
	fi
}

_addrepo_in_sources_list()
{
	# $1 = repositório para adicionar em /etc/apt/sources.list.d/
	# Se o repositório já existir em outro arquivo a adição do repositório
	# será IGNORADA.

	# $2 = Nome do arquivo para gravar o repositório. Se o arquivo já existir
	# a adição do repositório será IGNORADA. 

	# IMPORTANTE antes de adicionar os repositório, e necessário adicionar key.pub 
	# para cada repositório, para evitar problemas quando atualizar o cache do apt (sudo apt update)
	if [[ -z $2 ]]; then
		_sred "(_addrepo_in_sources_list): Necessário informar um arquivo para adicionar o repositório"
		return 1
	fi

	local repo="$1"
	local file_repo="$2"
	find /etc/apt -name *.list | xargs grep "^${repo}" 2> /dev/null
	if [[ $? == 0 ]] || [[ -f "$file_repo" ]]; then
		printf "${CGreen}INFO${CReset} ... repositório já existe em /etc/apt pulando.\n"
		return 0
	else
		printf "${CGreen}A${CReset}dicionando repositório em ... $file_repo\n"
		echo -e "$repo" | sudo tee "$file_repo"
		_APT update || return 1
	fi
	return 0
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
	_print "Executando ... sudo rpm $@"
	if sudo rpm "$@"; then
		return 0
	else
		_sred "(_RPM): Erro sudo rpm $@"
		return 1
	fi
}

_DNF()
{
	_msg "Executando ... sudo dnf $@"
	if sudo dnf "$@"; then
		return 0
	else
		_sred "(_DNF): Erro sudo dnf $@"
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

	_print "Executando ... sudo zypper $@"
	if sudo zypper "$@"; then
		return 0
	else
		_red "(_ZYPPER): Erro sudo zypper $@"
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

	_print "Executando ... sudo pacman $@"
	if sudo pacman "$@"; then
		return 0
	else
		_red "(_PACMAN): Erro sudo pacman $@"
		return 1
	fi
}

_PKG()
{
	# FreeBSD
	Pid_Pkg_Install=$(ps aux | grep 'root.*pkg' | egrep -m 1 '(install|update)' | awk '{print $2}')
	[[ ! -z $Pid_Pkg_Install ]] && _loop_pid "$Pid_Pkg_Install"

	_print "Executando ... sudo pkg $@"
	if sudo pkg "$@"; then
		return 0
	else
		_red "(PKG): Erro sudo pkg $@"
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

__pkg__()
{
	# Função para instalar os pacotes via linha de comando de acordo 
	# o gerenciador de pacotes de cada sistema.

	#=============================================================#
	# Somente baixar os pacotes caso receber '-d' ou '--downloadonly'
	# na linha de comando.
	#=============================================================#
	
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
		if [[ $(uname -s) == 'FreeBSD' ]]; then 
			_PKG install "$@"
			return 
		fi
		
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
