#!/usr/bin/env bash
#     
#    
#

source "$Lib_array"

function _c()
{
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

function _msg_pack_not_instaled()
{
echo -e "==> $(_c 31)$1 $(_c)não está instalado"
return 0	
}


#=====================================================#
# Remove all
#=====================================================#
function _delete_all()
{
while [[ $1 ]]; do
	if [[ -d "$1" ]] || [[ -L "$1" ]] || [[ -f "$1" ]]; then
		echo "$(_c 32)==> $(_c)Removendo: $1"

		# Precisa ser o [root] ?
		if [[ $(echo $1 | grep "$HOME") ]]; then rm -rf "$1"; else sudo rm -rf "$1"; fi
		#if [[ -w "$1" ]]; then rm -rf "$1"; else sudo rm -rf "$1"; fi

	else
		echo "$(_c 31)==> $(_c)Não encontrado: $1"

	fi
	shift
done
}

#=====================================================#
# Remove
#=====================================================#
function _remove_android_studio()
{
[[ ! -x $(command -v studio 2> /dev/null) ]] && { echo "==> android studio $(_c 31)não$(_c) está instalado"; return 0; }
_delete_all "${array_android_studio_dirs[@]}"
}

#-----------------------------------------------------#

function _remove_libreoffice_appimage()
{
	command -v "${array_libreoffice_dirs[1]}" 1> /dev/null 2>&1 || { 
		echo "==> LibreOfficeAppImage $(_c 31)não$(_c) está instalado"; return 0; 
	}
_delete_all "${array_libreoffice_dirs[@]}"
}

#-----------------------------------------------------#

function _remove_pycharm()
{
[[ ! -x $(which pycharm 2> /dev/null) ]] && { echo "==> pycharm $(_c 31)não$(_c) está instalado"; return 0; }
_delete_all "${array_pycharm_dirs[@]}"
}

#-----------------------------------------------------#

function _remove_peazip()
{
[[ ! -x $(which peazip 2> /dev/null) ]] && { echo "==> peazip $(_c 31)não$(_c) está instalado"; return 0; }
_delete_all "${array_peazip_dirs[@]}"
}

#-----------------------------------------------------#

function _remove_teamviewer()
{
[[ ! -x $(command -v teamviewer 2> /dev/null) ]] && { echo "==> teamviewer $(_c 31)não$(_c) está instalado"; return 0; }

	case "$sysname" in
		debian10|linuxmint19|ubuntu18.04) sudo apt remove teamviewer --auto-remove;;
		*) _delete_all "${array_teamviewer_dirs[@]}";;
	esac	
}

#-----------------------------------------------------#

function _remove_telegram()
{
[[ ! -x $(which telegram 2> /dev/null) ]] && { echo "==> telegram $(_c 31)não$(_c) está instalado"; return 0; }
_delete_all "${array_telegram_dirs[@]}"
}

#-----------------------------------------------------#

function _remove_veracrypt()
{
[[ ! -x $(which veracrypt 2> /dev/null) ]] && { echo "==> veracrypt $(_c 31)não$(_c) está instalado"; return 0; }
sudo "/usr/bin/veracrypt-uninstall.sh"	
}

#-----------------------------------------------------#

function _remove_vscode()
{
[[ ! -x $(which code 2> /dev/null) ]] && { echo "==> vscode $(_c 31)não$(_c) está instalado"; return 0; }
_delete_all "${array_vscode_dirs[@]}"
}

#-----------------------------------------------------#

#=====================================================#
# _packmanager_remove
#=====================================================#
function _packremove()
{
while [[ $1 ]]; do
	case "$1" in
		android-studio) _remove_android_studio;;
		icones-papirus) _delete_all "${array_papirus_dirs[@]}";;
		libreoffice-appimage) _remove_libreoffice_appimage;;
		peazip) _remove_peazip;;
		pycharm) _remove_pycharm;;
		sublime-text) "$Script_PackTargz" remove sublime-text;;
		teamviewer) _remove_teamviewer;;
		telegram) _remove_telegram;;
		tixati) _delete_all "${array_tixati_dirs[@]}";;
		torbrowser) "$Script_TorBrowser" --remove;;
		veracrypt) _remove_veracrypt;;
		vscode) _remove_vscode;;
		remove) echo -ne "\r";;
		*) echo "==> Não e possível remover o pacote: $1";;
	esac
	shift
done
}
