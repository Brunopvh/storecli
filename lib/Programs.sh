#!/usr/bin/env bash
#

github='https://github.com'

_etcher_ubuntu()
{
	# https://github.com/balena-io/etcher#debian-and-ubuntu-based-package-repository-gnulinux-x86x64
	_yellow "Adicionando key e repositório"
	sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 379CE192D401AB61
	echo "deb https://deb.etcher.io stable etcher" | sudo tee '/etc/apt/sources.list.d/balena-etcher.list'
	_APT update
	_pkg_manager_sys 'balena-etcher-electron'
}

_etcher_archlinux()
{
	# https://aur.archlinux.org/packages/balena-etcher/
	url_pkgbuild='https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=balena-etcher'
	url_snapshot='https://aur.archlinux.org/cgit/aur.git/snapshot/balena-etcher.tar.gz'
	path_file="$DirDownloads/etcher_archlinux.tar.gz"
	
	___download__ "$url_snapshot" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 
	_unpack "$path_file" || return 1
	
	cd "$DirUnpack"
	mv $(ls -d balena-*) "$DirTemp/etcher"
	cd "$DirTemp/etcher"
	_yellow "Executando: makepkg -s"
	makepkg -s
	
	_green "Executando sudo pacman -U $(ls etcher*.tar.*)"
	_PACMAN -U $(ls etcher*.tar.*)
}

_etcher_fedora()
{
	# https://github.com/balena-io/etcher
	_white "Adicionando repositório"
	sudo curl -sSL https://balena.io/etcher/static/etcher-rpm.repo -o /etc/yum.repos.d/etcher-rpm.repo
	_pkg_manager_sys 'balena-etcher-electron'
}

_etcher_appimage()
{
	# https://github.com/balena-io/etcher/releases/download/v1.5.81/balenaEtcher-1.5.81-x64.AppImage
	local url='https://github.com/balena-io/etcher/releases/download/v1.5.99/balenaEtcher-1.5.99-x64.AppImage'
	local path_file="$DirDownloads/$(basename $url)"

	__download__ "$url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 
	
	cp "$path_file" "${destinationFilesEtcher[file_appimage]}"
	chmod +x "${destinationFilesEtcher[file_appimage]}"
	
	_show_info 'AddFileDesktop'
	
	echo "[Desktop Entry]" > "${destinationFilesEtcher[file_desktop]}"
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
}

_etcher()
{
	# Já instalado.
	is_executable 'balena-etcher-electron' && _show_info 'PkgInstalled' 'Etcher' && return 0

	case "$os_id" in
		ubuntu|linuxmint|debian) _etcher_ubuntu;;
		fedora) _etcher_fedora;;
		arch) _etcher_appimage;;
		*) _etcher_appimage;;
	esac

	if is_executable 'balena-etcher-electron'; then
		_show_info 'SuccessInstalation' 'Etcher'
		return 0
	else
		_red '(_etcher) falha'
		return 1
	fi
}


_gnome_disk()
{
	_pkg_manager_sys 'gnome-disk-utility'
}


_veracrypt()
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

	# Necessário sessão gráfica para instalar esse programa.
	if [[ -z "$DISPLAY" ]]; then
		_red "Necessário sessão gráfica (Xorg) para instalar esse pacote"
		return 1
	fi

	# Já instalado?.
	is_executable 'veracrypt' && _show_info 'PkgInstalled' 'veracrypt' && return 0
	_yellow "Obtendo url de download aguarde"
	local vc_pg='https://www.veracrypt.fr/en/Downloads.html'
	local vc_html=$(grep -m 1 "http.*verac.*tar.bz2" <<< $(curl -sSL "$vc_pg"))
	local vc_url_download=$(echo "$vc_html" | sed 's/&#43;/+/g' | sed 's/.*="//g;s/">.*//g')
	local vc_url_AscPub='https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc'
	local vc_url_sig="${vc_url_download}.sig"
	
	local veracryptTarFile="$DirDownloads/$(basename $vc_url_download)"
	local veracryptSigFile="${veracryptTarFile}.sig"
	local veracryptAscFile="$DirDownloads/$(basename $vc_url_AscPub)"

	__download__ "$vc_url_download" "$veracryptTarFile" || return 1
	__download__ "$vc_url_sig" "$veracryptSigFile" || return 1
	__download__ "$vc_url_AscPub" "$veracryptAscFile" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	printf "%s" "[>] Importando key: "
	if gpg --import "$veracryptAscFile" 1> /dev/null 2>&1; then
		_syellow "OK"
	else
		_sred "FALHA"
		return 1
	fi

	__gpg__ --verify "$veracryptSigFile" "$veracryptTarFile" || return 1
	_unpack "$veracryptTarFile" || return 1
	cp "$DirUnpack"/$(ls veracrypt*setup-gui-x64) "$DirTemp"/veracrypt-setupx64
	chmod +x "$DirTemp"/veracrypt-setupx64
	xterm -title 'Instalando veracrypt' "$DirTemp"/veracrypt-setupx64

	case "$os_id" in
		arch) _green "Instalando o pacote: gtk2"; _pkg_manager_sys gtk2;;
	esac

	if is_executable 'veracrypt'; then
		_show_info 'SuccessInstalation' 'veracrypt'
		return 0
	else
		_show_info 'InstalationFailed' 'veracrypt'
		return 1
	fi
}


# Debian/Ubuntu/Mint
_woeusb_debian()
{
	# Instalar dependências, baixar o programa e compilar o código fonte.
	# libwxgtk3.0-gtk3-dev
	local woeusbRequeriments=('devscripts' 'equivs'  'grub-pc-bin' 'p7zip-full')
	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$DirGitclone/WoeUSB"
		
	_APT update || return 1
	
	_yellow "Instalando: ${woeusbRequeriments[@]}"
	_pkg_manager_sys "${woeusbRequeriments[@]}" || return 1
	
	# Instalar libwxgtk3
	case "$os_codename" in
		buster|bionic|tricia) _pkg_manager_sys 'libwxgtk3.0-dev' || return 1;;
		focal) _pkg_manager_sys 'libwxgtk3.0-gtk3-dev' || return 1;;
		*) _show_info 'ProgramNotFound' 'WoeUSB'; return 1;;
	esac
	
	_gitclone "$github_woeusb" || return 1
	
	cd "$dir_woeusb"
	_yellow "Executando: ./setup-development-environment.bash"; ./setup-development-environment.bash
	_yellow "Executando: dpkg-buildpackage -uc -b -d"
	
	sudo dpkg-buildpackage -uc -b -d || {
		_red "Falha: dpkg-buildpackage -uc -b -d"
		return 1 
	}

	_msg "OK"

	# Instalação do pacote .deb
	# O pacote .deb será gerado um diretório atrás do diretório de compilação, ou seja cd ..
	cd "$DirGitclone"
	sudo mv woeusb_*amd64.deb woeusb_amd64.deb
	if [[ ! -f woeusb_amd64.deb ]]; then
		_red "(_woeusb) arquivo '.deb' não encontrado"
		return 1
	fi

	if _DPKG --install "$DirGitclone/woeusb_amd64.deb"; then
		_green 'WoeUSB foi instalado com sucesso'	
	else
		_BROKE # Remover pacotes quebrados.
		_red '(WoeUSB) falha'
		return 1
	fi

	#===============================================================#
	#======================== salvar o arquivo .deb ? ==============#
	if _YESNO "Deseja salvar o arquivo woeusb_amd64.deb"; then
		mkdir -p "$HOME/Downloads"
		cp -vu "$DirGitclone/WoeUSB_amd64.deb" "$HOME"/Downloads/woeusb_amd64.deb
		_msg "Arquivo salvo em: $HOME/Downloads/woeusb_amd64.deb"
	fi
}


_woeusb_archlinux()
{
	# Clonar o repositório e compilar o pacote
	# Requerimentos para archlinux wx-config|wxGTK-devel dh-autoreconf devscripts

	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$DirGitclone/WoeUSB"

	# Habilitar repositório [multilib] em /etc/pacman.conf
	__sudo__ "$scriptAddRepo" --repo arch || {
		_red "Falha: $scriptAddRepo --repo arch"
		return 1
	}	

	# Instalar requerimentos antes de compilar
	_pkg_manager_sys 'wxgtk3' 'lib32-wxgtk2'
			
	_gitclone "$github_woeusb" || return 1
	chmod -R +x "$dir_woeusb" 

	cd "$dir_woeusb"
	_yellow "Executando: ./setup-development-environment.bash"
	./setup-development-environment.bash 2>> "$LogErro" || {
		_red "Falha: ./setup-development-environment"
		return 1
	}


	_yellow "Executando: autoreconf --force --install"
	autoreconf --force --install 2>> "$LogErro" || {
		_red "Falha: autoreconf --force --install"
		return 1
	}

	_yellow "Executando: ./configure" 
	./configure 2>> "$LogErro" || {
		_red "Falha: ./configure"
		return 1
	}

	_yellow "Executando: make" 
	make 2>> "$LogErro" || {
		_red "Falha: make"
		return 1
	}

	sudo make install || {
		_red "Falha: sudo make install"
		return 1
	}
}


_woeusb_github()
{
	# Clonar o repositório e compilar o pacote
	# Requerimentos para compilar o pacote:
	# wx-config|wxGTK-devel dh-autoreconf devscripts

	local github_woeusb="https://github.com/slacka/WoeUSB.git"
	local dir_woeusb="$DirGitclone/WoeUSB"

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
	
_woeusb()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _woeusb_debian;;
		fedora) _pkg_manager_sys 'WoeUSB.x86_64';;
		arch) _woeusb_archlinux;;
		'opensuse-leap') _pkg_manager_sys WoeUSB;;
		*) _woeusb_github;;
	esac
		
	if is_executable 'woeusb'; then
		_show_info 'SuccessInstalation' 'woeusb'
		return 0
	else
		_show_info 'InstalationFailed' 'woeusb'
		return 1
	fi
}



_android_sdktools()
{
	# https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
	local url_sdktools='https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip'
	local url_commandline_tools='https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip'
	local url_emulator='https://dl.google.com/android/repository/emulator-linux-6466327'

	local path_sdktools="$DirDownloads/$(basename $url_sdktools)"
	local path_commandline_tools="$DirDownloads/$(basename $url_commandline_tools)"
	local hash_commandline_tools='f10f9d5bca53cc27e2d210be2cbc7c0f1ee906ad9b868748d74d62e10f2c8275'
	local hash_skdtools=''
	local JDKloaction="$HOME/.local/bin/android-studio/jre"
	local SDKlocation="$HOME/Android/Sdk"

	# Baixar skdtools.
	__download__ "$url_sdktools" "$path_sdktools"
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
}


_android_studio_zip()
{
	# https://developer.android.com/studio
	local url='https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.1.0/android-studio-ide-192.6241897-linux.tar.gz'
	local hash_studio='e754dc9db31a5c222f230683e3898dcab122dfe7bdb1c4174474112150989fd7'
	local path_file="$DirDownloads/$(basename $url)"

	__download__ "$url" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	
	__shasum__ "$path_file" "$hash_studio" || return 1
	_unpack "$path_file" || return 1

	_white "Instalando android studio em ~/.local/bin"
	cd "$DirUnpack" 
	mv $(ls -d android-*) "${destinationFilesAndroidStudio[dir]}" 1> /dev/null # ~/.local/bin/androi-studio
	cp -u "${destinationFilesAndroidStudio[dir]}"/bin/studio.png "${destinationFilesAndroidStudio[file_png]}" # .png
	chmod -R +x "${destinationFilesAndroidStudio[dir]}" # ~/.local/bin/androi-studio

	# arquivo de configuração ".desktop"
	_show_info 'AddFileDesktop'
	echo '[Desktop Entry]' > "${destinationFilesAndroidStudio[file_desktop]}"
	{
		echo "Version=1.0"
		echo "Type=Application"
		echo "Name=Android Studio"
		echo "Icon=studio.png"
		echo "Exec=sh -c 'cd ${destinationFilesAndroidStudio[dir]}/bin && ./studio.sh'"
		echo "Comment=The Drive to Develop"
		echo "Categories=Development;IDE;"
		echo "Terminal=false"
		echo "StartupWMClass=jetbrains-studio"
	} >> "${destinationFilesAndroidStudio[file_desktop]}"

	# Atalho para linha de comando.
	echo '#!/bin/sh' > "${destinationFilesAndroidStudio[link]}" # ~/.local/bin/studio
	echo "cd ${destinationFilesAndroidStudio[dir]}/bin && ./studio.sh" >> "${destinationFilesAndroidStudio[link]}"

	# Permissão.
	chmod u+x "${destinationFilesAndroidStudio[file_desktop]}"
	chmod u+x "${destinationFilesAndroidStudio[link]}"

	# Área de trabalho.
	cp -u "${destinationFilesAndroidStudio[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesAndroidStudio[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesAndroidStudio[file_desktop]}" ~/Desktop/ 2> /dev/null

}

_android_studio_debian()
{
	# Encerrar a função se os sistema não for baseado em debian.
	if [[ ! -f /etc/debian_version ]]; then
		return 1
	fi

	local debianBusterRequeriments=(
		'qemu-kvm' 
		'libvirt-clients' 
		'libvirt-daemon-system'
		lib32z1 
		'lib32stdc++6' 
		lib32gcc1 
		lib32ncurses6 
		lib32tinfo6 
		'libc6-i386'
		)

	_APT update
	_green "Instalando: openjdk-11-jdk"
	_pkg_manager_sys 'openjdk-11-jdk'

	for c in "${debianBusterRequeriments[@]}"; do
		_msg "Instalando: $c"
		_pkg_manager_sys "$c"
	done
	
	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	_msg "Adicionando $USER aos grupos: | libvirt | libvirt-qemu |" 
	__sudo__ adduser "$USER" libvirt
	__sudo__ adduser "$USER" 'libvirt-qemu'

	_android_studio_zip || return 1
}


_android_archlinux()
{
	_android_studio_zip
}


_android_studio_ubuntu()
{
	# Encerrar a função se os sistema não for baseado em debian.
	if [[ ! -f /etc/debian_version ]]; then
		return 1
	fi

	local ubuntuBionicRequeriments=(
		'qemu-kvm' 
		'libvirt-bin' 
		'ubuntu-vm-builder' 
		'bridge-utils'
		lib32z1 
		lib32ncurses5 
		'lib32stdc++6' 
		lib32gcc1 
		lib32tinfo5 
		'libc6-i386'
		)

	_APT update
	_msg "Instalando: openjdk-8-jdk"
	_pkg_manager_sys 'openjdk-8-jdk'

	for c in "${ubuntuBionicRequeriments[@]}"; do
		_msg "Instalando: $c"
		_pkg_manager_sys "$c"
	done
	
	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	_msg "Adicionando $USER aos grupos: | libvirt | libvirt-qemu |" 
	__sudo__ adduser "$USER" libvirt
	__sudo__ adduser "$USER" 'libvirt-qemu'

	_android_studio_zip || return 1
}


_android_studio_fedora()
{
	local array_libs_fedora=(
			'zlib.i686' 'ncurses-libs.i686' 'bzip2-libs.i686'
			)

	__msg "Instalando: ${array_libs_fedora[@]}"
	_pkg_manager_sys "${array_libs_fedora[@]}"

	_android_studio_zip || return 1
	#_android_sdktools
}


_android_studio_opensuseleap()
{
	_pkg_manager_sys 'java-1_8_0-openjdk-devel' 'qemu-kvm'

	local requerimentsOpenSuse=(
			'libstdc++6-32bit' 
			'zlib-devel-32bit' 
			'libncurses5-32bit' 
			'libbz2-1-32bit'
		)
	_yellow "Instalando: ${requerimentsOpenSuse[@]}"
	_pkg_manager_sys "${requerimentsOpenSuse[@]}"
	_android_studio_zip
}


_android_studio()
{
	# https://www.blogopcaolinux.com.br/2017/09/Instalando-Android-Studio-no-Debian-e-no-Ubuntu.html
	# https://www.blogopcaolinux.com.br/2017/05/Instalando-Android-Studio-no-openSUSE-e-Fedora.html
	# https://developer.android.com/studio/index.html#downloads

	# Já instalado.
	is_executable 'studio' && _show_info 'PkgInstalled' 'android-studio' && return 0

	case "$os_id" in
		debian) _android_studio_debian;;
		linuxmint|ubuntu) _android_studio_ubuntu;;
		'opensuse-leap') _android_studio_opensuseleap;;
		fedora) _android_studio_fedora;;
		arch) _android_archlinux;;
		*) _show_info 'ProgramNotFound' 'android-studio'; return 1;;
	esac

	if is_executable 'studio'; then
		_show_info 'SuccessInstalation' 'android-studio'
		return 0
	else
		_show_info 'InstalationFailed' 'android-studio'
		return 1
	fi
}

_codeblocks_fedora()
{
	# https://sempreupdate.com.br/como-instalar-o-codeblocks-no-fedora/
	#
	# local url_codeblocks_fedora='http://sourceforge.net/projects/codeblocks/files/Binaries/17.12/Linux/Fedora%2028%20(aka%20Rawhide)/codeblock-17.12-1.fc28.x86_64.tar.xz'

	_pkg_manager_sys codeblocks || return 1
	_pkg_manager_sys make automake gcc 'gcc-c++' 'kernel-devel' || return 1
	# sudo dnf groupinstall "Development Tools" "Development Libraries" 
}

_codeblocks_archlinux()
{
	# https://www.archlinux.org/packages/community/x86_64/codeblocks/
	_pkg_manager_sys codeblocks
}


_codeblocks()
{
	case "$os_id" in
		debian) _pkg_manager_sys codeblocks 'codeblocks-common' 'codeblocks-contrib' || return 1;;
		fedora) _codeblocks_fedora;;
		archlinux) _codeblocks_archlinux;;
		*) _show_info 'ProgramNotFound' 'codeblocks'; return 1;;
	esac
}


_pycharm()
{
	# Já instalado.
	is_executable 'pycharm' && _show_info 'PkgInstalled' 'pycharm' && return 0
	local url_pycharm='https://download-cf.jetbrains.com/python/pycharm-community-2020.1.tar.gz'
	local hash_pycharm='1aa49fd01ec9020c288a583ac90e777df3ae5c5dfcf4cc73d93ac7be1284a9d1'
	local path_file="$DirDownloads/$(basename $url_pycharm)"
	
	__download__ "$url_pycharm" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	__shasum__ "$path_file" "$hash_pycharm" || return 1
	_unpack "$path_file" || return 1

	cd "$DirUnpack" 
	mv $(ls -d pycharm*) "${destinationFilesPycharm[dir]}" 1> /dev/null
	cp -u "${destinationFilesPycharm[dir]}"/bin/pycharm.png "${destinationFilesPycharm[file_png]}"

	# Criar atalho para execução na linha de comando.
	echo "#!/usr/bin/env bash" > "${destinationFilesPycharm[link]}"
	echo -e "\ncd ${destinationFilesPycharm[dir]}/bin/ && ./pycharm.sh" >> "${destinationFilesPycharm[link]}"
	chmod +x "${destinationFilesPycharm[link]}"

	_show_info 'AddFileDesktop' 
	echo "[Desktop Entry]" > "${destinationFilesPycharm[file_desktop]}"
    {
        echo "Name=Pycharm Community"
        echo "Version=1.0"
        echo "Icon=${destinationFilesPycharm[file_png]}"
        echo "Exec=pycharm"
        echo "Terminal=false"
        echo "Categories=Development;IDE;"
        echo "Type=Application"
    } >> "${destinationFilesPycharm[file_desktop]}"

    
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/Desktop/ 2> /dev/null 

	if is_executable 'pycharm'; then
		_show_info 'SuccessInstalation' 'pycharm'
		return 0
	else
		_show_info 'InstalationFailed' 'pycharm'
		return 1
	fi
}

_sublime_text()
{
	# Já instalado.
	is_executable 'sublime' && _show_info 'PkgInstalled' 'sublime-text' && return 0
	sublime_pag='https://www.sublimetext.com/3'
	sublime_html=$(grep -m 1 'http.*sublime.*x64.tar.bz2' <<< $(curl -sL "$sublime_pag"))
	sublime_url=$(echo "$sublime_html" | sed 's/">64.*//g;s/.*href="//g')
	path_file="$DirDownloads/$(basename $sublime_url)"

	__download__ "$sublime_url" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 
	_unpack "$path_file" || return 1

	sudo cp -u "$DirUnpack"/sublime_text_3/sublime_text.desktop "${destinationFilesSublime[file_desktop]}"  
	sudo cp -u "$DirUnpack"/sublime_text_3/Icon/256x256/sublime-text.png "${destinationFilesSublime[file_png]}" 
	sudo mv "$DirUnpack"/sublime_text_3 "${destinationFilesSublime[dir]}"
	sudo ln -sf "${destinationFilesSublime[dir]}"/sublime_text "${destinationFilesSublime[link]}" 
	
	is_executable 'gtk-update-icon-cache' && sudo 'gtk-update-icon-cache'

	if is_executable 'sublime'; then
		_show_info 'SuccessInstalation' 'sublime'
		sublime &
		return 0
	else
		_show_info 'InstalationFailed' 'sublime'
		return 1
	fi
}


_vim()
{
	_pkg_manager_sys vim
}


_vscode_package_deb()
{
	local url_code_debian='https://go.microsoft.com/fwlink/?LinkID=760868'
	local path_file="$DirDownloads/vscode-amd64.deb"
	__download__ "$url_code_debian" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	_DPKG --install "$path_file" # .deb
}


_vscode_tarfile()
{
	local url_vscode_tar='https://go.microsoft.com/fwlink/?LinkID=620884'
	local path_file="$DirDownloads/vscode.tar.gz"

	__download__ "$url_vscode_tar" "$path_file"

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	_unpack "$path_file" || return 1

	cd "$DirUnpack"
	mv $(ls -d VSCode*) "${destinationFilesVscode[dir]}" 
	cp -u "${destinationFilesVscode[dir]}"/resources/app/resources/linux/code.png "${destinationFilesVscode[file_png]}"

	# Criar atalho para execução na linha de comando.
	echo "#!/usr/bin/env bash" > "${destinationFilesVscode[link]}"
	echo -e "\ncd ${destinationFilesVscode[dir]}/bin/ && ./code" >> "${destinationFilesVscode[link]}"
	chmod +x "${destinationFilesVscode[link]}"

	# Criar entrada no menu do sistema.
	_show_info "AddFileDesktop"
	echo "[Desktop Entry]" > "${destinationFilesVscode[file_desktop]}" 
	{
		echo "Name=Code"
		echo "Version=1.0"
		echo "Icon=code"
		echo "Exec=${destinationFilesVscode[dir]}/bin/code"
		echo "Terminal=false"
		echo "Categories=Development;IDE;" 
		echo "Type=Application"
	} >> "${destinationFilesVscode[file_desktop]}"

	ln -sf "${destinationFilesVscode[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	ln -sf "${destinationFilesVscode[file_desktop]}" ~/Desktop/ 2> /dev/null 
	ln -sf "${destinationFilesVscode[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null	
}

_vscode()
{
	# Já instalado.
	is_executable 'code' && _show_info 'PkgInstalled' 'code' && return 0

	case "$os_id" in
		debian|ubuntu|linuxmint) _vscode_package_deb;;
		*) _vscode_tarfile;;
	esac
	

	if is_executable 'code'; then
		_show_info 'SuccessInstalation' 'code'
		return 0
	else
		_show_info 'InstalationFailed' 'code'
		return 1
	fi
}

_codecs_tumbleweed()
{
	# https://software.opensuse.org/download/package?package=opensuse-codecs-installer&project=multimedia%3Aapps
	# https://forums.opensuse.org/showthread.php/523476-Multimedia-Guide-for-openSUSE-Tumbleweed
	
	# Adicionar repostórios
	"$scriptAddRepo" --repo tumbleweed

	# Instalar os codecs
	local array_tumbleweed_codecs=(
		opensuse-codecs-installer
		libxine2-codecs 
		dvdauthor 
		gstreamer-plugins-bad 
		gstreamer-plugins-bad-orig-addon 
		gstreamer-plugins-ugly-orig-addon 
		gstreamer-plugins-good-extra 
		libxine2-codecs    
		gstreamer-plugins-base  
		gstreamer-plugins-good 
		gstreamer-plugins-libav  
		gstreamer-plugins-ugly 
		gstreamer-plugins-good-qtqml
		smplayer 
		x264 
		x265 
		vlc-codecs 
		vlc-codec-gstreamer 
		ogmtools 
		libavcodec58
	)

	for c in "${array_tumbleweed_codecs[@]}"; do
		_yellow "Instalando [$c]"
		_pkg_manager_sys "$c"		
	done
}

_codecs_opensuse_leap()
{
	if [[ "$os_version" != '15.1' ]]; then
		return
	fi

	codecsOpesSuseLeap=(
		ffmpeg 
		lame 
		gstreamer-plugins-bad 
		gstreamer-plugins-ugly 
		gstreamer-plugins-ugly-orig-addon 
		gstreamer-plugins-libav 
		libavdevice56 
		libavdevice58 
		libdvdcss2 
		)

	sudo zypper addrepo -f http://packman.inode.at/suse/openSUSE_Leap_15.1/ packman
	sudo zypper addrepo -f http://opensuse-guide.org/repo/openSUSE_Leap_15.1/ dvd
	sudo zypper ref
	for i in "${codecsOpesSuseLeap[@]}"; do
		_pkg_manager_sys "$i"
	done

}

_codecs_ubuntu()
{
	_pkg_manager_sys --install-recommends ffmpeg ffmpegthumbnailer
	_pkg_manager_sys 'ubuntu-restricted-extras'
}

_codecs_debian()
{
	#------------------| AlsaMixer |---------------------------#
	# visite o link abaixo se tiver problemas com a sua placa de audio.
	# https://vitux.com/how-to-control-audio-on-the-debian-command-line/
	# sudo apt install install alsa-utils
	#
	
	local deb_multimidia='http://www.deb-multimedia.org'
	local url_wcodecs="$deb_multimidia/pool/non-free/w/w64codecs/w64codecs_20071007-dmo2_amd64.deb"
	local hash_wcodecs="cc36b9ff0dce8d4f89031756163d54acdd4e800d6106f07db2031fdf77e90392"
	local path_file="$DirDownloads/$(basename $url_wcodecs)"

	__download__ "$url_wcodecs" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0 

	_pkg_manager_sys --install-recommends ffmpeg ffmpegthumbnailer
	_pkg_manager_sys lame

	__shasum__ "$path_file" "$hash_wcodecs" || return 1
	
	_msg "Instalando: $path_file"
	_DPKG --install "$path_file" || return 1
}

_codecs_fedora()
{
	# Add repo fusion non free
	sudo "$scriptAddRepo" --repo fedora

	local array_gstreamer_fedora=(
		gstreamer-plugins-espeak 
		gstreamer-plugins-fc gstreamer-rtsp 
		gstreamer-plugins-good 
		gstreamer-plugins-bad 
		gstreamer-plugins-bad-free-extras 
		gstreamer-plugins-bad-nonfree 
		gstreamer-plugins-ugly 
		gstreamer-ffmpeg gstreamer1-plugins-base 
		gstreamer1-libav 
		gstreamer1-plugins-bad-free-extras 
		gstreamer1-plugins-bad-freeworld 
		gstreamer1-plugins-base-tools 
		gstreamer1-plugins-good-extras 
		gstreamer1-plugins-ugly 
		gstreamer1-plugins-bad-free 
		gstreamer1-plugins-good
		)

	local array_codecs_fedora=(
		'ffmpeg' 
		'ffmpegthumbnailer.x86_64'
		'amrnb' 
		'amrwb' 
		'faad2' 
		'flac' 
		'ffmpeg' 
		'gpac-libs' 
		'lame' 
		'libfc14audiodecoder' 
		'mencoder' 
		'mplayer' 
		'x265' 
		'gstreamer1' 
		'gstreamer1-plugins-base' 
		'gstreamer-ffmpeg' 
		'libmpeg3' 
		'x264' 
		'x264-libs' 
		'xvidcore' 
	)

	_msg "Instalando: ${array_codecs_fedora[@]}"
	_pkg_manager_sys "${array_codecs_fedora[@]}"

	_msg "Instalando: ${array_gstreamer_fedora[@]}"	
	_pkg_manager_sys "${array_gstreamer_fedora[@]}"
}

_codecs_arch()
{
	#
	# https://bbs.archlinux.org/viewtopic.php?id=223197
	#

	local list_codecs_arch=(
		'a52dec' 
		'faac' 
		'faad2' 
		'flac' 
		'jasper' 
		'lame' 
		'libdca' 
		'libdv' 
		'libmad' 
		'libmpeg2' 
		'libtheora' 
		'libvorbis' 
		'libxv' 
		'opus' 
		'wavpack' 
		'x264' 
		'xvidcore'
		'ffmpeg'
		'ffmpegthumbnailer'
	)

	local list_codecs_parole=(
		'gst-libav'
		'gst-plugins-bad'
		'gst-plugins-ugly'
		)

	for x in "${list_codecs_arch[@]}"; do 
		_space_text "Instalando" "$x"
		_pkg_manager_sys "$x"
	done

	
	for x in "${list_codecs_parole[@]}"; do 
		_space_text "Instalando" "$x"
		_pkg_manager_sys "$x"
	done
	
}

_codecs()
{
case "$os_id" in
	freebsd12.0-release) _pkg_manager_sys ffmpeg ffmpegthumbnailer 'gstreamer-ffmpeg';;
	debian) _codecs_debian;;
	linuxmint|ubuntu) _codecs_ubuntu;;
	fedora) _codecs_fedora;;
	'opensuse-tumbleweed') _codecs_tumbleweed;;
	'opensuse-leap') _codecs_opensuse_leap;;
	arch) _codecs_arch;;
	*) _show_info 'ProgramNotFound' 'codecs'; return 1;;

esac
}

_celluloid()
{
	_pkg_manager_sys 'celluloid'
}

_cinema()
{
	_pkg_manager_sys 'cinema'
}

_gnome_mpv()
{
	if is_executable 'dnf'; then
		_pkg_manager_sys 'gnome-mpv' 'smplayer-themes'
	elif [[ -f '/etc/debian_version' ]]; then
		_pkg_manager_sys 'gnome-mpv'
	else
		_pkg_manager_sys 'gnome-mpv' 
	fi
}

_parole()
{
	_pkg_manager_sys parole	
}

_smplayer()
{
	_pkg_manager_sys smplayer
}

_spotify_debian()
{
	# https://wiki.debian.org/spotify
	_msg "Adicionando key e repositório"
	sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4773BD5E130D1D45
	echo 'deb http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list
	_APT update
	_pkg_manager_sys 'spotify-client'
}

_spotify_ubuntu()
{
	# https://www.spotify.com/br/download/linux/
	_msg "Adicionando key e repositório"
	curl -sSL https://download.spotify.com/debian/pubkey.gpg | sudo apt-key add - 
	echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
	_APT update 
 	_pkg_manager_sys 'spotify-client'
}

_spotify_archlinux()
{
	# https://www.vivaolinux.com.br/dica/Spotify-no-Arch-Linux
	local spotify_url='https://repository-origin.spotify.com/pool/non-free/s/spotify-client'
	local spotify_file_server=$(curl -sSL "$spotify_url" | grep -m 1 'spotify.*amd64.deb' | sed 's/">.*//g;s/.*="//g')
	local Spotify_Url_Server="$spotify_url/$spotify_file_server"
	local path_file="$DirDownloads/spotify-client-amd64.deb"
	
	local array_spotify_requeriments=( 
		gconf 
		gtk2
		glib2 
		nss 
		libsystemd 
		libxtst 
		libx11 
		libxss 
		rtmpdump
		'desktop-file-utils' 
		'alsa-lib' 
		'openssl-1.0'
	)
	
	for X in "${array_spotify_requeriments[@]}"; do
		_msg "Instalando: $X"
		_pkg_manager_sys "$X"
	done
		
	__download__ "$Spotify_Url_Server" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0	
	_unpack "$path_file" || return 1
	cd "$DirUnpack"
	_white "Descomprimindo arquivo data.tar.gz"
	sudo tar -zxpvf data.tar.gz -C / 1> /dev/null
	sudo install -Dm644 /usr/share/spotify/spotify.desktop /usr/share/applications/spotify.desktop
	sudo install -Dm644 /usr/share/spotify/icons/spotify-linux-512.png /usr/share/pixmaps/spotify-client.png
}

_spotify_fedora()
{
	# https://www.spotify.com/br/download/linux/
	# https://flathub.org/apps/details/com.spotify.Client
	# flatpak install flathub com.spotify.Client
	# https://docs.fedoraproject.org/en-US/quick-docs/installing-spotify/
	# flatpak run com.spotify.Client

	local FlatpakRepoSpotity='flathub https://flathub.org/repo/flathub.flatpakrepo'

	is_executable flatpak || _pkg_manager_sys flatpak

	echo -ne "[>] Executando: remote-add --if-not-exists $FlatpakRepoSpotity "
	if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
		_syellow "OK"
	else
		_sred "FALHA"
	fi

	_FLATPAK install flathub com.spotify.Client || return 1
	return 0
}

_spotify()
{
	if [[ "$os_id" == 'debian' ]]; then
		_spotify_debian
	elif [[ "$os_id" == 'ubuntu' ]] || [[ "$os_id" == 'linuxmint' ]]; then
		_spotify_ubuntu
	elif [[ "$os_id" == 'arch' ]]; then
		_spotify_archlinux
	elif [[ "$os_id" == 'fedora' ]]; then
		_spotify_fedora
	else
		_show_info 'ProgramNotFound' 'spotify'; return 1
	fi
	
}

_totem(){
	_pkg_manager_sys totem
}

_vlc_fedora()
{
	sudo "$scriptAddRepo" --repo fedora # Adicionar repositórios fusion non free
	_pkg_manager_sys vlc 'python-vlc'
}

_vlc()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _pkg_manager_sys vlc;;
		'opensuse-leap') _pkg_manager_sys vlc;;
		fedora) _vlc_fedora;;
		arch) _pkg_manager_sys vlc;;
	esac

	if is_executable 'vlc'; then
		_show_info 'SuccessInstalation' 'vlc'
	else
		_show_info 'InstalationFailed' 'vlc'
	fi
}

_atril()
{
	_pkg_manager_sys atril
}

_ubuntu_msttcorefonts()
{
	local url_msttcorefonts='http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb'
	local path_file="$DirDownloads/$(basename $url_msttcorefonts)"

	__download__ "$url_msttcorefonts" "$path_file" || return 1

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
	
	# Já instalado.
	is_executable 'libreoffice-appimage' && _show_info 'PkgInstalled' 'libreoffice-appimage' && return 0
	local url='https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage'
	local path_file="$DirDownloads/$(basename $url)"
	local hash_libreoffice='4dc846ccf77114594b9f3fd1ffb398f784adfcce75371f22551612e83c3ef1e6'

	__download__ "$url" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

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

_chromium_lang()
{
	# Instalar pacote de idioma ptbr se o idioma do usuário for
	# 

	# Verificar se o idioma da sessão e pt_br.
	local lang=$(set | grep -m 1 '^LANG=' | sed 's/.*=//g')
	[[ "$lang" == 'pt_BR.UTF-8' ]] || return 0

	_white "Instalando pacote de idioma para chromium"
	case "$os_id" in
		debian) _pkg_manager_sys 'chromium-l10n';;
		ubuntu) _pkg_manager_sys 'chromium-browser-l10n';;
		*) return 0;;
	esac
}

_chromium()
{
	case "$os_id" in
		debian) _pkg_manager_sys chromium;;
		ubuntu|linuxmint) _pkg_manager_sys 'chromium-browser';;
		fedora) _pkg_manager_sys chromium;;
		arch) _pkg_manager_sys chromium;;
		'opensuse-tumbleweed'|'opensuse-leap') _pkg_manager_sys chromium;; 
		freebsd12) _pkg_manager_sys chromium;;
		*) _show_info 'ProgramNotFound' 'chromium'; return 1;;
	esac

	_chromium_lang # Instalar pacote de idioma ptbr.
}

_firefox_lang()
{
	# Verificar se o idioma da sessão e pt_br e em seguida instalar o
	# pacote de idiomas pt_br para firefox.
	local lang=$(set | grep -m 1 '^LANG=' | sed 's/.*=//g')
	[[ "$lang" == 'pt_BR.UTF-8' ]] || return 0

	case "$os_id" in
		arch) _pkg_manager_sys 'firefox-i18n-pt-br';;
		debian) _pkg_manager_sys 'firefox-esr-l10n-pt-br';;
		ubuntu) _pkg_manager_sys 'firefox-locale-pt';;
	esac
}

_firefox()
{
	case "$os_id" in
		arch) _pkg_manager_sys firefox;;
		debian) _pkg_manager_sys 'firefox-esr';;
		ubuntu|linuxmint) _pkg_manager_sys firefox;;
		fedora) _pkg_manager_sys 'firefox.x86_64' 'mozilla-ublock-origin.noarch';;
		'opensuse-leap') _pkg_manager_sys MozillaFirefox;;
		*) _show_info 'ProgramNotFound' 'firefox'; return 1;;
	esac

	_firefox_lang
}

_google_chrome_debian()
{
	local google_chrome_repo='deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
	local google_chrome_file='/etc/apt/sources.list.d/google-chrome.list'	
	_white "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	curl -sSL 'https://dl.google.com/linux/linux_signing_key.pub' | sudo apt-key add -

	# find /etc/apt -name *.list | xargs grep "^deb .*google\.com/linux.*stable main" 2> /dev/null
	_white "Adicionando repositório"
	echo "$google_chrome_repo" | sudo tee "$google_chrome_file"

	# sudo apt install libu2f-udev
	_APT update
	_pkg_manager_sys 'google-chrome-stable' 
}


_google_chrome_fedora()
{
	# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
	# dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo dnf install fedora-workstation-repositories
	sudo dnf config-manager --set-enabled google-chrome
	_pkg_manager_sys 'google-chrome-stable'
}

_google_chrome_opensuse()
{
	# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-openSUSE-Leap-15
	# wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	# curl -SL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	_yellow "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	_yellow "Adicionando repositório: http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	_pkg_manager_sys 'google-chrome-stable'
}

_google_chrome_tumbleweed()
{
	
	_white "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	_white "Adicionando repositório [http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google]"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	_pkg_manager_sys 'google-chrome-stable'
}

_google_chrome_archlinux()
{
	# Dependências opcionais para google-chrome
    # libpipewire02: WebRTC desktop sharing under Wayland
    # kdialog: for file dialogs in KDE
    # gnome-keyring: for storing passwords in GNOME keyring
    # kwallet: for storing passwords in KWallet
    # gtk3-print-backends: for printing 
    # libunity: for download progress on KDE
    # ttf-liberation: fix fonts for some PDFs (CRBug #369991) 
    # xdg-utils 
    #
	# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-Arch-com-Git
	local github_chrome='https://aur.archlinux.org/google-chrome.git'

 	_gitclone "$github_chrome" || return 1
	cd "$DirTemp"/google-chrome

	_msg "Instalando base-devel"
	_pkg_manager_sys "base-devel"
	_pkg_manager_sys pipewire

	_msg "Executando: makepkg -s"
	cd "$DirTemp/google-chrome"
	makepkg -s

	_msg "Executando sudo pacman -U $(ls google*.tar.*)"
	_PACMAN -U --noconfirm $(ls google*.tar.*)
}

_google_chrome()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _google_chrome_debian;;
		opensuse-tumbleweed|opensuse-leap) _google_chrome_opensuse;;
		fedora) _google_chrome_fedora;;
		arch) _google_chrome_archlinux;;
		*) _show_info 'ProgramNotFound' 'google-chrome'; return 1;;
	esac	

	if is_executable 'google-chrome'|| is_executable 'google-chrome-stable'; then
		_show_info 'SuccessInstalation' 'google-chrome'
		return 0
	else
		_show_info 'InstalationFailed' 'google-chrome'
		return 1
	fi
}

_opera_stable_debian()
{
	local opera_repo='deb [arch=amd64] https://deb.opera.com/opera-stable/ stable non-free'
	local opera_file='/etc/apt/sources.list.d/opera-stable.list'
	
	_white "Importando key"
	sudo sh -c 'curl -sSL http://deb.opera.com/archive.key | apt-key add -' || return 1
	
	find /etc/apt -name *.list | xargs grep "^deb .*deb\.opera.* stable.*free$" 2> /dev/null

	if [[ $? == '0' ]]; then
		_white "Repositório já está disponível 'pulando'"
	else
		_white "Adicionando repositório"
		echo "$opera_repo" | sudo tee "$opera_file"
	fi
	_APT update
	_pkg_manager_sys 'opera-stable' || return 1	
}

_opera_stable_fedora()
{
	# https://www.blogopcaolinux.com.br/2017/07/Instalando-o-Opera-no-openSUSE-e-no-Fedora.html
	# https://rpm.opera.com/manual.html

	_white "Importando key"
	sudo rpm --import https://rpm.opera.com/rpmrepo.key || return 1

	_white "Adicionando repositório"
	echo '[opera]' | sudo tee /etc/yum.repos.d/opera.repo
	{
		echo "name=Opera packages"
		echo "type=rpm-md"
		echo "baseurl=https://rpm.opera.com/rpm"
		echo "gpgcheck=1"	
		echo "gpgkey=https://rpm.opera.com/rpmrepo.key"
		echo "enabled=1"
	} | sudo tee -a /etc/yum.repos.d/opera.repo

	_pkg_manager_sys 'opera-stable'
}

_opera_stable_suse()
{
	# https://www.blogopcaolinux.com.br/2017/07/Instalando-o-Opera-no-openSUSE-e-no-Fedora.html
	# sudo zypper up  
	sudo rpm --import https://rpm.opera.com/rpmrepo.key || return 1

	echo '[opera]' | sudo tee /etc/zypp/repos.d/opera.repo
	{
		echo "name=Opera packages"
		echo "type=rpm-md"
		echo "baseurl=https://rpm.opera.com/rpm"
		echo "gpgcheck=1"
		echo "gpgkey=https://rpm.opera.com/rpmrepo.key"
		echo "enabled=1"
		echo "autorefresh=1"
		echo "keeppackages=0"
	} | sudo tee -a /etc/zypp/repos.d/opera.repo

	_yellow "Syncronizando repositórios"
	sudo zypper ref
	_pkg_manager_sys 'opera-stable'  || return 1
}

_opera_stable()
{
case "$os_id" in
	debian|linuxmint|ubuntu) _opera_stable_debian;;
	fedora) _opera_stable_fedora;;
	'opensuse-tumbleweed'|'opensuse-leap') _opera_stable_suse;;
	*) _show_info 'ProgramNotFound' 'opera'; return 1;;
esac	

	if [[ $? == '0' ]]; then 
		_show_info 'SuccessInstalation' 'opera'
	else
		_show_info 'InstalationFailed' 'opera'
		return 1
	fi
}

_torbrowser()
{
	# Url do script de instalação do torbrowser.
	local url_master_scritpTorBrowser='https://raw.github.com/Brunopvh/torbrowser/master/tor.sh'

	if ! is_executable "$scritpTorBrowser"; then
		__download__ "$url_master_scritpTorBrowser" "$scritpTorBrowser" || return 1
		chmod +x "$scritpTorBrowser"
	fi

	if [[ "$DownloadOnly" == 'True' ]]; then
		"$scritpTorBrowser" --install --downloadonly
	else
		"$scritpTorBrowser" --install
	fi
}

_megasync_opensuse_tumbleweed()
{
	# https://www.blogopcaolinux.com.br/2017/02/Instalando-o-MEGA-Sync-no-openSUSE-e-Fedora.html
	_white "Adicionando key [https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key]"
	sudo rpm --import https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key || return 1
	
	_white "Adicionando repositório [https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA]"
	sudo zypper ar -f https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA || return 1
	sudo zypper ref

	_white "Instalando megasync"
	_pkg_manager_sys megasync || return 1	
}

_megasync_debian()
{
	# find /etc/apt -name *.list | xargs grep "^deb .*mega\.nz/linux.Debian.*" 2> /dev/null
	local mega_repos="deb https://mega.nz/linux/MEGAsync/Debian_10.0/ ./"	
	local mega_file_list="/etc/apt/sources.list.d/megasync.list"

	if [[ "$os_codename" != 'buster' ]]; then
		_red "A instalação de MegaSync não está disponível para o seu sistema"
		return 1
	fi

	_white "Adicionando key e repositório"	
	curl -sSL 'https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key' | sudo apt-key add - || return 1
	echo "$mega_repos" | sudo tee "$mega_file_list"
	_APT update
	_pkg_manager_sys megasync || return 1
}

_megasync_ubuntu()
{
	# find /etc/apt -name *.list | xargs grep "^deb .*mega\.nz/linux.*Ubuntu_18\.04" 2> /dev/null
	# https://mega.nz/linux/MEGAsync/xUbuntu_19.10/
	# https://mega.nz/linux/MEGAsync/
	
	local url_ubuntu_main='http://archive.ubuntu.com/ubuntu/pool/main'
	local url_libraw16="$url_ubuntu_main/libr/libraw/libraw16_0.18.8-1ubuntu0.3_amd64.deb"
	local mega_file_list="/etc/apt/sources.list.d/megasync.list"
	path_libraw="$DirDownloads/$(basename $url_libraw16)" # Requerimento para ubutnu 19.10

	case "$os_codename" in
		bionic|tricia) 
			mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./"
			mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_18.04/Release.key'
			;;
		eoan)
			mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./"
			mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_19.10/Release.key'
			__download__ "$url_libraw16" "$path_libraw" || return 1 
			_msg "Instalando: $path_libraw"
			_DPKG --install "$path_libraw" || return 1
			;;
		focal)
			mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_20.04/ ./"
			mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_20.04/Release.key'
			;;
		*)
			_show_info 'ProgramNotFound' 'megasync' 
			return 1
			;;
	esac

	_msg "Adicionando key e repositório"
	curl -sSL "$mega_url_key" -o- | sudo apt-key add - || return 1
	echo "$mega_repos_ubuntu" | sudo tee "$mega_file_list" 1> /dev/null
	_APT update
	_msg "Instalando: libc-ares2 libmediainfo0v5" 
	_pkg_manager_sys 'libc-ares2' libmediainfo0v5 
	_pkg_manager_sys megasync
}

_megasync_fedora()
{
	_white "Importando key [https://mega.nz/linux/MEGAsync/Fedora_30/repodata/repomd.xml.key]"
	sudo rpm --import 'https://mega.nz/linux/MEGAsync/Fedora_30/repodata/repomd.xml.key'

	echo '[MEGAsync]' | sudo tee /etc/yum.repos.d/megasync.repo 1> /dev/null
	{
		echo "name=MEGAsync"
		echo "type=rpm-md"
		echo "baseurl=http://mega.nz/linux/MEGAsync/Fedora_30/"
		echo "gpgcheck=1"	
		echo "enabled=1"
		echo "gpgkey=https://mega.nz/linux/MEGAsync/Fedora_30/repodata/repomd.xml.key"	
	} | sudo tee -a /etc/yum.repos.d/megasync.repo 1> /dev/null

	_pkg_manager_sys megasync
}

_megasync_archlinux()
{
	# https://github.com/meganz/MEGAsync
	# https://unix.stackexchange.com/questions/200311/how-to-install-megasync-client-in-arch-based-antergos-linux
	# https://aur.archlinux.org/packages/megasync/
	#
	# https://oxylabs.directorioforuns.com/t6-como-instalar-o-megasync-no-arch-linux
	#
	# https://github.com/meganz/MEGAsync/archive/master.tar.gz
	# git clone --recursive https://github.com/meganz/MEGAsync.git
	#

	local mega_url_tar='https://mega.nz/linux/MEGAsync/Arch_Extra/x86_64/megasync-x86_64.pkg.tar.xz'
	local path_mega_tar="$DirDownloads/$(basename $mega_url_tar)"

	# Requerimentos para compilação no ArchLinux - libpdfium.
	local array_mega_requeriments_archlinux=(
		'crypto++' 
		'c-ares'
		'lsb-release' 
		'qt5-tools'
		libuv 
		libmediainfo   
		swig 
		doxygen 
		)

	# Baixar o pacote do repositório MEGA.
	__download__ "$mega_url_tar" "$path_mega_tar" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	# Instalar dependências.
	_msg "Instalando: ${array_mega_requeriments_archlinux[@]}"
	_pkg_manager_sys "${array_mega_requeriments_archlinux[@]}"

	# Copiar o instalador para o diretório temporário e em seguida instalar o pacote.
	cp "$path_mega_tar" "$DirTemp/megasync-x86_64.pkg.tar.xz" || return 1
	cd "$DirTemp"
	_PACMAN -U megasync-x86_64.pkg.tar.xz

	# Syncronizar os repositórios
	_PACMAN -Sy
}


_megasync()
{
	# Já instalado.
	is_executable 'megasync' && _show_info 'PkgInstalled' 'megasync' && return 0

	case "$os_id" in
		'opensuse-tumbleweed') _megasync_opensuse_tumbleweed;;
		debian) _megasync_debian;;
		linuxmint|ubuntu) _megasync_ubuntu;;
		fedora) _megasync_fedora;;
		arch) _megasync_archlinux;;
		*) _show_info 'ProgramNotFound' 'megasync'; return 1;;
	esac

	if is_executable 'megasync'; then
		_show_info 'SuccessInstalation' 'megasync'
		return 0
	else
		_show_info 'InstalationFailed' 'megasync'
		return 1
	fi
}

_tor_debian()
{
	local tor_asc='https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc'
	local tor_file_list='/etc/apt/sources.list.d/torproject.list'

	if [[ "$os_codename" == 'bionic' ]] || [[ "$os_codename" == 'tricia' ]]; then  # Ubuntu bionic
		tor_repos='deb https://deb.torproject.org/torproject.org bionic main'
	elif [[ "$os_codename" == 'buster' ]]; then                                  # Debian buster
		tor_repos='deb https://deb.torproject.org/torproject.org buster main'
	else
		_show_info 'ProgramNotFound' 'tor'
		return
	fi

	_yellow "Importando chaves"
	
	curl -sSL "$tor_asc" | sudo gpg --import || _red "Falha" && return 1
	sudo sh -c 'gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -' || return 1

	_yellow "Adicionando repositório"
	echo "$tor_repos" | sudo tee "$tor_file_list" 1> /dev/null
	_APT update

	_yellow "Instalando tor deb.torproject.org-keyring"
	_pkg_manager_sys tor deb.torproject.org-keyring
	_pkg_manager_sys proxychains || return 1
}

_tor_fedora()
{
	case "$os_version" in
		32) _pkg_manager_sys tor;;
		*) _show_info 'ProgramNotFound' 'tor';;
	esac

	_pkg_manager_sys proxychains || return 1
}

_proxychains()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _tor_debian;;
		arch) _pkg_manager_sys 'proxychains-ng' 'tor';;
		fedora) _tor_fedora;;
		*) _show_info 'ProgramNotFound' 'proxychains tor';;
	esac
}

_qbittorrent()
{
	_pkg_manager_sys qbittorrent || return 1
}

_skype_debian()
{
	local skype_url='https://go.skype.com/skypeforlinux-64.deb'
	local path_file="$DirDownloads/$(basename $skype_url)"

	__download__ "$skype_url" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	_DPKG --install "$path_file" || return 1
}

_skype()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _skype_debian;;
		*) _show_info 'ProgramNotFound' 'skype';;
	esac
}

_install_teamviewer_debian()
{
	# https://www.teamviewer.com/en/download/linux/
	# wget -O- https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | sudo apt-key add -
	# echo 'deb http://linux.teamviewer.com/deb stable main' > /etc/apt/sources.list.d/teamviewer.list
	# echo 'deb http://linux.teamviewer.com/deb preview main' >> /etc/apt/sources.list.d/teamviewer.list
	# sudo apt update; sudo apt install teamviewer
	#
	local tw_pag='https://www.teamviewer.com/en/download/linux/'      # Página de download.
	local tw_html=$(curl -SsL "$tw_pag" | grep "download.*linux.*64")
	local url_deb=$(echo "$tw_html" | grep -m 1 'amd64.deb' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$DirDownloads/teamviewer_amd64.deb"

	# Requeriments teamviewer Debian/Ubuntu/Mint
	array_tw_debian=(
		'libdbus-1-3' 
		'libqt5gui5' 
		'libqt5widgets5' 
		'libqt5qml5' 
		'libqt5quick5' 
		'libqt5webkit5' 
		'libqt5x11extras5' 
		'qml-module-qtquick2' 
		'qml-module-qtquick-controls' 
		'qml-module-qtquick-dialogs' 
		'qml-module-qtquick-window2' 
		'qml-module-qtquick-layouts' 
		)
	
	__download__ "$url_deb" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0	

	for i in "${array_tw_debian[@]}"; do
		_msg "Instalando: $i"
		_pkg_manager_sys "$i" 
	done
	_DPKG --install "$path_file" || _BROKE # Remover pacotes quebrados.
}

_install_teamviewer_fedora()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/' # Página de download.
	local tw_html=$(curl -SsL "$tw_pag" | grep "download.*linux.*64")
	local url_rpm=$(echo "$tw_html" | grep -m 1 'x86_64.rpm' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$DirDownloads/teamviewer_x86_64.rpm"

	# Requeriments teamviewer Fedora
	local array_tw_fedora=(
		'libdbus-1.so.3()(64bit)' 
		'libQt5Gui.so.5()(64bit)' 
		'libQt5Widgets.so.5()(64bit)' 
		'libQt5Qml.so.5()(64bit)' 
		'libQt5Quick.so.5()(64bit)' 
		'libQt5WebKitWidgets.so.5()(64bit)' 
		'libQt5X11Extras.so.5()(64bit)' 
		'libqtquick2plugin.so()(64bit)' 
		'libwindowplugin.so()(64bit)' 
		'libqquicklayoutsplugin.so()(64bit)' 
		'libqtquickcontrolsplugin.so()(64bit)' 
		'libdialogplugin.so()(64bit)'
	)
	
	__download__ "$url_rpm" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar
	_RPM --install "$path_file" || return 1
}


_teamviewer_tar()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/'      # Página de download.
	local tw_html=$(curl -sSL "$tw_pag" | grep "download.*linux.*64")
	local url_tar=$(echo "$tw_html" | grep -m 1 'amd64.tar' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$DirDownloads/teamviewer_amd64.tar.xz"
	
	__download__ "$url_tar" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0	
	
	_unpack "$path_file" || return 1
	cd "$DirUnpack" && cd teamviewer
	chmod -R +x *
	__sudo__ ./tv-setup install || return 1
}


_teamviewer()
{
	# https://www.blogopcaolinux.com.br/2018/04/Instalando-o-TeamViewer-no-Debian-Ubuntu-e-Linux-Mint.html
	is_executable 'teamviewer' && _show_info 'PkgInstalled' 'teamviewer' && return 0

	case "$os_id" in
		debian|linuxmint|ubuntu) _install_teamviewer_debian;;
		fedora) _install_teamviewer_fedora;;
		*) _teamviewer_tar;;
	esac

	if is_executable 'teamviewer'; then
		_show_info 'SuccessInstalation' 'teamviewer'
		return 0
	else
		_show_info 'InstalationFailed' 'teamviewer'
		return 1
	fi
}

# Instalar telegram
_telegram()
{
	# https://desktop.telegram.org/
	# https://updates.tdesktop.com/tlinux/tsetup.1.8.15.tar.xz
	local url_telegram='https://telegram.org/dl/desktop/linux'
	local path_file="$DirDownloads/telegramsetup.tar.xz"

	__download__ "$url_telegram" "$path_file" || return 1

	# Instalar gconf2.
	_msg "Instalando gconf2"
	case "$os_id" in
		'opensuse-tumbleweed'|'opensuse-leap') _pkg_manager_sys gconf2;;
		ubuntu|linuxmint|debian) _pkg_manager_sys gconf2;;
		fedora) _pkg_manager_sys GConf2;;
	esac

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0	
	
	# Já instalado.
	is_executable 'telegram' && _show_info 'PkgInstalled' 'telegram' && return 0
	
	_unpack "$path_file" || return 1
	cd "$DirUnpack" 
	mv -v $(ls -d Telegra*) "${destinationFilesTelegram[dir]}" 1> /dev/null
	chmod -R 755 "${destinationFilesTelegram[dir]}"
	ln -sf "${destinationFilesTelegram[dir]}"/Telegram "${destinationFilesTelegram[link]}"
	telegram&

	if is_executable 'telegram'; then
		_show_info 'SuccessInstalation' 'telegram'
		return 0
	else
		_show_info 'InstalationFailed' 'telegram'
		return 1
	fi
}


_tixati_tarfile()
{
	# Já instalado.
	is_executable 'tixati' && _show_info 'PkgInstalled' 'tixati' && return 0

	_yellow "Obtendo URL de download aguarde."
	local tixati_pag__download__nloads='https://www.tixati.com/download/linux.html'
	local tixati_html=$(curl -sSL "$tixati_pag__download__nloads" | grep -m 1 'tixati.*64.*tar.gz')
	local url_tarfile=$(echo "$tixati_html" | sed 's/gz".*/gz/g;s/.*="//g')
	local url_signature_file="${url_tarfile}.asc"
	local TarFile="$DirDownloads/$(basename $url_tarfile)"
	local signatureFile="${TarFile}.asc"
	
	[[ -f "$path_file_asc" ]] && rm "$path_file_asc"
	__download__ "$url_tarfile" "$TarFile" || return 1
	__download__ "$url_signature_file" "$signatureFile" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0 

	printf "%s" "[>] Importando key tixati "
	if curl -sSL https://www.tixati.com/tixati.key -o- | gpg --import 1>> "$LogFile" 2>> "$LogErro"; then
		echo -e "${CYellow}OK${CReset}"
	else
		echo ' '
		_red "Falha: gpg --import"
		return 1
	fi

	# Gpg
	__gpg__ --verify "$signatureFile" "$TarFile" || return 1

	# Instalar gconf2.
	_msg "Instalando gconf2"
	case "$os_id" in
		'opensuse-tumbleweed'|'opensuse-leap') _pkg_manager_sys gconf2;;
		ubuntu|linuxmint|debian) _pkg_manager_sys gconf2;;
		fedora) _pkg_manager_sys GConf2;;
	esac	

	_unpack "$TarFile" || return 1
	cd "$DirUnpack"
	mv $(ls -d tixati*) tixati-amd64 
	cd "$DirUnpack/tixati-amd64"

	sudo mv tixati.desktop "${destinationFilesTixati[file_desktop]}" # .desktop
	sudo mv tixati.png "${destinationFilesTixati[file_png]}"         # PNG.
	sudo mv tixati "${destinationFilesTixati[file_bin]}"             # bin.
	
	sudo chmod +x "${destinationFilesTixati[file_desktop]}"
	sudo chmod +x "${destinationFilesTixati[file_bin]}"

	ln -sf "${destinationFilesTixati[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesTixati[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesTixati[file_desktop]}" ~/Desktop/ 2> /dev/null

	# Definir tixati como gerenciador bittorrent padrão.
	if _YESNO "Deseja usar tixati como bittorrent padrão"; then
		_yellow "Definindo tixati como padrão"
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/command 'tixati "%s"'
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/enabled true
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/need-terminal false
	fi


	if is_executable 'tixati'; then
		_show_info 'SuccessInstalation' 'tixati'
		return 0
	else
		_show_info 'InstalationFailed' 'tixati'
		return 1
	fi
}

_tixati()
{
	_tixati_tarfile
}


_uget()
{
	_pkg_manager_sys uget 
}


_youtube_dl()
{
	# https://youtube-dl.org/
	# http://ytdl-org.github.io/youtube-dl/download.html
	# https://youtube-dl.org/downloads/latest/youtube-dl-2019.11.28.tar.gz
	# https://github.com/ytdl-org/youtube-dl/releases/download/2019.11.28/youtube-dl-2019.11.28.tar.gz.sig
	# https://yt-dl.org/downloads/latest/youtube-dl

	local url_ytdl_test='https://yt-dl.org/downloads/latest/youtube-dl'
	local url_ytdl_sig='https://yt-dl.org/downloads/latest/youtube-dl.sig'
	local url_ytdl_asc_philipp='https://phihag.de/keys/A4826A18.asc'
	local url_ytdl_asc_sergey='https://dstftw.github.io/keys/18A9236D.asc'

	local path_file_sig="$DirDownloads/youtube-dl.sig"
	local path_file="$DirDownloads/youtube-dl"   # Path+Nome.
	local hash_sig='04d2edc85b80b59ffe46fdda3937b0074dfe10ede49fec6c36c609cd87841fcb' # sha256sum - .sig
	
	__download__ "$url_ytdl_test" "$path_file" || return 1 
	__download__ "$url_ytdl_sig" "$path_file_sig" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0
	
	# Asc philipp
	printf "%s" "[>] Importando: $url_ytdl_asc_philipp "
	if curl -sSL "$url_ytdl_asc_philipp" -o- | gpg --import - 1> /dev/null 2> /dev/null; then  
		echo -e "${CYellow}OK${CReset}"
	else
		echo ' '
		_red "Falha"
	fi
	
	# Asc sergey
	printf "%s" "[>] Importando: $url_ytdl_asc_sergey "
	if curl -sSL "$url_ytdl_asc_sergey" -o- | gpg --import - 1> /dev/null 2> /dev/null; then 
		echo -e "${CYellow}OK${CReset}"
	else
		echo ' '
		_red "Falha"
	fi

	# Gpg
	__gpg__ --verify "$path_file_sig" "$path_file" || return 1
	
	# Já instalado.
	is_executable "$directoryUSERbin/youtube-dl" && _show_info 'PkgInstalled' "youtube-dl" && return 0

	_white "Instalando youtube-dl em ~/.local/bin"
	cp -u "$path_file" "$directoryUSERbin"/youtube-dl
	chmod a+x "$directoryUSERbin"/youtube-dl

	if is_executable 'youtube-dl'; then
		_show_info 'SuccessInstalation' 'youtube-dl'
		return 0
	else
		_show_info 'InstalationFailed' 'youtube-dl'
		return 1
	fi
}

_python_twodict_github()
{
	# Instalar python twodict direto do github.
	_gitclone 'https://github.com/MrS0m30n3/twodict.git' || return 1
	_white "Executando: python2 setup.py"

	cd "$DirGitclone/twodict"
	if is_executable 'python2'; then
		sudo python2 setup.py install 1>> "$LogFile"
	elif is_executable 'python2.7'; then
		sudo python2.7 setup.py install 1>> "$LogFile"
	else
		_red "Falha: Instale o python2"
		return 1
	fi

	if [[ "$?" == '0' ]]; then 
		_show_info 'SuccessInstalation' 'python twodict'
		return 0
	else
		_show_info 'InstalationFailed' 'python twodict'
		return 1
	fi
}

_youtube_dlgui_file_desktop_user()
{
	# Criar arquivo .desktop na HOME para o usuario atual.
	_show_info "AddFileDesktop"

	file_desktop_tubedl_gui=~/.local/share/applications/youtube-dl-gui.desktop
	echo '[Desktop Entry]' > "$file_desktop_tubedl_gui"
	{
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=youtube-dl-gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} >> "$file_desktop_tubedl_gui"

	chmod u+x "$file_desktop_tubedl_gui"
	ln -sf "$file_desktop_tubedl_gui" ~/Desktop/ 2> /dev/null
	ln -sf "$file_desktop_tubedl_gui" ~/'Área de trabalho'/ 2> /dev/null
	ln -sf "$file_desktop_tubedl_gui" ~/'Área de Trabalho'/ 2> /dev/null
}

_youtube_dlgui_file_desktop_root()
{
	# Criar arquivo desktop para todos os usuarios.
	local file_desktop_tubedl_gui='/usr/share/applications/youtube-dl-gui.desktop' # .desktop

	_show_info "AddFileDesktop"
	echo '[Desktop Entry]' | sudo tee "$file_desktop_tubedl_gui" 1>> "$LogFile"
	{
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=youtube-dl-gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} | sudo tee -a "$file_desktop_tubedl_gui" 1> /dev/null

	_yellow "Criando atalho na Área de Trabalho"
	ln -sf "$file_desktop_tubedl_gui" ~/'Área de Trabalho'/ 2> /dev/null
	ln -sf "$file_desktop_tubedl_gui" ~/'Área de trabalho'/ 2> /dev/null
	ln -sf "$file_desktop_tubedl_gui" ~/Desktop/ 2> /dev/null
}


# Baixar e compilar youtube-dl-gui
_youtube_dlgui_compile()
{
	local url_ytdl_gui='https://github.com/MrS0m30n3/youtube-dl-gui/archive/master.zip'
	local path_file="$DirDownloads/youtube-dl-gui.zip"

	__download__ "$url_ytdl_gui" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 

	_unpack "$path_file" || return 1
	cd "$DirUnpack"/youtube-dl-gui-master || return 1
	_msg "Compilando youtube-dl-gui"
	
	if is_executable python2; then
		sudo python2 setup.py install 1>> "$LogFile" || return 1
	elif is_executable python2.7; then
		sudo python2 setup.py install 1>> "$LogFile" || return 1
	fi
		
	# Criar o arquivo ".desktop" após compilar o programa.
	_youtube_dlgui_file_desktop_root
	return 0
}

_youtube_dlgui_pip() 
{
	# ppa ubuntu.
	# sudo sh -c 'add-apt-repository ppa:nilarimogard/webupd8; apt update'
	# sudo apt install youtube-dlg --yes
	_pkg_manager_sys 'python-wxgtk3.0' gettext 'python-pip' 'python-twodict' || return 1
	pip install --user wheel 'youtube-dlg' || return 1
	_youtube_dlgui_file_desktop_user
	return 0
} 

_youtube_dlgui_ubuntu()
{
	# https://github.com/MrS0m30n3/youtube-dl-gui.git
	
	# Ubuntu e Linuxmint.
	case "$os_codename" in
		bionic|tricia) 
				_youtube_dlgui_pip 
				return
				;;
				
		eoan|focal)
				_pkg_manager_sys 'python-wxgtk3.0' gettext || return 1
				_python_twodict_github || return 1
				_youtube_dlgui_compile || return 1
				return 0
				;;	
				
		*)
			_show_info 'ProgramNotFound' 'youtube-dlg-gui'	
			return 1 
			;;
	esac	
}

_youtube_dlgui_fedora()
{
	# https://fedora.pkgs.org/31/fedora-x86_64/python2-wxpython-3.0.2.0-26.fc31.x86_64.rpm.html
	# https://wiki.wxpython.org/How%20to%20install%20wxPython
	#
	# Apartir da versão 32 do Fedora o pacote python2-wxpython3 não está mais
	# disponível no repositório, sendo necessário baixar o pacote do repositório
	# Fedora 31 e instalar usando o comando "rpm --install".
	#
	local f_packages='https://download-ib01.fedoraproject.org/pub/fedora/linux/releases/31/Everything/x86_64/os/Packages/p'
	local wxpython_rpm='python2-wxpython-3.0.2.0-26.fc31.x86_64.rpm'
	local url="$f_packages/$wxpython_rpm"
	local path_file="$DirDownloads/$wxpython_rpm"
	
	# Instalar python2-wxpython3
	case "$os_version" in
		31) _pkg_manager_sys 'python2-wxpython' || return 1;;
		32) 
			_pkg_manager_sys 'wxGTK3-media' 'python3-wxpython4.x86_64' || return 1
			__download__ "$url" "$path_file" || return 1
			_yellow "Instalando: $path_file"
			_RPM --install "$path_file" 
			;;
	esac
	
	_python_twodict_github || return 1
	_youtube_dlgui_compile || return 1
	return 0
}

_youtube_dlgui_tumbleweed()
{
	# https://software.opensuse.org/download/package?package=youtube-dl-gui&project=openSUSE%3AFactory
	local url_opensuse_repo='https://download.opensuse.org/repositories/openSUSE:'
	local url_ytdlg_tumbleweed="$url_opensuse_repo/Factory/standard/noarch/youtube-dl-gui-0.4-1.7.noarch.rpm"
	local path_file="$DirDownloads/$(basename $url_ytdlg_tumbleweed)"

	__download__ "$url_ytdlg_tumbleweed" "$path_file" || return 1 
	_pkg_manager_sys "$path_file" || return 1
	
	if is_executable 'youtube-dl-gui'; then
		_show_info 'SuccessInstalation' 'youtube-dl-gui'
		return 0
	else
		_show_info 'InstalationFailed' 'youtube-dl-gui'
		return 1
	fi
}

_youtube_dlgui_debian()
{
	# Testado apenas no debian 10.
	case "$os_codename" in
		buster)
			_pkg_manager_sys 'python-wxgtk3.0' 'python-twodict' gettext || return 1
			_youtube_dlgui_compile || return 1
			return 0
			;;
		*)
			_show_info 'ProgramNotFound' 'youtube-dlg-gui'
			return 1
			;;	
	esac
}


_youtube_dlgui_archlinux()
{
	_pkg_manager_sys 'python2-wxpython3' || return 1
	_python_twodict_github || return 1
	_youtube_dlgui_compile || return 1
	return 0
}

_youtube_dlgui_freebsd()
{
	# freebsd-12.0-release sudo pkg install py27-wxPython30
	_yellow "Instalando: py27-wxPython30"
	_pkg_manager_sys py27-wxPython30 || return 1
	_python_twodict_github || return 1
	_gitclone 'https://github.com/MrS0m30n3/youtube-dl-gui.git' || return 1
	cd "$DirTemp/youtube-dl-gui"
	sudo python2.7 setup.py install || return 1
	return 0
}

_youtube_dlgui()
{
	case "$os_id" in
		debian) _youtube_dlgui_debian || return 1;;
		ubuntu|linuxmint) _youtube_dlgui_ubuntu || return 1;;
		fedora) _youtube_dlgui_fedora || return 1;;
		arch) _youtube_dlgui_archlinux || return 1;;
		'12.1-STABLE'|'12.1-RELEASE') _youtube_dlgui_freebsd || return 1;;
		'opensuse-tumbleweed') _youtube_dlgui_tumbleweed || return 1;;
		*) _show_info 'ProgramNotFound' 'youtube-dl-gui'; return 1;;
	esac
	
	if is_executable 'youtube-dl-gui'; then
		_show_info 'SuccessInstalation' 'youtube-dl-gui'
		return 0
	else
		_show_info 'InstalationFailed' 'youtube-dl-gui'
		return 1
	fi
}

_bluetooth()
{
	if [[ "$os_id" != 'debian' ]]; then
		_red "Este pacote está disponível apenas para sistemas Debian"
		return 1
	fi

	_pkg_manager_sys bluez 'bluez-firmware' 'bluez-hcidump'
	echo -e "$space_line"
	_white "1 - ${CGreen}G${CReset}NOME"
	_white "2 - ${CGreen}K${CReset}DE"
	_white "3 - ${CGreen}L${CReset}XDE/${CGreen}X${CReset}FCE/${CGreen}L${CReset}XQT/${CGreen}M${CReset}ATE"
	
	while true; do

		_white "Selecione a sua interface gráfica: ${CGreen}(1 / 2 / 3): ${CReset}" 
		read -t 10 -n 1 desktop; echo ' '

		case "${desktop,,}" in
			1) _pkg_manager_sys 'gnome-bluetooth';;
			2) _pkg_manager_sys bluedevil;;
			3) _pkg_manager_sys blueman;;
			*) 
			_white "Opição inválida, você pode ${CGreen}repetir${CReset} ou ${_red}cancelar${CReset} [r/c]: " 
			read -t 10 -n 1 input; echo ' '
			if [[ "${input,,}" == 'r' ]]; then
				continue	
			else
				return 0; break
			fi		
			;;
		esac	
		break	
	done
}


_compactadores()
{

	local compactadores_debian=(
		'p7zip-full' 'p7zip' 'p7zip-rar' 'cabextract' 'unzip' 'xz-utils' 'lhasa' 
		'unace' 'arc' 'arj' 'lzma' 'rar' 'unrar-free' 'zip' 'ncompress'
	)

	local compactadores_fedora=(
		'zip' 'ncompress' 'xarchiver' 'arj' 'cabextract' 'unzip' 'p7zip' 'lzma' 'arc' 
	)

	local compactadores_arch=( 
		'tar' 'gzip' 'bzip2' 'unzip' 'unrar' 'p7zip'
	)


	if is_executable 'zypper'; then
		_pkg_manager_sys "${compactadores_fedora[@]}"
	elif is_executable 'dnf'; then
		_pkg_manager_sys "${compactadores_fedora[@]}"
	elif is_executable 'apt'; then
		_pkg_manager_sys "${compactadores_debian[@]}"
	elif is_executable 'pacman'; then
		_pkg_manager_sys "${compactadores_arch[@]}"
	else
		_show_info 'ProgramNotFound' 'compactadores'
		return 1
	fi
}

_firmware()
{
	if [[ "$os_id" != 'debian' ]]; then
		_yellow "Este pacote está disponível apenas para sistemas Debian"
		return 1
	fi

	case "$1" in
		firmware-ralink) _pkg_manager_sys 'firmware-ralink';;
		firmware-atheros) _pkg_manager_sys 'firmware-atheros';;
		firmware-realtek) _pkg_manager_sys 'firmware-realtek';;
		firmware-linux-nonfree) _pkg_manager_sys 'firmware-linux-nonfree';;
	esac
}


_gparted()
{
	_pkg_manager_sys gparted
}

_peazip()
{
	# Já instalado
	is_executable 'peazip' &&  _show_info 'PkgInstalled' 'peazip' && return 0
	# Url fixo versão 6.8
	local peazip_url__download='http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
	local path_file="$DirDownloads/$(basename $peazip_url__download)"
	local hash_file='c88f31bbe733ef5895472c78a9d84130a88d2cffd7262d115394b65bbc796d56'

	__download__ "$peazip_url__download" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar 

	__shasum__ "$path_file" "$hash_file" || return 1
	_unpack "$path_file" || return 1

	cd "$DirUnpack"
	mv -v $(ls -d peazip*) "$DirUnpack/peazip-amd64" 1> /dev/null
	mv "$DirUnpack/peazip-amd64" "${destinationFilesPeazip[dir]}"
	
	cd "${destinationFilesPeazip[dir]}" 
	cp -u FreeDesktop_integration/peazip.png "${destinationFilesPeazip[file_png]}"     
	cp -u "${destinationFilesPeazip[dir]}"/peazip "${destinationFilesPeazip[file_bin]}"

	echo '[Desktop Entry]' > "${destinationFilesPeazip[file_desktop]}"
	{
		echo 'Version=1.0'
		echo 'Encoding=UTF-8'
		echo 'Name=PeaZip'
		echo 'MimeType=application/x-gzip;application/x-tar;application/x-deb;bzip;application/x-rar'
		echo 'GenericName=Archiving Tool'
		echo 'Exec=peazip %F'
		echo 'Icon=peazip.png'
		echo 'Type=Application'
		echo 'Terminal=false'
		echo 'X-KDE-HasTempFileOption=true'
		echo 'Categories=GTK;KDE;Utility;System;Archiving;'
	} | tee -a "${destinationFilesPeazip[file_desktop]}" 1> /dev/null

	chmod -R a+x "${destinationFilesPeazip[dir]}"
	chmod -R a+rwx "${destinationFilesPeazip[file_desktop]}"                                 

	_show_info 'AddFileDesktop'
	ln -sf "${destinationFilesPeazip[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesPeazip[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesPeazip[file_desktop]}" ~/Desktop/ 2> /dev/null

	is_executable 'gtk-update-icon-cache' && gtk-update-icon-cache

	if is_executable 'peazip'; then
		_show_info 'SuccessInstalation' 'peazip'
		return 0
	else
		_show_info 'InstalationFailed' 'peazip'
		return 1
	fi
}

_refind_zip()
{
	# https://sourceforge.net/projects/refind/postdownload
	# http://www.rodsbooks.com/refind/
	# http://www.rodsbooks.com/refind/installing.html
	# https://sourceforge.net/p/refind/code/ci/master/tree/
	local url_rpm='https://ufpr.dl.sourceforge.net/project/refind/0.6.11/refind-0.6.11-1.x86_64.rpm'
	local url_zip='https://sourceforge.net/projects/refind/files/0.12.0/refind-bin-0.12.0.zip/download'
	local path_file="$DirDownloads/refind-bin-0.12.0.zip"
	
	__download__ "$url_zip" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 
	
	# Já instalado.
	is_executable 'refind-install' && _show_info 'PkgInstalled' 'refind-install' && return 0
	
	_unpack "$path_file" || return 1
	cd "$DirUnpack"
	mv $(ls -d refind*) refind
	sudo mv refind "${destinationFilesRefind[dir]}"
	
	# Criar script para execução
	echo '#!/usr/bin/env bash' | sudo tee "${destinationFilesRefind[file_script]}" 
	{
		echo "cd ${destinationFilesRefind[dir]}"
		echo "./refind-install \$@"
	} | sudo tee -a "${destinationFilesRefind[file_script]}"
	
	sudo chmod -R +x "${destinationFilesRefind[dir]}"
	sudo chmod a+x "${destinationFilesRefind[file_script]}"
	
}

_refind()
{
	case "$os_id" in
		debian|ubuntu|linuxmint|arch) _pkg_manager_sys refind;;
		*) _refind_zip;;
	esac
	
	if is_executable 'refind-install'; then
		_show_info 'SuccessInstalation' 'refind-install'
		return 0
	else
		_show_info 'InstalationFailed' 'refind-install'
		return 1
	fi
}


_stacer_debian()
{
	# https://github.com/oguzhaninan/Stacer/releases
	# https://github.com/oguzhaninan/Stacer
	local url='https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb'
	local path_file="$DirDownloads/$(basename $url)"

	__download__ "$url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	_DPKG --install "$path_file"
}

_stacer_fedora()
{
	_pkg_manager_sys stacer	
}


_stacer_appimage()
{
	# https://aur.archlinux.org/packages/stacer/
	# https://github.com/oguzhaninan/Stacer
	# https://github.com/oguzhaninan/Stacer/releases
	#
	local stacer_versions='https://github.com/oguzhaninan/Stacer/releases/download'
	local url_stacer_appimage="$stacer_versions/v1.1.0/Stacer-1.1.0-x64.AppImage"
	local path_file="$DirDownloads/Stacer-1.1.0-x64.AppImage"
	
	__download__ "$url_stacer_appimage" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	
	cp -u "$path_file" "${destinationFilesStacer[file_appimage]}"
	
	_show_info "AddFileDesktop"
	echo '[Desktop Entry]' | tee "${destinationFilesStacer[file_desktop]}" 1> /dev/null
	{
		echo "Encoding=UTF-8"
		echo "Name=Stacer"
		echo "Exec=stacer"
		echo "Comment=Linux System Optimizer and Monitoring"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=stacer"
		echo "Keywords=stacer;monitor;"
		echo "Type=Application"
		echo "Categories=Utility;System;"
	} | tee -a "${destinationFilesStacer[file_desktop]}" 1> /dev/null

	chmod a+x "${destinationFilesStacer[file_appimage]}"
	chmod +rwx "${destinationFilesStacer[file_desktop]}"

	_yellow "Criando atalho na Área de Trabalho"
	ln -sf "${destinationFilesStacer[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesStacer[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesStacer[file_desktop]}" ~/Desktop/ 2> /dev/null

	is_executable 'gtk-update-icon-cache' && gtk-update-icon-cache

	if is_executable 'stacer'; then
		_show_info 'SuccessInstalation' 'Stacer'
	else
		_show_info 'InstalationFailed' 'stacer'
	fi
}


_stacer()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _stacer_debian;;
		arch) 
			_pkg_manager_sys 'qt5-charts' 'hicolor-icon-theme' 'qt5-declarative' 'qt5-declarative' 'qt5-tools'
			_stacer_appimage
			;;
		*) _stacer_appimage;;
	esac
}


_virtualbox_extpack()
{
	# Após instalar o virtualbox no sistema, devemos executar esta
	# função para instalar o pacote extensionpack (em qualquer distro)
	# uma vez que está função funciona da mesma maneira em qualquer 
	# distribuição linux. 
	#   Baixa o pacote (extensionpack) instala o pacote usando o virtualbox
	# e adiciona o usuário atual no grupo  vboxuser.
	#
	_white "Aguarde"
	local vb_pag="https://www.virtualbox.org/wiki/Downloads"
	local vb_html=$(grep -m 1 "Oracle.*Ext.*vbox.*" <<< $(curl -sL "$vb_pag"))
	local vb_url=$(echo "$vb_html" | sed 's/.*href="//g;s/">.*//g')
	local path_file="$DirDownloads/$(basename $vb_url)"

	__download__ "$vb_url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	# Instalação
	_yellow "Instalando Extension Pack"
	sudo VBoxManage extpack install --replace "$path_file"

	_YESNO "Deseja adicionar $USER ao grupo ${CGreen}vboxusers${CReset}" || return 1
	
	#sudo gpasswd -a "$USER" vboxusers  
	sudo usermod -a -G vboxusers $USER	
}

_virtualbox_fedora()
{
	local requeriments_vb_fedora=(
		'libgomp' 
		'glibc-headers' 
		'glibc-devel' 
		'kernel-headers' 
		'dkms' 
		'qt5-qtx11extras' 
		'libxkbcommon' 
		'kernel-devel' 
		'binutils' 
		'gcc' 
		'make' 
		'patch'
	)

	_pkg_manager_sys "${requeriments_vb_fedora[@]}"
	_pkg_manager_sys $(rpm -qa kernel | sort -V | tail -n 1) 
	_pkg_manager_sys kernel-devel-$(uname -r)

	__download__ "https://www.virtualbox.org/download/oracle_vbox.asc" "$DirDownloads/oracle_vbox.asc"
	_yellow "Importando: $DirDownloads/oracle_vbox.asc"
	sudo rpm --import "$DirDownloads/oracle_vbox.asc"
	
	_white "Adicionando repositório: http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo"
	sudo sh -c 'curl -s -o /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo'
	
	case "$os_version" in
		31) _pkg_manager_sys 'VirtualBox-6.0' || return 1;;
		32) _pkg_manager_sys 'VirtualBox-6.1' || return 1;;
	esac
	
	# Módulos
	_white "Configurando módulos"
	sudo sh -c '/usr/lib/virtualbox/vboxdrv.sh setup'
	sudo sh -c '/sbin/vboxconfig'

	# Instalar o pacote ExtensionPack.
	_virtualbox_extpack 
}


_virtualbox_debian()
{
	# find /etc/apt -name *.list | xargs grep "^deb .*download\.virtualbox\.org.*debian buster contrib$" 2> /dev/null
		
	local url_libvpx='http://ftp.us.debian.org/debian/pool/main/libv/libvpx/libvpx5_1.7.0-3+deb10u1_amd64.deb'
	local path_libvpx="$DirDownloads/$(basename $url_libvpx)"
	local sum_libvpx='72d8466a4113dd97d2ca96f778cad6c72936914165edafbed7d08ad3a1679fec'
	local vbox_file="/etc/apt/sources.list.d/virtualbox.list"

	case "$os_codename" in
		buster) vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib";;
		bionic|tricia|focal) vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib";;
		*) _red "Seu sistema ainda não tem suporte a instalação do virtualbox por meio deste script"; return 1;;
	esac
	
	# Limpar o cache antes de adicionar as chaves (recomendado).
	_msg "Limpando o cache do (apt)"
	_APT clean
	# sudo rm -rf /var/lib/apt/lists/* 1> /dev/null 2> /dev/null
	
	echo -ne "Adicionando key: https://www.virtualbox.org/download/oracle_vbox_2016.asc "
	sudo sh -c 'curl -sL https://www.virtualbox.org/download/oracle_vbox_2016.asc | apt-key add -' || return 1
		
	echo -ne "Adicionando key: https://www.virtualbox.org/download/oracle_vbox.asc "
	sudo sh -c 'curl -sL https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add -' || return 1
		
	echo -ne "Adicionando repositório "
	echo "$vbox_repo" | sudo tee "$vbox_file"
	
	# Atualizar o cache 'apt update' apartir da função _APT.
	_APT update 
	
	# _pkg_manager_sys libvpx6 
	_pkg_manager_sys 'module-assistant' 'build-essential' 'libsdl-ttf2.0-0' dkms
	_pkg_manager_sys linux-headers-$(uname -r)
	
	if [[ "$os_codename" == 'focal' ]]; then
		__download__ "$url_libvpx" "$path_libvpx" || return 1
		__shasum__ "$path_libvpx" "$sum_libvpx" || return 1
		_DPKG --install "$path_libvpx" || _BROKE
	fi
	
	echo -e "$space_line"
	_pkg_manager_sys 'virtualbox-6.0' || return 1
	_virtualbox_extpack
}

_virtualbox_archlinux()
{
	# https://sempreupdate.com.br/como-instalar-o-virtualbox-no-arch-linux/
	# https://wiki.archlinux.org/index.php/VirtualBox_(Portugu%C3%AAs)
	# https://www.virtualbox.org/wiki/Linux_Downloads
	# https://www.edivaldobrito.com.br/sbinvboxconfig-nao-esta-funcionando/
	# virtualbox-host-modules-arch
	# virtualbox-host-dkms
	# systemd-modules-load.service -> (carregar módulos no boot)
	# /usr/lib/modules-load.d/virtualbox-host-modules-arch.conf -> Arquivo de configuração
	
	local array_vb_archlinux=(
		'virtualbox' 
		'virtualbox-host-modules-arch'
		'linux-headers'
	)

	for c in "${array_vb_archlinux[@]}"; do
		_space_text "[+] Instalando" "$c"
		_pkg_manager_sys "$c"
		_space_text "${C_red}[!]${CReset} Falha" "$c"
	done

	# /etc/modules-load.d/virtualbox.conf
	# sudo depmod -a
	_white "Configurando módulos"
	sudo /sbin/rcvboxdrv setup
	sudo /sbin/vboxconfig
	sudo modprobe vboxdrv

	# Configuração para carregar o módulo durante o boot.
	# sudo echo vboxdrv >> /etc/modules-load.d/virtualbox.conf

	# Instalar o pacote ExtensionPack.
	#_virtualbox_extpack 
}

_virtualbox_linux_run()
{
	# Virtualbox para qualquer Linux.
	# Encontar os urls de downloads do executável .run (dor virtualbox)
	# e o arquivo que contém as hashs sha256 para cada versão do virtualbox
	#
	# O download do arquivo contendo as hashs e semelhante ao comando
	# abixo, ATENÇÃO a mudança de versão do virtualbox (6.x)
	# curl -O https://www.virtualbox.org/download/hashes/6.1.6/SHA256SUMS
	#
	# https://download.virtualbox.org/virtualbox/6.1.6/VirtualBox-6.1.6-137129-Linux_amd64.run
	#
	# sudo /etc/init.d/vboxdrv setup
	# sudo /sbin/vboxconfig
	# sudo /sbin/rcvboxdrv setup

	# Pagina de download do virtualbox
	vbox_pag='https://www.virtualbox.org/wiki/Linux_Downloads'

	# Encontrar ocorrências .run ou SHA256 no html da pagina de download.
	vbox_html=$(egrep "(https.*download.*64.run|SHA256)" <<< $(curl -sSL $vbox_pag))

	# Filtrar o url do arquivo executável (.run) e atribuir path para download.
	vbox_url_run=$(echo "$vbox_html" | grep -m 1 '64.run' | sed 's/.*href="//g;s/run".*/run/g')
	vbox_version=$(echo "$vbox_url_run" | cut -d '/' -f 5)
	path_file="$DirDownloads/$(basename $vbox_url_run)"
	
	# Definir o url de download do arquivo com as hashs e seu destino de download.
	vbox_url_hash="https://www.virtualbox.org/download/hashes/$vbox_version/SHA256SUMS"
	vbox_path_file_hash="$DirDownloads/virtualbox_$vbox_version.check"

	__download__ "$vbox_url_run" "$path_file" || return 1
	__download__ "$vbox_url_hash" "$vbox_path_file_hash" || return

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	# Obter a HASH da versão atual no que está no arquivo .check
	# em seguida verificar a integridade do pacote.
	vbox_sum=$(grep '64.run' "$vbox_path_file_hash" | cut -d' ' -f 1)
	__shasum__ "$path_file" "$vbox_sum" || return 1
	chmod +x "$path_file"
	sudo "$path_file"
	sudo /sbin/rcvboxdrv setup
	sudo /sbin/vboxconfig
	_virtualbox_extpack
}

_virtualbox()
{
	#is_executable virtualbox && _show_info 'PkgInstalled' 'virtualbox' && return 0
	case "$os_id" in
		debian|linuxmint|ubuntu) _virtualbox_debian;;
		fedora) _virtualbox_fedora;;
		arch) _virtualbox_linux_run;;	
		*) _show_info 'ProgramNotFound' 'virtualbox'; return 1;;	
	esac
}

_ohmybash()
{
	# github_ohmy_bash="https://github.com/ohmybash/oh-my-bash.git"
	# https://github.com/ohmybash/oh-my-bash/wiki/Themes#agnoster
	#
	# Temas:
	# I recommend the following:
	# cd home
	# mkdir -p .bash/themes/agnoster-bash
	# git clone https://github.com/speedenator/agnoster-bash.git .bash/themes/agnoster-bash
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
	
	local ohmybash_master='https://github.com/ohmybash/oh-my-bash/archive/master.zip'
	local ohmybashZipFile="$DirDownloads/ohmybash.zip"
	local url_installer='https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh'
	local ohmybash_installer="$DirDownloads/ohmybash_installer.sh"
	
	if is_executable "$scriptOhmybashInstaller"; then
		"$scriptOhmybashInstaller"
	else 
		sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" 
	fi

	__download__ "$ohmybash_master" "$ohmybashZipFile" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar 

	_unpack "$ohmybashZipFile" || return 1
	_msg "Instalando temas para ohmybash em: $HOME/.bash/themes"
	mkdir -p "$HOME/.bash/themes"
	cp -R -u "$DirUnpack/oh-my-bash-master/themes/" "$HOME/.bash/" || return 1
	
	_YESNO "Gostaria de habilitar um tema para ohmybash" || return 1

	_yellow "1 => bakke"
	_yellow "2 => bobby"
	_yellow "3 => bobby-python"
	_yellow "4 => emperor"
	_yellow "5 => mairan (recomendado)"
	_yellow "6 => rjorgenson"
	read -n 1 -t 15 -p "Selecione um numero correspondente a opção desejada: " option
	echo ' '

	case "$option" in
		1) option='bakke';;
		2) option='bobby';;
		3) option='bobby-python';;
		4) option='emperor';;
		5) option='mairan';;
		6) option='rjorgenson';;
		*) _red "Opção incorreta saindo"; return 1;;
	esac

	_msg "Habilitando o tema $option para ohmybash"
	case "$option" in
		bakke) sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" "$HOME/.bashrc";;
		bobby) sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" "$HOME/.bashrc";;
		'bobby-python') sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" "$HOME/.bashrc";;
		emperor) sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" "$HOME/.bashrc";;
		mairan) sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" "$HOME/.bashrc";;
		rjorgenson) sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" "$HOME/.bashrc";;
	esac
	_white "OK"
	
}

_ohmyzsh()
{
	# sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	# https://github.com/ohmyzsh/ohmyzsh
	#
	if ! is_executable 'zsh'; then
		_yellow "Necessário instalar shell [zsh]"	
	fi

	_pkg_manager_sys zsh
	_yellow "Instalando ohmyzsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"	
}

_papirus_debian()
{
	# sudo apt install libreoffice-style-papirus
	_pkg_manager_sys 'papirus-icon-theme'
}

_papirus_github()
{
	#------------------- Instruções para instalação ---------------------#
	# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
	# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/master.zip
	# https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh
	# https://github.com/PapirusDevelopmentTeam

	local url_papirus_master="$github/PapirusDevelopmentTeam/papirus-icon-theme/archive/master.tar.gz"
	local path_file="$DirDownloads/papirus.tar.gz"

	__download__ "$url_papirus_master" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 

	_unpack "$path_file" || return 1
	cd "$DirUnpack"
	mv  $(ls -d papirus-*) papirus
	cd papirus
	
	printf "%s" "[>] Instalando Papirus-Dark "
	cp -R -u Papirus-Dark "${destinationFilesPapirus[papirus_dark]}" && _syellow "OK"

	printf "%s" "[>] Instalando Papirus "
	cp -R -u Papirus "${destinationFilesPapirus[papirus]}" && _syellow "OK"
	
	printf "%s" "[>] Instalando Papirus-Light " 
	cp -R -u Papirus-Light "${destinationFilesPapirus[papirus_light]}" && _syellow "OK"

	printf "%s" "[>] Instalando ePapirus "
	cp -R -u ePapirus "${destinationFilesPapirus[epapirus]}" && _syellow "OK"
	
}

_papirus()
{
	case "$os_id" in
		debian) _papirus_debian;;
		*) _papirus_github;;
	esac
}

_sierra()
{
	# https://github.com/vinceliuice/Sierra-gtk-theme
	# https://github.com/vinceliuice/Sierra-gtk-theme#flathub
	#----------------------------------------------------------------------#
	#
	# Flathub
	# Light Theme flatpak install flathub org.gtk.Gtk3theme.High-Sierra
	# Dark Theme flatpak install flathub org.gtk.Gtk3theme.High-Sierra-Dark
	#----------------------------------------------------------------------#
	#
	# Suse
	# sudo zypper ar obs://X11:common:Factory/sierra-gtk-theme x11
    # sudo zypper ref
    # sudo zypper in sierra-gtk-theme
	#----------------------------------------------------------------------#
	#
	local github_sierra="$github/vinceliuice/Sierra-gtk-theme"
	local url_sierra='https://github.com/vinceliuice/Sierra-gtk-theme/archive/master.tar.gz'
	local path_file="$DirDownloads/sierra_gtk_theme.tar.gz"

	case "$os_id" in
		fedora) 
				_pkg_manager_sys 'gtk-murrine-engine' 'gtk2-engines'
				;;

		arch) 
				_pkg_manager_sys 'gtk-engine-murrine' 'gtk-engines'
				;;

		debian|ubuntu|linuxmint) 
				_pkg_manager_sys 'gtk2-engines-murrine' 'gtk2-engines-pixbuf'
				;;
	esac

	__download__ "$url_sierra" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	_unpack "$path_file" || return 1
	cd "$DirUnpack"
	mv $(ls -d Sierra*) sierra_theme 
	cd sierra_theme
	chmod +x install.sh
	./install.sh --color dark
}

_dashtodock_github()
{
	# https://micheleg.github.io/dash-to-dock/download.html
	#
	local url='https://github.com/micheleg/dash-to-dock/archive/master.tar.gz'
	local url_repo='https://github.com/micheleg/dash-to-dock.git'
	local path_file="$DirDownloads/dash_to_dock.tar.gz"

	_gitclone "$url_repo" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 

	_pkg_manager_sys make
	cd "$DirTemp"/dash-to-dock
	make
	make install
	#sudo make install 

	if _YESNO "Deseja abrir a jenela de configuração gnome-shell-extension-prefs"; then
		gnome-shell-extension-prefs
	fi

}

_dashtodock()
{
	case "$os_id" in
		fedora) _pkg_manager_sys 'gnome-shell-extension-dash-to-dock.noarch';;
		debian) _pkg_manager_sys 'gnome-shell-extension-dashtodock';;
		*) _dashtodock_github;;
	esac
}

_drive_menu()
{
	case "$os_id" in
		fedora) _pkg_manager_sys 'gnome-shell-extension-drive-menu';;
		*) _show_info 'ProgramNotFound' 'drive-menu'; return 1;;
	esac
}

_gnome_backgrounds()
{
	case "$os_id" in 
		arch) _pkg_manager_sys 'gnome-backgrounds';;
		fedora) _pkg_manager_sys 'gnome-backgrounds-extras' 'verne-backgrounds-gnome';;
		*) _show_info 'ProgramNotFound' 'gnome-backgrounds'; return 1;;
	esac
}

_topicons_plus_github()
{
	# https://github.com/phocean/TopIcons-plus/archive/master.zip
	# https://github.com/phocean/TopIcons-plus/archive/master.tar.gz
	# https://github.com/phocean/TopIcons-plus

	local url='https://github.com/phocean/TopIcons-plus/archive/master.tar.gz'
	local path_file="$DirDownloads/topicons_plus.tar.gz"

	__download__ "$url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0 

	_unpack "$path_file" || return 1
	_pkg_manager_sys make

	cd "$DirUnpack"
	mv $(ls -d Top*) "$DirUnpack"/topicons_plus
	cd topicons_plus
	
	# make install
	sudo make install INSTALL_PATH=/usr/share/gnome-shell/extensions
	echo -e "$space_line"

	if _YESNO "Deseja abrir a jenela de configuração para topicons-plus"; then
		gnome-extensions prefs TopIcons@phocean.net
	fi

}

_topicons_plus()
{
	case "$os_id" in
		fedora) _pkg_manager_sys 'gnome-shell-extension-topicons-plus';;
		debian) _pkg_manager_sys 'gnome-shell-extension-top-icons-plus';;
		*) _topicons_plus_github;;
	esac
}

_gnome_tweaks()
{
	_pkg_manager_sys 'gnome-tweaks'
}

_snapd()
{
	# https://www.edivaldobrito.com.br/suporte-a-pacotes-snap-no-linux/
	case "$os_id" in
		debian) _pkg_manager_sys snapd;;
		fedora) _pkg_manager_sys snapd;;
		*) _show_info 'ProgramNotFound' 'snapd'; return 1;;
	esac
}

_epsxe_windows()
{
	# ePSXe win 32
	# CONFIGURAÇÃO PATH NO WINE
	# https://www.windows-commandline.com/set-path-command-line/
	#
	# echo %path%
	# setx path "%path%;c:\directoryPath" 
	# setx path "%path%;c:\epsxe-win"
	# setx path "%path%;c:\dir1\dir2"
	# pathman /as C:\epsxe-win
	#
	# REMOVE DIRETÓRIO DO PATH
	# pathman /rs directoryPath	
	#
	#
	#local URLepsxeWin='http://www.epsxe.com/files/ePSXe205.zip'  # V2.0.5
	local URLepsxeWin='http://www.epsxe.com/files/ePSXe1925.zip'   # V1.9.25
	local pathFileZip="$DirDownloads/$(basename $URLepsxeWin)"
	#local hashFileZip='46e1a7ad3dc9c75763440c153465cdccc9a3ba367e3158542953ece4bcdb7b4f' # V2.0.5
	local hashFileZip='6145d4faf69f7614ed54d09657a826d115d7e7d1d8f408d8e2fb615df50f63c5' # V1.9.25

	mkdir -p "${destinationFilesEpsxeWin32[dir]}"
	_clear_temp_dirs

	__download__ "$URLepsxeWin" "$pathFileZip" || return 1
	_unpack "$pathFileZip" || return 1
	cd "$DirUnpack"
	cp -R -n * "${destinationFilesEpsxeWin32[dir]}"/

	_yellow "Criando: script para execução de ePSXe"
	echo '#!/bin/sh' > "${destinationFilesEpsxeWin32[file_script]}"
	{
		echo -e "\nWINEPREFIX=/home/bruno/.wine"
		echo -e "\ncd ${destinationFilesEpsxeWin32[dir]}"
		echo -e "wine ePSXe.exe" 
	} >> "${destinationFilesEpsxeWin32[file_script]}"


	echo "[Desktop Entry]" > "${destinationFilesEpsxeWin32[file_desktop]}"
	{
	  echo "Type=Application"
	  echo "Terminal=false"
	  echo "Exec=${destinationFilesEpsxeWin32[file_script]}"
	  echo "Name=ePSXe-Win32"
	  echo "Comment=Instalado via storecli github: https://github.com/Brunopvh/storecli"
	  echo "Categories=Game;Emulator;"
	} >> "${destinationFilesEpsxeWin32[file_desktop]}"

	chmod +x "${destinationFilesEpsxeWin32[file_script]}"
	chmod +rwx "${destinationFilesEpsxeWin32[file_desktop]}"
	winetricks directx9 atmlib
	"${destinationFilesEpsxeWin32[file_script]}"
}

_epsxe_zip()
{
	# https://wiki.archlinux.org/index.php/EPSXe
	# https://aur.archlinux.org/packages/epsxe/
	# libncurses.so.5 => not found
	# libtinfo.so.5 => not found
	# libSDL_ttf-2.0.so.0 => not found
	#
	local urlEpsxe='http://www.epsxe.com/files/ePSXe205linux_x64.zip'
	local pathFileEpsxe="$DirDownloads/$(basename $urlEpsxe)"

	__download__ "$urlEpsxe" "$pathFileEpsxe" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	_unpack "$pathFileEpsxe" || return 0
	cd "$DirUnpack"
	mkdir -p "${destinationFilesEpsxe[dir]}"
	cp -R -u epsxe_x64 "${destinationFilesEpsxe[dir]}"/
	cp -R -u docs "${destinationFilesEpsxe[dir]}"/
	ln -sf "${destinationFilesEpsxe[dir]}"/epsxe_x64 "${destinationFilesEpsxe[link]}" 
	
	echo "[Desktop Entry]" > "${destinationFilesEpsxe[file_desktop]}"
	{
	  echo "Type=Application"
	  echo "Terminal=false"
	  echo "Exec='cd ${destinationFilesEpsxe[dir]}; ./epsxe_x64'"
	  echo "Name=ePSXe"
	  echo "Comment=Instalado via storecli github: https://github.com/Brunopvh/storecli"
	  echo "Icon=${destinationFilesEpsxe[file_png]}"
	  echo "Categories=Game;Emulator;"
	} >> "${destinationFilesEpsxe[file_desktop]}"
	
	chmod -R +x "${destinationFilesEpsxe[dir]}"
	chmod +x "${destinationFilesEpsxe[file_desktop]}"
}

_epsxe_snapd()
{
	# https://snapcraft.io/epsxe
	_snapd
	sudo snap install epsxe --candidate
}

_epsxe_fedora()
{
	_pkg_manager_sys snapd
	sudo ln -s /var/lib/snapd/snap /snap
	sudo snap install epsxe --candidate
}

_epsxe()
{
	case "$os_id" in
		arch) _epsxe_zip;;
		debian) _epsxe_snapd;;
		fedora) _epsxe_fedora;;
		*) _show_info 'ProgramNotFound' 'epsxe'; return 0;;
	esac
}

#=============================================================#
# Instalar todos os pacotes da categória Acessorios.
#=============================================================#
_Acessory_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Acessórios'" || return 1
	fi

	if [[ "$AssumeYes" == 'True' ]] && [[ "$DownloadOnly" = 'True' ]]; then
		main --yes --downloadonly install etcher
		main --yes --downloadonly install gnome-disk
		main --yes --downloadonly install veracrypt
		main --yes --downloadonly install woeusb
	elif [[ "$AssumeYes" == 'True' ]]; then
		main --yes install etcher
		main --yes install gnome-disk
		main --yes install veracrypt
		main --yes install woeusb
	else
		main install etcher
		main install gnome-disk
		main install veracrypt
		main install woeusb
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Sistema.
#=============================================================#
_System_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Sistema'" || return 1 
	fi
	
	if [[ "$AssumeYes" == 'True' ]] && [[ "$DownloadOnly" == 'True' ]]; then
		main --yes --downloadonly install bluetooth
		main --yes --downloadonly install compactadores
		main --yes --downloadonly install gparted
		main --yes --downloadonly install peazip
		main --yes --downloadonly install refind
		main --yes --downloadonly install stacer
		main --yes --downloadonly install virtualbox
		
	elif [[ "$AssumeYes" == 'True' ]]; then
		"$scriptStorecli" --yes install bluetooth
		"$scriptStorecli" --yes install compactadores
		"$scriptStorecli" --yes install gparted
		"$scriptStorecli" --yes install peazip
		"$scriptStorecli" --yes install refind
		"$scriptStorecli" --yes install stacer
		"$scriptStorecli" --yes install virtualbox
	else
		"$scriptStorecli" install bluetooth
		"$scriptStorecli" install compactadores
		"$scriptStorecli" install gparted
		"$scriptStorecli" install peazip
		"$scriptStorecli" install refind
		"$scriptStorecli" install stacer
		"$scriptStorecli" install virtualbox
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Internet_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Internet'" || return 1
	fi

	if [[ "$AssumeYes" == 'True' ]] && [[ "$DownloadOnly" == 'True' ]]; then
		"$scriptStorecli" --yes --downloadonly install megasync
		"$scriptStorecli" --yes --downloadonly install proxychains
		"$scriptStorecli" --yes --downloadonly install qbittorrent
		"$scriptStorecli" --yes --downloadonly install teamviewer
		"$scriptStorecli" --yes --downloadonly install telegram
		"$scriptStorecli" --yes --downloadonly install tixati
		"$scriptStorecli" --yes --downloadonly install uget
		"$scriptStorecli" --yes --downloadonly install youtube-dl
		"$scriptStorecli" --yes --downloadonly install youtube-dl-gui
	elif [[ "$AssumeYes" == 'True' ]]; then
		"$scriptStorecli" --yes install megasync
		"$scriptStorecli" --yes install proxychains
		"$scriptStorecli" --yes install qbittorrent
		"$scriptStorecli" --yes install teamviewer
		"$scriptStorecli" --yes install telegram
		"$scriptStorecli" --yes install tixati
		"$scriptStorecli" --yes install uget
		"$scriptStorecli" --yes install youtube-dl
		"$scriptStorecli" --yes install youtube-dl-gui
	else
		"$scriptStorecli" install megasync
		"$scriptStorecli" install proxychains
		"$scriptStorecli" install qbittorrent
		"$scriptStorecli" install teamviewer
		"$scriptStorecli" install telegram
		"$scriptStorecli" install tixati
		"$scriptStorecli" install uget
		"$scriptStorecli" install youtube-dl
		"$scriptStorecli" install youtube-dl-gui
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Browser_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Navegadores'" || return 1
	fi

	if [[ "$AssumeYes" == 'True' ]] && [[ "$DownloadOnly" == 'True' ]]; then
		"$scriptStorecli" --yes --downloadonly install chromium
		"$scriptStorecli" --yes --downloadonly install firefox
		"$scriptStorecli" --yes --downloadonly install google-chrome
		"$scriptStorecli" --yes --downloadonly install opera-stable
		"$scriptStorecli" --yes --downloadonly install torbrowser
	elif [[ "$AssumeYes" == 'True' ]]; then
		"$scriptStorecli" --yes install chromium
		"$scriptStorecli" --yes install firefox
		"$scriptStorecli" --yes install google-chrome
		"$scriptStorecli" --yes install opera-stable
		"$scriptStorecli" --yes install torbrowser
	else
		"$scriptStorecli" install chromium
		"$scriptStorecli" install firefox
		"$scriptStorecli" install google-chrome
		"$scriptStorecli" install opera-stable
		"$scriptStorecli" install torbrowser
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Office.
#=============================================================#
_Office_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Escritório'" || return 0
	fi

	if [[ "$AssumeYes" == 'True' ]] && [[ "$DownloadOnly" == 'True' ]]; then
		"$scriptStorecli" -y -d install atril
		"$scriptStorecli" -y -d install fontes-ms
		"$scriptStorecli" -y -d install libreoffice-appimage
		"$scriptStorecli" -y -d install libreoffice
	elif [[ "$AssumeYes" == 'True' ]]; then
		"$scriptStorecli" -y install atril
		"$scriptStorecli" -y install fontes-ms
		"$scriptStorecli" -y install libreoffice-appimage
		"$scriptStorecli" -y install libreoffice
	else
		"$scriptStorecli" install atril
		"$scriptStorecli" install fontes-ms
		"$scriptStorecli" install libreoffice-appimage
		"$scriptStorecli" install libreoffice
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Midia.
#=============================================================#
_Midia_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Midia'" || return 1
	fi

	if [[ "$AssumeYes" == 'True' ]] && [[ "$DownloadOnly" == 'True' ]]; then
		"$scriptStorecli" -y -d install codecs
		"$scriptStorecli" -y -d install celluloid
		"$scriptStorecli" -y -d install cinema
		"$scriptStorecli" -y -d install gnome-mpv
		"$scriptStorecli" -y -d install parole
		"$scriptStorecli" -y -d install smplayer
		"$scriptStorecli" -y -d install spotify
		"$scriptStorecli" -y -d install totem
		"$scriptStorecli" -y -d install vlc
	elif [[ "$AssumeYes" == 'True' ]]; then
		"$scriptStorecli" -y install codecs
		"$scriptStorecli" -y install celluloid
		"$scriptStorecli" -y install cinema
		"$scriptStorecli" -y install gnome-mpv
		"$scriptStorecli" -y install parole
		"$scriptStorecli" -y install smplayer
		"$scriptStorecli" -y install spotify
		"$scriptStorecli" -y install totem
		"$scriptStorecli" -y install vlc
	else
		"$scriptStorecli" install codecs
		"$scriptStorecli" install celluloid
		"$scriptStorecli" install cinema
		"$scriptStorecli" install gnome-mpv
		"$scriptStorecli" install parole
		"$scriptStorecli" install smplayer
		"$scriptStorecli" install spotify
		"$scriptStorecli" install totem
		"$scriptStorecli" install vlc
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Desenvolvimento.
#=============================================================#
_Dev_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Desenvolvimento'" || return 1
	fi
	
	if [[ "$AssumeYes" == 'True' ]] && [[ "$DownloadOnly" == 'True' ]]; then
		"$scriptStorecli" -y -d install android-studio
		"$scriptStorecli" -y -d install codeblocks
		"$scriptStorecli" -y -d install pycharm
		"$scriptStorecli" -y -d install sublime-text
		"$scriptStorecli" -y -d install vim
		"$scriptStorecli" -y -d install vscode
	elif [[ "$AssumeYes" == 'True' ]]; then
		"$scriptStorecli" -y install android-studio
		"$scriptStorecli" -y install codeblocks
		"$scriptStorecli" -y install pycharm
		"$scriptStorecli" -y install sublime-text
		"$scriptStorecli" -y install vim
		"$scriptStorecli" -y install vscode
	else
		"$scriptStorecli" install android-studio
		"$scriptStorecli" install codeblocks
		"$scriptStorecli" install pycharm
		"$scriptStorecli" install sublime-text
		"$scriptStorecli" install vim
		"$scriptStorecli" install vscode
	fi
}


