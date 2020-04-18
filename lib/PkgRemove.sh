#!/usr/bin/env bash
#
#

_delete_all()
{
	# $1 = array com vários arquivos e diretórios a serem removidos.
	#sudo -k
	while [[ $1 ]]; do

		# Verificar se $1 existe
		if [[ -d "$1" ]] || [[ -f "$1" ]] || [[ -L "$1" ]] || [[ -x "$1" ]]; then
			# Presica ser root?.
			if [[ -w "$1" ]] && [[ -w $(dirname "$1") ]]; then 
				msg "Removendo: $1"
				rm -rf "$1"
			else
				echo -ne "[>] Necessário ser ${Yellow}'root'${Reset} para remover: [$1]"
				sudo rm -rf "$1" && echo ' OK removido'
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
			papirus) _delete_all "${array_papirus_dirs[@]}";;
			peazip) _delete_all "${array_peazip_dirs[@]}";;
			pycharm) _delete_all "${array_pycharm_dirs[@]}";;
			'sublime-text') _delete_all "${array_sublime_dirs[@]}";;
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
