#!/usr/bin/env bash
#
#

_delete_all()
{
	# $1 = array com vários arquivos e diretórios a serem removidos.
	while [[ $1 ]]; do

		# Verificar se $1 existe
		if [[ -d "$1" ]] || [[ -f "$1" ]] || [[ -L "$1" ]] || [[ -x "$1" ]]; then
			
			echo -ne "[>] ${Yellow}D${Reset}eletando: $1 "
			if rm -rf "$1" 2>> "$LogErro"; then
				echo -e "${Yellow}OK${Reset}"
			else
				echo ' '
				_SUDO rm -rf "$1"
			fi
		else
			red "Não encontrado: $1"
		fi
		shift
	done
}

#=============================================================#

_pack_remove()
{
	while [[ $1 ]]; do
		white "${Red}R${Reset}emovendo $(SPACE_TEXT Removendo) $1"

		case "$1" in
#-----------------------| ACESSÓRIOS |------------------------------------------#
			etcher) _delete_all "${array_etcher_dirs[@]}";;
			veracrypt) sudo veracrypt-uninstall.sh;;
			woeusb) _package_man_distro remove woeusb;;

#-----------------------| DEV |-------------------------------------------------#
			android-studio) _delete_all "${array_android_studio_dirs[@]}";;
			pycharm) _delete_all "${array_pycharm_dirs[@]}";;
			'sublime-text') _delete_all "${array_sublime_dirs[@]}";;
			vscode) _delete_all "${array_vscode_dirs[@]}";;

#-----------------------| ESCRITÓRIO |------------------------------------------#
			libreoffice-appimage) _delete_all "${array_libreoffice_dirs[@]}";;
			papirus) _delete_all "${array_papirus_dirs[@]}";;

#-----------------------| MIDIA |-----------------------------------------------#
			vlc) _package_man_distro remove vlc;;

#-----------------------| INTERNET |--------------------------------------------#
			telegram)  _delete_all "${array_telegram_dirs[@]}";;
			tixati) _delete_all "${array_tixati_dirs[@]}";;
			torbrowser) "$Script_TorBrowser" --remove;;
			'youtube-dl') _delete_all "$Dir_User_Bin/youtube-dl";;

#-----------------------| SISTEMA |---------------------------------------------#
			peazip) _delete_all "${array_peazip_dirs[@]}";;
			refind) _delete_all "${array_refind_dirs[@]}";;
			stacer) _delete_all "${array_stacer_dirs[@]}";;
			
			*) red "Não foi possivel remover: $1";;
		esac
		shift
	done
}
