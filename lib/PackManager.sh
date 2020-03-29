#!/usr/bin/env bash
#     
#    
#

# Importar categorias para utilizar as funções que instalam os programas.
source "$Lib_array"
source "$Lib_Acessorios"
source "$Lib_Dev"
source "$Lib_Escritorio"
source "$Lib_Internet"
source "$Lib_Midia"
source "$Lib_Sistema"
source "$Lib_Preferencias"

#-----------------------------------------------------#

function _c()
{
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

#-----------------------------------------------------#

function _msg_pack_instaled()
{
	_msg "já instalado para remove-lo use: $(basename $0) $(_c 32)r$(_c)emove $1"
}

#=====================================================#
# Quebrado
#=====================================================#
function _quebrado()
{
	[[ ! -x $(command -v apt 2> /dev/null) ]] && { 
		_prog_not_found 
		return 1
	}	

	_msg "Executando [apt-get clean; apt-get remove -y; apt-get autoremove -y]"
	sudo sh -c 'apt-get clean; apt-get remove -y; apt-get autoremove -y'

	_msg "Executando [apt-get install -f -y; dpkg --configure -a; apt --fix-broken install]"
	sudo sh -c 'apt-get install -f -y; dpkg --configure -a; apt --fix-broken install'

	_msg "Executando [apt update]"
	sudo apt update 
	#sudo apt-get install --yes --force-yes -f 

	_msg "OK"
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
	if [[ "$1" == '-d' ]] || [[ "$1" == '--downloadonly' ]]; then
		echo -en "\r"
	else
		_msg "Instalando $(space_msg $1) $1"
	fi


	case "$1" in
#-------------------- Acessórios ------------------------#
		gnome-disk) _gnome_disk;;
		veracrypt) _veracrypt;;
		woeusb) _woeusb;;

#-------------------- desenvolvimento -------------------#
		android-studio) _android_studio;;
		codeblocks) _codeblocks;;
		pycharm) _pycharm;;
		sublime-text) _sublime_text;;
		vim) _vim;;
		vscode) _vscode;;

#-------------------- Escritório ------------------------#
		atril) _atril;;
		fontes-ms) _fontes_microsoft;;
		libreoffice) _libreoffice;;
		libreoffice-appimage) _libreoffice_appimage;;

#-------------------- gnome-shell --------------------------#
		gnome-utils) _gnome_shell;;

#-------------------- internet --------------------------#
		chromium) _chromium;;
		google-chrome) _google_chrome;;
		megasync) _megasync;;
		opera-stable) _opera_stable;;
		proxychains) _proxychains;;
		qbittorrent) _qbittorrent;;
		teamviewer) _teamviewer;;
		telegram) _telegram;;
		tixati) _tixati;;
		torbrowser) _torbrowser;;
		uget) _uget;;
		youtube-dl) _youtube_dl;;
		youtube-dl-gui) _youtube_dl_gui_github;;

#-------------------- midia ----------------------------#
		codecs) _codecs;;
		vlc) _vlc;;
		parole) _parole;;
		gnome-mpv) _gnome_mpv;;
		smplayer) _smplayer;;

#-------------------- sistema ---------------------------#
		bluetooth) _bluetooth;;
		compactadores) _compactadores;;
		firmware-*) _firmware "$1";;
		gparted) _gparted;;
		peazip) _peazip;;
		virtualbox) _virtualbox;;

#------------------------ wine ---------------------------#
		wine) "$Script_Pywine" install wine;;
		winetricks) "$Script_Pywine" install winetricks;;

#-------------------- preferencias ---------------------------#
		hacking-parrot) _hacking_parrot;;
		papirus) _papirus;; # Instalar diretamente pelo arquivo ./scripts/papirus.sh "$Script_Papirus"
		ohmybash) _ohmybash;;
		ohmyzsh) _ohmyzsh;;
		sierra) _sierra;;
		--downloadonly|-d) echo -en "\r";;
		install) echo -ne "\r";;
		*) _red "Programa indisponível $(space_msg $1) $1";;
	esac
	shift
done
}
