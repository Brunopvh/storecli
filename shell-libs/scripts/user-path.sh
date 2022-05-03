#!/usr/bin/env bash
#
# DEPENDÊNCIAS:
#   + touch
#

readonly __user_dir_bin=~/.local/bin


function _config_file_bashrc()
{
	[[ $(id -u) == 0 ]] && return
    [[ -z $HOME ]] && HOME=~/

	touch ~/.bashrc
	
	# Se a linha de configuração já existir, encerrar a função aqui.
	grep "$HOME/.local/bin" ~/.bashrc 1> /dev/null && return 0
	[[ ! -f ~/.bashrc.bak ]] && cp ~/.bashrc ~/.bashrc.bak 1> /dev/null

	echo -e "Configurando o arquivo ... ~/.bashrc"
	sed -i "/^export.*PATH=.*:/d" ~/.bashrc
	echo "export PATH=$PATH" >> ~/.bashrc
	echo "Execute ... source ~/.bashrc OU reinicie o shell"
	sleep 0.5
}

function _config_file_zshrc()
{
	[[ $(id -u) == 0 ]] && return
	[[ ! -x $(command -v zsh) ]] && return 0
    [[ -z $HOME ]] && HOME=~/

	touch ~/.zshrc
	
	# Se a linha de configuração já existir, encerrar a função aqui.
	grep "$HOME/.local/bin" ~/.zshrc 1> /dev/null && return 0
	[[ ! -f ~/.zshrc.bak ]] && cp ~/.zshrc ~/.zshrc.bak 1> /dev/null

	echo "Configurando o arquivo ... ~/.zshrc"
	sed -i "/^export.*PATH=.*:/d" ~/.zshrc
	echo "export PATH=$PATH" >> ~/.zshrc
	echo "Execute ... source ~/.zshrc OU reinicie o shell"
	sleep 0.5
}


function addZshPath(){
    _config_file_zshrc
}


function addBashPath(){
    _config_file_bashrc
}


function addUserPath(){
    [[ $(id --user) == 0 ]] && return

    [[ -x $(command -v bash) ]] && addBashPath
    [[ -x $(command -v zsh) ]] && addZshPath
}



addUserPath
