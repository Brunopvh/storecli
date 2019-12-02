#!/usr/bin/env bash
#
#
#

source "$Lib_platform"
source "$Lib_array"

function _c()
{
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

#===============================================#
# Install cli debian
#===============================================#
function _install_cli_debian()
{
echo "$(_c 32)==> $(_c)Instalando: ${array_cli_requeriments[@]} ${array_cli_debian[@]}"
sudo apt install -y "${array_cli_requeriments[@]}" "${array_cli_debian[@]}"

if [[ $? == '0' ]]; then 
	return 0

else
	# Error apt install
	echo "==> O gerenciador de pacotes $(_c 31)apt $(_c) retornou [erro]"
	return 1
fi
}

#===============================================#
# Install cli ubuntu
#===============================================#
function _install_cli_ubuntu()
{
echo "==> Instalando dependências"
sudo apt install -y 'git' 'curl' 'wget' 'xterm' 'gawk' 'unzip' 'python3' 'python'
sudo apt install -y "${array_cli_debian[@]}"

if [[ $? == '0' ]]; then 
	return 0

else
	# Error apt install
	echo "==> O gerenciador de pacotes $(_c 31)apt $(_c) retornou [erro]"
	return 1
fi
}

#===============================================#
# Install cli suse
#===============================================#
function _install_cli_suse()
{
echo "$(_c 32)==> $(_c)Instalando: ${array_cli_requeriments[@]}"
sudo zypper in "${array_cli_requeriments[@]}"

if [[ $? == '0' ]]; then 
	return 0

else
	# Error zypper install
	echo "==> O gerenciador de pacotes $(_c 31)zypper $(_c) retornou [erro]"
	return 1
fi
}

#===============================================#
# Install cli suse
#===============================================#
function _install_cli_fedora()
{
	echo "$(_c 32 0)Instalando: ${array_cli_requeriments[@]} $(_c)"
	sudo dnf install "${array_cli_requeriments[@]}"

	if [[ $? == '0' ]]; then
		return 0

	else
		echo "$(_c 31)O gerenciador de pacotes dnf retornou erro $(_c)"
		return 1

	fi
}


#===============================================#
# Install cli freebsd
#===============================================#
function _install_cli_freebsd()
{
echo "$(_c 32)==> $(_c)Instalando: ${array_cli_freebsd[@]} ${_python_requeriments_freebsd[@]}"
sudo pkg install -y "${array_cli_freebsd[@]}"

if [[ "$?" == '0' ]]; then
	return 0

else
	# Error pkg install
	echo "==> O gerenciador de pacotes $(_c 31)pkg $(_c) retornou [erro]"
	return 1

fi
}


#===============================================#
# Install python requeriments debian
#===============================================#
function _python_requeriments_debian()
{
	echo "$(_c 32)==> Instalando python requeriments $(_c)"
	sudo apt install -y 'python3' 'python' 'python3-pip' 'python-pip' 'python3-setuptools' 'python-setuptools'
	[[ "$?" == '0' ]] || { echo "$(_c 31)Função _python_requeriments_debian retornou erro"; return 1; }
}

#===============================================#
# Install python requeriments linux
#===============================================#
function _python_requeriments_linux()
{
echo "$(_c 32)==> $(_c)Instalando: ${array_python_linux[@]}"

if [[ -x $(which zypper 2> /dev/null) ]]; then # OpenSuse
	sudo zypper in "${array_python_linux[@]}"
	[[ $? == '0' ]] || { return 1; }

elif [[ -x $(which dnf 2> /dev/null) ]]; then # Fedora
	sudo dnf install -y "${array_python_linux[@]}"
	[[ $? == '0' ]] || { return 1; }

else
	echo "$(_c 31)==> $(_c)[Erro] seu sistema não e suportado."
	return 1

fi

pip3 install wget bash --user
[[ $? == '0' ]] || { return 1; }
}


#===============================================#
# Install python requeriments freebsd
#===============================================#
function _python_requeriments_freebsd()
{
echo "$(_c 32)==> $(_c)Instalando: ${array_python_freebsd[@]}"

if [[ -x $(which pkg 2> /dev/null) ]]; then
	sudo pkg install -y "${array_python_freebsd[@]}"
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
	echo "$(_c 31)Sistema não suportado $(_c)"; return 1
fi


if [[ $? == '0' ]]; then
	echo "==> [OK] função $(_c 32)_install_requeriments $(_c)foi executada com sucesso"
	#echo 'requeriments false' > "$Config_File"
	return 0

else
	echo "==> Função $(_c 31)_install_requeriments $(_c)retornou [erro]" 
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

else
	echo "$(_c 31)Sistema não suportado $(_c)"; return 1

fi


if [[ $? == '0' ]]; then
	echo "$(_c 32 0)==> função_python_requeriments foi executada com sucesso $(_c)"
	echo 'requeriments false' > "$Config_File"
	return 0

else
	echo "$(_c 31)==> Função_python_requeriments retornou [erro] $(_c)" 
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

		else
			echo -ne " \r" # Encontrado, echoar nada.
		
		fi
	done
}


#---------------------------------------------------#

# ~/.bashrc
function _conf_path_bash()
{
	! grep -q "^export.*$HOME/.local/bin.*" ~/.bashrc && {
		echo "==> Adicionando: ~/.local/bin em PATH [~/.bashrc]"
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
	
	bash ~/'.bashrc'
	}
}

#---------------------------------------------------#

# ~/.zshrc
function _conf_path_zsh()
{
	command -v zsh 2> /dev/null || return 0
	
	! grep -q "^export.*$HOME/.local/bin.*" ~/.zshrc && {
		echo "==> Adicionando: ~/.local/bin em PATH [~/.zshrc]"
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
	
	zsh ~/'.zshrc'
	}
}
