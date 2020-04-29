#!/usr/bin/env bash
#
#
#

#=============================================================#

_apt_process_look()
{
	# '/var/cache/apt/archives/lock'

	local array_time_chars=('\' '|' '/' '-')
	local num_char='0'

	while [[ $(ps aux | grep 'root.*apt' | egrep '(install|upgrade)') ]]; do
		
		local _pid=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade)' | awk '{print $2}')
		local _char="${array_time_chars[$num_char]}"

		if [[ -z "$_pid" ]]; then
			break
		else
			echo -ne "Aguardando processo apt finalizar pid [$_pid] [${_char}]\r"
			sleep 0.3
		fi

		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'

	done
	echo -e "Aguardando processo apt finalizar pid [$_pid] [${_char}]"
	echo "Finalizado"
}


#=============================================================#
# Loop deverá ser executado se houver outro processo 'pacman -S'
# em execução.
#=============================================================#
_pacman_process_look()
{
	local array_time_chars=('\' '|' '/' '-')
	local num_char='0'

	while [[ $(ps aux | grep 'root.*pacman' | egrep '(-S|y)') ]]; do
		
		local _pid=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
		local _char="${array_time_chars[$num_char]}"

		if [[ -z "$_pid" ]]; then
			break
		else
			#echo -ne "Aguardando processo pacman -S finalizar pid [$_pid] ${Red}[$_char]${Reset}\r"
			echo -ne "Aguardando processo pacman -S finalizar pid [$_pid] [${_char}]\r"
			sleep 0.3
		fi

		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'

	done	
	echo -e "Aguardando processo pacman -S finalizar pid [$_pid] [${_char}]"
	echo "Finalizado"
}

_BROKE()
{
	# Função para remover pacotes quebrados em sistemas debian.
	if [[ ! -x $(command -v apt 2> /dev/null) ]]; then
		yellow "Esta opção só está disponivel para sistemas baseados em Debian"
		return 0
	fi

	echo -e "$space_line"
	msg "Executando [apt-get clean; apt-get remove -y; apt-get autoremove -y]"
	if ! sudo sh -c 'apt-get clean; apt-get remove -y; apt-get autoremove -y'; then
		red "Falha: apt-get clean; apt-get remove -y; apt-get autoremove -y"
	fi

	echo -e "$space_line"
	msg "Executando [apt install -f -y; dpkg --configure -a]"
	if ! sudo sh -c 'apt install -f -y; dpkg --configure -a'; then
		red "Falha: apt install -f -y; dpkg --configure -a"
	fi

	echo -e "$space_line"
	msg "Executando [apt --fix-broken install]"
	if ! sudo sh -c 'apt --fix-broken install'; then
		red "Falha: apt --fix-broken install"
	fi

	echo -e "$space_line"
	msg "Executando [apt update]"
	sudo apt update
	msg "OK"
	# sudo apt install --yes --force-yes -f 
}

_APT()
{
	[[ $(ps aux | grep 'root.*apt' | egrep '(install|upgrade)') ]] && _apt_process_look

	if sudo apt "$@"; then
		return 0
	else
		red "Gerenciador de pacotes [apt] retornou erro"
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
		red "Gerenciador de pacotes [dnf] retornou erro"
		return 1
	fi
}

_PACMAN()
{
	[[ $(ps aux | grep 'root.*pacman' | egrep '(-S|y)') ]] && _pacman_process_look

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
	if sudo pkg "$@"; then
		return 0
	else
		red "Gerenciador de pacotes [pkg] retornou erro"
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
	elif [[ "$install_yes" == 'True' ]]; then
		_INFO 'pkg_not_found' "$@"
		return 1
	fi
	
	#---------------------------------------------------------#
	# Instalação normal.
	#---------------------------------------------------------#
	if [[ -f '/etc/debian_version' ]]; then # Debia/apt
		if _APT install "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$os_id" == 'fedora' ]]; then # Fedora/dnf
		if _DNF install "$@"; then
			return 0
		else
			return 1
		fi
	elif [[ "$os_id" == 'arch' ]]; then # ArchLinux/pacman
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
	elif [[ -x $(which pkg 2> /dev/null) ]]; then # FreeBSD/pkg
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


