#!/usr/bin/env bash
#
# 
# Este módulo serve para auxiliar o script storecli a instalar
# algumas exentenções uteis para o gnome-shell.
#

source "$Lib_Arrays"

#=============================================================#
# Dash to dock
#=============================================================#

function _dashtodock_github()
{
	# https://micheleg.github.io/dash-to-dock/download.html
	#

	local url='https://github.com/micheleg/dash-to-dock/archive/master.tar.gz'
	local url_repo='https://github.com/micheleg/dash-to-dock.git'
	local path_file="$Dir_Downloads/dash_to_dock.tar.gz"

	_gitclone "$url_repo" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi


	# Instalar o pacote make
	_package_man_distro make

	cd "$dir_temp"/dash-to-dock
	echo -e "$space_line"
	make
	make install
	#sudo make install 

	echo -e "$space_line"

	if _YESNO "Deseja abrir a jenela de configuração gnome-shell-extension-prefs"; then
		# gnome-shell-extension-prefs dash-to-dock@micxgx.gmail.com
		gnome-shell-extension-prefs
	fi

}

function _dashtodock()
{
	case "$os_id" in
		fedora) _package_man_distro 'gnome-shell-extension-dash-to-dock.noarch';;
		debian) _package_man_distro 'gnome-shell-extension-dashtodock';;
		*) _dashtodock_github;;
	esac
}

#=============================================================#
# Drive Menu
#=============================================================#
function _drive_menu()
{
	case "$os_id" in
		fedora) _package_man_distro 'gnome-shell-extension-drive-menu';;
		*) _INFO 'pkg_not_found' 'drive-menu'; return 1;;
	esac
}

#=============================================================#
# Gnome Backgrounds
#=============================================================#
function _gnome_backgrounds()
{
	case "$os_id" in 
		arch) _package_man_distro 'gnome-backgrounds';;
		fedora) _package_man_distro 'gnome-backgrounds-extras' 'verne-backgrounds-gnome';;
		*) _INFO 'pkg_not_found' 'gnome-backgrounds'; return 1;;
	esac
}

#=============================================================#
# Top icons plus
#=============================================================#
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

	cd "$Dir_Unpack"
	mv $(ls -d Top*) "$Dir_Unpack"/topicons_plus
	cd topicons_plus
	echo -e "$space_line"
	# make install
	sudo make install INSTALL_PATH=/usr/share/gnome-shell/extensions
	echo -e "$space_line"

	if _YESNO "Deseja abrir a jenela de configuração para topicons-plus"; then
		gnome-extensions prefs TopIcons@phocean.net
	fi

}

function _topicons_plus()
{
	case "$os_id" in
		fedora) _package_man_distro 'gnome-shell-extension-topicons-plus';;
		debian) _package_man_distro 'gnome-shell-extension-top-icons-plus';;
		*) _topicons_plus_github;;
	esac
}

#=============================================================#
# Gnome tweaks
#=============================================================#
function _gnome_tweaks()
{
	_package_man_distro 'gnome-tweaks'
}
