#!/usr/bin/env bash
#


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
		if [[ $(ps aux | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]]; then 
			break
		fi

		Char="${array_chars[$num_char]}"		
		echo -ne "Aguardando processo com pid [$Pid] finalizar [${Char}]\r"
		sleep 0.25
		
		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	echo -e "Aguardando processo com pid [$Pid] ${_yellow}finalizado${CReset} [${Char}]"	
}



_DPKG()
{
	# Função para executar dpkg --install
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
	Pid_Python_Aptd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(aptd)' | awk '{print $2}')

	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	done


	while [[ ! -z $Pid_Apt_Systemd ]]; do 
		_loop_pid "$Pid_Apt_Systemd"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	done
	
	while [[ ! -z $Pid_Dpkg_Install ]]; do 
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
	done

	if sudo dpkg "$@"; then
		return 0
	else
		_red "(dpkg) retornou erro"
		return 1
	fi
}

_APT()
{
	# Antes de proseguir com a instalação devemos verificar se já 
	# existe outro processo instalação com apt em execução para não
	# causar erros.
	# sudo rm /var/lib/dpkg/lock-frontend
	# sudo rm /var/cache/apt/archives/lock
	#
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')

	# Processo apt install em execução no sistema
	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	done

	# Processo apt systemd em execução no sistema
	while [[ ! -z $Pid_Apt_Systemd ]]; do
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	done

	# Processo dpkg install em execução no sistema
	while [[ ! -z $Pid_Dpkg_Install ]]; do
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
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
		_yellow "Esta opção só está disponivel para sistemas baseados em Debian"
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


_pkg_manager_sys_remove()
{
	# Somente programas remover, o argumento 'remove' deve ser passado para a função.
	if [[ -f '/etc/debian_version' ]]; then
		if _APT "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$os_id" == 'fedora' ]]; then
		if _DNF "$@"; then
			return 0
		else
			return 1
		fi
	fi
}

_pkg_manager_sys()
{
	# Função para instalar os pacotes via linha de comando de
	# acordo com cada sistema.

	if [[ "$1" == 'remove' ]]; then
		_pkg_manager_sys_remove "$@"
		return 0
	fi

	#=============================================================#
	# Somente baixar os pacotes caso receber '-d' ou '--downloadonly'
	# na linha de comando.
	#=============================================================#
	if [[ "$DownloadOnly" == 'True' ]] && [[ -f '/etc/debian_version' ]]; then # Debian
		if _APT install --download-only --yes "$@"; then
			__yellow 'Executado em modo somente baixar' "$@"
			return 0
		else
			return 1
		fi
	elif [[ "$DownloadOnly" == 'True' ]] && [[ "$os_id" == 'fedora' ]]; then # Fedora
		if _DNF install --downloadonly -y "$@"; then
			__yellow 'Executado em modo somente baixar' "$@"
			return 0
		else
			return 1
		fi
	elif [[ "$DownloadOnly" == 'True' ]] && [[ -x $(which zypper 2> /dev/null) ]]; then # OpenSuse
		if _ZYPPER download "$@"; then
			__yellow 'Executado em modo somente baixar' "$@"
			return 0
		else
			return 1
		fi
	elif [[ "$DownloadOnly" == 'True' ]] && [[ "$os_id" == 'arch' ]]; then # ArchLinux
		if _PACMAN -S --noconfirm --needed --downloadonly "$@"; then
			__yellow 'Executado em modo somente baixar' "$@"
			return 0
		else
			return 1
		fi
	elif [[ "$DownloadOnly" == 'True' ]]; then
		__yellow 'Executado em modo somente baixar' "$@"
		return 1
	fi

	#=============================================================#
	# Assumir sim/yes para indagações caso receber '-y' ou '--yes'
	# na linha de comando.
	#=============================================================#
	if [[ "$AssumeYes" == 'True' ]] && [[ -f '/etc/debian_version' ]]; then # Debian
		if _APT install --yes "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$AssumeYes" == 'True' ]] && [[ "$os_id" == 'fedora' ]]; then # Fedora
		if _DNF install -y "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$AssumeYes" == 'True' ]] && [[ "$os_id" == 'arch' ]]; then # ArchLinux
		if _PACMAN -S --noconfirm --needed "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$AssumeYes" == 'True' ]] && [[ -x $(which zypper 2> /dev/null) ]]; then # OpenSuse
		if _ZYPPER install -y "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$AssumeYes" == 'True' ]] && [[ -x $(which pkg 2> /dev/null) ]]; then # FreeBSD
		if _PKG install -y "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$AssumeYes" == 'True' ]]; then
		__red "Seu sistema não é suportado"
		return 1
	fi
	
	#=============================================================#
	# Instalação normal, caso não seja passado os argumentos -y ou -d
	#=============================================================#
	if [[ -f '/etc/debian_version' ]]; then           # Debia/apt
		if _APT install "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$os_id" == 'fedora' ]]; then            # Fedora/dnf
		if _DNF install "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$os_id" == 'arch' ]]; then              # ArchLinux/pacman
		if _PACMAN -S --needed "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ -x $(which zypper 2> /dev/null) ]]; then # Suse/zypper
		if _ZYPPER install "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ -x $(which pkg 2> /dev/null) ]]; then    # FreeBSD/pkg
		if _PKG install "$@"; then
			return 0
		else
			return 1
		fi
	else
		_INFO 'pkg_not_found' "$@"
		return 1
	fi
}