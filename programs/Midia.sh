#!/usr/bin/env bash
#
#
#

#=====================================================#
# Codecs
#=====================================================#
function _codecs_tumbleweed()
{
	# https://software.opensuse.org/download/package?package=opensuse-codecs-installer&project=multimedia%3Aapps
	# https://forums.opensuse.org/showthread.php/523476-Multimedia-Guide-for-openSUSE-Tumbleweed
	
	# Adicionar repostórios
	"$Script_AddRepo" --tumbleweed-repos

	# Instalar os codecs
	local array_tumbleweed_codecs=(
		opensuse-codecs-installer
		libxine2-codecs 
		dvdauthor 
		gstreamer-plugins-bad 
		gstreamer-plugins-bad-orig-addon 
		gstreamer-plugins-ugly-orig-addon 
		gstreamer-plugins-good-extra 
		libxine2-codecs    
		gstreamer-plugins-base  
		gstreamer-plugins-good 
		gstreamer-plugins-libav  
		gstreamer-plugins-ugly 
		gstreamer-plugins-good-qtqml
		smplayer 
		x264 
		x265 
		vlc-codecs 
		vlc-codec-gstreamer 
		ogmtools 
		libavcodec58
	)

	for c in "${array_tumbleweed_codecs[@]}"; do
		_yellow "[+] Instalando [$c]"
		if ! sudo zypper in "$c"; then
			_red "[!] Falha [$c]"
			sleep 0.5
		fi
	done

}

#-----------------------------------------------------#

function _codecs_ubuntu()
{
	package_man_cli --install-recommends ffmpeg ffmpegthumbnailer
	package_man_cli ubuntu-restricted-extras
}

#-----------------------------------------------------#

function _codecs_debian()
{
	#------------------| AlsaMixer |---------------------------#
	# visite o link abaixo se tiver problemas com a sua placa de audio.
	# https://vitux.com/how-to-control-audio-on-the-debian-command-line/
	# sudo apt install install alsa-utils
	#
	
	local deb_multimidia='http://www.deb-multimedia.org'
	local url_wcodecs="$deb_multimidia/pool/non-free/w/w64codecs/w64codecs_20071007-dmo2_amd64.deb"
	local soma_wcodecs="cc36b9ff0dce8d4f89031756163d54acdd4e800d6106f07db2031fdf77e90392"
	local path_arq="$dir_user_cache/$(basename $url_wcodecs)"

	_dow "$url_wcodecs" "$path_arq" --curl
	
	[[ "$download_only" == 'on' ]] && { 
		_green "Feito somente download" 
		return 0 
	}

	package_man_cli --install-recommends ffmpeg ffmpegthumbnailer
	package_man_cli lame

	_check_sum "$path_arq" "$soma_wcodecs" || {
		_red "Abortando a instalação de $path_arq"
		return 1
	} # w64codecs.

	
	echo -e "$space_line"
	_msg "Instalando [$path_arq]"
	sudo dpkg --install "$path_arq"
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
	freebsd12.0-release) package_man_cli ffmpeg ffmpegthumbnailer gstreamer-ffmpeg;;
	debian10) _codecs_debian;;
	linuxmint19|ubuntu18.04) _codecs_ubuntu;;
	fedora30|fedora31) _codecs_fedora;;
	opensuse-tumbleweed) _codecs_tumbleweed;;
	arch) _codecs_arch;;
	*) _prog_not_found;;

esac
}

#-----------------------------------------------------#

function _celluloid()
{
	package_man_cli 'celluloid'
}

#-----------------------------------------------------#

function _cinema()
{
	package_man_cli 'cinema'
}

#-----------------------------------------------------#

function _vlc_tumbleweed()
{
	# https://en.opensuse.org/SDB:Firefox_MP4/H.264_Video_Support
	# http://download.videolan.org/pub/videolan/vlc/SuSE/Tumbleweed/vlc.ymp
	# sudo zypper in libqt5-qtquickcontrols2-private-headers-devel

	_red "Programa indisponível"; sleep 1
}

#-----------------------------------------------------#

# Vlc
function _vlc()
{
	# No fedora e necessário de repostórios externos para instalar o vlc por isso
	# requer um passo-a-passo especial.
	if _WHICH 'dnf'; then
		"$Script_AddRepo" --fedora-repos # Adicionar repositórios fusion non free
		package_man_cli vlc python-vlc
	elif _WHICH 'zypper'; then
		_vlc_tumbleweed
	else
		package_man_cli vlc
	fi
}

#-----------------------------------------------------#

#=====================================================#
# Parole
#=====================================================#
function _parole()
{
	package_man_cli parole	
}

#-----------------------------------------------------#

#=====================================================#
# Gnome mpv
#=====================================================#
function _gnome_mpv()
{
	if _WHICH 'dnf'; then
		package_man_cli gnome-mpv smplayer-themes
	elif [[ -f '/etc/debian_version' ]]; then
		package_man_cli gnome-mpv
	else
		package_man_cli gnome-mpv 

	fi
}


#=====================================================#
# Smplayer
#=====================================================#
function _smplayer()
{
	package_man_cli smplayer
}

#=====================================================#
# Totem
#=====================================================#
function _totem(){
	package_man_cli totem
}


