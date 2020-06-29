#!/usr/bin/env bash
#
#

_atril()
{
	_pkg_manager_sys atril
}


_ubuntu_msttcorefonts()
{
	local url_msttcorefonts='http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb'
	local path_file="$DirDownloads/$(basename $url_msttcorefonts)"

	_dow "$url_msttcorefonts" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0
	 
	_pkg_manager_sys cabextract || return 1
	_DPKG --install "$path_file" || return 1
	return 0

}

_fontes_microsoft()
{
	case "$os_id" in
		linuxmint|ubuntu) _ubuntu_msttcorefonts;;
		debian) _pkg_manager_sys msttcorefonts 'ttf-mscorefonts-installer';;
		fedora) _pkg_manager_sys 'mscore-fonts';;
		'opensuse-tumbleweed'|'opensuse-leap') _pkg_manager_sys fetchmsttfonts;;
		*) _show_info 'ProgramNotFound' 'fontes-ms'; return 1;;
	esac
}


_libreoffice_appimage()
{
	# https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage
	# https://github.com/AppImage/AppImageKit/wiki/FUSE
	# https://wiki.archlinux.org/index.php/FUSE
	# 
	local url='https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage'
	local path_file="$DirDownloads/$(basename $url)"
	local hash_libreoffice='4dc846ccf77114594b9f3fd1ffb398f784adfcce75371f22551612e83c3ef1e6'

	_dow "$url" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0

	# Já instalado.
	is_executable 'libreoffice-appimage' && _show_info 'PkgInstalled' && return 0

	_show_info "AddFileDesktop"
	echo '[Desktop Entry]' | tee "${destinationFilesLibreofficeAppimage[file_desktop]}" 1> /dev/null
	{
		echo "Encoding=UTF-8"
		echo "Name=LibreOffice AppImage"
		echo "Exec=${destinationFilesLibreofficeAppimage[file_appimage]}"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=libreoffice"
		echo "Keywords=libreoffice;editor;office;"
		echo "Type=Application"
		echo "Categories=Office;WordProcessor;"
	} | tee -a "${destinationFilesLibreofficeAppimage[file_desktop]}" 1> /dev/null

	cp -u "$path_file" "${destinationFilesLibreofficeAppimage[file_appimage]}"
	chmod a+x "${destinationFilesLibreofficeAppimage[file_appimage]}" 
	chmod a+x "${destinationFilesLibreofficeAppimage[file_desktop]}"

	_yellow "Criando atalho na Área de trabalho"
	ln -sf "${destinationFilesLibreofficeAppimage[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesLibreofficeAppimage[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesLibreofficeAppimage[file_desktop]}" ~/Desktop/ 2> /dev/null

	if is_executable 'libreoffice-appimage'; then
		_show_info 'SuccessInstalation' 'libreoffice-appimage'
		return 0
	else
		_show_info 'InstalationFailed' 'libreoffice-appimage'
		return 1
	fi
}



_libreoffice_ptbr(){
	# Verificar qual o idioma do usuário atual
	local lang=$(printenv | grep -m 1 '^LANG=' | sed 's/.*=//g')
	
	# Se for "pt_BR.UTF-8" instalar suporte para português do Brasil.
	[[ "$lang" != 'pt_BR.UTF-8' ]] && return 0

	case "$os_id" in
		debian) _pkg_manager_sys 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		ubuntu|linuxmint) _pkg_manager_sys 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		fedora) _pkg_manager_sys 'libreoffice-langpack-pt-BR';;
		'open-suse') _pkg_manager_sys 'libreoffice-l10n-pt_BR';;
		arch) _pkg_manager_sys 'libreoffice-fresh-pt-br';;
		freebsd) _pkg_manager_sys 'pt_BR-libreoffice';;
	esac
}


_libreoffice()
{
	case "$os_id" in 
		debian|ubuntu|linuxmint) _pkg_manager_sys libreoffice;;
		fedora) _pkg_manager_sys libreoffice;;
		'open-suse') _pkg_manager_sys 'libreoffice-l10n-pt_BR';;
		arch) _pkg_manager_sys libreoffice;;
		freebsd) _pkg_manager_sys libreoffice;;
		*) _libreoffice_appimage; return;;
	esac

	_libreoffice_ptbr
}


#=============================================================#
# Instalar todos os pacotes da categória Office.
#=============================================================#
_Office_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Escritório'" || return 0
	fi
	_atril
	_fontes_microsoft
	_libreoffice_appimage
	_libreoffice
}


