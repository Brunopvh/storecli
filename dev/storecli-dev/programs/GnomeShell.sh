#!/usr/bin/env bash
#
# 
# Este módulo serve para auxiliar o script storecli a instalar
# algumas exentenções uteis para o gnome-shell.
#

_dashtodock_github()
{
	# https://micheleg.github.io/dash-to-dock/download.html
	#

	local url='https://github.com/micheleg/dash-to-dock/archive/master.tar.gz'
	local url_repo='https://github.com/micheleg/dash-to-dock.git'
	local path_file="$Dir_Downloads/dash_to_dock.tar.gz"

	_gitclone "$url_repo" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0 

	# Instalar o pacote make
	_pkg_manager_sys make

	cd "$DirTemp"/dash-to-dock
	make
	make install
	#sudo make install 

	if _YESNO "Deseja abrir a jenela de configuração gnome-shell-extension-prefs"; then
		# gnome-shell-extension-prefs dash-to-dock@micxgx.gmail.com
		gnome-shell-extension-prefs
	fi

}

_dashtodock()
{
	case "$os_id" in
		fedora) _pkg_manager_sys 'gnome-shell-extension-dash-to-dock.noarch';;
		debian) _pkg_manager_sys 'gnome-shell-extension-dashtodock';;
		*) _dashtodock_github;;
	esac
}

#=============================================================#
# Drive Menu
#=============================================================#
_drive_menu()
{
	case "$os_id" in
		fedora) _pkg_manager_sys 'gnome-shell-extension-drive-menu';;
		*) _show_info 'ProgramNotFound' 'drive-menu'; return 1;;
	esac
}

#=============================================================#
# Gnome Backgrounds
#=============================================================#
_gnome_backgrounds()
{
	case "$os_id" in 
		arch) _pkg_manager_sys 'gnome-backgrounds';;
		fedora) _pkg_manager_sys 'gnome-backgrounds-extras' 'verne-backgrounds-gnome';;
		*) _show_info 'ProgramNotFound' 'gnome-backgrounds'; return 1;;
	esac
}

#=============================================================#
# Top icons plus
#=============================================================#
_topicons_plus_github()
{
	# https://github.com/phocean/TopIcons-plus/archive/master.zip
	# https://github.com/phocean/TopIcons-plus/archive/master.tar.gz
	# https://github.com/phocean/TopIcons-plus

	local url='https://github.com/phocean/TopIcons-plus/archive/master.tar.gz'
	local path_file="$Dir_Downloads/topicons_plus.tar.gz"

	__download__ "$url" "$path_file" || return 1

	# Somente baixar
	if [[ "$DownloadOnly" == 'True' ]]; then
		_show_info 'DownloadOnly' "$path_file"
		return 0 
	fi

	_unpack "$path_file" || return 1
	_pkg_manager_sys make

	cd "$DirUnpack"
	mv $(ls -d Top*) "$DirUnpack"/topicons_plus
	cd topicons_plus
	
	# make install
	sudo make install INSTALL_PATH=/usr/share/gnome-shell/extensions
	echo -e "$space_line"

	if _YESNO "Deseja abrir a jenela de configuração para topicons-plus"; then
		gnome-extensions prefs TopIcons@phocean.net
	fi

}

_topicons_plus()
{
	case "$os_id" in
		fedora) _pkg_manager_sys 'gnome-shell-extension-topicons-plus';;
		debian) _pkg_manager_sys 'gnome-shell-extension-top-icons-plus';;
		*) _topicons_plus_github;;
	esac
}

#=============================================================#
# Gnome tweaks
#=============================================================#
_gnome_tweaks()
{
	_pkg_manager_sys 'gnome-tweaks'
}
