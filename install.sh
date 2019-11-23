#!/bin/sh
#
#
#


_c()
{
	[ -z $1 ] && { printf "\033[m"; return 0; }
	[ -z $2 ] && { printf "\033[1;${1}m"; return 0; }
	[ ! -z $2 ] && { printf "\033[${2};${1}m"; return 0; }
}

#---------------------------------------------------#
_msgs()
{
	echo "==> $@"
}

#---------------------------------------------------#
# Remove
#---------------------------------------------------#

_uninstall_user()
{
	[ -d ~/'.local/bin/storecli-amd64' ] && {
		echo "$(_c 31)$(_msgs Desinstalando: ~/'.local/bin/storecli-amd64') $(_c)"
		rm -rf ~/'.local/bin/storecli-amd64'
	}
	rm ~/'.local/bin/storecli' 2> /dev/null
}

#---------------------------------------------------#

_uninstall_root()
{
	[ -d '/opt/storecli-amd64' ] && {
		echo "$(_c 31)$(_msgs Desinstalando: /opt/storecli-amd64) $(_c)"
		sudo rm -rf '/opt/storecli-amd64'
		sudo rm '/usr/local/bin/storecli' 2> /dev/null
	}

	[ -L '/usr/local/bin/storecli' ] && sudo rm '/usr/local/bin/storecli'
	command -v storecli 2> /dev/null && sudo rm $(command -v storecli 2> /dev/null)
}

#---------------------------------------------------#
# Install
#---------------------------------------------------#
_install_user()
{
	echo "$(_c 32 0)$(_msgs Instalando: ~/'.local/bin/storecli-amd64') $(_c)"
	mkdir -p ~/'.local/bin'
	mv "/tmp/up_$USER/storecli" ~/'.local/bin/storecli-amd64'
	chmod -R u+x ~/'.local/bin/storecli-amd64'
	ln -sf ~/'.local/bin/storecli-amd64/storecli.sh' ~/'.local/bin/storecli'
}

#---------------------------------------------------#

_install_root()
{
	echo "$(_c 32 0)$(_msgs Instalando: /opt/storecli-amd64) $(_c)"
	sudo mkdir -p /opt
	mv "/tmp/up_$USER/storecli" '/opt/storecli-amd64'
	ln -sf '/opt/storecli-amd64/storecli.sh' '/usr/local/bin/storecli'
	sudo chmod -R a+x '/opt/storecli-amd64'
	sudo chmod a+x '/usr/local/bin/storecli'
}

#---------------------------------------------------#

_git_clone()
{
	repo='https://github.com/Brunopvh/storecli.git'
	mkdir -p "/tmp/up_$USER"
	cd "/tmp/up_$USER" && rm -rf * 2> /dev/null

	if git clone "$repo"; then
		return 0
	else
		return 1
	fi
}

#---------------------------------------------------#

_path_zsh()
{
	command -v zsh 2> /dev/null || return 0
	if ! grep "^export PATH=$HOME./local/bin.*" ~/'.zshrc'; then
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
	fi

	zsh ~/'.zshrc'
}

#---------------------------------------------------#

_path_bash()
{
	if ! grep "^export PATH=$HOME./local/bin.*" ~/'.bashrc'; then
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
	fi

	bash ~/'.bashrc'
}

#---------------------------------------------------#
command -v bash 2> /dev/null || { echo "$(_c 31)Erro instale o shell [bash] $(_c)"; exit 1; }

_git_clone || { echo "$(_c 31)$(_msgs Falha: função _git_clone retornou erro) $(_c)"; exit 1; }
_uninstall_user
_uninstall_root

if [ $(id -u) -eq '0' ]; then
	_install_root

else
	_install_user

	_path_bash || { 
		echo "$(_c 31)$(_msgs Erro escreva a linha a seguir no arquivo ~/.bashrc manualmente:) $(_c)"; 
		echo "export PATH=$HOME/.local/bin:$PATH"
		exit 1
		}

	_path_zsh || { 
		echo "$(_c 31)$(_msgs Erro escreva a linha a seguir no arquivo ~/.zshrc manualmente:) $(_c)"; 
		echo "export PATH=$HOME/.local/bin:$PATH"
		exit 1
		}
fi


exit "$?"
