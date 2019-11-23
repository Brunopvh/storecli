#!/usr/bin/env bash
#     
#    
#

source "$Lib_array"
source "$Lib_Dev"
source "$Lib_Internet"

function _msg_pack_instaled()
{
echo "==> já instalado para remove-lo use $( basename $0) $(cl 32)r$(cl)emove $1"
}

#-----------------------------------------------------#

function _c()
{
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

#=====================================================#
# Quebrado
#=====================================================#
function _quebrado()
{
[[ ! -x $(command -v apt 2> /dev/null) ]] && { _prog_not_found; return 1; }	

echo "$(cl 32)==> $(cl)Limpando cache aguarde..."
sudo sh -c 'apt-get clean; apt-get remove -y; apt-get autoremove -y'

echo "$(cl 32)==> $(cl)Executando dpkg --configure -a"
sudo sh -c 'apt-get install -f -y; dpkg --configure -a; apt --fix-broken install'

echo "$(cl 32)==> $(cl)Executando apt update"
sudo apt update 
#sudo apt-get install --yes --force-yes -f 

echo -e "\n$(cl 33)[OK]$(cl)"
}

#-----------------------------------------------------#

#=====================================================#
# Gnome-Disk
#=====================================================#
function _gnome_disk()
{
	case "$sysname" in
		debian10) sudo apt install gnome-disk-utility;;
		*) _prog_not_found; return 1;;
	esac
}

#-----------------------------------------------------#

#=====================================================#
# Veracrypt
#=====================================================#
function _veracrypt()
{
url_veracrypt_default='https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2'
veracrypt_pag='https://www.veracrypt.fr/en/Downloads.html'
veracrypt_html=$(wget -q "$veracrypt_pag" -O- | grep -m 1 "http.*verac.*tar.bz2" | awk '{print $2}')
veracrypt_url_dow=$(echo "$veracrypt_html" | sed 's/bz2\".*/bz2/g;s/.*\"//g' | sed 's/&#43\;/+/g')
veracrypt_pacote=$(basename "$veracrypt_url_dow")
local path_arq="$dir_user_cache/$veracrypt_pacote"

_dow "$veracrypt_url_dow" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v veracrypt 2> /dev/null) ]] && { _msg_pack_instaled 'veracrypt'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv $(ls veracrypt*setup-gui-x64) "$dir_temp/veracryptx64" 1> /dev/null
chmod +x "$dir_temp/veracryptx64"
sudo "$dir_temp/veracryptx64"
[[ -d "$dir_temp" ]] && { cd "$dir_temp" && sudo rm -rf *; }
}

#-----------------------------------------------------#

#=====================================================#
# Midia
#=====================================================#

#=====================================================#
# Codecs
#=====================================================#

function _codecs_debian()
{
local deb_multimidia='http://www.deb-multimedia.org'
local url_wcodecs="$deb_multimidia/pool/non-free/w/w64codecs/w64codecs_20071007-dmo2_amd64.deb"
local soma_wcodecs="cc36b9ff0dce8d4f89031756163d54acdd4e800d6106f07db2031fdf77e90392"
local path_arq="$dir_user_cache/w64codecs_amd64.deb"

_dow "$url_wcodecs" "$path_arq" --curl
	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }

_check_sum "$path_arq" "$soma_wcodecs"
if [[ $? == '0' ]]; then
	sudo apt install -y --install-recommends ffmpeg ffmpegthumbnailer
	sudo apt install lame
	sudo dpkg --install "$path_arq"

else
	echo "$(cl 31)==> $(cl)Abortando a instalação"; exit 1

fi
}

#-----------------------------------------------------#

# Codecs
function _codecs()
{
case "$sysname" in
	freebsd12.0-release) sudo pkg install -y ffmpeg ffmpegthumbnailer gstreamer-ffmpeg;;
	debian10) _codecs_debian;;
	*) _prog_not_found;;

esac
}

# Vlc
function _vlc()
{
case "$sysname" in
	debian10) sudo apt install -y vlc;;
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
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y gnome-mpv

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
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

#-----------------------------------------------------#

#=====================================================#
# Sistema
#=====================================================#

#=====================================================#
# Gparted
#=====================================================#
function _gparted()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y gparted

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y gparted

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y gparted

	else
		_prog_not_found; return 1

	fi

}

#=====================================================#
# PeaZip
#=====================================================#
function _peazip()
{
peazip_server='https://osdn.net/dl/peazip'
peazip_pag='https://osdn.net/projects/peazip/downloads'

peazip_html=$(wget -q "$peazip_pag" -O- | grep -m 1 "portable.*tar.gz" | awk '{print $6}')
peazip_pacote=$(echo "$peazip_html" | sed 's/.*peazip_portable/peazip_portable/g;s/\/\".*//g')
peazip_url_download="$peazip_server/$peazip_pacote"
local path_arq="$dir_user_cache/$peazip_pacote"

_dow "$peazip_url_download" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	
	[[ -x $(command -v peazip 2> /dev/null) ]] && { _msg_pack_instaled 'peazip'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"

[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv -v $(ls -d peazip*) "$dir_temp/peazip-amd64" 1> /dev/null
chmod -R +x "$dir_temp/peazip-amd64"

sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.desktop "${array_peazip_dirs[0]}" # .desktop
sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.png "${array_peazip_dirs[1]}" # PNG.
sudo mv "$dir_temp"/peazip-amd64/peazip "${array_peazip_dirs[2]}" # binario.
sudo mv "$dir_temp"/peazip-amd64 "${array_peazip_dirs[3]}" # dir.

if [[ -x $(which peazip 2> /dev/null) ]]; then
	_info_msgs; echo "==> peazip instalado com sucesso."
	return 0

else
	echo "$(cor 31)==> $(cor)Falha"
	return 1

fi
}

#-----------------------------------------------------#

#=====================================================#
# Preferencias.
#=====================================================#
function _papirus()
{
# Está função NÃO está em uso no momento.
#
local url_papirus='https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh'
local path_arq="$dir_user_cache/papirus.run"

	_dow "$url_papirus" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	chmod +x "$path_arq"
	"$path_arq"
}

#-----------------------------------------------------#

#=====================================================#
# OhMyBash
#=====================================================#
function _ohmybash()
{
	# github_ohmy_bash="$github/ohmybash/oh-my-bash.git"
	echo -e "$(_c 33)==> $(_c)Instalar oh-my-bash $(_c 35)[s/n]$(_c) ? : "
	read input
	[[ "${input,,}" == 's' ]] || { echo -e "$(_c 31)==> $(_c)Abortando..."; return 0; }

	#sh -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
	wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O '/tmp/ohmybash.sh'
	chmod +x '/tmp/ohmybash.sh'; '/tmp/ohmybash.sh'
}

#=====================================================#
# packmanager install
#=====================================================#
function _packmanager_install()
{
for arg in "$@"; do
	if [[ "$arg" == '--downloadonly' ]] || [[ "$arg" == '-d' ]]; then
		export download_only='on'
	fi
done

while [[ "$1" ]]; do
	case "$1" in
#-------------------- Acessórios -------------------#
		gnome-disk) _gnome_disk;;
		veracrypt) _veracrypt;;

#-------------------- desenvolvimento -------------------#
		pycharm) _pycharm;;
		sublime-text) _sublime_text;;
		vim) _vim;;
		vscode) _vscode;;

#-------------------- internet --------------------------#
		google-chrome) _google_chrome;;
		megasync) _megasync;;
		opera-stable) _opera_stable;;
		proxychains) _proxychains;;
		qbittorrent) _qbittorrent;;
		telegram) _telegram;;
		tixati) _tixati;;
		torbrowser) _torbrowser;;
		uget) _uget;;

#-------------------- midia --------------------------#
		codecs) _codecs;;
		vlc) _vlc;;
		parole) _parole;;
		gnome-mpv) _gnome_mpv;;
		smplayer) _smplayer;;

#-------------------- sistema ---------------------------#
		gparted) _gparted;;
		peazip) _peazip;;

#-------------------- preferencias ---------------------------#
		icones-papirus) "$Script_Papirus";;
		ohmybash) _ohmybash;;

		--downloadonly) echo -en "\r";;
		-d) echo -en "\r";;
		install) echo -ne "\r";;
		*) echo "==> Programa indisponível: $(cl 31)$1 $(cl)";;
	esac
	shift
done

}
