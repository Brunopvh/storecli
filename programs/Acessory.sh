#!/usr/bin/env bash
#
#
#


#=====================================================#
# Etcher
#=====================================================#
function _etcher_debian()
{
	# https://www.balena.io/etcher/
	# https://github.com/balena-io/etcher/releases/ (VERSÕES PARA DOWNLOAD)
	# https://github.com/resin-io/etcher/releases/download/v1.1.1/etcher-electron_1.1.1_amd64.deb
	# https://github.com/balena-io/etcher/releases/download/v1.5.81/balena-etcher-electron_1.5.81_amd64.deb
	#
	local url='https://github.com/balena-io/etcher/releases/download/v1.5.81/balena-etcher-electron_1.5.81_amd64.deb'
	local path_file="$Dir_Downloads/$(basename $url)"

	_dow "$url" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	yellow "Instalando: libappindicator1 libpango1.0-0"
	_package_man_distro libappindicator1 'libpango1.0-0'
	yellow "Instalando: $path_file"
	sudo dpkg --install "$path_file"
	_BROKE # Remover pacotes quebrados
}

function _etcher_ubuntu()
{
	# https://github.com/balena-io/etcher#debian-and-ubuntu-based-package-repository-gnulinux-x86x64
	yellow "Adicionando key e repositório"
	sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 379CE192D401AB61
	echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
	_APT update
	_package_man_distro 'balena-etcher-electron'
}

function _etcher_archlinux()
{
	# https://aur.archlinux.org/packages/balena-etcher/
	local url_pkgbuild='https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=balena-etcher'
	local url_snapshot='https://aur.archlinux.org/cgit/aur.git/snapshot/balena-etcher.tar.gz'
	local path_file="$Dir_Downloads/etcher_archlinux.tar.gz"
	
	_dow "$url_snapshot" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi
	
	_unpack "$path_file" || return 1
	
	cd "$Dir_Unpack"
	mv $(ls -d balena-*) "$dir_temp/etcher"
	cd "$dir_temp/etcher"
	yellow "Executando: makepkg -s"
	makepkg -s
	
	#green "Executando sudo pacman -U $(ls etcher*.tar.*)"
	#sudo pacman -U $(ls etcher*.tar.*)
}

function _etcher_fedora()
{
	# https://github.com/balena-io/etcher
	white "Adicionando repositório"
	sudo curl -sSL https://balena.io/etcher/static/etcher-rpm.repo -o /etc/yum.repos.d/etcher-rpm.repo
	_package_man_distro 'balena-etcher-electron'
}

function _etcher_appimage()
{
	# Baixar o etcher AppImage em seguida mover para /opt e criar link simbólico em
	# /usr/local/bin/ e configurar o arquivo .desktop
	# https://github.com/balena-io/etcher/releases/download/v1.5.81/balenaEtcher-1.5.81-x64.AppImage

	local url='https://github.com/balena-io/etcher/releases/download/v1.5.81/balenaEtcher-1.5.81-x64.AppImage'
	local path_file="$Dir_Downloads/$(basename $url)"

	_dow "$url" "$path_file" || return 1

	# Somente baixar
	[[ "$download_only" == 'True' ]] && _INFO 'download_only' "$path_file" && return 0 
	
	
	# Já instalado.
	if _WHICH 'balena-etcher-electron'; then
		_INFO 'pkg_are_instaled' 'balena-etcher-electron'
		return 0
	fi
	
	white "Criando link simbólico em: ${array_etcher_dirs[2]}"
	sudo cp "$path_file" "${array_etcher_dirs[1]}"
	sudo chmod a+x "${array_etcher_dirs[1]}"
	sudo ln -sf "${array_etcher_dirs[1]}" "${array_etcher_dirs[2]}"
	
	
	white "Criando arquivo .desktop"
	
	echo "[Desktop Entry]" | sudo tee "${array_etcher_dirs[0]}"
	{
        echo "Name=BalenaEtcher"
        echo "Comment=Flash OS images to SD cards and USB drives, safely and easily"
        echo "Version=1.0"
        echo "Icon=balena-etcher-electron"
        echo "Exec=${array_etcher_dirs[2]}"
        echo "Terminal=false"
        echo "Categories=Utility;"
        echo "Type=Application"
    } | sudo tee -a "${array_etcher_dirs[0]}"

  
	white "Criando atalho na Área de trabalho"
	cp -u "${array_etcher_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_etcher_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${array_etcher_dirs[0]}" ~/Desktop/ 2> /dev/null 

	if _WHICH 'balena-etcher-electron'; then
		_INFO 'pkg_sucess' 'balena-etcher-electron'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'balena-etcher-electron'
		return 1
	fi
}

function _etcher()
{
	case "$os_id" in
		ubuntu|debian) _etcher_ubuntu;;
		fedora) _etcher_fedora;;
		arch) _etcher_appimage;;
		*) _etcher_appimage;;
	esac
}

#=====================================================#
# Gnome-Disk
#=====================================================#
function _gnome_disk()
{
	#white "Instalando $(SPACE_TEXT Instalando) gnome-disk-utility"
	_package_man_distro 'gnome-disk-utility'
}

#=====================================================#
# Veracrypt
#=====================================================#
function _veracrypt()
{
	# https://www.veracrypt.fr/en/Digital%20Signatures.html
	# 5069A233D55A0EEB174A5FC3821ACD02680D16DE
	#
	# Chechar  fingerprint
	# gpg --import --import-options show-only VeraCrypt_PGP_public_key.asc
	# 
	# Importar public key
	# gpg --import VeraCrypt_PGP_public_key.asc
	#
	# Verificar a assinatura do arquivo de instalação.
	# gpg --verify veracrypt-1.23-setup.tar.bz2.sig veracrypt-1.23-setup.tar.bz2
	#
	# 'https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2'
	# https://launchpad.net/veracrypt/trunk/1.24-update4/&#43;download/veracrypt-1.24-Update4-setup.tar.bz2
	#
	# libgtk-x11-2.0.so.0 (ArchLinux)
	#
	# Necessário sessão gráfica para instalar esse programa.
	if [[ -z "$DISPLAY" ]]; then
		red "Necessário sessão gráfica (Xorg) para instalar esse pacote"
		return 1
	fi

	local vc_pg='https://www.veracrypt.fr/en/Downloads.html'
	local vc_html=$(grep -m 1 "http.*verac.*tar.bz2" <<< $(curl -sSL "$vc_pg"))
	local vc_url_dow=$(echo "$vc_html" | sed 's/&#43;/+/g' | sed 's/.*="//g;s/">.*//g')
	local vc_url_sig="${vc_url_dow}.sig"

	local path_file="$Dir_Downloads/$(basename $vc_url_dow)"
	local path_sig="${path_file}.sig"
	

	_dow "$vc_url_sig" "$path_sig" || return 1
	_dow "$vc_url_dow" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Já instalado.
	if _WHICH 'veracrypt'; then
		_INFO 'pkg_are_instaled' 'veracrypt'
		return 0
	fi

	# Importar chaves públicas.
	green "Importando key [https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc]"
	curl -sSL 'https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc' -o - | gpg --import
	_verify_sig "$path_sig" "$path_file" || return 1
	_unpack "$path_file" || return 1

	cd "$Dir_Unpack"
	mv $(ls veracrypt*setup-gui-x64) "$Dir_Unpack/veracryptx64" 1> /dev/null
	chmod +x "$Dir_Unpack/veracryptx64"
	#sudo xterm -title 'Instalando veracrypt' "$Dir_Unpack/veracryptx64" 
	xterm -title 'Instalando veracrypt' "$Dir_Unpack/veracryptx64" 

	case "$os_id" in
		arch) green "Instalando o pacote [gtk2]"; _package_man_distro gtk2;;
	esac

	if _WHICH 'veracrypt'; then
		_INFO 'pkg_sucess' 'veracrypt'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'veracrypt'
		return 1
	fi
}

#=====================================================#
# WoeUsb
#=====================================================#
function _woeusb_debian(){
	github_woeusb="https://github.com/slacka/WoeUSB.git"

	local dir_woeusb="$dir_temp/WoeUSB"
	local requeriments_woeusb_debian=(
			'devscripts' 'equivs' 'libwxgtk3.0-dev' 'grub-pc-bin' 'p7zip-full'
		)

	white "Necessário instalar os seguintes pacotes: ${requeriments_woeusb_debian[@]}"
	_YESNO "Deseja proseguir" || return 1
	

	_APT update || return 1
	_package_man_distro "${requeriments_woeusb_debian[@]}" || return 1

	cd "$dir_temp" && sudo rm -rf *  # Limpar o diretório temporário.
	_gitclone "$github_woeusb" || return 1

	ls -hl "$dir_woeusb"/debian/changelog || return 1

	if ! sudo sed -i 's/(@@WOEUSB_VERSION@@)/(1.0)/g' "$dir_woeusb"/debian/changelog; then
		red "Falha ao tentar configurar o arquivo: $dir_woeusb/debian/changelog"
		return 1
	fi

	yellow "Compilando." 
	sleep 1

	cd "$dir_woeusb"
	sudo sh -c 'dpkg-buildpackage -uc -b' || { 
		red "Falha ao tentar compilar o WoeUSB"
		return 1 
	}

	echo -e "$space_line"

	#==================================================================#
	#========================= instalação do pacote .deb ==============#
	cd ..
	if _DPKG --install "$dir_temp/woeusb_1.0_amd64.deb"; then
		echo -e "$space_line"
		_INFO 'pkg_sucess' 'WoeUSB'	
	else
		_BROKE # Remover pacotes quebrados.
		echo -e "$space_line"
		_INFO 'pkg_instalation_failed' 'WoeUSB'
		cd "$dir_temp" && sudo rm -rf *
		return 1
	fi

	#===============================================================#
	#======================== salvar o arquivo .deb ? ==============#

	green "Deseja salvar o arquivo woeusb_1.0_amd64.deb [${Yellow}s${Reset}/${Red}n${Reset}]?: "
	read -t 10 -n 1 sn

	if [[ -z "$install_yes" ]]; then
		[[ "${sn,,}" == 's' ]] && {
		mkdir -p "$HOME/Downloads"
		echo -e "$space_line"
		cp -vu "$dir_temp/woeusb_1.0_amd64.deb" "$HOME"/Downloads/woeusb_1.0_amd64.deb
		green "Arquivo salvo em: [$HOME/Downloads/woeusb_1.0_amd64.deb]"
	}
	fi

	cd "$dir_temp" && sudo rm -rf *
}


function _woeusb_ubuntu()
{
	# Instalar dependencias e em seguida baixar o codigo fonte e compilar
	# libwxgtk3.0-gtk3-dev
	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$dir_temp/WoeUSB"
		
	_APT update || return 1
	
	yellow "Instalando: 'devscripts' 'equivs'  'grub-pc-bin' 'p7zip-full'"
	if ! _package_man_distro 'devscripts' 'equivs'  'grub-pc-bin' 'p7zip-full'; then
		red "Falha: 'devscripts' 'equivs'  'grub-pc-bin' 'p7zip-full'"
		return 1
	fi
	
	
	# Instalar libwxgtk3
	case "$os_codename" in
		buster|bionic|trica) _package_man_distro 'libwxgtk3.0-dev' || return 1;;
		focal) _package_man_distro 'libwxgtk3.0-gtk3-dev' || return 1;;
	esac
	
	# Clonar o repositório
	_gitclone "$github_woeusb" || return 1
	
	cd "$dir_woeusb"
	yellow "Executando: ./setup-development-environment.bash"; ./setup-development-environment.bash
	yellow "Executando: dpkg-buildpackage -uc -b -d"
	if ! sudo dpkg-buildpackage -uc -b -d; then
		red "Falha ao tentar compilar o WoeUSB"
		cd /tmp && cd "$dir_temp" && sudo rm -rf *
		return 1 
	fi

	echo -e "$space_line"

	#==================================================================#
	# Instalação do pacote .deb
	# O pacote .deb será gerado um diretório atrás do diretório de 
	# compilação, ou seja cd ..
	cd "$dir_temp"
	sudo mv woeusb_*amd64.deb woeusb_amd64.deb
	if _DPKG --install "$dir_temp/woeusb_amd64.deb"; then
		echo -e "$space_line"
		_INFO 'pkg_sucess' 'WoeUSB'	
	else
		_BROKE # Remover pacotes quebrados.
		echo -e "$space_line"
		_INFO 'pkg_instalation_failed' 'WoeUSB'
		cd "$dir_temp" && sudo rm -rf *
		return 1
	fi

	#===============================================================#
	#======================== salvar o arquivo .deb ? ==============#
	if _YESNO "Deseja salvar o arquivo woeusb_amd64.deb"; then
		mkdir -p "$HOME/Downloads"
		cp -vu "$dir_temp/woeusb_amd64.deb" "$HOME"/Downloads/woeusb_amd64.deb
		white "Arquivo salvo em: $HOME/Downloads/woeusb_amd64.deb"
	fi

	cd "$dir_temp" && sudo rm -rf * 
}


function _woeusb_github()
{
	# Clonar o repositório e compilar o pacote
	# Requerimentos para compilar o pacote:
	# wx-config|wxGTK-devel dh-autoreconf devscripts

	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$dir_temp/WoeUSB"

	case "$os_id" in
		arch) 
			sudo "$Dir_Storecli_Scripts"/addrepo.py --repo arch || return 1	
			_package_man_distro 'wxgtk3' 'lib32-wxgtk2'
			;;

		*) 
			yellow "Instale wx-config no seu sistema"
			;;
	esac

	_gitclone "$github_woeusb" || return 1
	chmod -R +x "$dir_woeusb" 

	cd "$dir_woeusb"
	yellow "Executando: ./setup-development-environment.bash"
	if ! ./setup-development-environment.bash 2>> "$LogErro"; then
		red "Falha: ./setup-development-environment"
		return 1
	fi


	yellow "Executando: autoreconf --force --install"
	if ! autoreconf --force --install 2>> "$LogErro"; then
		red "Falha: autoreconf --force --install"
		return 1
	fi


	yellow "Executando: ./configure" 
	if ! ./configure 2>> "$LogErro"; then
		red "Falha: ./configure"
		return 1
	fi


	yellow "Executando: make" 
	if ! make 2>> "$LogErro"; then
		red "Falha: make"
		return 1
	fi


	yellow "Executando: make install"
	if ! sudo make install; then
		red "Falha: sudo make install"
		return 1
	fi
}


function _woeusb()
{
	case "$os_id" in
		debian)_woeusb_ubuntu;;
		ubuntu|linuxmint) _woeusb_ubuntu;;
		fedora) _package_man_distro 'WoeUSB.x86_64';;
		*) _woeusb_github;;
	esac
		
	if _WHICH 'woeusb'; then
		_INFO 'pkg_sucess' 'woeusb'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'woeusb'
		return 1
	fi
}


#=============================================================#
# Instalar todos os pacotes da categória Acessorios.
#=============================================================#
_Acessory_All()
{
	if [[ -z "$install_yes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Acessórios'" || return 1
	fi
	_etcher
	_gnome_disk
	_veracrypt
	_woeusb
}

