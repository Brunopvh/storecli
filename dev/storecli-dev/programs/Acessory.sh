#!/usr/bin/env bash
#
#
#

#=====================================================#
# Etcher
#=====================================================#

function _etcher_ubuntu()
{
	# https://github.com/balena-io/etcher#debian-and-ubuntu-based-package-repository-gnulinux-x86x64
	_yellow "Adicionando key e repositório"
	sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 379CE192D401AB61
	echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
	_APT update
	_pkg_manager_sys 'balena-etcher-electron'
}

function _etcher_archlinux()
{
	# https://aur.archlinux.org/packages/balena-etcher/
	url_pkgbuild='https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=balena-etcher'
	url_snapshot='https://aur.archlinux.org/cgit/aur.git/snapshot/balena-etcher.tar.gz'
	path_file="$directoryUSERdownloads/etcher_archlinux.tar.gz"
	
	_dow "$url_snapshot" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 
	_unpack "$path_file" || return 1
	
	cd "$DirUnpack"
	mv $(ls -d balena-*) "$DirTemp/etcher"
	cd "$DirTemp/etcher"
	_yellow "Executando: makepkg -s"
	makepkg -s
	
	_green "Executando sudo pacman -U $(ls etcher*.tar.*)"
	sudo pacman -U $(ls etcher*.tar.*)
}

function _etcher_fedora()
{
	# https://github.com/balena-io/etcher
	_white "Adicionando repositório"
	sudo curl -sSL https://balena.io/etcher/static/etcher-rpm.repo -o /etc/yum.repos.d/etcher-rpm.repo
	_pkg_manager_sys 'balena-etcher-electron'
}

function _etcher_appimage()
{
	# https://github.com/balena-io/etcher/releases/download/v1.5.81/balenaEtcher-1.5.81-x64.AppImage
	url='https://github.com/balena-io/etcher/releases/download/v1.5.99/balenaEtcher-1.5.99-x64.AppImage'
	path_file="$directoryUSERdownloads/$(basename $url)"

	_dow "$url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 
	
	# Já instalado.
	if is_executable 'balena-etcher-electron'; then
		_green "Etcher está instalado"
		return 0
	fi
	
	cp "$path_file" "${destinationFilesEtcher[file_appimage]}"
	sudo chmod a+x "${destinationFilesEtcher[file_appimage]}"
	
	_white "Criando arquivo .desktop"
	
	echo "[Desktop Entry]" | tee "${destinationFilesEtcher[file_desktop]}" 1> /dev/null
	{
        echo "Name=BalenaEtcher"
        echo "Comment=Flash OS images to SD cards and USB drives, safely and easily"
        echo "Version=1.0"
        echo "Icon=balena-etcher-electron"
        echo "Exec=${destinationFilesEtcher[file_appimage]}"
        echo "Terminal=false"
        echo "Keywords=etcher;flash;usb;"
        echo "Categories=Utility;"
        echo "Type=Application"
    } | tee -a "${destinationFilesEtcher[file_desktop]}" 1> /dev/null

  
	_white "Criando atalho na Área de trabalho"
	cp -u "${destinationFilesEtcher[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesEtcher[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesEtcher[file_desktop]}" ~/Desktop/ 2> /dev/null 

	if is_executable 'gtk-update-icon-cache'; then
		'gtk-update-icon-cache'
	fi

	if is_executable 'balena-etcher-electron'; then
		_green 'Etcher instalado com sucesso'
		return 0
	else
		_red '(_etcher) falha'
		return 1
	fi
}

function _etcher()
{
	case "$os_id" in
		ubuntu|linuxmint|debian) _etcher_ubuntu;;
		fedora) _etcher_fedora;;
		arch) _etcher_archlinux;;
		*) _etcher_appimage;;
	esac
}

#=====================================================#
# Gnome-Disk
#=====================================================#
function _gnome_disk()
{
	_pkg_manager_sys 'gnome-disk-utility'
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
		_red "Necessário sessão gráfica (Xorg) para instalar esse pacote"
		return 1
	fi

	local vc_pg='https://www.veracrypt.fr/en/Downloads.html'
	local vc_html=$(grep -m 1 "http.*verac.*tar.bz2" <<< $(curl -sSL "$vc_pg"))
	local vc_url_dow=$(echo "$vc_html" | sed 's/&#43;/+/g' | sed 's/.*="//g;s/">.*//g')
	local vc_url_sig="${vc_url_dow}.sig"

	local path_file="$directoryUSERdownloads/$(basename $vc_url_dow)"
	local path_sig="${path_file}.sig"
	

	_dow "$vc_url_sig" "$path_sig" || return 1
	_dow "$vc_url_dow" "$path_file" || return 1

	# Somente baixar
	if [[ "$DownloadOnly" == 'True' ]]; then
		_green 'DownloadOnly' "$path_file"
		return 0 
	fi

	# Já instalado.
	if is_executable 'veracrypt'; then
		_green 'Veracrypt está instalado'
		return 0
	fi

	# Importar chaves públicas.
	_green "Importando key [https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc]"
	curl -sSL 'https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc' -o - | gpg --import
	_verify_sig "$path_sig" "$path_file" || return 1
	_unpack "$path_file" || return 1

	cd "$DirUnpack"
	mv $(ls veracrypt*setup-gui-x64) "$DirUnpack/veracryptx64" 1> /dev/null
	chmod +x "$DirUnpack/veracryptx64" 
	xterm -title 'Instalando veracrypt' "$DirUnpack/veracryptx64" 

	case "$os_id" in
		arch) _green "Instalando o pacote: gtk2"; _pkg_manager_sys gtk2;;
	esac

	if is_executable 'veracrypt'; then
		_green 'Veracrypt foi instalado com sucesso'
		return 0
	else
		_red '(_veracrypt) falha'
		return 1
	fi
}

#=====================================================#
# ==================>>> WoeUsb <<<====================#
#=====================================================#

# Debian/Ubuntu/Mint
function _woeusb_debian()
{
	# Instalar dependências, baixar o programa e compilar o código fonte.
	# libwxgtk3.0-gtk3-dev
	local woeusbRequeriments=('devscripts' 'equivs'  'grub-pc-bin' 'p7zip-full')
	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$DirTemp/WoeUSB"
		
	_APT update || return 1
	
	_yellow "Instalando: ${woeusbRequeriments[@]}"
	_pkg_manager_sys "${woeusbRequeriments[@]}" || return 1
	
	# Instalar libwxgtk3
	case "$os_codename" in
		buster|bionic|tricia) _pkg_manager_sys 'libwxgtk3.0-dev' || return 1;;
		focal) _pkg_manager_sys 'libwxgtk3.0-gtk3-dev' || return 1;;
	esac
	
	# Clonar o repositório
	_gitclone "$github_woeusb" || return 1
	
	cd "$dir_woeusb"
	_yellow "Executando: ./setup-development-environment.bash"; ./setup-development-environment.bash
	_yellow "Executando: dpkg-buildpackage -uc -b -d"
	
	if ! sudo dpkg-buildpackage -uc -b -d; then
		_red "Falha: dpkg-buildpackage -uc -b -d"
		return 1 
	fi

	_msg "OK"

	# Instalação do pacote .deb
	# O pacote .deb será gerado um diretório atrás do diretório de 
	# compilação, ou seja cd ..
	cd "$DirTemp"
	sudo mv woeusb_*amd64.deb woeusb_amd64.deb
	if _DPKG --install "$DirTemp/woeusb_amd64.deb"; then
		_green 'WoeUSB foi instalado com sucesso'	
	else
		_BROKE # Remover pacotes quebrados.
		_green '(WoeUSB) falha'
		return 1
	fi

	#===============================================================#
	#======================== salvar o arquivo .deb ? ==============#
	if _YESNO "Deseja salvar o arquivo woeusb_amd64.deb"; then
		mkdir -p "$HOME/Downloads"
		cp -vu "$DirTemp/woeusb_amd64.deb" "$HOME"/Downloads/woeusb_amd64.deb
		_white "Arquivo salvo em: $HOME/Downloads/woeusb_amd64.deb"
	fi
}



function _woeusb_archlinux()
{
	# Clonar o repositório e compilar o pacote
	# Requerimentos para archlinux wx-config|wxGTK-devel dh-autoreconf devscripts

	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$DirTemp/WoeUSB"

	# Habilitar repositório [multilib] em /etc/pacman.conf
	if ! sudo "$Dir_Storecli_Scripts"/addrepo.py --repo arch; then
		_red "Falha: $Dir_Storecli_Scripts/addrepo.py"
	fi	

	# Instalar requerimentos antes de compilar
	_pkg_manager_sys 'wxgtk3' 'lib32-wxgtk2'
			
	_gitclone "$github_woeusb" || return 1
	chmod -R +x "$dir_woeusb" 

	cd "$dir_woeusb"
	_yellow "Executando: ./setup-development-environment.bash"
	if ! ./setup-development-environment.bash 2>> "$LogErro"; then
		_red "Falha: ./setup-development-environment"
		return 1
	fi


	_yellow "Executando: autoreconf --force --install"
	if ! autoreconf --force --install 2>> "$LogErro"; then
		_red "Falha: autoreconf --force --install"
		return 1
	fi

	_yellow "Executando: ./configure" 
	if ! ./configure 2>> "$LogErro"; then
		_red "Falha: ./configure"
		return 1
	fi

	_yellow "Executando: make" 
	if ! make 2>> "$LogErro"; then
		_red "Falha: make"
		return 1
	fi


	_yellow "Executando: make install"
	if ! sudo make install; then
		_red "Falha: sudo make install"
		return 1
	fi
}


function _woeusb_github()
{
	# Clonar o repositório e compilar o pacote
	# Requerimentos para compilar o pacote:
	# wx-config|wxGTK-devel dh-autoreconf devscripts

	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$DirTemp/WoeUSB"

	_gitclone "$github_woeusb" || return 1
	chmod -R +x "$dir_woeusb"

	_yellow "Instale wx-config no seu sistema"
	cd "$dir_woeusb"

	_yellow "Executando: ./setup-development-environment.bash"
	if ! ./setup-development-environment.bash 2>> "$LogErro"; then
		_red "Falha: ./setup-development-environment"
		return 1
	fi


	_yellow "Executando: autoreconf --force --install"
	if ! autoreconf --force --install 2>> "$LogErro"; then
		_red "Falha: autoreconf --force --install"
		return 1
	fi


	_yellow "Executando: ./configure" 
	if ! ./configure 2>> "$LogErro"; then
		_red "Falha: ./configure"
		return 1
	fi


	_yellow "Executando: make" 
	if ! make 2>> "$LogErro"; then
		_red "Falha: make"
		return 1
	fi


	_yellow "Executando: make install"
	if ! sudo make install; then
		_red "Falha: sudo make install"
		return 1
	fi
}
	
function _woeusb()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _woeusb_debian;;
		fedora) _pkg_manager_sys 'WoeUSB.x86_64';;
		'opensuse-leap') _pkg_manager_sys WoeUSB;;
		arch) _woeusb_archlinux;;
		*) _woeusb_github;;
	esac
		
	if is_executable 'woeusb'; then
		_green 'woeusb instalado com sucesso'
		return 0
	else
		_red "(_woeusb) falha"
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

