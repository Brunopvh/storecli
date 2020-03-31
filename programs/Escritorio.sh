#!/usr/bin/env bash
#
#
#
#

source "$Lib_array"

#-----------------------------------------------------#

function _atril()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in atril 

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install atril

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install atril

	elif [[ -x $(command -v pkg 2> /dev/null) ]]; then
		sudo pkg install atril

	fi
}

#-----------------------------------------------------#

function _fontes_microsoft()
{
	case "$os_id" in
		debian|linuxmint|ubuntu) package_man_cli msttcorefonts ttf-mscorefonts-installer;;
		fedora) package_man_cli mscore-fonts;;
		opensuse-tumbleweed) package_man_cli fetchmsttfonts;;
		*) _prog_not_found;;
	esac
}

#-----------------------------------------------------#

function _libreoffice_appimage()
{
# https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage
local url='https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage'
local path_arq="$dir_user_cache/$(basename $url)"
local soma_libreoffice='4dc846ccf77114594b9f3fd1ffb398f784adfcce75371f22551612e83c3ef1e6'

	_dow "$url" "$path_arq" --curl || return 1
	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(_c 32)=> $(_c)Feito somente download."; return 0; }

	command -v "${array_libreoffice_dirs[1]}" 2> /dev/null && { _msg_pack_instaled 'libreoffice-appimage'; return 0; }

	_check_sum "$path_arq" "$soma_libreoffice" || {
		echo "$(_c 31)=> $(_c)Erro função $(_c 31)_check_sum $(_c)retornou erro"
		echo "$(_c 31)=> Arquivo não confiável: $path_arq $(_c)" 
		return 1 
	}

	# .desktop
	echo '[Desktop Entry]' | tee "${array_libreoffice_dirs[0]}"
	{
		echo "Encoding=UTF-8"
		echo "Name=LibreOffice AppImage"
		echo "Exec=${array_libreoffice_dirs[1]}"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=libreoffice"
		echo "Type=Application"
		echo "Categories=Office;WordProcessor;"
	} | tee -a "${array_libreoffice_dirs[0]}"

cp -u "$path_arq" "${array_libreoffice_dirs[1]}"
chmod u+x "${array_libreoffice_dirs[1]}"
chmod u+x "${array_libreoffice_dirs[0]}"

	cp -u "${array_libreoffice_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_libreoffice_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_libreoffice_dirs[0]}" ~/Desktop/ 2> /dev/null

	if command -v "${array_libreoffice_dirs[1]}" 1> /dev/null 2>&1; then
		_msg 'LibreOfficeAppImage instalado com sucesso'
		#studio
		return 0

	else
		echo "=> Função $(_c 31)_libreoffice_appimage $(_c)retornou [erro]"
		return 1	

	fi
}

#-----------------------------------------------------#
_libreoffice_ptbr(){
	# Verificar qual o idioma do usuário atual
	local _lang=$(printenv | grep -m 1 '^LANG=' | sed 's/.*=//g')
	
	# Se for "pt_BR.UTF-8" instalar suporte para português do Brasil.
	if [[ "$_lang" != 'pt_BR.UTF-8' ]]; then
		return 0
	fi

	case "$os_id" in
		debian) sudo apt install -y libreoffice-help-pt-br libreoffice-l10n-pt-br;;
		ubuntu|linuxmint) sudo apt install -y libreoffice-help-pt-br libreoffice-l10n-pt-br;;
		fedora) sudo dnf install -y libreoffice-langpack-pt-BR;;
		open-suse) sudo zypper in libreoffice-l10n-pt_BR;;
		arch) sudo pacman -S libreoffice-fresh-pt-br;;
		freebsd) sudo pkg install pt_BR-libreoffice;;
	esac
}
#-----------------------------------------------------#

function _libreoffice()
{
	case "$os_id" in 
		debian|ubuntu|linuxmint) sudo apt install -y libreoffice;;
		fedora) sudo dnf install -y libreoffice;;
		open-suse) sudo zypper in -y libreoffice-l10n-pt_BR;;
		arch) sudo pacman -S libreoffice;;
		freebsd) sudo pkg install libreoffice;;
		*) _libreoffice_appimage;;
	esac

	_libreoffice_ptbr
}

#-----------------------------------------------------#


