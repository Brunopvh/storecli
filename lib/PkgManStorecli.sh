#!/usr/bin/env bash
#
#
#

_packmanager_storecli()
{
	if [[ -z $1 ]]; then
		usage
		return 1
	fi

	while [[ $1 ]]; do
		case "$1" in
			-d|--downloadonly) echo -en "\r";;
			-y|--yes) echo -en "\r";;
			*) msg "Instalando $(SPACE_TEXT Instalando) $1";; 
		esac
		 

		case "$1" in
			-d|--downloadonly) export download_only='True';;
			-y|--yes) export install_yes='True';;

#----------- Acessorios ------------------------------------#
			Acessorios) _Acessory_All;;
			etcher) _etcher;;
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

#----------- Desenvolvimento -------------------------------#
			Dev) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			pycharm) _pycharm;;
			sublime-text) _sublime_text;;
			vim) _vim;;
			vscode) _vscode;;

#----------- Office -----------------------------------------#
			Office) _Office_All;;
			atril) _atril;;
			'fontes-ms') _fontes_microsoft;;
			libreoffice) _libreoffice;;
			libreoffice-appimage) _libreoffice_appimage;;

#----------- Internet --------------------------------------#
			Internet) _Internet_All;;      # Instalar todos da catgória Internet.
			chromium) _chromium;;
			firefox) _firefox;;
			'google-chrome') _google_chrome;;
			megasync) _megasync;;
			'opera-stable') _opera_stable;;
			proxychains) _proxychains;;
			qbittorrent) _qbittorrent;;
			teamviewer) _teamviewer;;
			telegram) _telegram;;
			tixati) _tixati_tar;;
			torbrowser) _torbrowser;;
			uget) _uget;;
			youtube-dl) _youtube_dl;;
			youtube-dl-gui) _youtube_dlgui;;

#----------- Midia -----------------------------------------#
			Midia) _Midia_All;;
			blender) _blender;;
			celluloid) _celluloid;;
			cinema) _cinema;;
			codecs) _codecs;;
			'gnome-mpv') _gnome_mpv;;
			smplayer) _smplayer;;
			spotify) _spotify;;
			parole) _parole;;
			totem) _totem;;
			vlc) _vlc;;

#----------- Sistema ---------------------------------------#
			Sistema) _System_All;;
			bluetooth) _bluetooth;;
			compactadores) _compactadores;;
			gparted) _gparted;;
			peazip) _peazip;;
			stacer) _stacer;;
			virtualbox) _virtualbox;;

#----------- Preferências ----------------------------------#
			ohmybash) _ohmybash;;			
			ohmyzsh) _ohmyzsh;;
			papirus) _papirus;;
		


#----------- Gnome Extenções -------------------------------#
			'gnome-extensions') _gnome_shell_extensions;;
			'topicons-plus') _topicons_plus_github;;
			'dash-to-dock') _dashtodock_github;;

			*) _INFO 'pkg_not_found' "$1";;
		esac
		shift
	done
}
