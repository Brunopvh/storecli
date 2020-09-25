#!/bin/sh
#
# Este script serve para inserir os diretórios que contém binário na
# HOME('~/bin' e '~/.local/bin') na variável PATH do usuario atual.
#
VERSION='2020-08-16'
#

# NÃO pode ser root.
[ $(id -u) -eq 0 ] && {
	echo "\033[1;31mVocê NÃO pode ser o [root] para executar esse programa\033[m"
	exit 1
}

KERNEL_TYPE=$(uname -s)

if [ "$KERNEL_TYPE" = 'FreeBSD' ]; then
	bash_config="/usr/$HOME/.bashrc"
	zsh_config="/usr/$HOME/.zshrc"
elif [ "$KERNEL_TYPE" = 'Linux' ]; then
	bash_config="$HOME/.bashrc"
	zsh_config="$HOME/.bashrc"
fi

touch "$bash_config"

# Inserir ~/.local/bin em PATH.
echo "$PATH" | grep -q "$HOME/.local/bin" || {
	PATH="$HOME/.local/bin:$PATH"
}


path_bash()
{
	# Criar o arquivo ~/.bashrc se não existir
	if [ ! -f "$bash_config" ]; then
		echo ' ' >> "$bash_config"
	fi

	# Se a linha de configuração já existir, encerrar a função aqui.
	grep "$HOME/.local/bin" "$bash_config" 1> /dev/null && return 0

	# Continuar
	echo "Configurando o arquivo [$bash_config]"
	echo "export PATH=$PATH" >> "$bash_config"
	bash "source $bash_config"
}

path_zsh()
{
	# Criar o arquivo ~/.zshrc se não existir
	if [ ! -f "$zsh_config" ]; then
		echo ' ' >> "$zsh_config"
	fi

	# Se a linha de configuração já existir, encerrar a função aqui.
	grep "$HOME/.local/bin" "$zsh_config" 1> /dev/null && return 0

	# Continuar
	echo "Configurando o arquivo [$zsh_config]"
	echo "export PATH=$PATH" >> "$zsh_config"
}

main()
{

	path_bash
	path_zsh

	Bash_Shell=$(command -v bash)
	Zsh_Shell=$(command -v zsh)
}

main

