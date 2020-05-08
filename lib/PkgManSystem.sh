#!/usr/bin/env bash
#
#
#

#=============================================================#

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
	echo -e "Aguardando processo com pid [$Pid] ${Yellow}finalizado${Reset} [${Char}]"	
}



_DPKG()
{
	# Função para executar dpkg --install
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')

	[[ ! -z $Pid_Apt_Install ]] && _loop_pid "$Pid_Apt_Install"
	[[ ! -z $Pid_Apt_Systemd ]] && _loop_pid "$Pid_Apt_Systemd"
	[[ ! -z $Pid_Dpkg_Install ]] && _loop_pid "$Pid_Dpkg_Install"

	if sudo dpkg "$@"; then
		return 0
	else
		red "Gerenciador de pacotes [dpkg] retornou erro"
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

	[[ ! -z $Pid_Apt_Install ]] && _loop_pid "$Pid_Apt_Install"
	[[ ! -z $Pid_Apt_Systemd ]] && _loop_pid "$Pid_Apt_Systemd"
	[[ ! -z $Pid_Dpkg_Install ]] && _loop_pid "$Pid_Dpkg_Install"
	[[ -f '/var/lib/dpkg/lock-frontend' ]] && sudo rm -rf '/var/lib/dpkg/lock-frontend'
	[[ -f '/var/cache/apt/archives/lock' ]] && sudo rm -rf '/var/cache/apt/archives/lock'

	if sudo apt "$@"; then
		return 0
	else
		red "Gerenciador de pacotes [apt] retornou erro"
		red "Linha de comando: sudo apt $@"
		return 1
	fi
}

#=============================================================#
# Remover pacotes quebrados em sistemas debian.
#=============================================================#
_BROKE()
{
	if [[ ! -x $(command -v apt 2> /dev/null) ]]; then
		yellow "Esta opção só está disponivel para sistemas baseados em Debian"
		return 0
	fi

	
	local RunAptCmd=(
		clean
		remove
		autoremove
		'install -y -f'
		'--fix-broken install'
	)
	
	yellow "Executando: dpkg --configure -a"
	_DPKG --configure -a
	
	for X in "${RunAptCmd[@]}"; do
		yellow "Executando: apt $X"
		if ! _APT "$X"; then
			red "Falha: apt $X"
			sleep 0.5
		fi
	done

	# sudo apt install --yes --force-yes -f 
}


_RPM()
{
	if sudo rpm "$@"; then
		return 0
	else
		red "[_RPM] retornou erro"
		return 1
	fi
}

_DNF()
{
	if sudo dnf "$@"; then
		return 0
	else
		red "Gerenciador de pacotes [dnf] retornou erro"
		return 1
	fi
}

_ZYPPER()
{
	if sudo zypper "$@"; then
		return 0
	else
		red "Gerenciador de pacotes [zypper] retornou erro"
		return 1
	fi
}

_PACMAN()
{
	Pid_Pacman_Install=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
	[[ ! -z $Pid_Pacman_Install ]] && _loop_pid "$Pid_Pacman_Install"

	if sudo pacman "$@"; then
		return 0
	else
		red "Gerenciador de pacotes [pacman] retornou erro"
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
		red "Gerenciador de pacotes [pkg] retornou erro"
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

#=============================================================#

_package_man_distro_remove()
{
	# Somente remover, o argumento 'remove' deve ser passado para a função.
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

#=============================================================#

_package_man_distro()
{
	# Função para instalar os pacotes via linha de comando de
	# acordo com cada sistema.

	if [[ "$1" == 'remove' ]]; then
		_package_man_distro_remove "$@"
		return 0
	fi

	#---------------------------------------------------------#
	# Somente baixar os pacotes caso receber '-d' ou '--downloadonly'
	# na linha de comando.
	#---------------------------------------------------------#
	if [[ "$download_only" == 'True' ]] && [[ -f '/etc/debian_version' ]]; then
		if _APT install --download-only --yes "$@"; then
			_INFO 'download_only' "$@"
			return 0
		else
			return 1
		fi
	elif [[ "$download_only" == 'True' ]] && [[ "$os_id" == 'fedora' ]]; then
		if _DNF install --downloadonly -y "$@"; then
			_INFO 'download_only' "$@"
			return 0
		else
			return 1
		fi
	elif [[ "$download_only" == 'True' ]] && [[ "$os_id" == 'arch' ]]; then
		if _PACMAN -S --downloadonly "$@"; then
			_INFO 'download_only' "$@"
			return 0
		else
			return 1
		fi
	elif [[ "$download_only" == 'True' ]]; then
		_INFO 'pkg_not_found' "$@"
		return 1
	fi

	#---------------------------------------------------------#
	# Assumir sim/yes para indagações caso receber '-y' ou '--yes'
	# na linha de comando.
	#---------------------------------------------------------#
	if [[ "$install_yes" == 'True' ]] && [[ -f '/etc/debian_version' ]]; then
		if _APT install --yes "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$install_yes" == 'True' ]] && [[ "$os_id" == 'fedora' ]]; then
		if _DNF install -y "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$install_yes" == 'True' ]] && [[ "$os_id" == 'arch' ]]; then
		if _PACMAN -S --noconfirm --needed "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$install_yes" == 'True' ]] && [[ -x $(which zypper 2> /dev/null) ]]; then
		if _ZYPPER install "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$install_yes" == 'True' ]] && [[ -x $(which pkg 2> /dev/null) ]]; then
		if _PKG install -y "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$install_yes" == 'True' ]]; then
		_INFO 'pkg_not_found' "$@"
		return 1
	fi
	
	#---------------------------------------------------------#
	# Instalação normal.
	#---------------------------------------------------------#
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


