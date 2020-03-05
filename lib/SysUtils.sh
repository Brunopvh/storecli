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
	echo "=> Instalando: ${array_cli_debian[@]} ${array_cli_ubuntu[@]}"
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
		echo "$(_c 31)O gerenciador de pacotes dnf retornou erro"
		return 1

	fi
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
	[[ "$?" == '0' ]] || { _red "Função _python_requeriments_debian retornou erro"; return 1; }
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

	else
		_red "Erro seu sistema não e suportado."
		return 1

	fi

		pip3 install wget --user
		[[ $? == '0' ]] || { return 1; }
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

		pip-3.6 install wget bash --user
		[[ $? == '0' ]] || { return 1; }
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

	else
		_red "Sistema não suportado."; return 1
	fi


if [[ $? == '0' ]]; then
	_msg "Função $(_c 32)_install_requeriments $(_c)foi executada com sucesso."
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
		 _python_requeriments_debian && pip3 install wget --user

	elif [[ "$sysname" == 'freebsd12.0-release' ]]; then
		_python_requeriments_freebsd
		
	elif [[ "$sysname" == 'opensuse-tumbleweed' ]]; then
		_python_requeriments_linux

	elif [[ "$sysname" == 'fedora31' ]]; then
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


#---------------------------------------------------#

# ~/.bashrc
function _conf_path_bash()
{
	# Encerrar a função se '~/.local/bin' já existir na variável PATH.
	if echo $PATH | grep -q "$HOME/.local/bin"; then return 0; fi

	! grep -q "^export.*$HOME/.local/bin.*" ~/.bashrc && {
		echo "=> Adicionando: ~/.local/bin em PATH [~/.bashrc]"
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
	
	bash ~/'.bashrc'
	}
}

#---------------------------------------------------#

# ~/.zshrc
function _conf_path_zsh()
{
	command -v zsh 1> /dev/null 2> /dev/null || return 0
	
	# Encerrar a função se '~/.local/bin' já existir na variável PATH.
	# if echo $PATH | grep -q "$HOME/.local/bin"; then return 0; fi 

	if grep -q "^export.*$HOME/.local/bin.*" ~/.zshrc; then return 0; fi
	
	echo "=> Adicionando: ~/.local/bin em PATH [~/.zshrc]"
	echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
	
	zsh ~/'.zshrc'

}
