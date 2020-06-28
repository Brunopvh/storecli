#!/usr/bin/env bash
#

#=============================================================#
# Diretórios do usuário
#=============================================================#
directoryUSERbin="$HOME/.local/bin"
directoryUSERicon="$HOME/.local/share/icons"
directoryUSERthemes="$HOME/.themes"
directoryUSERapplications="$HOME/.local/share/applications"
directoryUSERconfig="$HOME/.config/storecli"

mkdir -p "$directoryUSERbin"
mkdir -p "$directoryUSERicon"
mkdir -p "$directoryUSERthemes"
mkdir -p "$directoryUSERapplications"
mkdir -p "$directoryUSERconfig"

#=============================================================#
# Diretórios do root
#=============================================================#
directoryROOTbin='/usr/local/bin'
directoryROOTicon='/usr/share/icons/hicolor'
directoryROOTthemes='/usr/share/themes/'
directoryROOTapplications='/usr/share/applications'

if [[ ! -d "$directoryROOTbin" ]]; then
	_green "Criando o diretório: $directoryROOTbin"
	sudo mkdir "$directoryROOTbin"
fi


if [[ ! -d "$directoryROOTicon" ]]; then
	_green "Criando o diretório: $directoryROOTicon"
	sudo mkdir "$directoryROOTicon"
fi


if [[ ! -d "$directoryROOTthemes" ]]; then
	_green "Criando o diretório: $directoryROOTthemes"
	sudo mkdir "$directoryROOTthemes"
fi


if [[ ! -d "$directoryROOTapplications" ]]; then
	_green "Criando o diretório: $directoryROOTapplications"
	sudo mkdir "$directoryROOTapplications"
fi

