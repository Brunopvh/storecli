#!/usr/bin/env bash
#
# 
# Este módulo serve para auxiliar o script storecli a instalar
# algumas exentenções uteis para o gnome-shell.
#

source "$Lib_Arrays"

function _topicons_plus_github()
{
	# https://github.com/phocean/TopIcons-plus/archive/master.zip
	# https://github.com/phocean/TopIcons-plus/archive/master.tar.gz
	# https://github.com/phocean/TopIcons-plus

	local url='https://github.com/phocean/TopIcons-plus/archive/master.tar.gz'
	local path_file="$Dir_Downloads/topicons_plus.tar.gz"

	_dow "$url" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	_unpack "$path_file" || return 1

	_package_man_distro make

	mv $(ls -d Top*) "$Dir_Unpack"/topicons_plus
	cd "$Dir_Unpack"/topicons_plus
	echo -e "$space_line"
	# make install
	sudo make install INSTALL_PATH=/usr/share/gnome-shell/extensions

}


function _gnome_shell_extensions()
{
	# Sessão desktop do usuário
	user_session_desktop=$(set | grep '^XDG_SESSION_DESKTOP' | sed 's|.*=||g')


	#----------------------------------------------------#
	# Verifcar qual o gerenciador de pacotes da distro e instalar pacotes 
	# e extenções do gnome-shell.
	#----------------------------------------------------#
	
	if _WHICH "dnf"; then            # RedHat
		for c in "${array_gnome_shell_fedora[@]}"; do
			echo -e "$space_line"
			msg "Instalando: $c"
			_package_man_distro "$c"
		done

	elif _WHICH "zypper"; then       # Suse
		for c in "${array_gnome_shell_suse[@]}"; do
			echo -e "$space_line"
			msg "Instalando: $c"
			_package_man_distro "$c" 
		done

	elif _WHICH "pacman"; then       # ArchLinux
		for c in "${array_gnome_shell_archlinux[@]}"; do
			echo -e "$space_line"
			msg "Instalando: $c"
			_package_man_distro "$c"
		done

	elif _WHICH "apt"; then          # Debian
		for c in "${array_gnome_shell_debian[@]}"; do
			echo -e "$space_line"
			msg "Instalando: $c"
			_package_man_distro "$c"
		done

	else
		red "Falha"
		return 1
	fi

}
