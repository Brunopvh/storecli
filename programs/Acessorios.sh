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
# https://www.veracrypt.fr/en/Digital%20Signatures.html
veracrypt_url_dow='https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2' # Default.
veracrypt_pag='https://www.veracrypt.fr/en/Downloads.html'
veracrypt_html=$(wget -q "$veracrypt_pag" -O- | grep -m 1 "http.*verac.*tar.bz2" | awk '{print $2}')
veracrypt_url_dow=$(echo "$veracrypt_html" | sed 's/bz2\".*/bz2/g;s/.*\"//g' | sed 's/&#43\;/+/g') 
veracrypt_url_dow_sig="${veracrypt_url_dow}.sig"

veracrypt_pacote=$(basename "$veracrypt_url_dow")
veracrypt_sig=$(basename "$veracrypt_url_dow_sig")

local path_arq="$dir_user_cache/$veracrypt_pacote"
local path_sig="$dir_user_cache/$veracrypt_sig"

_dow "$veracrypt_url_dow" "$path_arq" --curl
_dow "$veracrypt_url_dow_sig" "$path_sig" --curl

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(_c 32)==> $(_c)Feito somente download."; return 0; }
[[ -x $(command -v veracrypt 2> /dev/null) ]] && { _msg_pack_instaled 'veracrypt'; return 0; }

# Importar chaves públicas.
echo "$(_c 32)==> $(_c)Importando chaves."
curl -LsS https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc | gpg --import

	# Gpg
	_verify_sig "$path_sig" "$path_arq" || { 
		echo "$(_c 31)Falha gpg --verify $(_c)";
		rm "$path_arq" 2> /dev/nul
		rm "$path_arq_sig" 2> /dev/nul 
		return 1
	}

	# unpack
	"$Script_UnPack" "$path_arq" "$dir_temp" || { 
		echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1 
	}

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv $(ls veracrypt*setup-gui-x64) "$dir_temp/veracryptx64" 1> /dev/null
chmod +x "$dir_temp/veracryptx64"
sudo "$dir_temp/veracryptx64"
[[ -d "$dir_temp" ]] && { cd "$dir_temp" && sudo rm -rf *; }
}

#-----------------------------------------------------#
