#!/usr/bin/env bash
#     
#    
#

source "$Lib_array"

function _msg_pack_not_instaled()
{
echo -e "==> $(cl 31)$1 $(cl)não está instalado"
return 0	
}


#=====================================================#
# Remove all
#=====================================================#
function _delete_all()
{
while [[ $1 ]]; do
	if [[ -d "$1" ]] || [[ -L "$1" ]] || [[ -f "$1" ]]; then
		echo "$(cl 32)==> $(cl)Removendo: $1"

		# Precisa ser o [root] ?
		if [[ $(echo $1 | grep "$HOME") ]]; then rm -rf "$1"; else sudo rm -rf "$1"; fi

	else
		echo "$(cl 31)==> $(cl)Não encontrado: $1"

	fi
	shift
done
}

#=====================================================#
# Remove
#=====================================================#
function _remove_pycharm()
{
[[ ! -x $(which pycharm 2> /dev/null) ]] && { echo "==> pycharm $(cl 31)não$(cl) está instalado"; return 0; }
_delete_all "${array_pycharm_dirs[@]}"
}

function _remove_vscode()
{
[[ ! -x $(which code 2> /dev/null) ]] && { echo "==> vscode $(cl 31)não$(cl) está instalado"; return 0; }
_delete_all "${array_vscode_dirs[@]}"
}

# Peazip
function _remove_peazip()
{
[[ ! -x $(which peazip 2> /dev/null) ]] && { echo "==> peazip $(cl 31)não$(cl) está instalado"; return 0; }
_delete_all "${array_peazip_dirs[@]}"
}

# Telegram
function _remove_telegram()
{
[[ ! -x $(which telegram 2> /dev/null) ]] && { echo "==> telegram $(cl 31)não$(cl) está instalado"; return 0; }
_delete_all "${array_telegram_dirs[@]}"
}

# Veracrypt
function _remove_veracrypt()
{
[[ ! -x $(which veracrypt 2> /dev/null) ]] && { echo "==> veracrypt $(cl 31)não$(cl) está instalado"; return 0; }
sudo "/usr/bin/veracrypt-uninstall.sh"	
}

#=====================================================#
# _packmanager_remove
#=====================================================#
function _packremove()
{
while [[ $1 ]]; do
	case "$1" in
		icones-papirus) _delete_all "${array_papirus_dirs[@]}";;
		peazip) _remove_peazip;;
		pycharm) _remove_pycharm;;
		sublime-text) "$Script_PackTargz" remove sublime-text;;
		vscode) _remove_vscode;;
		telegram) _remove_telegram;;
		tixati) _delete_all "${array_tixati_dirs[@]}";;
		torbrowser) "$Script_TorBrowser" --remove;;
		veracrypt) _remove_veracrypt;;
		remove) echo -ne "\r";;
		*) echo "==> Não e possível remover o pacote: $1";;
	esac
	shift
done
}
