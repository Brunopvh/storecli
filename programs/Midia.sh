#!/usr/bin/env bash
#

_blender()
{
	local url_blender='https://ftp.nluug.nl/pub/graphics/blender/release/Blender2.82/blender-2.82a-linux64.tar.xz'
	local path_file="$Dir_Downloads/$(basename $url_blender)"

	_dow "$url_blender" "$path_file" || return 1

	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' 'Blender'
		return 0
	fi

	_unpack "$path_file" || return 1

}

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
		yellow "Instalando [$c]"
		_package_man_distro "$c"		
	done
}

#-----------------------------------------------------#

function _codecs_ubuntu()
{
	_package_man_distro --install-recommends ffmpeg ffmpegthumbnailer
	_package_man_distro 'ubuntu-restricted-extras'
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
	local hash_wcodecs="cc36b9ff0dce8d4f89031756163d54acdd4e800d6106f07db2031fdf77e90392"
	local path_file="$Dir_Downloads/$(basename $url_wcodecs)"

	_dow "$url_wcodecs" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	_package_man_distro --install-recommends ffmpeg ffmpegthumbnailer
	_package_man_distro lame

	_check_sum "$path_file" "$hash_wcodecs" || return 1
	
	echo -e "$space_line"
	msg "Instalando [$path_file]"
	sudo dpkg --install "$path_file" || return 1
}

#-----------------------------------------------------#

# Fedora
function _codecs_fedora()
{
	# Add repo fusion non free
	"$Script_AddRepo" --fedora-repos

	local array_gstreamer_fedora=(
		gstreamer-plugins-espeak 
		gstreamer-plugins-fc gstreamer-rtsp 
		gstreamer-plugins-good 
		gstreamer-plugins-bad 
		gstreamer-plugins-bad-free-extras 
		gstreamer-plugins-bad-nonfree 
		gstreamer-plugins-ugly 
		gstreamer-ffmpeg gstreamer1-plugins-base 
		gstreamer1-libav 
		gstreamer1-plugins-bad-free-extras 
		gstreamer1-plugins-bad-freeworld 
		gstreamer1-plugins-base-tools 
		gstreamer1-plugins-good-extras 
		gstreamer1-plugins-ugly 
		gstreamer1-plugins-bad-free 
		gstreamer1-plugins-good
		)

	local array_codecs_fedora=(
		'ffmpeg' 
		'ffmpegthumbnailer.x86_64'
		'amrnb' 
		'amrwb' 
		'faad2' 
		'flac' 
		'ffmpeg' 
		'gpac-libs' 
		'lame' 
		'libfc14audiodecoder' 
		'mencoder' 
		'mplayer' 
		'x265' 
		'gstreamer1' 
		'gstreamer1-plugins-base' 
		'gstreamer-ffmpeg' 
		'libmpeg3' 
		'x264' 
		'x264-libs' 
		'xvidcore' 
	)

	for c in "${array_codecs_fedora[@]}"; do
		green "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha $c"
			sleep 0.5
		fi
	done


	for c in "${array_gstreamer_fedora[@]}"; do
		green "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha $c"
			sleep 0.5
		fi
	done
}

#-----------------------------------------------------#

function _codecs_arch()
{
	#
	# https://bbs.archlinux.org/viewtopic.php?id=223197
	#

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
		'ffmpeg'
		'ffmpegthumbnailer'
	)

	local list_codecs_parole=(
		'gst-libav'
		'gst-plugins-bad'
		'gst-plugins-ugly'
		)

	for x in "${list_codecs_arch[@]}"; do 
		echo -e "$space_line"
		yellow "Instalando: $x"
		if ! _package_man_distro "$x"; then red "Falha: $x"; fi
	done

	
	for x in "${list_codecs_parole[@]}"; do 
		echo -e "$space_line"
		yellow "Instalando: $x"
		if ! _package_man_distro "$x"; then red "Falha: $x"; fi
	done
	
}

#-----------------------------------------------------#

# Codecs
function _codecs()
{
case "$os_id" in
	freebsd12.0-release) _package_man_distro ffmpeg ffmpegthumbnailer 'gstreamer-ffmpeg';;
	debian) _codecs_debian;;
	linuxmint|ubuntu) _codecs_ubuntu;;
	fedora) _codecs_fedora;;
	'opensuse-tumbleweed') _codecs_tumbleweed;;
	arch) _codecs_arch;;
	*) _INFO 'pkg_not_found' 'chromium'; return 1;;

esac
}

#-----------------------------------------------------#

function _celluloid()
{
	_package_man_distro 'celluloid'
}


function _cinema()
{
	_package_man_distro 'cinema'
}

#=====================================================#
# Gnome mpv
#=====================================================#
function _gnome_mpv()
{
	if _WHICH 'dnf'; then
		_package_man_distro 'gnome-mpv' 'smplayer-themes'
	elif [[ -f '/etc/debian_version' ]]; then
		_package_man_distro 'gnome-mpv'
	else
		_package_man_distro 'gnome-mpv' 
	fi
}

#=====================================================#
# Parole
#=====================================================#
function _parole()
{
	_package_man_distro parole	
}

#=====================================================#
# Smplayer
#=====================================================#
function _smplayer()
{
	_package_man_distro smplayer
}

#=====================================================#
# Spotify
#=====================================================#
function _spotify_debian()
{
	# https://wiki.debian.org/spotify
	# 
	white "Adicionando keyserver e repositório"
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4773BD5E130D1D45
	echo 'deb http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt update
	_package_man_distro 'spotify-client'
}

function _spotify_ubuntu()
{
	# https://www.spotify.com/br/download/linux/
	white "Adicionando keyserver e repositório"
	curl -sSL https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - 
	echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
	sudo apt-get update 
 	_package_man_cli 'spotify-client'
}

function _spotify_archlinux()
{
	# https://www.vivaolinux.com.br/dica/Spotify-no-Arch-Linux
	local spotify_url='https://repository-origin.spotify.com/pool/non-free/s/spotify-client'
	local spotify_file_server=$(curl -sSL "$spotify_url" | grep -m 1 'spotify.*amd64.deb' | sed 's/">.*//g;s/.*="//g')
	local Spotify_Url_Server="$spotify_url/$spotify_file_server"
	local path_file="$Dir_Downloads/$spotify_file_server"
	
	_dow "$Spotify_Url_Server" "$path_file" || return 1
	
	
	local array_spotify_requeriments=( 
		gconf 
		gtk2
		glib2 
		nss 
		libsystemd 
		libxtst 
		libx11 
		libxss 
		rtmpdump
		'desktop-file-utils' 
		'alsa-lib' 
		'openssl-1.0'
	)
	
	for X in "${array_spotify_requeriments[@]}"; do
		yellow "Instalando: $X"
		if ! _package_man_distro "$X"; then
			red "Falha: $X"
		fi
	done
	
	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi
	
	_unpack "$path_file" || return 1
	cd "$Dir_Unpack"
	white "Descomprimindo arquivo data.tar.gz"
	sudo tar -zxpvf data.tar.gz -C / 1> /dev/null
	sudo install -Dm644 /usr/share/spotify/spotify.desktop /usr/share/applications/spotify.desktop
	sudo install -Dm644 /usr/share/spotify/icons/spotify-linux-512.png /usr/share/pixmaps/spotify-client.png
}

function _spotify()
{
	if [[ "$os_id" == 'debian' ]]; then
		_spotify_debian
	elif [[ "$os_id" == 'ubuntu' ]] || [[ "$os_id" == 'linuxmint' ]]; then
		_spotify_ubuntu
	elif [[ "$os_id" == 'arch' ]]; then
		_spotify_archlinux
	else
		_INFO 'pkg_not_found' 'spotify'; return 1
	fi
	
	if _WHICH 'spotify'; then
		_INFO 'pkg_sucess' 'spotify'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'spotify'
		return 1
	fi
}

#=====================================================#
# Totem
#=====================================================#
function _totem(){
	_package_man_distro totem
}


_vlc_fedora()
{
	"$Script_AddRepo" --fedora-repos # Adicionar repositórios fusion non free
	_package_man_distro vlc python-vlc
}

_vlc()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _package_man_distro vlc;;
		fedora) _vlc_fedora;;
		arch) _package_man_distro vlc;;
	esac

	if _WHICH 'vlc'; then
		_INFO 'pkg_sucess' 'vlc'
	else
		_INFO 'pkg_instalation_failed' 'vlc'
	fi
}


#=============================================================#
# Instalar todos os pacotes da categória Midia.
#=============================================================#
_Midia_All()
{
	if [[ -z "$install_yes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Internet'" || return 1
	fi
	_codecs
	_celluloid
	_cinema
	_gnome_mpv
	_parole
	_smplayer
	_spotify
	_totem
	_vlc
}
