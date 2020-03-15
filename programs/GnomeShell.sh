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

	# Fedora
	local array_gnome_shell_fedora=(
	'gnome-tweaks' 'gnome-shell-extension-topicons-plus'
	'gnome-shell-extension-drive-menu' 'gnome-backgrounds-extras'
	'verne-backgrounds-gnome'
	)

	# ArchLinux
	local array_gnome_shell_arclinux=(
	'gnome-tweaks' 'gnome-backgrounds'
	)

	#----------------------------------------------------#
	# Verifcar qual o gerenciador de pacotes da distro e instalar pacotes 
	# e extenções do gnome-shell.
	#----------------------------------------------------#
	
	if _WHICH "dnf"; then            # RedHat
		for c in "${array_gnome_shell_fedora[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			sudo dnf install -y "$c"
		done

	elif _WHICH "zypper"; then       # Suse
		for c in "${array_gnome_shell_fedora[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			sudo zypper install -y "$c"
		done

	elif _WHICH "pacman"; then       # ArchLinux
		for c in "${array_gnome_shell_arclinux[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			sudo pacman -S "$c"
		done

	elif _WHICH "apt"; then          # Debian
		for c in "${array_gnome_shell_debian[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			sudo apt install -y "$c"
		done

	else
		msg "Falha"
		exit 1
		break
	fi

}