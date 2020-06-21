#!/usr/bin/env bash
#
#
#

_packmanager_storecli()
{
	if [[ -z $1 ]]; then
		#usage
		usage_install_argument
		return 1
	fi

	# Se o sistema for LinuxMint, deverá ser tratado como Ubuntu.
	case "$os_codename" in
		tina|tricia) export os_codename='bionic';;
	esac

	while [[ $1 ]]; do
		case "$1" in
			-d|--downloadonly) echo -en "\r";;
			-y|--yes) echo -en "\r";;
			*) white "Instalando $(SPACE_TEXT Instalando)-> $1";; 
		esac
		 

		case "$1" in
			-d|--downloadonly) export download_only='True';;
			-y|--yes) export install_yes='True';;

#----------- Acessorios ------------------------------------#
			Acessorios) _Acessory_All;;
			etcher) _etcher;;
			gnome-disk) _gnome_disk;;
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

#----------- Desenvolvimento -------------------------------#
			Desenvolvimento) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			codeblocks) _codeblocks;;
			java) _java;;
			pycharm) _pycharm;;
			sublime-text) _sublime_text;;
			vim) _vim;;
			vscode) _vscode;;

#----------- Office -----------------------------------------#
			Escritorio) _Office_All;;
			atril) _atril;;
			'fontes-ms') _fontes_microsoft;;
			libreoffice) _libreoffice;;
			libreoffice-appimage) _libreoffice_appimage;;

#----------- Browser --------------------------------------#
			chromium) _chromium;;
			firefox) _firefox;;
			'google-chrome') _google_chrome;;
			'opera-stable') _opera_stable;;
			torbrowser) _torbrowser;;

#----------- Internet --------------------------------------#
			Internet) _Internet_All;;      # Instalar todos da catgória Internet.
			megasync) _megasync;;
			proxychains) _proxychains;;
			qbittorrent) _qbittorrent;;
			skype) _skype;;
			teamviewer) _teamviewer;;
			telegram) _telegram;;
			tixati) _tixati_tar;;
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
			p7zip-gui) _p7zip_gui;;
			peazip) _peazip;;
			refind) _refind;;
			stacer) _stacer;;
			virtualbox) _virtualbox;;

#----------- Preferências ----------------------------------#
			ohmybash) _ohmybash;;			
			ohmyzsh) _ohmyzsh;;
			papirus) _papirus;;
			sierra) _sierra;;
		


#----------- Gnome Extenções -------------------------------#
			'dash-to-dock') _dashtodock;;
			'drive-menu') _drive_menu;;
			'gnome-backgrounds') _gnome_backgrounds;;
			'gnome-tweaks') _gnome_tweaks;;
			'topicons-plus') _topicons_plus;;
			*) _INFO 'pkg_not_found' "$1";;
		esac
		shift
	done
}
