#!/usr/bin/env bash
#
#
#


#-----------------------------------------------------#

#=====================================================#
# Gnome-Disk
#=====================================================#
function _gnome_disk()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in gnome-disk-utility

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install gnome-disk-utility

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install gnome-disk-utility

	else
		_prog_not_found; return 1

	fi
}

#-----------------------------------------------------#

#=====================================================#
# Veracrypt
#=====================================================#
function _veracrypt()
{
url_veracrypt_default='https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2'
veracrypt_pag='https://www.veracrypt.fr/en/Downloads.html'
veracrypt_html=$(wget -q "$veracrypt_pag" -O- | grep -m 1 "http.*verac.*tar.bz2" | awk '{print $2}')
veracrypt_url_dow=$(echo "$veracrypt_html" | sed 's/bz2\".*/bz2/g;s/.*\"//g' | sed 's/&#43\;/+/g')
veracrypt_pacote=$(basename "$veracrypt_url_dow")
local path_arq="$dir_user_cache/$veracrypt_pacote"

_dow "$veracrypt_url_dow" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v veracrypt 2> /dev/null) ]] && { _msg_pack_instaled 'veracrypt'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv $(ls veracrypt*setup-gui-x64) "$dir_temp/veracryptx64" 1> /dev/null
chmod +x "$dir_temp/veracryptx64"
sudo "$dir_temp/veracryptx64"
[[ -d "$dir_temp" ]] && { cd "$dir_temp" && sudo rm -rf *; }
}

#-----------------------------------------------------#
