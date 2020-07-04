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
function _ubuntu_msttcorefonts()
{
	#local url_msttcorefonts='http://mirrors.kernel.org/ubuntu/pool/multiverse/m/msttcorefonts/ttf-mscorefonts-installer_3.4+nmu1ubuntu2_all.deb'
	local url_msttcorefonts='http://ftp.de.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.6_all.deb'
	local url_msttcorefonts='http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb'
	local path_file="$Dir_Downloads/$(basename $url_msttcorefonts)"

	_dow "$url_msttcorefonts" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	_package_man_distro cabextract || return 1
	_DPKG --install "$path_file" || return 1
	return 0

}

function _fontes_microsoft()
{
	# https://sempreupdate.com.br/como-instalar-fontes-microsoft-opensuse/
	case "$os_id" in
		linuxmint|ubuntu) _ubuntu_msttcorefonts;;
		debian) _package_man_distro msttcorefonts 'ttf-mscorefonts-installer';;
		fedora) _package_man_distro 'mscore-fonts';;
		'opensuse-tumbleweed'|'opensuse-leap') _package_man_distro fetchmsttfonts;;
		*) _INFO 'pkg_not_found' 'fontes-ms'; return 1;;
	esac
}

#-----------------------------------------------------#
function __configure_fuse_archlinux__()
{
	# https://hamacker.wordpress.com/ubuntu-perfeito/ubuntu-perfeito-faca-voce-mesmo/habilitando-o-fuse/
	# cat /etc/fuse.conf - Vizualizar configuração atual
	# Se a linha que contém a configuração (user_allow_other) estiver comentada
	# Um usuário comun não terá permissão para montar arquivos virtuais.  
	# user_allow_other - esta linha deve ser descomentada.
	_package_man_distro squashfuse fuseiso

	sudo modprobe fuse
	sudo groupadd fuse
	sudo usermod -a -G fuse "$USER"

	[[ ! -f /etc/fuse.conf ]] && return 1

	yellow "Configurando: /etc/fuse.conf"
	if ! grep -q ^'user_allow_other' /etc/fuse.conf; then
		if grep -q ^'#user_allow_other' /etc/fuse.conf; then
			sudo sed -i 's|#user_allow_other|user_allow_other|g' /etc/fuse.conf
		else
			echo 'user_allow_other' | sudo tee -a /etc/fuse.conf
		fi
	fi
	
	sudo mkdir -p '/etc/modules-load.d/'
	echo "fuse" | sudo tee '/etc/modules-load.d/fuse.conf' 1> /dev/null
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

	# .desktop
	yellow "Criando arquivo .desktop"
	echo '[Desktop Entry]' | sudo tee "${array_libreoffice_dirs[file_desktop]}" 1> "$LogFile"
	{
		echo "Encoding=UTF-8"
		echo "Name=LibreOffice AppImage"
		echo "Exec=${array_libreoffice_dirs[link_execution]}"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=libreoffice"
		echo "Keywords=libreoffice;editor;office;"
		echo "Type=Application"
		echo "Categories=Office;WordProcessor;"
	} | sudo tee -a "${array_libreoffice_dirs[file_desktop]}" 1> "$LogFile"

	yellow "Copiando arquivos"
	sudo cp -u "$path_file" "${array_libreoffice_dirs[file_appimage]}"
	sudo ln -sf "${array_libreoffice_dirs[file_appimage]}" "${array_libreoffice_dirs[link_execution]}"
	sudo chmod a+x "${array_libreoffice_dirs[file_appimage]}"
	# sudo chmod u+x "${array_libreoffice_dirs[file_desktop]}" 
	sudo chmod a+x "${array_libreoffice_dirs[link_execution]}"

	yellow "Criando atalho na Área de trabalho"
	cp -u "${array_libreoffice_dirs[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_libreoffice_dirs[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_libreoffice_dirs[file_desktop]}" ~/Desktop/ 2> /dev/null

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


