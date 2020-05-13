#!/usr/bin/env bash
#
#
#
#

#-----------------------------------------------------#

function _atril()
{
	_package_man_distro atril
}

#-----------------------------------------------------#

function _fontes_microsoft()
{
	case "$os_id" in
		debian|linuxmint|ubuntu) _package_man_distro msttcorefonts 'ttf-mscorefonts-installer';;
		fedora) _package_man_distro 'mscore-fonts';;
		opensuse-tumbleweed) _package_man_distro fetchmsttfonts;;
		*) _INFO 'pkg_not_found' 'fontes-ms'; return 1;;
	esac
}

#-----------------------------------------------------#

function _libreoffice_appimage()
{
	# https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage
	# https://github.com/AppImage/AppImageKit/wiki/FUSE
	# https://wiki.archlinux.org/index.php/FUSE
	# 
	local url='https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage'
	local path_file="$Dir_Downloads/$(basename $url)"
	local hash_libreoffice='4dc846ccf77114594b9f3fd1ffb398f784adfcce75371f22551612e83c3ef1e6'

	_dow "$url" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Já instalado.
	if _WHICH 'libreoffice-appimage'; then
		_INFO 'pkg_are_instaled' 'libreoffice-appimage'
		return 0
	fi

	#_check_sum "$path_file" "$hash_libreoffice" || return 1

	# .desktop
	green "Criando arquivo .desktop"
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

	cp -u "$path_file" "${array_libreoffice_dirs[1]}"
	ln -sf "$Dir_User_Bin/libreoffice-amd64.AppImage" "$Dir_User_Bin/libreoffice-appimage"
	chmod u+x "${array_libreoffice_dirs[1]}"
	chmod u+x "${array_libreoffice_dirs[0]}"
	ln -sf "$Dir_User_Bin/libreoffice-amd64.AppImage" "$Dir_User_Bin/libreoffice-appimage"
	chmod u+x "$Dir_User_Bin/libreoffice-appimage"

	green "Criando atalho na Área de trabalho"
	cp -u "${array_libreoffice_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_libreoffice_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_libreoffice_dirs[0]}" ~/Desktop/ 2> /dev/null

	if _WHICH 'libreoffice-appimage'; then
		_INFO 'pkg_sucess' 'libreoffice-appimage'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'libreoffice-appimage'
		return 1
	fi
}

#-----------------------------------------------------#

_libreoffice_ptbr(){
	# Verificar qual o idioma do usuário atual
	local lang=$(set | grep -m 1 '^LANG=' | sed 's/.*=//g')
	
	# Se for "pt_BR.UTF-8" instalar suporte para português do Brasil.
	if [[ "$lang" != 'pt_BR.UTF-8' ]]; then
		return 0
	fi

	case "$os_id" in
		debian) _package_man_distro 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		ubuntu|linuxmint) _package_man_distro 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		fedora) _package_man_distro 'libreoffice-langpack-pt-BR';;
		open-suse) _package_man_distro 'libreoffice-l10n-pt_BR';;
		arch) _package_man_distro 'libreoffice-fresh-pt-br';;
		freebsd) _package_man_distro 'pt_BR-libreoffice';;
	esac
}
#-----------------------------------------------------#

function _libreoffice()
{
	case "$os_id" in 
		debian|ubuntu|linuxmint) _package_man_distro libreoffice;;
		fedora) _package_man_distro libreoffice;;
		open-suse) _package_man_distro 'libreoffice-l10n-pt_BR';;
		arch) _package_man_distro libreoffice;;
		freebsd) _package_man_distro libreoffice;;
		*) _libreoffice_appimage;;
	esac

	_libreoffice_ptbr
}

#-----------------------------------------------------#

#=============================================================#
# Instalar todos os pacotes da categória Office.
#=============================================================#
_Office_All()
{
	if [[ -z "$install_yes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Escritório'" || return 0
	fi
	_atril
	_fontes_microsoft
	_libreoffice_appimage
	_libreoffice
}


