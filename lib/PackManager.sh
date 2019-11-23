#!/usr/bin/env bash
#     
#    
#

source "$Lib_array"
source "$Lib_Acessorios"
source "$Lib_Dev"
source "$Lib_Internet"
source "$Lib_Sistema"
source "$Lib_Preferencias"

function _msg_pack_instaled()
{
echo "==> já instalado para remove-lo use $( basename $0) $(_c 32)r$(_c)emove $1"
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
