#!/usr/bin/env bash
#
#
#

source "$Lib_platform"
source "$Lib_array"

function cl() { echo -e "\033[1;${1}m"; }

#===============================================#
# Install cli debian
#===============================================#
function _install_cli_debian()
{
echo "$(cl 32)==> $(cl)Instalando: ${array_cli_requeriments[@]} ${array_cli_debian[@]}"
sudo apt install -y "${array_cli_requeriments[@]}" "${array_cli_debian[@]}"

if [[ $? == '0' ]]; then 
	_python_requeriments_linux

else
	# Error apt install
	echo "==> O gerenciador de pacotes $(cl 31)apt $(cl) retornou [erro]"
	return 1
fi

# Error _python_requeriments_linux
[[ $? == '0' ]] || { echo "$(cl 31)==> $(cl)Função $(cl 31)_python_requeriments_linux $(cl) retornou erro"; }
}

#===============================================#
# Install cli suse
#===============================================#
function _install_cli_suse()
{
echo "$(cl 32)==> $(cl)Instalando: ${array_cli_requeriments[@]}"
sudo zypper in "${array_cli_requeriments[@]}"

if [[ $? == '0' ]]; then 
	_python_requeriments_linux

else
	# Error zypper install
	echo "==> O gerenciador de pacotes $(cl 31)zypper $(cl) retornou [erro]"
	return 1
fi

# Error _python_requeriments_linux
[[ $? == '0' ]] || { echo "$(cl 31)==> $(cl)Função $(cl 31)_python_requeriments_linux $(cl) retornou erro"; }
}

#===============================================#
# Install cli freebsd
#===============================================#
function _install_cli_freebsd()
{
echo "$(cl 32)==> $(cl)Instalando: ${array_cli_freebsd[@]} ${_python_requeriments_freebsd[@]}"
sudo pkg install -y "${array_cli_freebsd[@]}"

if [[ "$?" == '0' ]]; then
	_python_requeriments_freebsd

else
	# Error pkg install
	echo "==> O gerenciador de pacotes $(cl 31)pkg $(cl) retornou [erro]"
	return 1

fi

# Error _python_requeriments_freebsd
[[ $? == '0' ]] || { echo "$(cl 31)==> $(cl)Função $(cl 31)_python_requeriments_freebsd $(cl) retornou erro"; }
}


#===============================================#
# Install python requeriments linux
#===============================================#
function _python_requeriments_linux()
{
echo "$(cl 32)==> $(cl)Instalando: ${array_python_linux[@]}"

if [[ -x $(which zypper 2> /dev/null) ]]; then # OpenSuse
	sudo zypper in "${array_python_linux[@]}"
	[[ $? == '0' ]] || { return 1; }

elif [[ -x $(which apt 2> /dev/null) ]]; then # Debian
	sudo apt install -y "${array_python_linux[@]}"
	[[ $? == '0' ]] || { return 1; }

elif [[ -x $(which dnf 2> /dev/null) ]]; then # Fedora
	sudo dnf install -y "${array_python_linux[@]}"
	[[ $? == '0' ]] || { return 1; }

else
	echo "$(cl 31)==> $(cl)[Erro] seu sistema não e suportado."
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
echo "$(cl 32)==> $(cl)Instalando: ${array_python_freebsd[@]}"

if [[ -x $(which pkg 2> /dev/null) ]]; then
	sudo pkg install -y "${array_python_freebsd[@]}"
fi

pip-3.6 install wget bash --user
[[ $? == '0' ]] || { return 1; }
}


#===============================================#
# Configure/Install requeriments
#===============================================#
function _install_requeriments()
{
if [[ "$sysname" == 'debian10' ]]; then
	 _install_cli_debian 

elif [[ "$sysname" == 'freebsd12.0-release' ]]; then
	_install_cli_freebsd
	
elif [[ "$sysname" == 'opensuse-tumbleweed' ]]; then
	_install_cli_suse

else
	return 1
fi


if [[ $? == '0' ]]; then
	echo "==> [OK] função $(cl 32)_install_requeriments $(cl)foi executada com sucesso"
	echo 'requeriments false' > "$Config_File"

else
	echo "==> Função $(cl 31)_install_requeriments $(cl)retornou [erro]" 
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


# ~/.bashrc
function _conf_path_bash()
{
if ! grep -q "^export PATH.*$HOME/.local/bin.*" ~/.bashrc; then
	echo "$(_c 32)==> Adicionando: ~/.local/bin em PATH [~/.bashrc] $(_c)"
	echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
fi
}

# ~/.zshrc
function _conf_path_zsh()
{
	[[ -x $(command -v zsh 2> /dev/null) ]] || return 0

	if ! -q grep "^export PATH.*$HOME/.local/bin.*" ~/.zshrc; then
		echo "$(_c 32)==> Adicionando: ~/.local/bin em PATH [~/.zshrc] $(_c)"
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
	fi
}
