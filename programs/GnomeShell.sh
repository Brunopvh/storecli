#!/usr/bin/env bash
#
# 
# Este módulo serve para auxiliar o script storecli a instalar
# algumas exentenções uteis para o gnome-shell.
#

function _gnome_shell()
{
	# Fedora
	local array_gnome_shell_fedora=(
	'gnome-tweaks' 
	'gnome-shell-extension-topicons-plus'
	'gnome-shell-extension-drive-menu' 
	'gnome-shell-extension-dash-to-dock.noarch'
	'gnome-backgrounds-extras'
	'verne-backgrounds-gnome'
	)

	# OpenSuxe
	local array_gnome_shell_suse=(
	'gnome-tweaks' 
	)

	# ArchLinux
	local array_gnome_shell_arclinux=(
	'gnome-tweaks' 
	'gnome-backgrounds'
	)

	# Debian
	local array_gnome_shell_debian=(
	'gnome-tweaks' 
	'gnome-shell-extension-top-icons-plus' 
	'gnome-shell-extension-dashtodock'
	)

	#----------------------------------------------------#
	# Verifcar qual o gerenciador de pacotes da distro e instalar pacotes 
	# e extenções do gnome-shell.
	#----------------------------------------------------#
	
	if _WHICH "dnf"; then            # RedHat
		for c in "${array_gnome_shell_fedora[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			package_man_cli "$c"
		done

	elif _WHICH "zypper"; then       # Suse
		for c in "${array_gnome_shell_suse[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			package_man_cli "$c" || {
				_red "[!] Falha $c"
			}
		done

	elif _WHICH "pacman"; then       # ArchLinux
		for c in "${array_gnome_shell_arclinux[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			package_man_cli "$c"
		done

	elif _WHICH "apt"; then          # Debian
		for c in "${array_gnome_shell_debian[@]}"; do
			echo -e "$space_line"
			_white "Instalando: $c"
			package_man_cli "$c"
		done

	else
		msg "Falha"
		exit 1
		break
	fi

}
