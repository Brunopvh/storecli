#!/usr/bin/env bash
#
#
# - REQ-LIBS = utils
# - REQ-LIBS = print_text
# - REQ-LIBS = sys
# - REQ-LIBS = requests
# 
# + REQ-SYSTEM = awk
# 
#
#



function getAptProc()
{
	# Verificar se existe algum processo APT em execução.
	#
	#
	#
	local _procs=''
	
	# Verificar se existe outro processo apt em execução antes de prosseguir com a instalação.
	_procs=$(ps aux)
	proc_apt_install=$(echo "$_procs" | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	proc_apt_systemd=$(echo "$_procs" | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	proc_dpkg_install=$(echo "$_procs" | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
	proc_python_aptd=$(echo "$_procs" | grep 'root.*apt' | egrep -m 1 '(aptd)' | awk '{print $2}')
 	
	[[ $proc_apt_install != '' ]] && return $proc_apt_install
	[[ $proc_apt_systemd != '' ]] && return $proc_apt_systemd
	[[ $proc_dpkg_install != '' ]] && return $proc_dpkg_install
	[[ $proc_python_aptd != '' ]] && return $proc_python_aptd
	return 0

}


function waitAptProcess()
{
	# Verificar se existe algum processo APT em execução.
	local proc_apt=$(getAptProc)

	[[ $proc_apt == 0 ]] && return

	waitPid $proc_apt
	
}

runGdebi()
{
	existsAptProcess

	echo -e "Executando ... sudo gdebi $@"
	if sudo gdebi "$@"; then return 0; fi
	red "(runGdebi) erro: gdebi $@"
	return 1		
}

runDpkg()
{
	existsAptProcess

	echo -e "Executando ... sudo dpkg $@"
	if sudo dpkg "$@"; then return 0; fi

	sred "(runDpkg): Erro sudo dpkg $@"
	return 1
}

runApt()
{
	# Antes de proseguir com a instalação devemos verificar se já 
	# existe outro processo de instalação com apt em execução para não
	# causar erros.
	# sudo rm /var/lib/dpkg/lock-frontend 
	# sudo rm /var/cache/apt/archives/lock
	
	existsAptProcess
	[[ -f '/var/lib/dpkg/lock-frontend' ]] && sudo rm -rf '/var/lib/dpkg/lock-frontend'
	[[ -f '/var/cache/apt/archives/lock' ]] && sudo rm -rf '/var/cache/apt/archives/lock'

	echo -e "Executando ... sudo apt $@"
	if sudo apt "$@"; then return 0; fi
	sred "(runApt): Erro sudo apt $@"
	return 1	
}

aptKeyAdd()
{
	isAdmin || return 1

	if [[ ! -f $1 ]]; then
		printErro "aptKeyAdd: arquivo não encontrado."
		return 1
	fi

	echo -ne "Adicionando key apartir do arquivo ... $1 "
	sudo apt-key add "$1"
	[[ $? == 0 ]] && {
		echo OK
		return 0
	}
	printErro "aptKeyAdd"
	return 1
}

function existsDebianRepo()
{
	local _repo="$1"
	find /etc/apt -name *.list | xargs grep "^${_repo}" 1> /dev/null 2>&1 || return $?
	return 0
}

addRepoApt()
{
	# $1 = repositório para adicionar em /etc/apt/sources.list.d/
	# Se o repositório já existir em outro arquivo a adição do repositório
	# será IGNORADA.

	# $2 = Nome do arquivo para gravar o repositório (.list). Se o arquivo já existir
	# a adição do repositório será IGNORADA. 

	# IMPORTANTE: antes de adicionar os repositório, é necessário adicionar o key.pub 
	# de cada repositório adicionado, evitando assim possíveis problemas quando atualizar 
	# o cache do apt (sudo apt update).
	if [[ -z $2 ]]; then
		printErro "(addRepoApt): informe um arquivo para adicionar o repositório"
		return 1
	fi

	if isFile "$2"; then echo -e "[PULANDO] arquivo já existe ... $2"; return 0; fi
	if existsDebianRepo "$1"; then echo -e "[PULANDO] repositório j́á existe em /etc/apt"; return 0; fi

	local repo="$1"
	local file_repo="$2"
	#find /etc/apt -name *.list | xargs grep "^${repo}" 2> /dev/null

	printInfo "Adicionando repositório em ... $file_repo"
	echo -e "$repo" | sudo tee "$file_repo"
	runApt update || return $?
	return 0
}


#=============================================================#
# Remover pacotes quebrados em sistemas debian.
#=============================================================#

runAptBroke()
{
	if isExecutable apt; then
		red "(runAptBroke) esta opção só está disponível para sistemas baseados em Debian"
		return 0
	fi


	COMMANDS=(
		'sudo dpkg --configure -a'
		'sudo apt clean'
		'sudo apt remove'
		'sudo apt install -y -f'
		)

	if [[ $(grep '^ID=' /etc/os-release | cut -d '=' -f 2) == 'debian' ]]; then
		COMMANDS[4]='sudo apt --fix-broken install'
	fi
	
	for cmd in "${COMMANDS[@]}"; do
		echo -e "Executando ... $cmd"
		$cmd
	done
	
	# sudo apt install --yes --force-yes -f 
}


runRpm()
{
	echo -e "Executando ... sudo rpm $@"
	sudo rpm $@
	[[ $? == 0 ]] && return 0
	msgErro "sudo rpm $@"
	return 1
}

runDnf()
{
	echo -e "Executando ... sudo dnf $@"
	sudo dnf "$@"
	[[ $? == 0 ]] && return 0
	msgErro "sudo dnf $@"
	return 1

}

rpmKeyAdd()
{
	isAdmin || return 1

	if ! isFile "$1"; then
		msgErro "Arquivo não encontrado ... $1"
		return 1
	fi

	echo -ne "Adicionando key ... $1 "
	sudo rpm --import "$1" 
	if [[ $? == 0 ]]; then
		echo 'OK'
		return 0
	fi
	printErro "rpmKeyAdd"
	return 1
}


addFedoraRepo()
{
	# $1 = url do repositório.
	# $2 = Nome do arquivo para gravar o repositório.

	[[ -z $2 ]] && {
		msgErro "(addFedoraRepo): informe um arquivo para adicionar o repositório"
		return 1
	}

	# Verificar se $1 e do tipo url.
	! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/' && {
		red "(addFedoraRepo): url inválida"
		return 1
	}

	local url_repo="$1"
	local file_repo="$2"
	local temp_file_repo="$(mktemp -u)"

	[[ -f "$file_repo" ]] && {
		printInfo "[PULANDO] ... repositório já existe em /etc/yum.repos.d"
		return 0
	}
	
	printInfo "adicionando repositório em ... $file_repo"
	download "$url_repo" "$temp_file_repo" 1> /dev/null 2>&1 || return $?

	sudoCommand mv "$temp_file_repo" "$file_repo" 
	sudoCommand chown root:root "$file_repo"
	sudoCommand chmod 644 "$file_repo"
	#rm -rf "$temp_file_repo" 
	return 0
}

_ZYPPER()
{
	pidZypperInstall=$(ps aux | grep 'root.*zypper' | egrep -m 1 '(install)' | awk '{print $2}')

	# Processo zypper install em execução no sistema.
	while [[ ! -z $pidZypperInstall ]]; do
		waitPid "$pidZypperInstall"
		pidZypperInstall=$(ps aux | grep 'root.*zypper' | egrep -m 1 '(install)' | awk '{print $2}')
	done

	echo -e "Executando ... sudo zypper $@"
	if sudo zypper "$@"; then
		return 0
	else
		red "(_ZYPPER): Erro sudo zypper $@"
		return 1
	fi
}



runPacMan()
{
	local _procs=$(ps aux)
	Pid_Pacman_Install=$(echo "$_procs" | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
	waitPid "$Pid_Pacman_Install"
	sleep 0.1

	echo -e "Executando ... sudo pacman $@"
	if sudo pacman "$@"; then
		return 0
	else
		msgErro "sudo pacman $@"
		return 1
	fi
}



runPacManOld()
{
	Pid_Pacman_Install=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
	while [[ ! -z $Pid_Pacman_Install ]]; do
		waitPid "$Pid_Pacman_Install"
		Pid_Pacman_Install=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
		sleep 0.2
	done

	echo -e "Executando ... sudo pacman $@"
	if sudo pacman "$@"; then
		return 0
	else
		red "(runPacMan): Erro sudo pacman $@"
		return 1
	fi
}

_PKG()
{
	# FreeBSD
	Pid_Pkg_Install=$(ps aux | grep 'root.*pkg' | egrep -m 1 '(install|update)' | awk '{print $2}')
	[[ ! -z $Pid_Pkg_Install ]] && waitPid "$Pid_Pkg_Install"

	echo -e "Executando ... sudo pkg $@"
	if sudo pkg "$@"; then
		return 0
	else
		red "(PKG): Erro sudo pkg $@"
		return 1
	fi
}

_FLATPAK()
{
	if flatpak "$@"; then
		return 0
	else
		red "Falha: flatpak $@"
		return 1
	fi
}


sysPkgMan()
{
	# Função para instalar os pacotes via linha de comando de acordo 
	# o gerenciador de pacotes de cada sistema.

	#=============================================================#
	# Somente baixar os pacotes caso receber '-d' ou '--downloadonly'
	# na linha de comando ou se a variável AssumeYes for igual a True.
	#=============================================================#
	
	if [[ "$DownloadOnly" == 'True' ]] && [[ "$AssumeYes" == 'True' ]]; then 
		# Somente baixar os pacotes e assumir yes para indagações.
		if [[ $(uname -s) == 'FreeBSD' ]]; then 
			_PKG install -y "$@" || return 1
		elif [[ -f /etc/debian_version ]] && [[ -x $(which apt 2> /dev/null) ]]; then
			runApt install --download-only --yes "$@" || return 1
		elif [[ -f /etc/fedora-release ]] && [[ -x $(which dnf 2> /dev/null) ]]; then
			runDnf install --downloadonly -y "$@" || return 1
		elif [[ "$OS_ID" == 'opensuse-leap' ]] || [[ "$OS_ID" == 'opensuse-tumbleweed' ]]; then
			_ZYPPER download "$@" || return 1
		elif [[ "$OS_ID" == 'arch' ]]; then
			runPacMan -S --noconfirm --needed --downloadonly "$@" || return 1
		else
			red "(sysPkgMan) Erro: $@"
			return 1
		fi
		return "$?"
	
	elif [[ "$DownloadOnly" == 'True' ]]; then
		# Somente baixar os pacotes.
		if [[ $(uname -s) == 'FreeBSD' ]]; then 
			_PKG install "$@"
			return 
		fi
		
		case "$OS_ID" in
			debian|ubuntu|linuxmint) runApt install --download-only "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER download "$@" || return 1;;
			fedora) runDnf install --downloadonly "$@" || return 1;;
			arch) runPacMan -S --needed --downloadonly "$@" || return 1;;
		esac
	elif [[ "$AssumeYes" == 'True' ]]; then 
		# Assumir yes para indagações durante a instalação, equivalênte ao comando
		# apt install -y / aptitude install -y em sistemas debian.
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install -y "$@"; return; fi
		case "$OS_ID" in
			debian|ubuntu|linuxmint) runApt install --yes "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install -y "$@" || return 1;;
			fedora) runDnf install -y "$@" || return 1;;
			arch) runPacMan -S --noconfirm --needed "$@" || return 1;;
		esac
	else
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install "$@"; return; fi
		case "$OS_ID" in
			debian|ubuntu|linuxmint) runApt install "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install "$@" || return 1;;
			fedora) runDnf install "$@" || return 1;;
			arch) runPacMan -S --needed "$@" || return 1;;
		esac
	fi
}
