#!/usr/bin/env bash
#
# Este script serve para inserir os diretórios que contém binário na
# HOME('~/bin' e '~/.local/bin') na variável PATH do usuario atual.
# 
# 
VERSION='2020-03-06'
#

Script=$(basename $(readlink -f "$0")) # Somente o nome deste arquivo.

function usage()
{
	echo -e "Use: ./$Script"
}

# Não é nescessário arguementos.
if [[ "${#@}" -ge '1' ]]; then # Maior ou igual a 1.
	usage
	exit 1
fi

# Criar o diretório ~/.local/bin se não existir
if ! [[ -d "$HOME/.local/bin" ]]; then
	mkdir "$HOME/.local/bin"
fi

# Inserir o diretório ~/.local/bin em PATH se não existir.
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
	echo -e "Inserindo [$HOME/.local/bin] na variável PATH de [$USER]"
	PATH="$HOME/.local/bin:$PATH"
fi

function Config_bash()
{
	# Criar o arquivo ~/.bashrc se não existir
	if [[ ! -f "$HOME/.bashrc" ]]; then
		echo ' ' >> "$HOME/.bashrc"
	fi

	# Configurar o arquivo ~/.bashrc
	if ! grep -q "^export.*$HOME/.local/bin.*" "$HOME/.bashrc"; then
		echo "Adicionando [$HOME/.local/bin] em PATH [$HOME/.bashrc]"
		echo -e "export PATH=$HOME/.local/bin:$PATH" >> "$HOME/.bashrc"
	fi

	bash -c ". $HOME/.bashrc"
}

function Config_zsh()
{

	# zshell não instalado.
	Zshell=$(command -v zsh 2> /dev/null)
	if [[ ! -x "$Zshell" ]]; then
		return 0
	fi

	# Criar o arquivo ~/.zshrc se não existir
	if [[ ! -f "$HOME/.zshrc" ]]; then
		echo ' ' >> "$HOME/.zshrc"
	fi

	# Configurar o arquivo ~/.zshrc
	if ! grep -q "^export.*$HOME/.local/bin.*" "$HOME/.zshrc"; then
		echo "Adicionando [$HOME/.local/bin] em PATH [$HOME/.zshrc]"
		echo -e "export PATH=$HOME/.local/bin:$PATH" >> "$HOME/.zshrc"
	fi

	zsh -c ". ~/.zshrc"
}

function main(){
	Config_bash || return 1
	Config_zsh || return 1
}

main || {
	echo "[!] Falha"
	exit 1
}

exit 0