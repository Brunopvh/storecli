#!/usr/bin/env bash
#
#
#

_pkg_manager_storecli()
{
	if [[ -z $1 ]]; then
		usage
		return 1
	fi

	# Se o sistema for LinuxMint, deverá ser tratado como Ubuntu.
	case "$os_codename" in
		tina|tricia) export os_codename='bionic';;
	esac

	_yellow "storecli ${__version__}: sua loja de aplicativos via linha de comando."
	_space_text "[+] Sistema" "$os_id $os_release"

	while [[ $1 ]]; do
		case "$1" in
			-d|--downloadonly) ;;
			-y|--yes) ;;
			-I|--ignore-cli) ;;
			*) _space_text "[+] Instalando" "$1";; 
		esac
		 

		case "$1" in
			-d|--downloadonly) export DownloadOnly='True';;
			-y|--yes) export AssumeYes='True';;

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
			*) _red "(_pkg_manager_storecli) programa não encontrado: $1";;
		esac
		shift
	done
}

__delete_files__()
{
	if [[ -z $1 ]]; then
		return 1
	fi

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# A função __sudo__ irá remover o arquivo/diretório.
	for FILE in "$@"; do
		if [[ ! -L "$FILE" ]] && [[ ! -f "$FILE" ]] && [[ ! -d "$FILE" ]]; then
			_red "Não encontrado: $FILE"
		else
			_red "Removendo: $FILE"
			rm -rf "$FILE" 2> /dev/null || __sudo__ rm -rf "$FILE"
		fi
	done
}

_remove_packages()
{
	[[ -z $1 ]] && return 1
	while [[ $1 ]]; do
		_space_text "Removendo" "$1"

		case "$1" in
			etcher) __delete_files__ "${destinationFilesEtcher[@]}";;
			veracrypt) __sudo__ 'veracrypt-uninstall.sh';;
		esac
		shift
	done
#-----------------------| ACESSÓRIOS |------------------------------------------#

return "$?"
}