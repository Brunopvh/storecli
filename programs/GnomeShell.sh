#!/usr/bin/env bash
#
# 
# Este módulo serve para auxiliar o script storecli a instalar
# algumas exentenções uteis para o gnome-shell.


function _gnome_shell()
{
	if ! printenv | grep -q ^"DESKTOP_SESSION=gnome"; then
		_red "Você não está em sessão gnome-shell" 
		return 1
	fi

	#----------------------------------------------------#
	# Verifcar qual o gerenciador de pacotes da distro e instalar pacotes 
	# e extenções do gnome-shell.
	#----------------------------------------------------#
	echo -e "$space_line"
	_white "Instalando os pacotes: ${array_gnome_shell[@]}"

	for c in "${array_gnome_shell[@]}"; do

		echo -e "$space_line"
		_white "Instalando: [$c]"

		if _WHICH "dnf"; then            # RedHat
			sudo dnf install -y "$c"

		elif _WHICH "zypper"; then       # Suse
			sudo zypper install -y "$c"

		elif _WHICH "pacman"; then       # ArchLinux
			sudo pacman -S "$c"

		elif _WHICH "apt"; then          # Debian
			sudo apt install -y "$c"

		else
			msg "Falha"
			exit 1
			break
		fi
	done
}