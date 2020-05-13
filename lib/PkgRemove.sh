#!/usr/bin/env bash
#
#

_delete_all()
{
	# $1 = array com vários arquivos e diretórios a serem removidos.
	while [[ $1 ]]; do

		# Verificar se $1 existe
		if [[ -d "$1" ]] || [[ -f "$1" ]] || [[ -L "$1" ]] || [[ -x "$1" ]]; then
			echo -ne "[>] Deletando: $1 "
			if rm -rf "$1" 2> /dev/null; then
				echo -e "${Yellow}OK${Reset}"
			else
				echo -e "Necessário ser ${Red}'root'${Reset} para executar: sudo rm -rf $1"
				sudo rm -rf "$1"
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
		msg "${Red}R${Reset}emovendo $(SPACE_TEXT Removendo) $1"

		case "$1" in
			android-studio) _delete_all "${array_android_studio_dirs[@]}";;
			etcher) _delete_all "${array_etcher_dirs[@]}";;
			papirus) _delete_all "${array_papirus_dirs[@]}";;
			peazip) _delete_all "${array_peazip_dirs[@]}";;
			pycharm) _delete_all "${array_pycharm_dirs[@]}";;
			refind) _delete_all "${array_refind_dirs[@]}";;
			'sublime-text') _delete_all "${array_sublime_dirs[@]}";;
			telegram)  _delete_all "${array_telegram_dirs[@]}";;
			tixati) _delete_all "${array_tixati_dirs[@]}";;
			torbrowser) "$Script_TorBrowser" --remove;;
			veracrypt) sudo veracrypt-uninstall.sh;;
			vlc) _package_man_distro remove vlc;;
			vscode) _delete_all "${array_vscode_dirs[@]}";;
			woeusb) _package_man_distro remove woeusb;;
			'youtube-dl') _delete_all "$Dir_User_Bin/youtube-dl";;
			*) red "Não foi possivel remover: $1";;
		esac
		shift
	done
}
