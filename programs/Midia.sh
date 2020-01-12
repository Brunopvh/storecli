#!/usr/bin/env bash
#
#
#

#=====================================================#
# Codecs
#=====================================================#
function _codecs_tumbleweed()
{
	sudo zypper ar -f http://opensuse-guide.org/repo/openSUSE_Tumbleweed/ libdvdcss
	sudo zypper ar -f http://packman.inode.at/suse/openSUSE_Tumbleweed/ packman
	sudo zypper ref

	sudo zypper install -f libxine2-codecs dvdauthor gstreamer-plugins-bad gstreamer-plugins-bad-orig-addon   
	sudo zypper install -f smplayer x264 x265 ogmtools libavcodec58
}

#-----------------------------------------------------#

function _codecs_ubuntu()
{
	sudo apt install -y --install-recommends ffmpeg ffmpegthumbnailer
	sudo apt install ubuntu-restricted-extras
}

#-----------------------------------------------------#

function _codecs_debian()
{
local deb_multimidia='http://www.deb-multimedia.org'
local url_wcodecs="$deb_multimidia/pool/non-free/w/w64codecs/w64codecs_20071007-dmo2_amd64.deb"
local soma_wcodecs="cc36b9ff0dce8d4f89031756163d54acdd4e800d6106f07db2031fdf77e90392"
local path_arq="$dir_user_cache/$(basename $url_wcodecs)"

_dow "$url_wcodecs" "$path_arq" --curl
# --download-only
[[ "$download_only" == 'on' ]] && { echo "$$(_c 32)=> $$(_c)Feito somente download."; return 0; }

sudo apt install -y --install-recommends ffmpeg ffmpegthumbnailer
sudo apt install lame

	_check_sum "$path_arq" "$soma_wcodecs" # w64codecs.
	if [[ $? == '0' ]]; then	
		sudo dpkg --install "$path_arq"

	else
		echo "$(_c 31)=> $(_c)Abortando a instalação de $path_arq"; exit 1

	fi
}

#-----------------------------------------------------#

# Fedora
function _codecs_fedora()
{
	# Add repo fusion non free
	"$Script_AddRepo" --fedora-repos

local lista_codecs=(
'gstreamer1' 'gstreamer1-plugins-base' 
'gstreamer-ffmpeg' 'libmpeg3'
'x264' 'x264-libs' 'xvidcore' 
)

	echo "$(_c 32)=> $(_c)Instalando: ffmpeg ffmpegthumbnailer"
	sudo dnf install -y ffmpeg ffmpegthumbnailer.x86_64

	echo "$(_c 32)=> $(_c)Instalando: ${lista_codecs[@]}"
	sudo dnf install -y "${lista_codecs[@]}" 
}

#-----------------------------------------------------#

# Codecs
function _codecs()
{
case "$sysname" in
	freebsd12.0-release) sudo pkg install -y ffmpeg ffmpegthumbnailer gstreamer-ffmpeg;;
	debian10) _codecs_debian;;
	linuxmint19|ubuntu18.04) _codecs_ubuntu;;
	fedora30|fedora31) _codecs_fedora;;
	opensuse-tumbleweed) _codecs_tumbleweed;;
	*) _prog_not_found;;

esac
}

function _vlc_fedora()
{
	# Add repo fusion non free
	"$Script_AddRepo" --fedora-repos
	echo "$(_c 32 0)=> $(_c)Instalando vlc: "
	sudo dnf install vlc python-vlc
}

#-----------------------------------------------------#

# Vlc
function _vlc()
{
case "$sysname" in
	debian10) sudo apt install -y vlc;;
	linuxmint19|ubuntu18.04) sudo apt install -y vlc;;
	fedora30|fedora31) _vlc_fedora;;
	freebsd12.0-release) sudo pkg install -y vlc;;
	*) _prog_not_found;;

esac
}

#-----------------------------------------------------#

#=====================================================#
# Parole
#=====================================================#
function _parole()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y parole

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y parole

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y parole

	else
		_prog_not_found; return 1

	fi

}

#-----------------------------------------------------#

#=====================================================#
# Gnome mpv
#=====================================================#
function _gnome_mpv()
{
	if [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y gnome-mpv smplayer-themes

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y gnome-mpv

	else
		_prog_not_found; return 1

	fi
}


#-----------------------------------------------------#

#=====================================================#
# Smplayer
#=====================================================#
function _smplayer()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y smplayer

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y smplayer

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y smplayer

	else
		_prog_not_found; return 1

	fi

}
