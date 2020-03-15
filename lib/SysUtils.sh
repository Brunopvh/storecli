#!/usr/bin/env bash
#
#
#

source "$Lib_platform"
source "$Lib_array"

#==================================================#
# cli requeriments.
#==================================================#
# Unix.
array_cli_requeriments=(
'sudo' 'git' 'curl' 'wget' 'xterm' 'gawk' 'xterm' 'unzip' 'python3' 'python2'
)

# FreeBSD
array_cli_freebsd=(
'git' 'curl' 'wget' 'xterm' 'gawk' 'unzip'
)

# Python Linux
array_python_linux=( 
'python3' 'python2' 'python3-pip' 'python-pip' 'python3-setuptools' 'python-setuptools'
)

# Python FreeBSD
array_python_freebsd=(
'python3' 'python36' 'py36-pip-19.1.1' 'py27-pip-19.1.1' 
'py36-pip-tools-4.1.0' 'py27-pip-tools-4.1.0'
)

# Debian Cli
array_cli_debian=(
'aptitude' 'gdebi' 'dirmngr'  'apt-transport-https' 'gnupg' 'gpgv2' 'gpgv' 'xz-utils'
)

# Ubuntu Cli
array_cli_ubuntu=(
'git' 'curl' 'wget' 'xterm' 'gawk' 'unzip' 'python3' 'python'
)

#===============================================#
# Install cli debian
#===============================================#
function _install_cli_debian()
{
	_msg "Instalando: ${array_cli_requeriments[@]} ${array_cli_debian[@]}"
	sudo apt install -y "${array_cli_requeriments[@]}" "${array_cli_debian[@]}"

	if [[ $? == '0' ]]; then 
		return 0

	else
		# Error apt install
		_msg "O gerenciador de pacotes $(_c 31)apt $(_c) retornou erro."
		return 1
	fi
}

#===============================================#
# Install cli ubuntu
#===============================================#
function _install_cli_ubuntu()
{
	_msg "Instalando: ${array_cli_debian[@]} ${array_cli_ubuntu[@]}"
	sudo apt install -y "${array_cli_debian[@]}" "${array_cli_ubuntu[@]}"

	if [[ $? == '0' ]]; then 
		return 0
	else
		# Error apt install
		_msg "O gerenciador de pacotes $(_c 31)apt $(_c) retornou erro."
		return 1
	fi
}

#===============================================#
# Install cli suse
#===============================================#
function _install_cli_suse()
{
	_msg "Instalando: ${array_cli_requeriments[@]}"
	sudo zypper in "${array_cli_requeriments[@]}"

	if [[ $? == '0' ]]; then 
		return 0
	else
		# Error zypper install
		_msg "O gerenciador de pacotes $(_c 31)zypper $(_c) retornou [erro]"
		return 1
	fi
}

#===============================================#
# Install cli fedora
#===============================================#
function _install_cli_fedora()
{
	_green "Instalando: ${array_cli_requeriments[@]}"
	sudo dnf install "${array_cli_requeriments[@]}"

	if [[ $? == '0' ]]; then
		return 0
	else
		_red "O gerenciador de pacotes dnf retornou erro"
		return 1
	fi
}

#===============================================#
# Install cli arch
#===============================================#
function _install_cli_arch()
{
	_msg "Instalando: ${array_cli_requeriments[@]}"
	sudo pacman -S "${array_cli_requeriments[@]}" || { 
		_red "O gerenciador de pacotes pacman retornou erro"
		return 1
	}

	echo "$(_c 32)$space_line"
	read -p "Adicionar suporte ao sistema de arquivos $(_c 32)ntfs$(_c) [s/n]?: " sn
	
	if [[ "${sn,,}" == 's' ]]; then
		sudo pacman -S ntfs-3g 
		sudo modprobe fuse
	else
		_white "Abortando"
	fi
	
	"$Script_AddRepo" --arch-repos

	_msg "Instalando: binutils"
	sudo pacman -S binutils

	_msg "Instalando: base-devel"
	sudo pacman -S base-devel

}

#===============================================#
# Install cli freebsd
#===============================================#
function _install_cli_freebsd()
{
	_msg "Instalando: ${array_cli_freebsd[@]} ${_python_requeriments_freebsd[@]}"
	sudo pkg install -y "${array_cli_freebsd[@]}"

	if [[ "$?" == '0' ]]; then
		return 0
	else
		# Error pkg install
		_msg "O gerenciador de pacotes $(_c 31)pkg $(_c) retornou erro."
		return 1
	fi
}


#===============================================#
# Install python requeriments debian/Ubuntu
#===============================================#
function _python_requeriments_debian()
{
	_green "Instalando python requeriments"
	sudo apt install -y 'python3' 'python' 'python3-pip' 'python-pip' 'python3-setuptools' 'python-setuptools'
	[[ "$?" == '0' ]] || { 
		_red "Função [_python_requeriments_debian] retornou erro"
		return 1 
	}

	pip3 install wheel --user || return 1 
	pip3 install wget --user || return 1
}

#===============================================#
# Install python requeriments ArchLinux
#===============================================#
function _python_requeriments_arch()
{
	sudo pacman -S 'python3' 'python2' 'python-pip' 'python-setuptools'
	pip install wget --user
	pip install wheel --user
}

#===============================================#
# Install python requeriments linux, Suse/Fedora
#===============================================#
function _python_requeriments_linux()
{
	_green "Instalando: ${array_python_linux[@]}"

	if [[ -x $(which zypper 2> /dev/null) ]]; then # OpenSuse
		sudo zypper in "${array_python_linux[@]}"
		[[ $? == '0' ]] || { return 1; }

	elif [[ -x $(which dnf 2> /dev/null) ]]; then # Fedora
		sudo dnf install -y "${array_python_linux[@]}"
		[[ $? == '0' ]] || { return 1; }

	elif [[ -x $(which pacman 2> /dev/null) ]]; then # ArchLinux
		_python_requeriments_arch || return 1

	else
		_red "Erro seu sistema não e suportado."
		return 1

	fi

		# Se a instalação dos pacotes que estão no "array_python_linux" for concluida com sucesso, então
		# o script irá prosseguir para as linhas de código abaixo.
		
		# python3 -m pip install -U pylint --user
		pip3 install wheel --user || return 1
		pip3 install wget --user || return 1
		if [[ $? == '0' ]]; then
			return 0
		else
			return 1
		fi
}


#===============================================#
# Install python requeriments freebsd
#===============================================#
function _python_requeriments_freebsd()
{
	_msg "Instalando: ${array_python_freebsd[@]}"

	if [[ -x $(which pkg 2> /dev/null) ]]; then
		sudo pkg install -y "${array_python_freebsd[@]}"
	else
		return 1
	fi

	pip-3.6 install wget bash --user || { return 1; }
}

#===============================================#
#===============================================#
# Configure/Install requeriments
#===============================================#
#===============================================#

function _install_requeriments()
{
	if [[ "$os_id" == 'debian' ]]; then 
		 _install_cli_debian 

	elif [[ "$os_id" == "linuxmint"  ]] || [[  "$os_id" == 'ubuntu' ]]; then
		_install_cli_ubuntu

	elif [[ "$sysname" == 'freebsd12.0-release' ]]; then
		_install_cli_freebsd
		
	elif [[ "$sysname" == 'opensuse-tumbleweed' ]]; then
		_install_cli_suse

	elif [[ "$sysname" == 'fedora31' ]]; then
		_install_cli_fedora

	elif [[ "$sysname" == 'arch' ]]; then # ArchLinux
		_install_cli_arch

	else
		_red "Sistema não suportado [$sysname]"; return 1
	fi


	if [[ $? == '0' ]]; then
		_msg "Função $(_c 32)[_install_requeriments] $(_c)foi executada com sucesso."
		return 0
	else
		_red "Função [_install_requeriments] retornou erro." 
		return 1
	fi
}

#===============================================#
#===============================================#
# Configure/Install python requeriments
#===============================================#
#===============================================#

function _python_requeriments()
{
	if [[ "$os_id" == 'debian' ]] || [[ "$os_id" == 'linuxmint' ]] || [[ "$os_id" == 'ubuntu' ]]; then
		 _python_requeriments_debian

	elif [[ "$sysname" == 'freebsd12.0-release' ]]; then
		_python_requeriments_freebsd
		
	elif [[ "$sysname" == 'opensuse-tumbleweed' ]]; then
		_python_requeriments_linux

	elif [[ "$sysname" == 'fedora31' ]]; then
		_python_requeriments_linux

	elif [[ "$sysname" == 'arch' ]]; then # ArchLinux
		_python_requeriments_linux

	else
		_red "Sistema não suportado"; return 1

	fi


	if [[ $? == '0' ]]; then
		_green "Função [_python_requeriments] foi executada com sucesso"
		echo 'requeriments false' > "$Config_File"
		return 0
	else
		_red "Função [_python_requeriments] retornou erro." 
		return 1
	fi
}

#===============================================#
# Config dirs
#===============================================#
function _create_dirs_user()
{
	# Create dirs
	mkdir -p "${array_user_dirs[@]}"

	for i in "${array_user_dirs[@]}"; do	
		if [[ ! -d "$i" ]]; then 
			echo "$i"; return 1 # Não encontrado sair.
		fi
	done
}

