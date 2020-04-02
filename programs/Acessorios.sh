#!/usr/bin/env bash
#
#
#

source "$Lib_array"

#=====================================================#
# Gnome-Disk
#=====================================================#
function _gnome_disk()
{
	package_man_cli gnome-disk-utility
}

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
	[[ "$download_only" == 'on' ]] && { echo "$(_c 32)=> $(_c)Feito somente download."; return 0; }
	[[ -x $(command -v veracrypt 2> /dev/null) ]] && { _msg_pack_instaled 'veracrypt'; return 0; }

	# Importar chaves públicas.
	echo "$(_c 32)=> $(_c)Importando chaves."
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
			_red "Falha função [unpack] retornou erro" 
			return 1 
		}

		_msg "Instalando"

		cd "$dir_temp" && mv $(ls veracrypt*setup-gui-x64) "$dir_temp/veracryptx64" 1> /dev/null
		chmod +x "$dir_temp/veracryptx64"
		sudo "$dir_temp/veracryptx64"
		[[ -d "$dir_temp" ]] && { cd "$dir_temp" && sudo rm -rf *; }
}

#=====================================================#
# WoeUsb
#=====================================================#
function _woeusb_buster(){
	github='https://github.com'
	github_woeusb="$github/slacka/WoeUSB.git"

	local dir_woeusb="$dir_temp/WoeUSB"
	local requeriments_woeusb=(
			'devscripts' 
			'equivs' 
			'libwxgtk3.0-dev'
			'grub-pc-bin'
			)

	_white "Necessário instalar os seguintes pacotes: ${requeriments_woeusb[@]}"
	echo -ne "Deseja proseguir $(_c 32)[s/n]$(_c) ? : "
	read input

	[[ "${input,,}" == 's' ]] || { _red "Abortando..."; sleep 1; return 0; }

	sudo apt update
	sudo apt install -y "${requeriments_woeusb[@]}" || { 
		_red "[-] Falha na instalação de: ${requeriments_woeusb[@]}"
		return 1 
	}

	cd "$dir_temp" && sudo rm -rf *  # Limpar o diretório temporário.
	_gitclone "$github_woeusb" || { 
		_red "[-] Falha ao tentar clonar: $github_woeusb"
		return 1 
	}

	ls -hl "$dir_woeusb"/debian/changelog

	if ! sudo sed -i 's/(@@WOEUSB_VERSION@@)/(1.0)/g' "$dir_woeusb"/debian/changelog; then
		_red "Falha ao tentar configurar o arquivo: $dir_woeusb/debian/changelog"
		return 1
	fi

	_green "Compilando." 
	sleep 1

	cd "$dir_woeusb"
	sudo sh -c 'dpkg-buildpackage -uc -b' || { 
		_white "Falha ao tentar compilar o WoeUSB"
		return 1 
	}

	#==================================================================#
	#========================= instalação do pacote .deb ==============#
	cd ..
	if sudo dpkg --install "$dir_temp/woeusb_1.0_amd64.deb"; then
		echo -e "$esp"
		_green "WoeUSB instalado com sucesso"	
	else
		_quebrado # Remover pacotes quebrados.
		echo ' '
		_red "Falha ao tentar intalar WoeUSB"
		cd "$dir_temp" && sudo rm -rf *
		return 1
	fi

	#===============================================================#
	#======================== salvar o arquivo .deb ? ==============#

	_white "Deseja salvar o arquivo woeusb_1.0_amd64.deb $(_c 33)[s/n]$(_c)?: "
	read input

	[[ "${input,,}" == 's' ]] && {
		mkdir -p "$HOME/Downloads"
		echo -e "$esp"
		cp -vu "$dir_temp/woeusb_1.0_amd64.deb" "$HOME"/Downloads/woeusb_1.0_amd64.deb
		_white "Arquivo salvo em: [$HOME/Downloads/woeusb_1.0_amd64.deb]"
		echo -e "$esp" 
	}

	cd "$dir_temp" && sudo rm -rf *
}

function _woeusb(){
	if [[ "$os_codename" == 'buster' ]]; then
		_woeusb_buster
	elif [[ "$os_id" == 'ubuntu' ]] || [[ "$os_id" == 'linuxmint' ]]; then
		package_man_cli woeusb
	elif [[ "$os_id" == 'fedora' ]]; then
		package_man_cli WoeUSB
	else
		_prog_not_found
	fi
		
}

#-----------------------------------------------------#
