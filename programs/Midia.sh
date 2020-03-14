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
		_msg "Abortando a instalação de $path_arq"; return 1

	fi
}

#-----------------------------------------------------#

# Fedora
function _codecs_fedora()
{
	# Add repo fusion non free
	"$Script_AddRepo" --fedora-repos

local lista_codecs=(
'gstreamer1' 
'gstreamer1-plugins-base' 
'gstreamer-ffmpeg' 
'libmpeg3'
'x264' 
'x264-libs' 
'xvidcore' 
)

	_green "Instalando: ffmpeg ffmpegthumbnailer"
	sudo dnf install -y ffmpeg ffmpegthumbnailer.x86_64 || return 1

	_green "Instalando: ${lista_codecs[@]}"
	sudo dnf install -y "${lista_codecs[@]}" || return 1 
}

#-----------------------------------------------------#

function _codecs_arch()
{
	local list_codecs_arch=(
		'a52dec' 
		'faac' 
		'faad2' 
		'flac' 
		'jasper' 
		'lame' 
		'libdca' 
		'libdv' 
		'libmad' 
		'libmpeg2' 
		'libtheora' 
		'libvorbis' 
		'libxv' 
		'opus' 
		'wavpack' 
		'x264' 
		'xvidcore'
	)

	_green "Instalando: ${list_codecs_arch[@]}"
	sudo pacman -S "${list_codecs_arch[@]}" || return 1
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
	arch) _codecs_arch;;
	*) _prog_not_found;;

esac
}

function _vlc_fedora()
{
	if [[ "$os_id" != 'fedora' ]]; then
		_prog_not_found
		return 1
	fi

	# Add repo fusion non free
	"$Script_AddRepo" --fedora-repos
	_green "Instalando: vlc"
	sudo dnf install vlc python-vlc
}

#-----------------------------------------------------#

# Vlc
function _vlc()
{
	if _WHICH 'dnf'; then # dnf/fedora
		_vlc_fedora
	elif _WHICH 'apt'; then
		sudo apt install -y vlc
	elif _WHICH 'pacman'; then
		sudo pacman -S vlc
	else
		_prog_not_found
	fi
	return "$?"
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

	elif [[ -x $(command -v pacman 2> /dev/null) ]]; then
		sudo pacman -S parole

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

	elif [[ -x $(command -v pacman 2> /dev/null) ]]; then
		sudo pacman -S smplayer

	else
		_prog_not_found; return 1

	fi

}

#=====================================================#
# Totem
#=====================================================#
function _totem(){
	case "$os_id" in
		debian|ubuntu|linuxmint) sudo apt install -y totem;;
		fedora) sudo dnf install -y totem;;
		*) _prog_not_found; return 1;;
	esac

}


