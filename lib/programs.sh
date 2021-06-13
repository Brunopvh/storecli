#!/usr/bin/env bash
#

github='https://github.com'

function check_python_version2()
{
	# Verificar se o python versão 2 está instalado.
	if is_executable python2; then
		export PYTHON_VERSION2='True'
		export PYTHON2_EXECUTABLE=$(command -v python2)
	elif python -c "import platform; print(platform.python_version()[0:3])" | grep -q '^2.7$' 2> /dev/null; then
		export PYTHON_VERSION2='True'
		export PYTHON2_EXECUTABLE=$(command -v python2)
	else
		export PYTHON_VERSION2='False'
		return 1
	fi
	return 0
}

function __add_link_from_python(){
	[[ -x $(command -v python) ]] && return 0
	
	if [[ -x $(command -v python3) ]]; then
		print_info "Criando link simbolico para python3 em ... $DIR_BIN/python"
		ln -sf $(command -v python3) "$DIR_BIN"/python
	elif [[ -x $(command -v python2) ]]; then
		print_info "Criando link simbolico para python2 em ... $DIR_BIN/python"
		ln -sf $(command -v python3) "$DIR_BIN"/python
	else
		print_erro "Necessário ter um link para o executável do python ou python3"
		sleep 1
		return 1
	fi
	sleep 1
	return 0
}

_coin_qt_gui()
{
	local URL_REPO_COIN_QT_GUI='https://github.com/Brunopvh/coin-qt-gui/archive/refs/heads/master.zip'
	local OUTPUT_FILE_COIN="$DirDownloads/coin-qt-gui.tar.gz"
	local FILE_DESKTOP="$DIR_APPLICATIONS/coin-qt-gui.desktop"

	download "$URL_REPO_COIN_QT_GUI" "$OUTPUT_FILE_COIN" || return 1
	[[ $DownloadOnly == 'True' ]] && print_info 'Feito somente download' && return 0
	unpack_archive "$OUTPUT_FILE_COIN" $DirUnpack || return
	cd $DirUnpack
	mv $(ls -d coin-qt-gui*) coin-qt-gui
	cd coin-qt-gui
	python3 setup.py install --user || return
	print_info "Copiando arquivo desktop"
	cp data/coin-qt-gui.desktop "${destinationFilesCoinQtGui[file_desktop]}"
	chmod +x "${destinationFilesCoinQtGui[file_desktop]}"
}

_add_file_desktop_electrum()
{
	echo '[Desktop Entry]' > "${destinationFilesElectrum[file_desktop]}"

	{
		echo "Comment=Lightweight Bitcoin Client"
		echo 'Exec=/bin/sh -c "electrum %u"'
		echo "GenericName[en_US]=Bitcoin Wallet"
		echo "GenericName=Bitcoin Wallet"
		echo "Icon=electrum"
		echo "Name[en_US]=Electrum Bitcoin Wallet"
		echo "Name=Electrum Bitcoin Wallet"
		echo "Categories=Finance;Network;"
		echo "StartupNotify=true"
		echo "StartupWMClass=electrum"
		echo "Terminal=false"
		echo "Type=Application"
		echo "MimeType=x-scheme-handler/bitcoin;"
		echo "Actions=Testnet;"
		echo ""
		echo "[Desktop Action Testnet]"
		echo 'Exec=/bin/sh -c "electrum --testnet %u"'
		echo "Name=Testnet mode"
	} >> "${destinationFilesElectrum[file_desktop]}"

	chmod +x "${destinationFilesElectrum[file_desktop]}"

}

_install_electrum_appimage()
{
	# https://github.com/spesmilo/electrum
	# https://electrum.org/#home

	local URL_ELECTRUM='https://download.electrum.org/4.0.9/electrum-4.0.9-x86_64.AppImage'
	local URL_ELECTRUM_SIG='https://download.electrum.org/4.0.9/electrum-4.0.9-x86_64.AppImage.asc'
	local URL_ELECTRUM_PNG='https://raw.github.com/spesmilo/electrum/master/electrum/gui/icons/electrum.png'
	local PATH_ELECTRUM="$DirDownloads/$(basename $URL_ELECTRUM)"
	local PATH_ELECTRUM_SIG="$DirDownloads/$(basename $URL_ELECTRUM_SIG)"
	local PATH_ELECTRUM_PNG="$DirDownloads/electrum.png"
	local HASH_PNG='0b93801e52706091b5be0219a8f7fb6f04a095f7c5dd8bf9a0a93f5f5d6ed98e'

	download "$URL_ELECTRUM" $PATH_ELECTRUM || return 1
	download "$URL_ELECTRUM_SIG" $PATH_ELECTRUM_SIG || return 1
	download "$URL_ELECTRUM_PNG" $PATH_ELECTRUM_PNG || return 1
	gpg_import 'https://raw.githubusercontent.com/spesmilo/electrum/master/pubkeys/ThomasV.asc'
	gpg_verify $PATH_ELECTRUM_SIG $PATH_ELECTRUM || return 1

	__shasum__ $PATH_ELECTRUM_PNG $HASH_PNG || return 1
	cp $PATH_ELECTRUM "${destinationFilesElectrum[script]}"
	cp $PATH_ELECTRUM_PNG "${destinationFilesElectrum[png]}"
	chmod +x "${destinationFilesElectrum[script]}"

	_add_file_desktop_electrum
	is_executable gtk-update-icon-cache && gtk-update-icon-cache

	if is_executable electrum; then
		print_info "electrum instalado com sucesso"
		return 0
	else
		print_erro "Falha na instalação de electrum"
		return 1
	fi

}

_install_electrum()
{
	_install_electrum_appimage
}

_install_storecli_gui()
{
	local URL_STORECLI='https://github.com/Brunopvh/storecli/archive/master.tar.gz'
	is_executable storecli || "$SCRIPT_STORECLI_INSTALLER"

	if is_executable xdpyinfo; then
		#Resolution=$(xdpyinfo | grep -A 3 "screen #0" | grep dimensions | tr -s " " | cut -d" " -f 3)
		Resolution=$(xdpyinfo | grep -A 3 "screen #0" | grep dimensions | awk '{print $4}' | sed 's/(//g')
		ResolutionX=$(echo $Resolution | cut -d 'x' -f 1)
		ResolutionY=$(echo $Resolution | cut -d 'x' -f 2)
	fi
	
	if [[ -z $Resolution ]]; then
		SetResolutionX=130
		SetResolutionY=30
	else
		SetResolutionX="$(($ResolutionX/2))"
		SetResolutionY="$(($ResolutionY/2))"
	fi

	SetGeometry="${SetResolutionX}x${SetResolutionY}"

	print_info 'Criando arquivo .desktop' 
	echo "[Desktop Entry]" > "${destinationFilesStorecli[file_desktop]}"
    {
        echo "Name=Storecli Gui"
        echo "Version=$__version__"
        echo "Icon=system-software-install"
        echo "Exec=xterm -title StorecliGui -geo $SetGeometry -e 'storecli; read -p PressioneEnter:'"
        echo "Terminal=false"
        echo "Categories=Acessory;"
        echo "Type=Application"
    } >> "${destinationFilesStorecli[file_desktop]}"

	cp -u "${destinationFilesStorecli[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesStorecli[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesStorecli[file_desktop]}" ~/Desktop/ 2> /dev/null 
	printf "OK\n"
}

etcher_debian_file()
{
	# https://github.com/balena-io/etcher/releases
	# Instalar o etcher em sistemas Debian apartir do pacote .deb.
	local url_etcher_debian_file='https://github.com/balena-io/etcher/releases/download/v1.5.100/balena-etcher-electron_1.5.100_amd64.deb'
	local path_etcher_debian_file="$DirDownloads/$(basename $url_etcher_debian_file)"

	__sudo__ apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 379CE192D401AB61 || return 1 
	download "$url_etcher_debian_file" "$path_etcher_debian_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download.' && return 0
	
	_APT update || return 1
	system_pkgmanager "$path_etcher_debian_file" || _BROKE
	add_repo_apt "deb https://deb.etcher.io stable etcher" '/etc/apt/sources.list.d/balena-etcher.list'
	return 0
}

etcher_debian_online_repo()
{
	# https://github.com/balena-io/etcher#debian-and-ubuntu-based-package-repository-gnulinux-x86x64
	# https://github.com/balena-io/etcher/releases
	__sudo__ apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 379CE192D401AB61 || return 1 
	add_repo_apt "deb https://deb.etcher.io stable etcher" '/etc/apt/sources.list.d/balena-etcher.list'
	_APT update || return 1
	system_pkgmanager balena-etcher-electron || return 1
	return 0	
}


etcher_fedora_online_repo()
{
	# https://github.com/balena-io/etcher
	# yellow "Executando ... curl -sSL https://balena.io/etcher/static/etcher-rpm.repo -o /etc/yum.repos.d/etcher-rpm.repo"
	__sudo__ curl -sSL https://balena.io/etcher/static/etcher-rpm.repo -o /etc/yum.repos.d/etcher-rpm.repo
	system_pkgmanager 'balena-etcher-electron'
}

_etcher_appimage()
{
	# https://github.com/balena-io/etcher/releases/download/v1.5.81/balenaEtcher-1.5.81-x64.AppImage
	local url_etcher_appimage='https://github.com/balena-io/etcher/releases/download/v1.5.99/balenaEtcher-1.5.99-x64.AppImage'
	local path_etcher_appimage="$DirDownloads/$(basename $url_etcher_appimage)"

	if [[ $(id -u) == 0 ]]; then
		print_erro "Você não pode ser o root para instalar este pacote."
		return 1
	fi

	download "$url_etcher_appimage" "$path_etcher_appimage" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 
	
	cp "$path_etcher_appimage" "${destinationFilesEtcher[file_appimage]}"
	chmod +x "${destinationFilesEtcher[file_appimage]}"
	
	print_info 'Criando arquivo .desktop'
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

	cp -u "${destinationFilesEtcher[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesEtcher[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesEtcher[file_desktop]}" ~/Desktop/ 2> /dev/null 

	is_executable 'gtk-update-icon-cache' && gtk-update-icon-cache
}

_etcher_archlinux()
{
	# https://aur.archlinux.org/packages/balena-etcher/
	url_pkgbuild='https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=balena-etcher'
	url_snapshot='https://aur.archlinux.org/cgit/aur.git/snapshot/balena-etcher.tar.gz'
	path_file="$DirDownloads/etcher_archlinux.tar.gz"
	
	download "$url_snapshot" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 
	unpack_archive "$path_file" $DirUnpack || return 1
	
	cd "$DirUnpack"
	mv $(ls -d balena-*) "$DirTemp/etcher"
	cd "$DirTemp/etcher"
	yellow "Executando: makepkg -s"
	makepkg -s
	
	green "Executando sudo pacman -U $(ls etcher*.tar.*)"
	_PACMAN -U $(ls etcher*.tar.*)
}

_etcher()
{
	# Já instalado.
	is_executable 'balena-etcher-electron' && print_info 'Pacote instalado' 'Etcher' && return 0

	case "$BASE_DISTRO" in
		debian) etcher_debian_file;; # Debian/Ubuntu/Mint e derivados.
		fedora) etcher_fedora_online_repo;;
		arch) _etcher_appimage;;
		*) _etcher_appimage;;
	esac

	if is_executable 'balena-etcher-electron'; then
		print_info 'OK'
		return 0
	else
		print_erro '(_etcher)'
		return 1
	fi
}


_gnome_disk()
{
	system_pkgmanager 'gnome-disk-utility'
}

_plank()
{
	if [[ "$OS_ID" == 'fedora' ]]; then 
		# https://diolinux.com.br/2020/02/como-utilizar-plank-com-zoom-nos-icones-no-fedora.html
		print_info "Plank será instalado apartir de um repositório ${CSYellow}externo${CReset} ... copr:copr.fedorainfracloud.org:gqman69:plank"
		print_info "Versões de outros repositórios serão removidas"
		question "Deseja prosseguir com a instalação" || return 1
		_DNF copr enable 'gqman69/plank'
		is_executable plank && {
			yellow "Desinstalando versão anterior"
			_DNF remove plank
		}
		system_pkgmanager 'plank-0.11.4-99.fc31.x86_64' || return 1
	else
		system_pkgmanager plank
	fi
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
	# https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2
	# https://launchpad.net/veracrypt/trunk/1.24-update4/&#43;download/veracrypt-1.24-Update4-setup.tar.bz2
	#
	# libgtk-x11-2.0.so.0 (ArchLinux)

	# Necessário sessão gráfica para instalar esse programa.
	if [[ -z "$DISPLAY" ]]; then
		red "Necessário sessão gráfica (Xorg) para instalar veracrypt"
		return 1
	fi

	if ! is_executable xterm; then
		system_pkgmanager xterm
	fi

	# Já instalado?.
	is_executable 'veracrypt' && print_info 'Pacote instalado' 'veracrypt' && return 0
	
	local VERACRYPT_DOWN_PAGE='https://www.veracrypt.fr/en/Downloads.html'
	veracrypt_html_page=$(get_html_page "$VERACRYPT_DOWN_PAGE" --find 'download.*.tar')
	url_package_tar=$(echo -e "$veracrypt_html_page" | sed 's/.*="//g;s/".*//g;s/&#43;/+/g')
	url_signature_file="${url_package_tar}.sig"	
	VeracryptTarFile="$DirDownloads/$(basename $url_package_tar)"
	VeracryptSigFile="${VeracryptTarFile}.sig"

	download "$url_package_tar" "$VeracryptTarFile" || return 1
	download "$url_signature_file" "$VeracryptSigFile" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	  
	gpg_import 'https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc' || return 1
	gpg_verify "$VeracryptSigFile" "$VeracryptTarFile" || return 1
	unpack_archive "$VeracryptTarFile" $DirUnpack || return 1
	cd $DirUnpack
	cp $(ls veracrypt*setup-gui-x64) "$DirTemp"/veracrypt-setupx64
	chmod +x "$DirTemp"/veracrypt-setupx64
	xterm -title 'Instalando veracrypt' "$DirTemp"/veracrypt-setupx64

	case "$OS_ID" in
		arch) system_pkgmanager gtk2;;
	esac

	if is_executable 'veracrypt'; then
		print_info 'Pacote instalado com sucesso' 'veracrypt'
		return 0
	else
		print_erro 'falha na instalação' 'veracrypt'
		return 1
	fi
}

_microsoft_teams()
{
	if [[ "$BASE_DISTRO" == 'debian' ]]; then
		local URL_MICROSOFT_TEAMS='https://go.microsoft.com/fwlink/p/?LinkID=2112886&clcid=0x416&culture=pt-br&country=BR'
		local PATH_MICROSOFT_TEAMS="$DirDownloads/teams-amd64.deb"
	elif [[ "$BASE_DISTRO" == 'fedora' ]]; then
		local URL_MICROSOFT_TEAMS='https://go.microsoft.com/fwlink/p/?LinkID=2112907&clcid=0x416&culture=pt-br&country=BR'
		local PATH_MICROSOFT_TEAMS="$DirDownloads/teams-x86_64.rpm"
	else
		red "Programa indisponível para o seu sistema."
		return 1
	fi

	download "$URL_MICROSOFT_TEAMS" "$PATH_MICROSOFT_TEAMS" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	system_pkgmanager "$PATH_MICROSOFT_TEAMS"
}

_woeusb_cli_linux()
{
	local URL_SCRIPT_WOEUSB='https://github.com/WoeUSB/WoeUSB/raw/master/sbin/woeusb'
	local WOEUSB_TEMP_FILE=$(mktemp -u)

	download "$URL_SCRIPT_WOEUSB" "$WOEUSB_TEMP_FILE" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	__sudo__ mv "$WOEUSB_TEMP_FILE" '/usr/local/bin/woeusb'
	__sudo__ chmod +x '/usr/local/bin/woeusb'
}

_woeusb_ng_github()
{
	# Instalar WoeUSB-ng apartir do código fonte no github.
	# https://github.com/WoeUSB/WoeUSB-ng
	local REPO_WOEUSB_NG='https://github.com/WoeUSB/WoeUSB-ng.git'
	
	gitclone "$REPO_WOEUSB_NG" $DirGitclone || return 1
	printf "Entrando no diretório ... $DirGitclone/WoeUSB-ng\n"
	cd "$DirGitclone/WoeUSB-ng" || return 1
	__sudo__ pip3 install wheel
	__sudo__ pip3 install . || return 1
}

_woeusb_ng()
{
	# https://github.com/WoeUSB/WoeUSB-ng
	requeriments_woeusb_ng_debian=(git p7zip-full python3-pip python3-wxgtk4.0)
	requeriments_woeusb_ng_fedora=(git p7zip python3-pip python3-wxpython4)
	if [[ -f /etc/debian_version ]]; then
		system_pkgmanager "${requeriments_woeusb_ng_debian[@]}"
		_woeusb_ng_github
	elif [[ -f /etc/fedora-release ]]; then
		system_pkgmanager "${requeriments_woeusb_ng_fedora[@]}"
		_woeusb_ng_github
	elif [[ "$OS_ID" == 'arch' ]]; then
		_woeusb_ng_github
	fi

}

_woeusb()
{
	_woeusb_cli_linux
	_woeusb_ng

	if is_executable 'woeusb'; then
		print_info 'Pacote instalado com sucesso' 'woeusb'
		return 0
	else
		print_erro 'falha na instalação' 'woeusb'
		return 1
	fi
}

_android_studio_zip()
{
	# https://developer.android.com/studio
	local url_studio_ide='https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.1.0/android-studio-ide-192.6241897-linux.tar.gz'
	local hash_android_studio='e754dc9db31a5c222f230683e3898dcab122dfe7bdb1c4174474112150989fd7'
	local path_studio_zip_file="$DirDownloads/$(basename $url_studio_ide)"

	download "$url_studio_ide" "$path_studio_zip_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	
	__shasum__ "$path_studio_zip_file" "$hash_android_studio" || return 1
	unpack_archive "$path_studio_zip_file" $DirUnpack || return 1

	echo "Instalando android studio em ~/.local/bin"
	cd "$DirUnpack" 
	mv $(ls -d android-*) "${destinationFilesAndroidStudio[dir]}" 1> /dev/null # ~/.local/bin/android-studio
	cp -u "${destinationFilesAndroidStudio[dir]}"/bin/studio.png "${destinationFilesAndroidStudio[png]}" # .png
	chmod -R +x "${destinationFilesAndroidStudio[dir]}" # ~/.local/bin/androi-studio

	# arquivo de configuração ".desktop"
	print_info 'Criando arquivo .desktop'
	echo '[Desktop Entry]' > "${destinationFilesAndroidStudio[file_desktop]}"
	{
		echo "Version=1.0"
		echo "Type=Application"
		echo "Name=Android Studio"
		echo "Icon=studio.png"
		echo "Exec=bash -c 'cd ${destinationFilesAndroidStudio[dir]}/bin && ./studio.sh'"
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

_install_requeriments_android_studio()
{
	if [[ "$BASE_DISTRO" == 'debian' ]]; then
		case "$VERSION_CODENAME" in
			bionic|tricia)
					local requeriments_android_studio=(
						qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils lib32z1 
						lib32ncurses5 lib32stdc++6 lib32gcc1 lib32tinfo5 libc6-i386
						)
					;;
			focal|ulyssa) 
					local requeriments_android_studio=(
						qemu-kvm bridge-utils lib32z1 
						lib32ncurses5-dev lib32stdc++6 lib32gcc1 libc6-i386
						)
					;;
			buster) 
					
					local requeriments_android_studio=(
						qemu-kvm libvirt-clients libvirt-daemon-system lib32z1 
						lib32stdc++6 lib32gcc1 lib32ncurses6 lib32tinfo6 libc6-i386
						)
					;;
			*)
				print_erro "(_android_studio_ubuntu) seu sistema não é suportado para executar está ação."
				return 1
				;;	
			esac
		_APT update
	elif [[ "$BASE_DISTRO" == 'fedora' ]]; then
		case "$VERSION_ID" in
			32)
				local requeriments_android_studio=(
					zlib.i686 ncurses-libs.i686 bzip2-libs.i686
					)
			;;
		esac
	fi

	system_pkgmanager "${requeriments_android_studio[@]}"

	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	msg "Adicionando $USER aos grupos: | libvirt | libvirt-qemu |" 
	__sudo__ adduser "$USER" libvirt
	__sudo__ adduser "$USER" 'libvirt-qemu'
}

_android_studio_debian()
{
	# Encerrar a função se os sistema não for baseado em debian.
	if [[ "$BASE_DISTRO" != 'debian' ]]; then
		red "Seu sistema não é baseado em Debian."
		return 1
	fi

	[[ "$VERSION_CODENAME" == 'buster' ]] || {
		print_erro "Seu sistema não é Debian Buster"
		return 1
	}


	_APT update
	system_pkgmanager 'openjdk-11-jdk'
	system_pkgmanager "${debianBusterRequeriments[@]}"
	
	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu" 
	__sudo__ adduser "$USER" libvirt
	__sudo__ adduser "$USER" 'libvirt-qemu'

	_android_studio_zip || return 1
}

_android_studio_ubuntu()
{
	_install_requeriments_android_studio 
	system_pkgmanager 'openjdk-8-jdk'
	system_pkgmanager "${ubuntuBionicRequeriments[@]}"
	_android_studio_zip || return 1
}

_android_archlinux()
{
	_android_studio_zip
}

_android_studio_fedora()
{
	_install_requeriments_android_studio	
	_android_studio_zip || return 1
}


_android_studio_opensuseleap()
{
	system_pkgmanager 'java-1_8_0-openjdk-devel' 'qemu-kvm'

	local requerimentsOpenSuse=(
			'libstdc++6-32bit' 
			'zlib-devel-32bit' 
			'libncurses5-32bit' 
			'libbz2-1-32bit'
		)
	system_pkgmanager "${requerimentsOpenSuse[@]}"
	_android_studio_zip
}

_android_studio()
{
	# https://www.blogopcaolinux.com.br/2017/09/Instalando-Android-Studio-no-Debian-e-no-Ubuntu.html
	# https://www.blogopcaolinux.com.br/2017/05/Instalando-Android-Studio-no-openSUSE-e-Fedora.html
	# https://developer.android.com/studio/index.html#downloads

	# Já instalado.
	is_executable 'studio' && print_info 'Pacote instalado' 'android-studio' && return 0

	case "$OS_ID" in
		debian) _android_studio_debian;;
		linuxmint|ubuntu) _android_studio_ubuntu;;
		'opensuse-leap') _android_studio_opensuseleap;;
		fedora) _android_studio_fedora;;
		arch) _android_archlinux;;
		*) print_erro 'Programa indisponível para o seu sistema' 'android-studio'; return 1;;
	esac

	if is_executable 'studio'; then
		print_info 'Pacote instalado com sucesso' 'android-studio'
		return 0
	else
		print_erro 'falha na instalação' 'android-studio'
		return 1
	fi
}

_br_modelo()
{
	local URL_PNG_BRMODELO='https://github.com/chcandido/brModelo/raw/master/src/imagens/logico.png'
	local PAGE_BRMODELO='http://www.sis4.com/brModelo/download.html'
	local PATH_PNG_BRMODELO="$DirDownloads/brmodelo.png"
	local URL_BRMODELO='http://www.sis4.com/brModelo/brModelo.jar'
	local PATH_BRMODELO="$DirDownloads/brModelo.jar"

	download "$URL_BRMODELO" "$PATH_BRMODELO" || return 1
	download "$URL_PNG_BRMODELO" "$PATH_PNG_BRMODELO" || return 1
	is_executable java || _install_java_development_kit_tar

	cp -u "$PATH_BRMODELO" "${destinationFilesBrModelo[file_jar]}"
	cp -u "$PATH_PNG_BRMODELO" "${destinationFilesBrModelo[png]}"

	echo -e "#/bin/sh" > "${destinationFilesBrModelo[script]}"
	echo -e "\njava -jar ${destinationFilesBrModelo[file_jar]}" >> "${destinationFilesBrModelo[script]}"

	print_info "Criando arquivo .desktop"
	echo '[Desktop Entry]' > "${destinationFilesBrModelo[file_desktop]}"
	{
		echo "Version=1.0"
		echo "Name=brModelo"
		echo "Exec=java -jar ${destinationFilesBrModelo[file_jar]}"
		echo "Icon=${destinationFilesBrModelo[png]}"
		echo "Type=Application"
		echo "Comment=The software for MER"
		echo "Path=$DIR_OPTIONAL"
		echo "Terminal=false"
		echo "StartupNotify=true"
		echo "Categories=Development;Education;"
	} >> "${destinationFilesBrModelo[file_desktop]}"

	chmod +x  "${destinationFilesBrModelo[script]}"
	chmod +x  "${destinationFilesBrModelo[file_desktop]}"

}

_codeblocks_fedora()
{
	# https://sempreupdate.com.br/como-instalar-o-codeblocks-no-fedora/
	
	system_pkgmanager codeblocks || return 1
	system_pkgmanager make automake gcc 'gcc-c++' 'kernel-devel' || return 1
	# sudo dnf groupinstall "Development Tools" "Development Libraries" 
}

_codeblocks_archlinux()
{
	# https://www.archlinux.org/packages/community/x86_64/codeblocks/
	system_pkgmanager codeblocks
}


_codeblocks()
{
	case "$OS_ID" in
		debian|ubuntu) system_pkgmanager codeblocks 'codeblocks-common' 'codeblocks-contrib' || return 1;;
		fedora) _codeblocks_fedora;;
		archlinux) _codeblocks_archlinux;;
		*) print_erro 'Programa indisponível para o seu sistema' 'codeblocks'; return 1;;
	esac
}

_eclipse()
{
	local URL_ECLIPSE='https://eclipse.c3sl.ufpr.br/oomph/epp/2020-12/R/eclipse-inst-jre-linux64.tar.gz'
	local URL_SHA512_ECLIPS='https://www.eclipse.org/downloads/download.php?file=/oomph/epp/2020-12/R/eclipse-inst-jre-linux64.tar.gz#btn-ajax-checksum-sha512'
	local PATH_ECLIPSE_TAR="$DirDownloads/eclipse-inst-jre-linux64.tar.gz"
	local PATH_SHA512_ECLIPSE="$DirDownloads/eclipse-inst-jre-linux64.tar.gz.sha512"


	download "$URL_ECLIPSE" "$PATH_ECLIPSE_TAR" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download.' && return 0
	unpack_archive "$PATH_ECLIPSE_TAR" $DirUnpack || return 1
	cd $DirUnpack
	mv $(ls -d eclipse-*) eclipse
	cd eclipse
	chmod +x eclipse-inst
	./eclipse
}

_intellij()
{
	is_executable 'idea' && print_info 'Pacote instalado' 'ideaIC' && return 0
	# local intellij='https://download-cf.jetbrains.com/idea/ideaIC-2020.2.1.tar.gz'
	# local idea_sha256='a107f09ae789acc1324fdf8d22322ea4e4654656c742e4dee8a184e265f1b014'
	local intellij_url='https://download.jetbrains.com/idea/ideaIC-2020.3.3.tar.gz'
	local idea_sha256='60cabbab7e7f427c2b91e29f5c135ab99a043cc8e3dca835f1aa298031a24ed7'
	local path_file="$DirDownloads/$(basename $intellij_url)"

	download "$intellij_url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	__shasum__ "$path_file" "$idea_sha256" || return 1
	unpack_archive "$path_file" $DirUnpack || return 1
	
	cd "$DirUnpack" 
	mv $(ls -d idea-*) idea-IC
	echo -ne "Movendo ... ${destinationFilesIntellij[dir]} "
	mv idea-IC "${destinationFilesIntellij[dir]}" || return 1
	printf 'OK\n'
	echo -e "Entrando no diretório ... ${destinationFilesIntellij[dir]}/bin"
	cd "${destinationFilesIntellij[dir]}/bin"
	cp -vu idea.png "${destinationFilesIntellij[png]}" 1> /dev/null

	print_info "Criando arquivo '.desktop'"
	echo "[Desktop Entry]" > "${destinationFilesIntellij[file_desktop]}"
	{
		echo -e "Name=IntelliJ IDEA Ultimate Edition"
		echo -e "Version=1.0"
		echo -e "Comment=java"
		echo -e "Icon=${destinationFilesIntellij[png]}"
		echo -e "Exec=${destinationFilesIntellij[dir]}/bin/idea.sh %f"
		echo -e "Terminal=false"
		echo -e "Categories=Development;IDE"
		echo -e "Type=Application"
	} >> "${destinationFilesIntellij[file_desktop]}"

	chmod +x "${destinationFilesIntellij[file_desktop]}"
	is_executable gtk-update-icon-cache && gtk-update-icon-cache

	print_info "Criando atalho para execução"
	echo -e "#!/bin/sh" > "${destinationFilesIntellij[script]}"
	echo -e "cd ${destinationFilesIntellij[dir]}/bin" >> "${destinationFilesIntellij[script]}"
	echo -e "./idea.sh \$@" >> "${destinationFilesIntellij[script]}"
	chmod +x "${destinationFilesIntellij[script]}"

	cp -u "${destinationFilesIntellij[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesIntellij[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesIntellij[file_desktop]}" ~/Desktop/ 2> /dev/null 

	if is_executable idea; then
		print_info 'Pacote instalado com sucesso' 'ideaic'
		return 0
	else
		print_erro 'falha na instalação' 'ideaic'
		return 1
	fi
}

_install_java_development_kit_tar()
{
	# https://jdk.java.net/java-se-ri/15
	# https://openjdk.java.net/install/
	#
	local URL_JDK='https://download.java.net/openjdk/jdk15/ri/openjdk-15+36_linux-x64_bin.tar.gz'
	local URL_SHA256_JDK='https://download.java.net/openjdk/jdk15/ri/openjdk-15+36_linux-x64_bin.tar.gz.sha256'
	local PATH_JDK_TAR_FILE="$DirDownloads/$(basename $URL_JDK)"
	local sha256_jdk=$(http_request "$URL_SHA256_JDK")

	declare -A destinationFilesJDK
	destinationFilesJDK=(
		[dir]="$DIR_OPTIONAL/jdk"
		)

	mkdir -p "${destinationFilesJDK[@]}"

	download "$URL_JDK" "$PATH_JDK_TAR_FILE" || return 1
	[[ $DownloadOnly == 'True' ]] && print_info 'Feito somente download.' && return 0

	__shasum__ "$PATH_JDK_TAR_FILE" "$sha256_jdk" || return 1
	unpack_archive "$PATH_JDK_TAR_FILE" "$DirUnpack" || return 1
	cd $DirUnpack
	mv $(ls -d jdk-*) jdk
	cd jdk
	echo -e "Instalando JDK em ... ${destinationFilesJDK[dir]}"
	cp -R -u * "${destinationFilesJDK[dir]}"/

	echo "configurando JAVA_HOME"
	export JAVA_HOME="${destinationFilesJDK[dir]}"
	sed -i '/^export JAVA_HOME/d' ~/.bashrc
	sed -i '/^export PATH=\$JAVA_HOME\/bin.*/d' ~/.bashrc
	echo -e "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
	
	echo "$PATH" | grep -q "$JAVA_HOME/bin"
	if [[ $? != 0 ]]; then
		grep -q "PATH=\$JAVA_HOME/bin.*" ~/.bashrc || {
			echo -e "export PATH=\$JAVA_HOME/bin:$PATH" >> ~/.bashrc
		}
	fi

}

_install_openjdk_user_root()
{
	# https://www.blogopcaolinux.com.br/2017/06/Como-instalar-o-Oracle-Java-JDK-no-Debian.html
	# https://www.oracle.com/webfolder/s/digest/15-0-2-checksum.html
	local URL_OPENJDK='https://download.java.net/openjdk/jdk15/ri/openjdk-15+36_linux-x64_bin.tar.gz'
	local URL_SHA256_JDK='https://download.java.net/openjdk/jdk15/ri/openjdk-15+36_linux-x64_bin.tar.gz.sha256'
	local PATH_FILE_OPENJDK="$DirDownloads/$(basename $URL_OPENJDK)"
	local PATH_FILE_SHASUM="$DirDownloads/$(basename $URL_SHA256_JDK)"
	local DESTINATION_JAVA='/usr/lib/jvm/jdk-15'
	local __file_bashrc='/etc/bash.bashrc'
	local backup_file_bashrc="${__file_bashrc}.bak"

	if [[ -d $DESTINATION_JAVA ]]; then
		print_info "Java já está instalado em ... $DESTINATION_JAVA"
		return 0
	fi

	[[ -f "$backup_file_bashrc" ]] || __sudo__ cp "$__file_bashrc" "$backup_file_bashrc"
	[[ -d /usr/lib/jvm ]] || __sudo__ mkdir -p /usr/lib/jvm

	download "$URL_OPENJDK" "$PATH_FILE_OPENJDK" || return 1
	download "$URL_SHA256_JDK" "$PATH_FILE_SHASUM" || return 1
	local sha256_jdk=$(cut -d ' ' -f 1 $PATH_FILE_SHASUM)
	__shasum__ "$PATH_FILE_OPENJDK" $sha256_jdk || return 1
	
	unpack_archive "$PATH_FILE_OPENJDK" $DirUnpack || return 1
	cd $DirUnpack
	mv $(ls -d jdk-*) JDK
	is_admin || return 1
	__sudo__ chown -R root:root JDK
	__sudo__ cp -R -p JDK "$DESTINATION_JAVA" || return 1

	JAVA_HOME='/usr/lib/jvm/jdk-15'

	# Verificar se o arquivo bashrc contém a variável JAVA_HOME
	grep -q "export JAVA_HOME=" "$__file_bashrc"
	if [[ $? != 0 ]]; then
		print_info "Configurando JAVA_HOME"
		__sudo__ sed -i "/^export JAVA_HOME=/d" "$__file_bashrc"
		__sudo__ sed -i "/^export PATH=\$JAVA_HOME\/bin.*/d" "$__file_bashrc"
		echo -e "export JAVA_HOME=$JAVA_HOME" | sudo tee -a "$__file_bashrc"
	fi

	
	# Adicionar JAVA_HOME no PATH.
	echo "$PATH" | grep -q "$JAVA_HOME/bin"
	if [[ $? != 0 ]]; then
		grep -q "PATH=.*$JAVA_HOME/bin.*" "$__file_bashrc" || {
			print_info "Configurando PATH"
			echo -e "export PATH=\$JAVA_HOME/bin:\$PATH" | sudo tee -a "$__file_bashrc"
		}
	fi


	# Informar novo caminho dos pacotes java para o sistema.
	__sudo__ update-alternatives --install "/usr/bin/java" "java" "$DESTINATION_JAVA/bin/java" 1
	__sudo__ update-alternatives --install "/usr/bin/javac" "javac" "$DESTINATION_JAVA/bin/javac" 1
	__sudo__ update-alternatives --install "/usr/bin/jar" "jar" "$DESTINATION_JAVA/bin/jar" 1
	#__sudo__ update-alternatives --install "/usr/bin/javaws" "javaws" "$DESTINATION_JAVA/bin/javaws" 1

	# Definir comandos java padrão.
	__sudo__ update-alternatives --set java "$DESTINATION_JAVA"/bin/java
	__sudo__ update-alternatives --set javac "$DESTINATION_JAVA"/bin/javac
	__sudo__ update-alternatives --set jar "$DESTINATION_JAVA"/bin/jar
	#__sudo__ update-alternatives --set javaws "$DESTINATION_JAVA"/bin/javaws

	return 0
	print_info "Criando atalho para java-control"
	echo '[Desktop Entry]' | sudo tee /usr/share/applications/java-control.desktop
	{
		echo "Encoding=UTF-8"
		echo "Name=Java"
		echo "Comment=Java Control Panel"
		echo "Exec=$DESTINATION_JAVA/bin/jcontrol"
		echo "Icon=$DESTINATION_JAVA/jre/lib/desktop/icons/hicolor/48x48/apps/sun-jcontrol.png"
		echo "Terminal=false"
		echo "Type=Application"
		echo "Categories=Application;Settings;Java;X-Red-Hat-Base;X-Ximian-Settings;"
	} | sudo tee -a /usr/share/applications/java-control.desktop

	__sudo__ chmod a+x /usr/share/applications/java-control.desktop
	is_executable gtk-update-icon-cache && sudo gtk-update-icon-cache

}

_java()
{
	#_install_java_development_kit_tar
	_install_openjdk_user_root
}

_netbeans()
{
	# https://netbeans.apache.org/download/nb120/nb120.html
	# 

	local URL_NETBEANS_ZIPFILE='https://downloads.apache.org/netbeans/netbeans/12.0/netbeans-12.0-bin.zip'
	local URL_ASC_NETBEANS='https://downloads.apache.org/netbeans/netbeans/12.0/netbeans-12.0-bin.zip.asc'
	local PATH_NETBEANS="$DirDownloads/$(basename $URL_NETBEANS_ZIPFILE)"
	local PATH_NETBEANS_ASC="$DirDownloads/$(basename $URL_ASC_NETBEANS)"

	[[ -d "${destinationFilesNetbeans[dir]}" ]] && {
		print_info "Netbeans já instalado use a opção ${CGreen}remove${CReset} para desinstalar."
		return 0
	}


	gpg_import 'https://downloads.apache.org/netbeans/KEYS' || return 1
	download "$URL_ASC_NETBEANS" "$PATH_NETBEANS_ASC" || return 1
	download "$URL_NETBEANS_ZIPFILE" "$PATH_NETBEANS" || return 1
	gpg_verify "$PATH_NETBEANS_ASC" "$PATH_NETBEANS" || return 1
	[[ $DownloadOnly == 'True' ]] && print_info "Feito somente download." && return 0
	
	unpack_archive $PATH_NETBEANS $DirUnpack || return 1
	cd $DirUnpack
	cp -u ./netbeans/nb/netbeans.png "${destinationFilesNetbeans[png]}" || return 1
	echo "Movendo arquivos"
	mv netbeans "${destinationFilesNetbeans[dir]}"
	chmod +x "${destinationFilesNetbeans[dir]}"/bin/netbeans
	ln -sf "${destinationFilesNetbeans[dir]}"/bin/netbeans "${destinationFilesNetbeans[link]}"

	print_info "Criando arquivo ${destinationFilesNetbeans[file_desktop]}"
	echo '[Desktop Entry]' > "${destinationFilesNetbeans[file_desktop]}"
	{
		echo "Encoding=UTF-8"
		echo "Name=Apache NetBeans IDE"
		echo "Comment=The Smarter Way to Code"
		echo "Exec=/bin/sh ${destinationFilesNetbeans[dir]}/bin/netbeans"
		echo "Icon=${destinationFilesNetbeans[png]}"
		echo "Categories=Application;Development;Java;IDE"
		echo "Version=1.0"
		echo "Type=Application"
		echo "Terminal=0"
	} >> "${destinationFilesNetbeans[file_desktop]}"

	chmod +x "${destinationFilesNetbeans[file_desktop]}"
	is_executable gtk-update-icon-cache && gtk-update-icon-cache
	if is_executable netbeans; then
		print_info "Netbeans instalado com sucesso"
		return 0
	else
		print_erro "Falha na instalação de Netbeans"
		return 1
	fi

}

_nodejs_lts_tar()
{
	# https://nodejs.org/en/
	local URL_NODEJS_TARFILE='https://nodejs.org/dist/v14.15.3/node-v14.15.3-linux-x64.tar.xz'
	local PATH_NODEJS_TARFILE="$DirDownloads/$(basename $URL_NODEJS_TARFILE)"

	if [[ -d "${destinationFilesNodejs[dir]}" ]]; then
		red "Desinstale a versão anterior para prosseguir."
		return 1
	fi

	download "$URL_NODEJS_TARFILE" "$PATH_NODEJS_TARFILE" || return 1
	unpack_archive "$PATH_NODEJS_TARFILE" $DirUnpack || return 1
	cd $DirUnpack
	mv $(ls -d node-*) nodejs
	echo -e "Instalando em ... ${destinationFilesNodejs[dir]}"
	mv nodejs "${destinationFilesNodejs[dir]}"
	
	echo -e "Criando link para node em ... ${destinationFilesNodejs[script]}"
	
	echo '#!/bin/sh' > "${destinationFilesNodejs[script]}"
	echo -e "\ncd ${destinationFilesNodejs[dir]}/bin" >> "${destinationFilesNodejs[script]}"
	echo './node' >> "${destinationFilesNodejs[script]}"
	chmod +x "${destinationFilesNodejs[script]}"

	printf "Criando link para npm em ... ${destinationFilesNodejs[npm_link]}\n"
	ln -sf "${destinationFilesNodejs[dir]}"/lib/node_modules/npm/bin/npm-cli.js "${destinationFilesNodejs[npm_link]}"
	printf "Criando link para npx em ... ${destinationFilesNodejs[npx_link]}\n"
	ln -sf "${destinationFilesNodejs[dir]}"/lib/node_modules/npm/bin/npx-cli.js "${destinationFilesNodejs[npx_link]}"
}

_nodejs_lts_debian_online_repo()
{
	# https://github.com/nodesource/distributions/blob/master/README.md#debmanual
	# https://github.com/nodesource/distributions/blob/master/README.md
	# 
	# deb https://deb.nodesource.com/node_14.x buster main
	# curl -sSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | sudo apt-key add -
	# 
	# To install the Yarn package manager, run:
    # curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    # echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    # sudo apt-get update && sudo apt-get install yarn

	[[ ! -f /etc/debian_version ]] && return 1

	case "$VERSION_CODENAME" in
		buster) NODEJS_REPO='deb https://deb.nodesource.com/node_14.x buster main';;
		bionic) NODEJS_REPO='deb https://deb.nodesource.com/node_14.x bionic main';;
		*) red "Programa indisponível para o seu sistema."; return 1;;
	esac

	is_admin || return 1
	apt_key_add 'https://deb.nodesource.com/gpgkey/nodesource.gpg.key' || return 1
	add_repo_apt "$NODEJS_REPO" /etc/apt/sources.list.d/nodesource.list
	system_pkgmanager nodejs
}

_nodejs_lts()
{
	if [[ "$OS_ID" == 'debian' ]]; then
		_nodejs_lts_debian_online_repo
	else
		_nodejs_lts_tar
	fi
}

_pycharm()
{
	# Já instalado.
	is_executable 'pycharm' && print_info 'Pacote instalado' 'pycharm' && return 0
	#local url_pycharm='https://download-cf.jetbrains.com/python/pycharm-community-2020.2.tar.gz'
	#local sha256_pycharm='60b2eeea5237f536e5d46351fce604452ce6b16d037d2b7696ef37726e1ff78a'
	local url_pycharm='https://download.jetbrains.com/python/pycharm-community-2021.1.tar.gz'
	local sha256_pycharm='7060bfdc54397b6cc783ff0b1724b8027e2bc3ea9f7e68e43ca37ea10fa42fc6'
	local path_file="$DirDownloads/$(basename $url_pycharm)"
	
	download "$url_pycharm" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	__shasum__ "$path_file" "$sha256_pycharm" || return 1
	unpack_archive "$path_file" $DirUnpack || return 1

	cd "$DirUnpack"
	printf "${CGreen}C${CReset}opiando arquivos ... " 
	mv $(ls -d pycharm*) "${destinationFilesPycharm[dir]}" 1> /dev/null && printf "OK\n"
	cp -u "${destinationFilesPycharm[dir]}"/bin/pycharm.png "${destinationFilesPycharm[png]}"

	# Criar atalho para execução na linha de comando.
	echo "#!/usr/bin/env bash" > "${destinationFilesPycharm[link]}"
	echo -e "\ncd ${destinationFilesPycharm[dir]}/bin/ && ./pycharm.sh" >> "${destinationFilesPycharm[link]}"
	chmod +x "${destinationFilesPycharm[link]}"

	print_info 'Criando arquivo .desktop' 
	echo "[Desktop Entry]" > "${destinationFilesPycharm[file_desktop]}"
    {
        echo "Name=Pycharm Community"
        echo "Version=1.0"
        echo "Icon=${destinationFilesPycharm[png]}"
        echo "Exec=pycharm"
        echo "Terminal=false"
        echo "Categories=Development;IDE;"
        echo "Type=Application"
    } >> "${destinationFilesPycharm[file_desktop]}"

	cp -u "${destinationFilesPycharm[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/Desktop/ 2> /dev/null 

	if is_executable 'pycharm'; then
		print_info 'Pacote instalado com sucesso' 'pycharm'
		return 0
	else
		print_erro 'falha na instalação' 'pycharm'
		return 1
	fi
}

_sublime_text_tar_file()
{
	# Já instalado.
	is_executable 'sublime' && print_info 'Pacote instalado' 'sublime-text' && return 0

	local SUBLIME_DOWN_PAGE='https://www.sublimetext.com/3'
	local SUBLIME_HTML=$(get_html_page "$SUBLIME_DOWN_PAGE" --find sublime.*x64.tar.bz2)
	local URL_SUBLIME_TARFILE=$(echo $SUBLIME_HTML | sed 's/">64.*//g;s/.*href="//g')
	local PATH_SUBLIME="$DirDownloads/$(basename $URL_SUBLIME_TARFILE)"

	download "$URL_SUBLIME_TARFILE" "$PATH_SUBLIME" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 
	unpack_archive "$PATH_SUBLIME" $DirUnpack || return 1

	echo -e "Copiando arquivos"
	cp -u "$DirUnpack"/sublime_text_3/sublime_text.desktop "${destinationFilesSublime[file_desktop]}"  
	cp -u "$DirUnpack"/sublime_text_3/Icon/256x256/sublime-text.png "${destinationFilesSublime[png]}" 
	mv "$DirUnpack"/sublime_text_3 "${destinationFilesSublime[dir]}"
	ln -sf "${destinationFilesSublime[dir]}"/sublime_text "${destinationFilesSublime[link]}" 
	
	sed -i "s/Exec=.*/Exec=sublime/g" "${destinationFilesSublime[file_desktop]}"
	sed -i "s|Icon=.*|Icon=${destinationFilesSublime[png]}|g" "${destinationFilesSublime[file_desktop]}"

	gtk-update-icon-cache 1> /dev/null 2>&1
	cp -u "${destinationFilesSublime[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesSublime[file_desktop]}" ~/Desktop/ 2> /dev/null 
	cp -u "${destinationFilesSublime[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null

	if is_executable 'sublime'; then
		print_info 'Pacote instalado com sucesso' 'sublime'
		sublime &
		return 0
	else
		print_erro 'falha na instalação' 'sublime'
		return 1
	fi
}

_sublime_text_debian_file()
{
	# https://www.sublimetext.com/docs/3/linux_repositories.html#apt
	
	# Adicionar chave remota.
	apt_key_add 'https://download.sublimetext.com/sublimehq-pub.gpg' || return 1
	system_pkgmanager apt-transport-https
	add_repo_apt 'deb https://download.sublimetext.com/ apt/stable/' /etc/apt/sources.list.d/sublime-text.list
	system_pkgmanager sublime-text || return 1
	return 0
}

_sublime_text_rpm_fedora()
{
	_rpm_key_add 'https://download.sublimetext.com/sublimehq-rpm-pub.gpg' || return 1
	__sudo__ dnf config-manager --add-repo 'https://download.sublimetext.com/rpm/stable/x86_64/sublime-text.repo' 
	system_pkgmanager sublime-text || return 1
	return 0
}

_sublime_text()
{
	case "$BASE_DISTRO" in
		debian) _sublime_text_debian_file;;
		fedora) _sublime_text_rpm_fedora;;
		*) _sublime_text_tar_file;;
	esac
}


_vim()
{
	system_pkgmanager vim
}

_vscode_debian_file()
{
	local url_code_debian='https://update.code.visualstudio.com/latest/linux-deb-x64/stable'
	local path_code_debian_file="$DirDownloads/vscode-amd64.deb"
	download "$url_code_debian" "$path_code_debian_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	system_pkgmanager "$path_code_debian_file" -y || _BROKE
}

_vscode_tarfile()
{
	local url_vscode_tar='https://update.code.visualstudio.com/latest/linux-x64/stable'
	local path_tar_file="$DirDownloads/vscode.tar.gz"

	[[ $(id -u) == 0 ]] && {
		print_erro "Você não pode ser o 'root' para instalar este programa."
		return 1
	}

	download "$url_vscode_tar" "$path_tar_file"
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	unpack_archive "$path_tar_file" $DirUnpack || return 1

	cd "$DirUnpack"
	mv $(ls -d VSCode*) "${destinationFilesVscode[dir]}" 
	cp -u "${destinationFilesVscode[dir]}"/resources/app/resources/linux/code.png "${destinationFilesVscode[png]}"

	# Criar atalho para execução na linha de comando.
	echo "#!/bin/sh" > "${destinationFilesVscode[link]}"
	echo -e "\ncd ${destinationFilesVscode[dir]}/bin/ && ./code" >> "${destinationFilesVscode[link]}"
	chmod +x "${destinationFilesVscode[link]}"

	# Criar entrada no menu do sistema.
	print_info "Criando arquivo .desktop"
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

	cp -u "${destinationFilesVscode[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesVscode[file_desktop]}" ~/Desktop/ 2> /dev/null 
	cp -u "${destinationFilesVscode[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null	
}

_vscode()
{
	# Já instalado.
	is_executable 'code' && print_info 'Pacote instalado' 'code' && return 0

	case "$BASE_DISTRO" in
		debian) _vscode_debian_file;;
		*) _vscode_tarfile;;
	esac
	
	if is_executable 'code'; then
		print_info 'Pacote instalado com sucesso' 'code'
		return 0
	else
		print_erro 'falha na instalação' 'code'
		return 1
	fi
}

_codecs_tumbleweed()
{
	# https://software.opensuse.org/download/package?package=opensuse-codecs-installer&project=multimedia%3Aapps
	# https://forums.opensuse.org/showthread.php/523476-Multimedia-Guide-for-openSUSE-Tumbleweed
	
	# Adicionar repostórios
	"$SCRIPT_ADD_REPO" --repo tumbleweed

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
		yellow "Instalando [$c]"
		system_pkgmanager "$c"		
	done
}

_codecs_opensuse_leap()
{
	if [[ "$VERSION_ID" != '15.1' ]]; then
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
		system_pkgmanager "$i"
	done

}

_codecs_ubuntu()
{
	system_pkgmanager --install-recommends ffmpeg ffmpegthumbnailer
	system_pkgmanager 'ubuntu-restricted-extras'
}

_codecs_debian()
{
	#------------------| AlsaMixer |---------------------------#
	# visite o link abaixo se tiver problemas com a sua placa de audio.
	# https://vitux.com/how-to-control-audio-on-the-debian-command-line/
	# sudo apt install install alsa-utils
	#
	
	local url_deb_multimidia='http://www.deb-multimedia.org'
	local url_wcodecs="$url_deb_multimidia/pool/non-free/w/w64codecs/w64codecs_20071007-dmo2_amd64.deb"
	local hash_wcodecs="cc36b9ff0dce8d4f89031756163d54acdd4e800d6106f07db2031fdf77e90392"
	local path_wcodecs="$DirDownloads/$(basename $url_wcodecs)"

	system_pkgmanager --install-recommends ffmpeg ffmpegthumbnailer
	system_pkgmanager lame

	download "$url_wcodecs" "$path_wcodecs" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 
	__shasum__ "$path_wcodecs" "$hash_wcodecs" || return 1
	_APT install "$path_wcodecs" -y || _BROKE
}

_codecs_fedora()
{
	# Add repo fusion non free
	sudo "$SCRIPT_ADD_REPO" --repo fedora

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

	system_pkgmanager "${array_codecs_fedora[@]}"
	system_pkgmanager "${array_gstreamer_fedora[@]}"

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
		system_pkgmanager "$x"
	done

	
	for x in "${list_codecs_parole[@]}"; do 
		system_pkgmanager "$x"
	done
	
}

_codecs()
{
	case "$OS_ID" in
		freebsd12.0-release) system_pkgmanager ffmpeg ffmpegthumbnailer 'gstreamer-ffmpeg';;
		debian) _codecs_debian;;
		linuxmint|ubuntu) _codecs_ubuntu;;
		fedora) _codecs_fedora;;
		'opensuse-tumbleweed') _codecs_tumbleweed;;
		'opensuse-leap') _codecs_opensuse_leap;;
		arch) _codecs_arch;;
		*) print_erro 'Programa indisponível para o seu sistema' 'codecs'; return 1;;

	esac
}

_celluloid()
{
	system_pkgmanager 'celluloid'
}

_cinema()
{
	system_pkgmanager 'cinema'
}

_gnome_mpv()
{
	if is_executable 'dnf'; then
		system_pkgmanager 'gnome-mpv' 'smplayer-themes'
	elif [[ -f '/etc/debian_version' ]]; then
		system_pkgmanager 'gnome-mpv'
	else
		system_pkgmanager 'gnome-mpv' 
	fi
}

_parole()
{
	system_pkgmanager parole	
}

_smplayer()
{
	system_pkgmanager smplayer
}

_spotify_debian()
{
	# https://wiki.debian.org/spotify
	# https://www.spotify.com/br/download/linux/
	# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4773BD5E130D1D45 || return 1
	is_admin || return 1
	if ! apt_key_add 'https://download.spotify.com/debian/pubkey_0D811D58.gpg'; then
		print_info "Visite 'https://www.spotify.com/br/download/linux/' para instalar spotify manualmente."
		return 1
	fi

	SPOTIFY_REPO='deb http://repository.spotify.com stable non-free'
	add_repo_apt "$SPOTIFY_REPO" /etc/apt/sources.list.d/spotify.list 	
	system_pkgmanager 'spotify-client'
}

_spotify_archlinux()
{
	# https://www.vivaolinux.com.br/dica/Spotify-no-Arch-Linux
	local spotify_url='https://repository-origin.spotify.com/pool/non-free/s/spotify-client'
	local spotify_file_server=$(wget -qO- "$spotify_url" | grep -m 1 'spotify.*amd64.deb' | sed 's/">.*//g;s/.*="//g')
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
		system_pkgmanager "$X"
	done
		
	download "$Spotify_Url_Server" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0	
	unpack_archive "$path_file" $DirUnpack || return 1
	cd "$DirUnpack"
	echo -e "Descomprimindo arquivo data.tar.gz"
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

	is_executable flatpak || system_pkgmanager flatpak

	echo -ne "[>] Executando: remote-add --if-not-exists $FlatpakRepoSpotity "
	if flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo; then
		syellow "OK"
	else
		print_erro ""
	fi

	_FLATPAK install flathub com.spotify.Client || return 1
	return 0
}

_spotify()
{
	if [[ "$OS_ID" == 'debian' ]]; then
		_spotify_debian
	elif [[ "$OS_ID" == 'ubuntu' ]] || [[ "$OS_ID" == 'linuxmint' ]]; then
		_spotify_debian
	elif [[ "$OS_ID" == 'arch' ]]; then
		_spotify_archlinux
	elif [[ "$OS_ID" == 'fedora' ]]; then
		_spotify_fedora
	else
		print_erro 'Programa indisponível para o seu sistema' 'spotify'; return 1
	fi
	
}

_totem(){
	system_pkgmanager totem
}

_vlc_fedora()
{
	local repos_fusion_free='https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release'
	local repos_fusion_non_free='https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release'
	print_line
	yellow "Adicionando os seguintes repositórios: "
	echo -e "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm"
	echo -e "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm"
	echo -e "fedora-workstation-repositories"
	print_line

	_DNF install "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm"
	_DNF install "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm" 
	_DNF install fedora-workstation-repositories 

	system_pkgmanager vlc 'python-vlc' || return 1
}

_vlc()
{
	case "$OS_ID" in
		debian|ubuntu|linuxmint) system_pkgmanager vlc;;
		'opensuse-leap') system_pkgmanager vlc;;
		fedora) _vlc_fedora;;
		arch) system_pkgmanager vlc;;
	esac

	if is_executable 'vlc'; then
		print_info 'Pacote instalado com sucesso' 'vlc'
	else
		print_erro 'falha na instalação' 'vlc'
	fi
}

_atril()
{
	system_pkgmanager atril
}

_ubuntu_msttcorefonts()
{
	local url_msttcorefonts='http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb'
	local path_msttcorefons="$DirDownloads/$(basename $url_msttcorefonts)"

	download "$url_msttcorefonts" "$path_msttcorefons" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	 
	system_pkgmanager cabextract || return 1
	system_pkgmanager "$path_msttcorefons" || return 1
	return 0

}

_fontes_microsoft()
{
	case "$OS_ID" in
		linuxmint|ubuntu) _ubuntu_msttcorefonts;;
		debian) system_pkgmanager msttcorefonts 'ttf-mscorefonts-installer';;
		fedora) system_pkgmanager 'mscore-fonts';;
		'opensuse-tumbleweed'|'opensuse-leap') system_pkgmanager fetchmsttfonts;;
		*) print_erro 'Programa indisponível para o seu sistema' 'fontes-ms'; return 1;;
	esac
}

_libreoffice_appimage()
{
	# https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage
	# https://github.com/AppImage/AppImageKit/wiki/FUSE
	# https://wiki.archlinux.org/index.php/FUSE
	
	# Já instalado.
	is_executable 'libreoffice-appimage' && print_info 'Pacote instalado' 'libreoffice-appimage' && return 0
	local url='https://libreoffice.soluzioniopen.com/stable/full/LibreOffice-still.full-x86_64.AppImage'
	local path_file="$DirDownloads/$(basename $url)"
	local hash_libreoffice='4dc846ccf77114594b9f3fd1ffb398f784adfcce75371f22551612e83c3ef1e6'

	download "$url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	print_info "Criando arquivo .desktop"
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

	yellow "Criando atalho na Área de trabalho"
	ln -sf "${destinationFilesLibreofficeAppimage[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesLibreofficeAppimage[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	ln -sf "${destinationFilesLibreofficeAppimage[file_desktop]}" ~/Desktop/ 2> /dev/null

	if is_executable 'libreoffice-appimage'; then
		print_info 'Pacote instalado com sucesso' 'libreoffice-appimage'
		return 0
	else
		print_erro 'falha na instalação' 'libreoffice-appimage'
		return 1
	fi
}

_libreoffice_ptbr(){
	# Verificar qual o idioma do usuário atual
	local lang=$(printenv | grep -m 1 '^LANG=' | sed 's/.*=//g')
	
	# Se for "pt_BR.UTF-8" instalar suporte para português do Brasil.
	case "$lang" in
		pt_BR.UTF-8) ;;
		pt_BR.utf8) ;;
		*) return 0;;
	esac

	case "$OS_ID" in
		debian) system_pkgmanager 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		ubuntu|linuxmint) system_pkgmanager 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		fedora) system_pkgmanager 'libreoffice-langpack-pt-BR';;
		'open-suse') system_pkgmanager 'libreoffice-l10n-pt_BR';;
		arch) system_pkgmanager 'libreoffice-fresh-pt-br';;
		freebsd) system_pkgmanager 'pt_BR-libreoffice';;
	esac
}

_libreoffice()
{
	case "$OS_ID" in 
		debian|ubuntu|linuxmint) system_pkgmanager libreoffice;;
		fedora) system_pkgmanager libreoffice;;
		'open-suse') system_pkgmanager 'libreoffice-l10n-pt_BR';;
		arch) system_pkgmanager libreoffice;;
		freebsd) system_pkgmanager libreoffice;;
		*) _libreoffice_appimage; return;;
	esac

	_libreoffice_ptbr
}

#====================================================
# Navegadores
#====================================================

_chromium_lang()
{
	# Instalar pacote de idioma ptbr se o idioma do usuário for
	# 

	# Verificar se o idioma da sessão e pt_br.
	local lang=$(set | grep -m 1 '^LANG=' | sed 's/.*=//g')
	[[ "$lang" == 'pt_BR.UTF-8' ]] || return 0

	echo -e "Instalando pacote de idioma para chromium"
	case "$OS_ID" in
		debian) system_pkgmanager 'chromium-l10n';;
		ubuntu) system_pkgmanager 'chromium-browser-l10n';;
		*) return 0;;
	esac
}

_chromium()
{
	case "$OS_ID" in
		debian) system_pkgmanager chromium;;
		ubuntu|linuxmint) system_pkgmanager 'chromium-browser';;
		fedora) system_pkgmanager chromium;;
		arch) system_pkgmanager chromium;;
		'opensuse-tumbleweed'|'opensuse-leap') system_pkgmanager chromium;; 
		freebsd12) system_pkgmanager chromium;;
		*) print_erro 'Programa indisponível para o seu sistema' 'chromium'; return 1;;
	esac

	_chromium_lang # Instalar pacote de idioma ptbr.
}


_edge()
{
	# https://www.microsoftedgeinsider.com/pt-br/download/
	if [[ "$OS_ID" == 'fedora' ]]; then
		_RPM --import https://packages.microsoft.com/keys/microsoft.asc || return 1
		_DNF config-manager --add-repo https://packages.microsoft.com/yumrepos/edge || return 1
		__sudo__ mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge-dev.repo
		system_pkgmanager microsoft-edge-dev
	elif [[ -f /etc/debian_version ]]; then
		apt_key_add 'https://packages.microsoft.com/keys/microsoft.asc'
		add_repo_apt "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" /etc/apt/sources.list.d/microsoft-edge-dev.list
		_APT update || return 1
		system_pkgmanager microsoft-edge-dev
	else
		print_erro 'Programa indisponível para o seu sistema' 'edge' 
		return 1
	fi
	
}


_firefox_lang()
{
	# Verificar se o idioma da sessão e pt_br e em seguida instalar o
	# pacote de idiomas pt_br para firefox.
	local lang=$(set | grep -m 1 '^LANG=' | sed 's/.*=//g')
	case "$lang" in
		pt_BR.UTF-8) ;;
		pt_BR.utf-8) ;;
		*) return 0;;
	esac
	
	case "$OS_ID" in
		arch) system_pkgmanager 'firefox-i18n-pt-br';;
		debian) system_pkgmanager 'firefox-esr-l10n-pt-br';;
		ubuntu) system_pkgmanager 'firefox-locale-pt';;
	esac
}

_firefox()
{
	case "$OS_ID" in
		arch) system_pkgmanager firefox;;
		debian) system_pkgmanager 'firefox-esr';;
		ubuntu|linuxmint) system_pkgmanager firefox;;
		fedora) system_pkgmanager 'firefox.x86_64' 'mozilla-ublock-origin.noarch';;
		'opensuse-leap') system_pkgmanager MozillaFirefox;;
		*) print_erro 'Programa indisponível para o seu sistema' 'firefox'; return 1;;
	esac

	_firefox_lang
}

_google_chrome_debian()
{
	local google_chrome_repo='deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
	is_admin || return 1
	apt_key_add 'https://dl.google.com/linux/linux_signing_key.pub' || return 1
	add_repo_apt "$google_chrome_repo" /etc/apt/sources.list.d/google-chrome.list
	system_pkgmanager 'google-chrome-stable' # sudo apt install libu2f-udev
}


_google_chrome_fedora()
{
	# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
	# sudo dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	{
		_DNF install -y fedora-workstation-repositories
		_DNF config-manager --set-enabled google-chrome
		system_pkgmanager 'google-chrome-stable'
	} || _DNF install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
}

_google_chrome_opensuse()
{
	# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-openSUSE-Leap-15
	# wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	yellow "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	yellow "Adicionando repositório: http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	system_pkgmanager 'google-chrome-stable'
}

_google_chrome_tumbleweed()
{
	echo -e "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	echo -e "Adicionando repositório [http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google]"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	system_pkgmanager 'google-chrome-stable'
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

 	gitclone "$github_chrome" $DirGitclone || return 1
	cd "$DirGitclone"/google-chrome
	system_pkgmanager "base-devel" pipewire
	 
	msg "Executando: makepkg -s"
	cd "$DirGitclone/google-chrome"
	makepkg -s

	msg "Executando sudo pacman -U $(ls google*.tar.*)"
	_PACMAN -U --noconfirm $(ls google*.tar.*)
}

_google_chrome()
{
	case "$OS_ID" in
		debian|ubuntu|linuxmint) _google_chrome_debian;;
		opensuse-tumbleweed|opensuse-leap) _google_chrome_opensuse;;
		fedora) _google_chrome_fedora;;
		arch) _google_chrome_archlinux;;
		*) print_erro 'Programa indisponível para o seu sistema' 'google-chrome'; return 1;;
	esac	

	if is_executable 'google-chrome'|| is_executable 'google-chrome-stable'; then
		print_info 'Pacote instalado com sucesso' 'google-chrome'
		return 0
	else
		print_erro 'falha na instalação' 'google-chrome'
		return 1
	fi
}

_opera_stable_debian()
{
	local opera_repo='deb [arch=amd64] https://deb.opera.com/opera-stable/ stable non-free'
	apt_key_add 'http://deb.opera.com/archive.key'
	add_repo_apt "$opera_repo" /etc/apt/sources.list.d/opera-stable.list 
	system_pkgmanager 'opera-stable' || return 1	
}

_opera_stable_fedora()
{
	# https://www.blogopcaolinux.com.br/2017/07/Instalando-o-Opera-no-openSUSE-e-no-Fedora.html
	# https://rpm.opera.com/manual.html

	echo -e "Importando key"
	sudo rpm --import https://rpm.opera.com/rpmrepo.key || return 1

	echo -e "Adicionando repositório"
	echo '[opera]' | sudo tee /etc/yum.repos.d/opera.repo
	{
		echo "name=Opera packages"
		echo "type=rpm-md"
		echo "baseurl=https://rpm.opera.com/rpm"
		echo "gpgcheck=1"	
		echo "gpgkey=https://rpm.opera.com/rpmrepo.key"
		echo "enabled=1"
	} | sudo tee -a /etc/yum.repos.d/opera.repo

	system_pkgmanager 'opera-stable'
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

	yellow "Syncronizando repositórios"
	sudo zypper ref
	system_pkgmanager 'opera-stable'  || return 1
}

_opera_stable()
{
case "$OS_ID" in
	debian|linuxmint|ubuntu) _opera_stable_debian;;
	fedora) _opera_stable_fedora;;
	'opensuse-tumbleweed'|'opensuse-leap') _opera_stable_suse;;
	*) print_erro 'Programa indisponível para o seu sistema' 'opera'; return 1;;
esac	

	if [[ $? == '0' ]]; then 
		print_info 'Pacote instalado com sucesso' 'opera'
	else
		print_erro 'falha na instalação' 'opera'
		return 1
	fi
}

_torbrowser()
{
	local url_script_torbrowser_installer='https://raw.github.com/Brunopvh/torbrowser/master/tor.sh'

	is_executable tor-installer || {
		download "$url_script_torbrowser_installer" "$SCRIPT_TORBROWSER_INSTALLER" || return 1
		chmod +x "$SCRIPT_TORBROWSER_INSTALLER"
	}

	if [[ "$DownloadOnly" == 'True' ]]; then
		"$SCRIPT_TORBROWSER_INSTALLER" --downloadonly --install
	else
		"$SCRIPT_TORBROWSER_INSTALLER" --install --yes
	fi
}

#====================================================
# Internet
#====================================================

_clipgrab_appimage()
{
	# Instalar o clipgrab na versão AppImage.
	if is_executable clipgrab; then
		print_info 'Pacote instalado' 'clipgrab'
		return 0
	fi

	local url_page_clipgrab='https://clipgrab.de/pt'
	local HTML_PAGE=$(get_html_page "$url_page_clipgrab" --find 'clipgrab.*x86_64.AppImage')
	local URL_DOWNLOAD_CLIPGRAB=$(echo $HTML_PAGE | sed 's/.*href="//g;s/">.*//g')
	local PATH_CLIPGRAB="$DirDownloads/$(basename $URL_DOWNLOAD_CLIPGRAB)"

	download "$URL_DOWNLOAD_CLIPGRAB" "$PATH_CLIPGRAB" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	cp -u "$PATH_CLIPGRAB" "$DIR_BIN"/clipgrab
	chmod +x "$DIR_BIN"/clipgrab
	clipgrab&

	if is_executable clipgrab; then
		print_info 'Pacote instalado com sucesso' 'clipgrab'
		return 0
	else
		print_erro 'falha na instalação' 'clipgrab'
		return 1
	fi
}

_electron_player()
{
	python3 -m appcli 2> /dev/null || install_appcli
	
	if [[ "$AssumeYes" == 'True' ]]; then
		python3 -m appcli --install electron-player --yes
	else
		python3 -m appcli --install electron-player
	fi	
}


_freetube_zipfile(){
	# https://github.com/FreeTubeApp/FreeTube/releases/download/v0.12.0-beta/freetube_0.12.0_amd64.AppImage
	local URL_FREETUBE_RELEASES='https://github.com/FreeTubeApp/FreeTube/releases/tag/v0.12.0-beta'
	local HTML_FREETUBE=$(get_html_page "$URL_FREETUBE_RELEASES" --find 'x64.zip' | sed 's/.*href="//g;s/".*//g')
	local URL_FREETUBE="https://github.com/$HTML_FREETUBE"
	local PATH_FREETUBE="$DirDownloads/$(basename $URL_FREETUBE)"

	download "$URL_FREETUBE" "$PATH_FREETUBE" || return 1

}

_freetube_appimage(){
	# https://github.com/FreeTubeApp/FreeTube/releases/tag/v0.12.0-beta
	# https://github.com/FreeTubeApp/FreeTube/releases/download/v0.12.0-beta/freetube_0.12.0_amd64.AppImage
	local URL_FREETUBE_RELEASES='https://github.com/FreeTubeApp/FreeTube/releases/tag/v0.12.0-beta'
	local HTML_FREETUBE=$(get_html_page "$URL_FREETUBE_RELEASES" --find 'AppImage' | sed 's/.*href="//g;s/".*//g')
	local URL_FREETUBE="https://github.com/$HTML_FREETUBE"
	local PATH_FREETUBE="$DirDownloads/$(basename $URL_FREETUBE)"

	download "$URL_FREETUBE" "$PATH_FREETUBE" || return 1
	cp -u "$PATH_FREETUBE" "${destinationFilesFreeTube[bin]}"
	chmod +x "${destinationFilesFreeTube[bin]}"
	is_executable "${destinationFilesFreeTube[bin]}" || return 1
}

_freetube()
{
	[[ $(id -u) == 0 ]] && return 1
	_freetube_appimage || return 1

	# Criar arquivo .desktop na HOME para o usuario atual.
	print_info "Criando arquivo .desktop"

	echo '[Desktop Entry]' > "${destinationFilesFreeTube[file_desktop]}"
	{
		echo "Encoding=UTF-8"
		echo "Name=FreeTube"
		echo "Exec=freetube"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} >> "${destinationFilesFreeTube[file_desktop]}"

	chmod u+x "${destinationFilesFreeTube[file_desktop]}"
	cp -u "${destinationFilesFreeTube[file_desktop]}" ~/Desktop/ 2> /dev/null
	cp -u "${destinationFilesFreeTube[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesFreeTube[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	is_executable gtk-update-icon-cache && gtk-update-icon-cache

}

_megasync_opensuse_tumbleweed()
{
	# https://www.blogopcaolinux.com.br/2017/02/Instalando-o-MEGA-Sync-no-openSUSE-e-Fedora.html
	echo -e "Adicionando key [https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key]"
	sudo rpm --import https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key || return 1
	
	echo -e "Adicionando repositório [https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA]"
	sudo zypper ar -f https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA || return 1
	sudo zypper ref

	echo -e "Instalando megasync"
	system_pkgmanager megasync || return 1	
}

_megasync_debian()
{
	if [[ "$VERSION_CODENAME" != 'buster' ]]; then
		red "A instalação de MegaSync não está disponível para o seu sistema"
		return 1
	fi

	local mega_repos="deb https://mega.nz/linux/MEGAsync/Debian_10.0/ ./"
	apt_key_add 'https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key'
	add_repo_apt "$mega_repos" /etc/apt/sources.list.d/megasync.list
	system_pkgmanager megasync || return 1
}

_megasync_ubuntu()
{
	# find /etc/apt -name *.list | xargs grep "^deb .*mega\.nz/linux.*Ubuntu_18\.04" 2> /dev/null
	# https://mega.nz/linux/MEGAsync/xUbuntu_19.10/
	# https://mega.nz/linux/MEGAsync/
	
	local url_ubuntu_main='http://archive.ubuntu.com/ubuntu/pool/main'
	local url_libraw16="$url_ubuntu_main/libr/libraw/libraw16_0.18.8-1ubuntu0.3_amd64.deb"
	path_libraw="$DirDownloads/$(basename $url_libraw16)" # Requerido para ubuntu 19.10

	case "$VERSION_CODENAME" in
		bionic|tricia) 
			mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./"
			mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_18.04/Release.key'
			;;
		eoan)
			mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./"
			mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_19.10/Release.key'
			download "$url_libraw16" "$path_libraw" || return 1 
			_APT install "$path_libraw" || _BROKE
			;;
		focal|ulyssa)
			mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_20.04/ ./"
			mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_20.04/Release.key'
			;;
		*)
			print_erro 'Programa indisponível para o seu sistema' 'megasync' 
			return 1
			;;
	esac

	apt_key_add "$mega_url_key" || return 1
	add_repo_apt "$mega_repos_ubuntu" /etc/apt/sources.list.d/megasync.list || return 1
	system_pkgmanager 'libc-ares2' libmediainfo0v5 
	system_pkgmanager megasync
}

_megasync_fedora()
{
	echo -e "Importando key ... https://mega.nz/linux/MEGAsync/Fedora_30/repodata/repomd.xml.key"
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

	system_pkgmanager megasync
}

_libpdfium_archlinux()
{
	local repos_libpdfium='https://aur.archlinux.org/libpdfium-nojs.git'
	gitclone "$repos_libpdfium" $DirGitclone || return 1
	echo -e "Entrando no diretório ... $DirGitclone/libpdfium-nojs"
	cd "$DirGitclone/libpdfium-nojs"
	msg "Executando ... makepkg -s"
	makepkg -s
	msg "Executando sudo pacman -U $(ls libpdfium-*x86_64.pkg.tar*)"
	_PACMAN -U --noconfirm $(ls libpdfium-*x86_64.pkg.tar*) 
}

_megasync_archlinux()
{
	# https://unix.stackexchange.com/questions/200311/how-to-install-megasync-client-in-arch-based-antergos-linux
	# https://oxylabs.directorioforuns.com/t6-como-instalar-o-megasync-no-arch-linux
	# https://github.com/meganz/MEGAsync/archive/master.tar.gz
	# git clone --recursive https://github.com/meganz/MEGAsync.git

	# Obter url de download dos pacotes.
	local URL_MEGA_ARCH_EXTRA='https://mega.nz/linux/MEGAsync/Arch_Extra/x86_64'
	HTML_MEGASYNC=$(get_html_page "$URL_MEGA_ARCH_EXTRA" --find 'megasync.*pkg.tar.zst')
	MEGASYNC_NAME_FILE=$(echo -e "$HTML_MEGASYNC" | sed 's/.*megasync/megasync/g' | awk '{print $1}' | sed 's/zst.*/zst/g')

	local URL_MEGA_KEY='https://mega.nz/linux/MEGAsync/Arch_Extra/x86_64/DEB_Arch_Extra.key'
	local URL_SERVER_MEGA_ARCHLINUX='https://mega.nz/linux/MEGAsync/Arch_Extra/x86_64'
	local URL_MEGA_TARFILE="$URL_SERVER_MEGA_ARCHLINUX/$MEGASYNC_NAME_FILE"
	local URL_MEGA_SIGNATURE_FILE="${URL_MEGA_TARFILE}.sig"
	local PATH_MEGA_TARFILE="$DirDownloads/$(basename $URL_MEGA_TARFILE)"
	local PATH_MEGA_SIGNATURE_FILE=$(mktemp)


	# Requerimentos para compilação no ArchLinux - libpdfium.
	local array_mega_requeriments_archlinux=(
		'crypto++' 'c-ares' 'lsb-release' 'qt5-tools' libuv libmediainfo swig doxygen 
		)

	for app in "${array_mega_requeriments_archlinux}"; do
		system_pkgmanager "$app"
	done
	_libpdfium_archlinux

	# Baixar o pacote de instalação e o arquivo .sig do repositório MEGA.
	gpg_import "$URL_MEGA_KEY" || return 1
	download "$URL_MEGA_TARFILE" "$PATH_MEGA_TARFILE" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	# Verificar integridade do pacote baixado.
	download "$URL_MEGA_SIGNATURE_FILE" "$PATH_MEGA_SIGNATURE_FILE" || return 1
	gpg_verify "$PATH_MEGA_SIGNATURE_FILE" "$PATH_MEGA_TARFILE" || return 1
	rm -rf "$PATH_MEGA_SIGNATURE_FILE" 2> /dev/null

	# Copiar o instalador para o diretório temporário e em seguida instalar o pacote.
	cp "$PATH_MEGA_TARFILE" "$DirTemp/megasync-x86_64.pkg.tar.xz.zst" || return 1
	echo -e "Entrando no diretório ... $DirTemp"
	cd "$DirTemp"
	_PACMAN -U megasync-x86_64.pkg.tar.xz.zst
	_PACMAN -Sy
}

_megasync()
{
	# Já instalado.
	is_executable 'megasync' && print_info 'Pacote instalado' 'megasync' && return 0

	case "$OS_ID" in
		'opensuse-tumbleweed') _megasync_opensuse_tumbleweed;;
		debian) _megasync_debian;;
		linuxmint|ubuntu) _megasync_ubuntu;;
		fedora) _megasync_fedora;;
		arch) _megasync_archlinux;;
		*) print_erro 'Programa indisponível para o seu sistema' 'megasync'; return 1;;
	esac

	if is_executable 'megasync'; then
		print_info 'Pacote instalado com sucesso' 'megasync'
		return 0
	else
		print_erro 'falha na instalação' 'megasync'
		return 1
	fi
}

_tor_debian()
{
	local URL_TOR_ASC='https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc'
	local TOR_FILE_SOURCE_LIST='/etc/apt/sources.list.d/torproject.list'

	if [[ "$VERSION_CODENAME" == 'bionic' ]] || [[ "$VERSION_CODENAME" == 'tricia' ]]; then  # Ubuntu bionic
		TOR_REPO_MAIN='deb https://deb.torproject.org/torproject.org bionic main'
	elif [[ "$VERSION_CODENAME" == 'buster' ]]; then                                  # Debian buster
		TOR_REPO_MAIN='deb https://deb.torproject.org/torproject.org buster main'
	else
		print_erro 'Programa indisponível para o seu sistema' 'tor'
		return 1
	fi

	# http_request é uma função da lib requests.sh ver o arquivo ~/.shmrc
	echo -ne "Importando key ... "
	http_request "$URL_TOR_ASC" | sudo gpg --import 1> /dev/null 2>&1
	if [[ $? == 0 ]]; then
		echo 'OK'
	else
		print_erro "http_request"
		return 1
	fi

	echo -ne "Executando ... gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - "
	if ! sudo bash -c 'gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -'; then
		print_erro ""
		return 1
	fi

	# Verificar se o repositório já exite no diretório ou subdiretório /etc/apt.
	# find /etc/apt -name *.list | xargs grep '^deb https.*deb.torproject.org/torproject.org buster main'
	add_repo_apt "$TOR_REPO_MAIN" '/etc/apt/sources.list.d/torproject.list'
	_APT update
	system_pkgmanager tor deb.torproject.org-keyring
	system_pkgmanager proxychains || return 1
}

_tor_fedora()
{
	case "$VERSION_ID" in
		32) system_pkgmanager tor;;
		*) print_erro 'Programa indisponível para o seu sistema' 'tor';;
	esac

	system_pkgmanager proxychains || return 1
}

_proxychains()
{
	case "$OS_ID" in
		debian|ubuntu|linuxmint) _tor_debian;;
		arch) system_pkgmanager 'proxychains-ng' 'tor';;
		fedora) _tor_fedora;;
		*) print_erro 'Programa indisponível para o seu sistema' 'proxychains tor';;
	esac
}

_qbittorrent()
{
	system_pkgmanager qbittorrent || return 1
}

_skype_debian()
{
	local skype_url='https://go.skype.com/skypeforlinux-64.deb'
	local path_file="$DirDownloads/$(basename $skype_url)"

	download "$skype_url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	_APT install "$path_file" || return 1
}

_skype()
{
	case "$OS_ID" in
		debian|ubuntu|linuxmint) _skype_debian;;
		*) print_erro 'Programa indisponível para o seu sistema' 'skype';;
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
	local tw_html=$(get_html_page "$tw_pag" --find "http.*download.*linux.*amd64")
	local url_tw_deb=$(echo "$tw_html" | grep -m 1 'amd64.deb' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$DirDownloads/teamviewer_amd64.deb"

	# Requeriments teamviewer Debian/Ubuntu/Mint
	requeriments_tw_debian=(
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
	
	download "$url_tw_deb" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0	

	for i in "${requeriments_tw_debian[@]}"; do
		system_pkgmanager "$i" 
	done
	system_pkgmanager "$path_file" || _BROKE # Remover pacotes quebrados.
	return 0
}

_install_teamviewer_fedora()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/' # Página de download.
	local tw_html=$(wget -q -O- "$tw_pag" | grep "download.*linux.*64")
	local url_rpm=$(echo "$tw_html" | grep -m 1 'x86_64.rpm' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$DirDownloads/teamviewer_x86_64.rpm"

	# Requeriments teamviewer Fedora
	local requeriments_tw_fedora=(
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
	
	download "$url_rpm" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 # Somente baixar
	system_pkgmanager 'qt5-qtquickcontrols'
	system_pkgmanager "$path_file" || return 1
}


_teamviewer_tar()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/'      # Página de download.
	local tw_html=$(wget -q -O- "$tw_pag" | grep "download.*linux.*64")
	local url_tar=$(echo "$tw_html" | grep -m 1 'amd64.tar' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$DirDownloads/teamviewer_amd64.tar.xz"
	
	download "$url_tar" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0	
	
	unpack_archive "$path_file" $DirUnpack || return 1
	cd "$DirUnpack" && cd teamviewer
	chmod -R +x *
	__sudo__ ./tv-setup install || return 1
}


_teamviewer()
{
	# https://www.blogopcaolinux.com.br/2018/04/Instalando-o-TeamViewer-no-Debian-Ubuntu-e-Linux-Mint.html
	is_executable 'teamviewer' && print_info 'Pacote instalado' 'teamviewer' && return 0

	case "$OS_ID" in
		debian|linuxmint|ubuntu) _install_teamviewer_debian;;
		fedora) _install_teamviewer_fedora;;
		*) _teamviewer_tar;;
	esac

	if is_executable 'teamviewer'; then
		print_info 'Pacote instalado com sucesso' 'teamviewer'
		return 0
	else
		print_erro 'falha na instalação' 'teamviewer'
		return 1
	fi
}

# Instalar telegram
_telegram()
{
	# https://desktop.telegram.org/
	# https://updates.tdesktop.com/tlinux/tsetup.1.8.15.tar.xz
	local url_telegram='https://telegram.org/dl/desktop/linux'
	local path_telegram="$DirDownloads/telegramsetup.tar.xz"

	# Já instalado.
	is_executable 'telegram' && print_info 'Pacote instalado' 'telegram' && return 0

	download "$url_telegram" "$path_telegram" || return 1
	# Instalar gconf2.
	case "$OS_ID" in
		'opensuse-tumbleweed'|'opensuse-leap') system_pkgmanager gconf2;;
		ubuntu|linuxmint|debian) system_pkgmanager gconf2;;
		fedora) system_pkgmanager GConf2;;
	esac
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0	
	
	unpack_archive "$path_telegram" $DirUnpack || return 1
	cd "$DirUnpack" 
	mv -v $(ls -d Telegra*) "${destinationFilesTelegram[dir]}" 1> /dev/null
	chmod -R 755 "${destinationFilesTelegram[dir]}"
	ln -sf "${destinationFilesTelegram[dir]}"/Telegram "${destinationFilesTelegram[link]}"
	telegram&

	if is_executable 'telegram'; then
		print_info 'Pacote instalado com sucesso' 'telegram'
		return 0
	else
		print_erro 'falha na instalação' 'telegram'
		return 1
	fi
}


_tixati_tarfile()
{
	# Já instalado.
	is_executable 'tixati' && print_info 'Pacote instalado' 'tixati' && return 0

	# Baixar o html da página de download e filtrar pela ocorrência tixati.
	local download_page='https://www.tixati.com/download/linux.html'
	local url_tarfile=$(get_html_page "$download_page" --find 'tixati.*64.*tar.gz' | sed 's/gz".*/gz/g;s/.*="//g')
	local url_signature_file="${url_tarfile}.asc"
	local TarFile="$DirDownloads/$(basename $url_tarfile)"
	local signatureFile="${TarFile}.asc"

	download "$url_tarfile" "$TarFile" || return 1
	download "$url_signature_file" "$signatureFile" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' "$path_file" && return 0 

	gpg_import https://www.tixati.com/tixati.key || return 1
	gpg_verify "$signatureFile" "$TarFile" || return 1

	# Instalar gconf2.
	case "$OS_ID" in
		'opensuse-tumbleweed'|'opensuse-leap') system_pkgmanager gconf2;;
		ubuntu|linuxmint|debian) system_pkgmanager gconf2;;
		fedora) system_pkgmanager GConf2;;
	esac	

	unpack_archive "$TarFile" $DirUnpack || return 1
	cd "$DirUnpack"
	mv $(ls -d tixati*) tixati-amd64 
	cd "$DirUnpack/tixati-amd64"

	mv tixati.desktop "${destinationFilesTixati[file_desktop]}" # .desktop
	mv tixati.png "${destinationFilesTixati[png]}"         # PNG.
	mv tixati "${destinationFilesTixati[bin]}"             # bin.
	
	chmod a+x "${destinationFilesTixati[file_desktop]}"
	chmod a+x "${destinationFilesTixati[bin]}"

	cp -u "${destinationFilesTixati[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesTixati[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesTixati[file_desktop]}" ~/Desktop/ 2> /dev/null

	# Definir tixati como gerenciador bittorrent padrão.
	if question "Deseja usar tixati como bittorrent padrão"; then
		yellow "Definindo tixati como padrão"
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/command 'tixati "%s"'
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/enabled true
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/need-terminal false
	fi

	is_executable gtk-update-icon-cache && gtk-update-icon-cache
}

function _tixati_debian()
{
	local download_page='https://www.tixati.com/download/linux.html'
	local url_debian_file=$(get_html_page "$download_page" --find 'tixati.*64*.deb' | sed 's/deb.*/deb/g;s/.*="//g')
	local url_signature_file="${url_debian_file}.asc"
	local tixati_debian_file="$DirDownloads/$(basename $url_debian_file)"
	local tixati_sig_file="${tixati_debian_file}.asc"

	download "$url_debian_file" "$tixati_debian_file" || return 1
	download "$url_signature_file" "$tixati_sig_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' "$path_file" && return 0 

	gpg_import https://www.tixati.com/tixati.key || return 1
	gpg_verify "$tixati_sig_file" "$tixati_debian_file" || return 1
	system_pkgmanager "$tixati_debian_file"
}


function _tixati_rpm()
{
	local download_page='https://www.tixati.com/download/linux.html'
	local url_rpm_file=$(get_html_page "$download_page" --find 'tixati.*64*.deb' | sed 's/deb.*/deb/g;s/.*="//g')
	local url_signature_file="${url_rpm_file}.asc"
	local tixati_rpm_file="$DirDownloads/$(basename $url_rpm_file)"
	local tixati_sig_file="${tixati_rpm_file}.asc"

	download "$url_rpm_file" "$tixati_rpm_file" || return 1
	download "$url_signature_file" "$tixati_sig_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info "Somente download" && return 0 

	gpg_import https://www.tixati.com/tixati.key || return 1
	gpg_verify "$tixati_sig_file" "$tixati_rpm_file" || return 1
	system_pkgmanager "$tixati_rpm_file"
}


_tixati()
{
	case "$BASE_DISTRO" in
		debian) _tixati_debian;;
		fedora) _tixati_rpm;;
		*) _tixati_tarfile;;
	esac



	if is_executable 'tixati'; then
		print_info 'Tixati instalado com sucesso.'
		return 0
	else
		print_erro 'Tixati não foi instalado.'
		return 1
	fi
}

_uget()
{
	system_pkgmanager uget 
}


_youtube_dl()
{
	# https://youtube-dl.org/
	# http://ytdl-org.github.io/youtube-dl/download.html
	# https://youtube-dl.org/downloads/latest/youtube-dl-2019.11.28.tar.gz
	# https://github.com/ytdl-org/youtube-dl/releases/download/2019.11.28/youtube-dl-2019.11.28.tar.gz.sig
	# https://yt-dl.org/downloads/latest/youtube-dl

	# Já instalado.
	is_executable "$DIR_BIN/youtube-dl" && print_info 'PkgInstalled' "youtube-dl" && return 0

	local URL_YOUTUBE_DL_LATEST='https://yt-dl.org/downloads/latest/youtube-dl'
	local URL_YOUTUBE_DL_SIG='https://yt-dl.org/downloads/latest/youtube-dl.sig'
	local URL_ASC_SERGEY='https://dstftw.github.io/keys/18A9236D.asc'
	local PATH_SIGNATURE_FILE="$DirDownloads/youtube-dl.sig"
	local PATH_YTDL="$DirDownloads/youtube-dl"   
	local hash_sig='04d2edc85b80b59ffe46fdda3937b0074dfe10ede49fec6c36c609cd87841fcb' # sha256sum - .sig
	
	download "$URL_YOUTUBE_DL_LATEST" "$PATH_YTDL" || return 1 
	download "$URL_YOUTUBE_DL_SIG" "$PATH_SIGNATURE_FILE" || return 1 
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' "$PATH_YTDL" && return 0

	# Verificar integridade do script youtube-dl.
	gpg_import 'https://dstftw.github.io/keys/18A9236D.asc' || return 1
	gpg_verify "$PATH_SIGNATURE_FILE" "$PATH_YTDL" || return 1
	print_info "Instalando youtube-dl em ~/.local/bin"
	cp -u "$PATH_YTDL" "$DIR_BIN"/youtube-dl
	chmod a+x "$DIR_BIN"/youtube-dl

	if is_executable 'youtube-dl'; then
		print_info 'Pacote instalado com sucesso' 'youtube-dl'
		return 0
	else
		print_erro 'falha na instalação' 'youtube-dl'
		return 1
	fi
}

_youtube_dlgui_file_desktop_user()
{
	[[ $(id -u) == 0 ]] && return 1
	check_python_version2 || return 1

	# Criar arquivo .desktop na HOME para o usuario atual.
	print_info "Criando arquivo .desktop"

	echo '[Desktop Entry]' > "${destinationFilesYoutubeDlGuiUser[file_desktop]}"
	{
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=$PYTHON2_EXECUTABLE -m youtube_dl_gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} >> "${destinationFilesYoutubeDlGuiUser[file_desktop]}"

	chmod u+x "${destinationFilesYoutubeDlGuiUser[file_desktop]}"
	cp -u "${destinationFilesYoutubeDlGuiUser[file_desktop]}" ~/Desktop/ 2> /dev/null
	cp -u "${destinationFilesYoutubeDlGuiUser[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesYoutubeDlGuiUser[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	is_executable gtk-update-icon-cache && gtk-update-icon-cache
}

_youtube_dlgui_file_desktop_root()
{
	[[ $(id -u) == 0 ]] || return 1
	check_python_version2 || return 1

	# Criar arquivo desktop para todos os usuarios.
	local file_desktop_youtube_dl_gui='/usr/share/applications/youtube-dl-gui.desktop' # .desktop

	print_info "Criando arquivo .desktop"
	{
		echo '[Desktop Entry]'
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=$PYTHON2_EXECUTABLE -m youtube_dl_gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} | tee "$file_desktop_youtube_dl_gui" 1> /dev/null

	print_info "Criando atalho na Área de Trabalho"
	chmod +x "$file_desktop_youtube_dl_gui"
	cp -u "$file_desktop_youtube_dl_gui" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "$file_desktop_youtube_dl_gui" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "$file_desktop_youtube_dl_gui" ~/Desktop/ 2> /dev/null
	is_executable gtk-update-icon-cache && gtk-update-icon-cache
}


_python_twodict_github()
{
	# Instalar python twodict (python versão 2).

	gitclone 'https://github.com/MrS0m30n3/twodict.git' $DirGitclone || return 1
	echo -ne "Executando ... "
	cd "$DirGitclone/twodict"

	# Instalação para o usuário root.
	if [[ $(id -u) == 0 ]]; then
		if is_executable 'python2'; then
			echo -e "python2 setup.py install"
			python2 setup.py install 1>> "$LogFile"
		elif is_executable 'python2.7'; then
			echo -e "python2.7 setup.py install"
			python2.7 setup.py install 1>> "$LogFile"
		elif is_executable 'python'; then
			echo -e "python setup.py install"
			python setup.py install 1>> "$LogFile"
		fi
	else
		# Instalação para o usuário
		if is_executable 'python2'; then
			echo -e "python2 setup.py install --user"
			python2 setup.py install --user 1>> "$LogFile"
		elif is_executable 'python2.7'; then
			echo -e "python2.7 setup.py install --user"
			python2.7 setup.py install --user 1>> "$LogFile"
		elif is_executable 'python'; then
			echo -e "python setup.py install --user"
			python setup.py install --user 1>> "$LogFile"
		fi
	fi


	if [[ "$?" == '0' ]]; then 
		print_info 'Pacote instalado com sucesso' 'python twodict'
		return 0
	else
		print_erro 'falha na instalação' 'python twodict'
		return 1
	fi
}

_install_wxpython2()
{
	# Instalar wxpython para python versão 2.

	if [[ "$BASE_DISTRO" == 'debian' ]]; then
		system_pkgmanager 'python-wxgtk3.0'
	elif [[ "$BASE_DISTRO" == 'archlinux' ]]; then
		system_pkgmanager python2-wxpython3
	elif [[ "$BASE_DISTRO" == 'fedora' ]]; then
		local archive_fedora='https://archives.fedoraproject.org/pub/archive/fedora/linux/releases'
		local pkg_wxpython='python2-wxpython-3.0.2.0-26.fc31.x86_64.rpm'
		local url_wxpython="$archive_fedora/31/Everything/x86_64/os/Packages/p/$pkg_name"
		local path_wxpython_rpm="$DirDownloads/$pkg_wxpython"
		
		download "$url_wxpython" "$path_wxpython_rpm" || return 1 
		[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download.' && return 0
		# Instalar pacote rpm para fedora 32/33.
		if [[ "$VERSION_ID" == '32' ]] || [[ "$VERSION_ID" == '33' ]]; then
			system_pkgmanager "$path_wxpython_rpm" || return 1
		else
			print_erro 'Seu sistema não é Fedora 32/33 saindo ...'
			sleep 1
			return 1
		fi
	else
		print_erro 'Programa indisponível para o seu sistema' 'wxpython2'
		return 1
	fi
}

_youtube_dlgui_compile()
{
	# Baixar e compilar o codigo fonte do youtube-dl-gui no github.
	# Instalação no sistema em /usr/local/bin/youtube-dl-gui 
	local url_youtube_dl_gui_master='https://github.com/MrS0m30n3/youtube-dl-gui/archive/master.zip'
	local path_file="$DirDownloads/youtube-dl-gui.zip"

	download "$url_youtube_dl_gui_master" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 

	unpack_archive "$path_file" $DirUnpack || return 1
	cd "$DirUnpack"/youtube-dl-gui-master || return 1
	print_info "Compilando youtube-dl-gui"
	
	# Instalação para o usuário root.
	if [[ $(id -u) == 0 ]]; then
		if is_executable python2; then
			python2 setup.py install 1> /dev/null || return 1
		elif is_executable python2.7; then
			python2.7 setup.py install 1> /dev/null || return 1
		elif is_executable python27; then
			python27 setup.py install 1> /dev/null || return 1
		elif is_executable python; then
			python setup.py install 1> /dev/null || return 1
		fi
		_youtube_dlgui_file_desktop_root

	else
		# Instalação para o usuário
		if is_executable python2; then
			python2 setup.py install --user 1> /dev/null || return 1
		elif is_executable python2.7; then
			python2.7 setup.py install --user 1> /dev/null || return 1
		elif is_executable python27; then
			python27 setup.py install --user 1> /dev/null || return 1
		elif is_executable python; then
			python setup.py install --user 1> /dev/null || return 1
		fi
		_youtube_dlgui_file_desktop_user

	fi
	return 0
}

_youtube_dlgui_pip() 
{
	# ppa ubuntu.
	# sudo bash -c 'add-apt-repository ppa:nilarimogard/webupd8; apt update'
	# sudo apt install youtube-dlg --yes
	system_pkgmanager 'python-wxgtk3.0' gettext 'python-pip' 'python-twodict' || return 1
	pip install wheel --user
	pip install 'youtube-dlg' --user || return 1
	_youtube_dlgui_file_desktop_user
	return 0
} 


_youtube_dlgui_fedora()
{
	# https://fedora.pkgs.org/31/fedora-x86_64/python2-wxpython-3.0.2.0-26.fc31.x86_64.rpm.html
	# https://wiki.wxpython.org/How%20to%20install%20wxPython
	#
	# https://fedora.pkgs.org/31/fedora-x86_64/wxGTK3-gl-3.0.4-10.fc31.x86_64.rpm.html
	#
	# Apartir da versão 32 do Fedora o pacote python2-wxpython3 não está mais
	# disponível no repositório, sendo necessário baixar o pacote do repositório
	# Fedora 31 e instalar usando o comando "rpm --install" ou "dnf install".
	#
	# sudo dnf install wxGTK3 wxGTK3-gl wxGTK3-media python2
	
	_install_wxpython2 || return 1
	
	# Instalar dependências.
	if [[ "$VERSION_ID" == '32' ]] || [[ "$VERSION_ID" == '33' ]]; then
		system_pkgmanager 'wxGTK3' 'python2' || return 1
	else
		print_erro 'Seu sistema não é Fedora 32/33'
		sleep 1
		return 1
	fi
	
	_python_twodict_github || return 1
	_youtube_dlgui_compile || return 1
	return 0
}

_youtube_dlgui_ubuntu()
{
	# https://github.com/MrS0m30n3/youtube-dl-gui.git
	case "$VERSION_CODENAME" in
		bionic|tricia) 
			_youtube_dlgui_pip || return 1
			;;
		eoan|focal|ulyssa)
			system_pkgmanager 'python-wxgtk3.0' gettext || return 1
			_python_twodict_github || return 1
			_youtube_dlgui_compile || return 1
			;;
		*)
			print_erro 'Programa indisponível para o seu sistema' 'youtube-dl-gui'
			sleep 1	
			return 1
			;;
	esac

}

_youtube_dlgui_debian()
{
	# Testado apenas no debian 10.
	if [[ "$VERSION_CODENAME" == 'buster' ]]; then
		system_pkgmanager python python-pip python-setuptools python-wxgtk3.0 python-twodict gettext || return 1
	else
		print_erro 'Programa indisponível para o seu sistema' 'youtube-dlg-gui'
		return 1
	fi

	pip install wheel --user
	_youtube_dlgui_compile || return 1

}

_youtube_dlgui_archlinux()
{
	system_pkgmanager python2 python2-pip python2-setuptools || return 1
	_python_twodict_github || return 1
	_youtube_dlgui_compile || return 1
	return 0
}

_youtube_dlgui_freebsd()
{
	# freebsd-12.0-release sudo pkg install py27-wxPython30
	system_pkgmanager py27-wxPython30 || return 1
	_python_twodict_github || return 1
	_youtube_dlgui_compile || return 1
	return 0
}

_youtube_dlgui()
{
	# Verificar se o python versão 2 está instalado.
	check_python_version2 || {
		print_erro "python2 não está instalado em seu sistema"
		question 'Deseja instalar python2 para prosseguir' || return 1
		system_pkgmanager python2 || system_pkgmanager python27
	}
	
	__add_link_from_python || return 1

	if [[ -f /etc/debian_version ]]; then
		if [[ "$VERSION_CODENAME" == 'buster' ]]; then
			_youtube_dlgui_debian || return 1
		elif [[ "$OS_ID" == 'ubuntu' ]] || [[ "$OS_ID" == 'linuxmint' ]]; then
			_youtube_dlgui_ubuntu || return 1
		fi
	elif [[ "$OS_ID" == 'fedora' ]]; then
		_youtube_dlgui_fedora || return 1
	elif [[ "$OS_ID" == 'arch' ]]; then
		_youtube_dlgui_archlinux || return 1
	else
		print_erro 'Programa indisponível para o seu sistema' 'youtube-dl-gui'; return 1
	fi
	
	if is_executable 'youtube-dl-gui'; then
		print_info 'Pacote instalado com sucesso' 'youtube-dl-gui'
		return 0
	else
		print_erro 'falha na instalação' 'youtube-dl-gui'
		return 1
	fi
}

_youtube_dl_qt()
{
	local URL_YOUTUBE_DL_QT=https://github.com/Brunopvh/youtube-dl-qt/archive/refs/heads/master.tar.gz
	local PATH_YOUTUBE_DL_QT="$DirDownloads/youtube-dl-qt-master.tar.gz"

	download "$URL_YOUTUBE_DL_QT" "$PATH_YOUTUBE_DL_QT" || return 1
	[[ $DownloadOnly == 'True' ]] && print_info 'Feito somente download.' && return 0
	unpack_archive "$PATH_YOUTUBE_DL_QT" $DirUnpack || return 1
	cd $DirUnpack
	mv $(ls -d youtube-dl-qt-*) youtube-dl-qt
	cd youtube-dl-qt
	chmod +x setup.sh
	./setup.sh || return 1


	echo "#!/bin/sh" > "$DIR_BIN"/youtube-dl-qt
	echo "python3 -m youtube_dl_qt" >> "$DIR_BIN"/youtube-dl-qt
	chmod +x "$DIR_BIN"/youtube-dl-qt

}

_youtube_dl_qt_old()
{
	[[ $(id -u) == 0 ]] && return 1
	local URL_REPO_YTDL_QT='https://github.com/Brunopvh/youtube-dl-qt/archive/master.tar.gz'
	local PATH_YTDL_QT="$DirDownloads/youtube-dl-qt.tar.gz"
	local SHA256_ICON='782291f220b4621e6087b42709a4e39a730141f720bc75e33e5f25e374594e07'
	local TEMP_FILE_PNG="$DirUnpack/youtube-dl-qt/png/youtube-dl-icon.png"

	if [[ -d "${destinationFilesYoutubeDlQt[dir]}" ]]; then
		print_info "youtube-dl-qt já instalado."
		return 0
	fi

	download "$URL_REPO_YTDL_QT" "$PATH_YTDL_QT" || return 1
	unpack_archive "$PATH_YTDL_QT" $DirUnpack || return 1
	cd $DirUnpack
	mv $(ls -d youtube-dl-qt*) youtube-dl-qt
	
	# Verificar hash do arquivo icone .png
	__shasum__ "$TEMP_FILE_PNG" "$SHA256_ICON" || return 1
	cp -u ./youtube-dl-qt/png/youtube-dl-icon.png "${destinationFilesYoutubeDlQt[icon]}"
	cp -R -u youtube-dl-qt "${destinationFilesYoutubeDlQt[dir]}" || return 1
	chmod a+x youtube-dl-qt "${destinationFilesYoutubeDlQt[dir]}"/youtube-dl-qt.py
	ln -sf "${destinationFilesYoutubeDlQt[dir]}"/youtube-dl-qt.py "${destinationFilesYoutubeDlQt[link]}"

	pip3 install PyQt5 --user
	echo '[Desktop Entry]' > "${destinationFilesYoutubeDlQt[file_desktop]}"
	{
		echo "Name=Youtube-DL-QT"
		echo "Version=1.0"
		echo "Exec=youtube-dl-qt"
		echo "Terminal=false"	
		echo "Categories=Internet;"
		echo "Type=Application"

	} | tee -a "${destinationFilesYoutubeDlQt[file_desktop]}" 1> /dev/null

	chmod +x "$DIR_APPLICATIONS"/youtube-dl-qt.desktop
	cp -u "$DIR_APPLICATIONS"/youtube-dl-qt.desktop ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "$DIR_APPLICATIONS"/youtube-dl-qt.desktop ~/'Área de trabalho'/ 2> /dev/null
	cp -u "$DIR_APPLICATIONS"/youtube-dl-qt.desktop ~/Desktop/ 2> /dev/null
	is_executable gtk-update-icon-cache && gtk-update-icon-cache
}

_archlinux_installer()
{
	local URL_ARCHLINUX_INSTALLER='https://raw.github.com/Brunopvh/storecli/master/scripts/archlinux-installer.sh'
	local DESTINATION_ARCHLINUX_INSTALLER="$DirDownloads/archlinux-installer"
	if [[ -z $dir_local_scripts ]]; then
		download "$URL_ARCHLINUX_INSTALLER" "$DESTINATION_ARCHLINUX_INSTALLER" || return 1
		__sudo__ cp "$DESTINATION_ARCHLINUX_INSTALLER" "${destinationFilesArchlinuxInstaller[script]}" 
	else
		__sudo__ cp "$dir_local_scripts/archlinux-installer.sh" "${destinationFilesArchlinuxInstaller[script]}"
	fi
	__sudo__ chmod a+x "${destinationFilesArchlinuxInstaller[script]}"

	if is_executable archlinux-installer; then
		green 'archlinux-installer instalado com sucesso.'
		return 0
	else
		red 'Falha ao tentar instalar archlinux-installer'
		return 1
	fi
}

_bluetooth()
{
	if [[ "$OS_ID" != 'debian' ]]; then
		red "Este pacote está disponível apenas para sistemas Debian"
		return 1
	fi

	system_pkgmanager bluez 'bluez-firmware' 'bluez-hcidump'
	print_line
	echo -e "1 - ${CGreen}G${CReset}NOME"
	echo -e "2 - ${CGreen}K${CReset}DE"
	echo -e "3 - ${CGreen}L${CReset}XDE/${CGreen}X${CReset}FCE/${CGreen}L${CReset}XQT/${CGreen}M${CReset}ATE"
	
	while true; do

		echo -e "Selecione a sua interface gráfica: ${CGreen}(1 / 2 / 3): ${CReset}" 
		read -t 10 -n 1 desktop; echo ' '

		case "${desktop,,}" in
			1) system_pkgmanager 'gnome-bluetooth';;
			2) system_pkgmanager bluedevil;;
			3) system_pkgmanager blueman;;
			*) 
			echo -e "Opição inválida, você pode ${CGreen}repetir${CReset} ou ${red}cancelar${CReset} [r/c]: " 
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

_bspwm_config()
{
	# Esta função deve ser executada depois de instalar o bspwm e suas dependências.
	# https://github.com/windelicato/dotfiles/wiki/bspwm-for-dummies
	# https://ricebr.github.io/Not-A-Blog//instalando-e-configurando-bspwm/
	touch ~/.xinitrc

	echo -e "Criando diretórios ... ~/.config/{bspwm,sxhkd}"
	mkdir -p ~/.config/{bspwm,sxhkd}
	cp -vr /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm
	cp -vr /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd

	grep 'xsetroot -cursor_name left_ptr &' ~/.config/bspwm/bspwmrc || {
		echo -e "Configurando ... ~/.config/bspwm/bspwmrc"
		echo 'xsetroot -cursor_name left_ptr &' >> ~/.config/bspwm/bspwmrc
	} 

	grep 'exec bspwm' ~/.xinitrc || {
		echo -e "Configurando ... ~/.xinitrc"
		echo 'exec bspwm' >> ~/.xinitrc
	}

	chmod +x ~/.config/bspwm/bspwmrc
}


_bspwm()
{
	
	case "$OS_ID" in
		fedora) system_pkgmanager bspwm sxhkd xsetroot st;;
		*) _show_info "ProgramNotFound"; return 1;;
	esac

	_bspwm_config
}

_compactadores()
{

	if [[ $BASE_DISTRO == 'fedora' ]]; then
		local compactadores=(
		'zip' 'ncompress' 'xarchiver' 'arj' 'cabextract' 'unzip' 'p7zip' 'lzma' 'arc' 
		)
	elif [[ $BASE_DISTRO == 'debian' ]]; then
		local compactadores=(
		'p7zip-full' 'p7zip' 'p7zip-rar' 'cabextract' 'unzip' 'xz-utils' 'lhasa' 
		'unace' 'arc' 'arj' 'lzma' 'rar' 'unrar-free' 'zip' 'ncompress'
		)
	elif [[ $BASE_DISTRO == 'archlinux' ]]; then
		local compactadores=( 
		'tar' 'gzip' 'bzip2' 'unzip' 'unrar' 'p7zip'
		)
	else
		print_erro 'Programa indisponível para o seu sistema' 'compactadores'
		return 1
	fi

	system_pkgmanager "${compactadores[@]}"
}

_firmware()
{
	if [[ "$OS_ID" != 'debian' ]]; then
		red "Este pacote está disponível apenas para sistemas Debian"
		return 1
	fi

	case "$1" in
		firmware-ralink) system_pkgmanager 'firmware-ralink';;
		firmware-atheros) system_pkgmanager 'firmware-atheros';;
		firmware-realtek) system_pkgmanager 'firmware-realtek';;
		firmware-linux-nonfree) system_pkgmanager 'firmware-linux-nonfree';;
	esac
}

_cpux_appimage()
{
	local URL_CPUX_APPIMAGE='https://github.com/X0rg/CPU-X/releases/download/v4.0.1/CPU-X-v4.0.1-x86_64.AppImage'
	local path_cpux_appimage="$DirDownloads/$(basename $URL_CPUX_APPIMAGE)"
	
	is_executable cpux && print_info 'Pacote instalado' 'cpux' && return 0
	
	download "$URL_CPUX_APPIMAGE" "$path_cpux_appimage" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	cp -vu "$path_cpux_appimage" "${destinationFilesCpux[file]}"
	chmod +x "${destinationFilesCpux[file]}"
	
	# Criar arquivo '.desktop'
	{
		echo "[Desktop Entry]"
		echo "Name=CPU-X"
		echo "Version=1.0"
		echo "Exec=${destinationFilesCpux[file]}"
		echo "Type=Application"		
	} > "${destinationFilesCpux[file_desktop]}"
	
	if is_executable cpux; then
		print_info 'Pacote instalado' 'cpu-x'
		return 0
	else
		print_erro 'falha na instalação' 'cpux'
		return 1
	fi
}

_cpux_ubuntu()
{
	case "$VERSION_CODENAME" in
		bionic|tricia) ;;
		*) _cpux_appimage; return 0;;
	esac

	local URL_CPUX_TAR='https://github.com/X0rg/CPU-X/releases/download/v4.0.1/CPU-X_v4.0.1_Ubuntu.tar.gz'
	local PATH_CPUX_TARFILE="$DirDownloads/$(basename $URL_CPUX_TAR)"

	download "$URL_CPUX_TAR" "$PATH_CPUX_TARFILE" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	unpack_archive "$PATH_CPUX_TARFILE" $DirUnpack || return 1
	if [[ "$VERSION_CODENAME" == 'bionic' ]] || [[ "$VERSION_CODENAME" == 'tricia' ]]; then
		printf "Entrando no diretório ... $DirUnpack/xUbuntu_18.04/amd64\n"
		cd "$DirUnpack/xUbuntu_18.04/amd64" || return 1
	else
		sred "Programa indisponível para o seu sistema."
		return 1
	fi

	cp -vu cpu-x_*amd64.deb "$DirTemp"/cpu-x-amd64.deb
	cp -vu cpuidtool_*amd64.deb "$DirTemp"/cpuidtool_amd64.deb
	cp -vu libcpuid15_*amd64.deb "$DirTemp"/libcpuid15_amd64.deb
	printf "Entrando no diretório ... $DirTemp\n"
	cd "$DirTemp"
	_DPKG --install cpu-x-amd64.deb cpuidtool_amd64.deb libcpuid15_amd64.deb || _BROKE
}


_cpux_debian()
{
	# https://github.com/X0rg/CPU-X/releases/download/v4.0.1/CPU-X_v4.0.1_Debian.tar.gz
	case "$VERSION_CODENAME" in
		buster) ;;
		*) _cpux_appimage; return 0;;
	esac

	local URL_CPUX_TAR='https://github.com/X0rg/CPU-X/releases/download/v4.0.1/CPU-X_v4.0.1_Debian.tar.gz'
	local PATH_CPUX_TARFILE="$DirDownloads/$(basename $URL_CPUX_TAR)"

	download "$URL_CPUX_TAR" "$PATH_CPUX_TARFILE" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	unpack_archive "$PATH_CPUX_TARFILE" $DirUnpack || return 1
	printf "Entrando no diretório ... $DirUnpack/Debian_10/amd64\n"
	cd "$DirUnpack/Debian_10/amd64" || return 1
	cp -vu cpu-x_*amd64.deb "$DirTemp"/cpu-x-amd64.deb
	cp -vu cpuidtool_*amd64.deb "$DirTemp"/cpuidtool_amd64.deb
	cp -vu libcpuid15_*amd64.deb "$DirTemp"/libcpuid15_amd64.deb
	printf "Entrando no diretório ... $DirTemp\n"
	cd "$DirTemp"
	_DPKG --install cpu-x-amd64.deb cpuidtool_amd64.deb libcpuid15_amd64.deb || _BROKE
}

_cpux()
{
	# https://github.com/X0rg/CPU-X
	if [[ -f /etc/fedora-release ]]; then
		system_pkgmanager cpu-x
	elif [[ "$OS_ID" == 'debian' ]]; then
		_cpux_debian
	elif [[ "$OS_ID" == 'ubuntu' ]]; then
		_cpux_ubuntu
	else
		_cpux_appimage
	fi
}

_genymotion()
{
	local URL_GENYMOTION='https://dl.genymotion.com/releases/genymotion-3.1.2/genymotion-3.1.2-linux_x64.bin'
	local PATH_GENYMOTION="$DirDownloads/$(basename $URL_GENYMOTION)"

	download "$URL_GENYMOTION" "$PATH_GENYMOTION" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	cd "$DIR_BIN"
	chmod +x "$PATH_GENYMOTION"
	"$PATH_GENYMOTION"

}

_google_earth_debian()
{
	# https://sempreupdate.com.br/como-instalar-o-google-earth-no-ubuntu-18-04-e-linux-mint-19/
	url_google_earth='http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb'
	path_file="$DirDownloads/$(basename $url_google_earth)"
	download "$url_google_earth" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	_APT install "$path_file" || return 1
	return 0
}

_google_earth_fedora()
{
	# https://edpsblog.wordpress.com/2013/06/25/google-earth-no-debian-fedora-e-opensuse/
	url_google_earth='http://dl.google.com/dl/earth/client/current/google-earth-stable_current_x86_64.rpm'
	path_file="$DirDownloads/$(basename $url_google_earth)"
	download "$url_google_earth" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	_DNF install "$path_file" || return 1
	return 0
}

_google_earth()
{
	if [[ -f /etc/debian_version ]]; then
		_google_earth_debian
	elif [[ -f /etc/fedora-release ]]; then
		_google_earth_fedora
	else
		print_erro 'Programa indisponível para o seu sistema' 'google-earth'
		return 1 
	fi
}

_gparted()
{
	system_pkgmanager gparted
}

_peazip()
{
	# 'http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
	# https://github.com/peazip/PeaZip/releases/download/7.4.2/peazip_portable-7.4.2.LINUX.x86_64.GTK2.tar.gz
	# https://peazip.github.io/peazip-linux.html

	# Já instalado
	is_executable 'peazip' &&  print_info 'Pacote instalado' 'peazip' && return 0
	local peazip_download_page='http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
	local path_file="$DirDownloads/$(basename $peazip_download_page)"

	download "$peazip_download_page" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 # Somente baixar 
	
	unpack_archive "$path_file" "$DirUnpack" || return 1
	
	echo -e "Entrando no diretório ... $DirUnpack"
	cd "$DirUnpack"
	mv -v $(ls -d peazip*) "peazip-amd64" 1> /dev/null || return 1
	mv "$DirUnpack/peazip-amd64" "${destinationFilesPeazip[dir]}"
	chmod a+x "${destinationFilesPeazip[dir]}"/peazip
	echo -e "Entrando no diretório ... ${destinationFilesPeazip[dir]}"
	cd "${destinationFilesPeazip[dir]}" 
	cp -u FreeDesktop_integration/peazip.png "${destinationFilesPeazip[png]}" 1> /dev/null     
	# cp -u FreeDesktop_integration/peazip.desktop "${destinationFilesPeazip[file_desktop]}"

	print_info "Criando arquivo '.desktop'"
	echo '[Desktop Entry]' > "${destinationFilesPeazip[file_desktop]}"
	{
		echo 'Version=1.0'
		echo 'Encoding=UTF-8'
		echo 'Name=PeaZip'
		echo 'MimeType=application/x-gzip;application/x-tar;application/x-deb;bzip;application/x-rar'
		echo 'GenericName=Archiving Tool'
		echo 'Exec=peazip %F'
		echo "Icon=${destinationFilesPeazip[png]}"
		echo 'Type=Application'
		echo 'Terminal=false'
		echo 'X-KDE-HasTempFileOption=true'
		echo 'Categories=GTK;KDE;Utility;System;Archiving;'
	} | tee -a "${destinationFilesPeazip[file_desktop]}" 1> /dev/null
                               
	print_info "Criando script para execução via linha de comando"
	{
		echo -e "#!/bin/sh\n"
		echo -e "cd ${destinationFilesPeazip[dir]}"
		echo -e "./peazip \$@"
	} | tee "${destinationFilesPeazip[script]}" 1> /dev/null
	chmod a+x "${destinationFilesPeazip[script]}"

	print_info 'Criando arquivo .desktop'
	cp -u "${destinationFilesPeazip[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesPeazip[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesPeazip[file_desktop]}" ~/Desktop/ 2> /dev/null

	is_executable 'gtk-update-icon-cache' && gtk-update-icon-cache

	if is_executable 'peazip'; then
		print_info 'Pacote instalado com sucesso' 'peazip'
		return 0
	else
		print_erro 'falha na instalação' 'peazip'
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
	
	download "$url_zip" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 
	
	# Já instalado.
	is_executable 'refind-install' && print_info 'Pacote instalado' 'refind-install' && return 0
	
	unpack_archive "$path_file" $DirUnpack || return 1
	cd "$DirUnpack"
	mv $(ls -d refind*) refind
	sudo mv refind "${destinationFilesRefind[dir]}"
	
	# Criar script para execução
	echo '#!/usr/bin/env bash' | sudo tee "${destinationFilesRefind[script]}" 
	{
		echo "cd ${destinationFilesRefind[dir]}"
		echo "./refind-install \$@"
	} | sudo tee -a "${destinationFilesRefind[script]}"
	
	sudo chmod -R +x "${destinationFilesRefind[dir]}"
	sudo chmod a+x "${destinationFilesRefind[script]}"
	
}

_refind()
{
	case "$OS_ID" in
		debian|ubuntu|linuxmint|arch) system_pkgmanager refind;;
		*) _refind_zip;;
	esac
	
	if is_executable 'refind-install'; then
		print_info 'Pacote instalado com sucesso' 'refind-install'
		return 0
	else
		print_erro 'falha na instalação' 'refind-install'
		return 1
	fi
}


_stacer_debian()
{
	# https://github.com/oguzhaninan/Stacer/releases
	# https://github.com/oguzhaninan/Stacer
	local url='https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb'
	local path_file="$DirDownloads/$(basename $url)"

	download "$url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	system_pkgmanager "$path_file"
}

_stacer_fedora()
{
	system_pkgmanager stacer	
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
	
	download "$url_stacer_appimage" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0
	
	cp -u "$path_file" "${destinationFilesStacer[file_appimage]}"
	
	print_info "Criando arquivo .desktop"
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

	yellow "Criando atalho na Área de Trabalho"
	cp -u "${destinationFilesStacer[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesStacer[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesStacer[file_desktop]}" ~/Desktop/ 2> /dev/null

	is_executable 'gtk-update-icon-cache' && gtk-update-icon-cache

	if is_executable 'stacer'; then
		print_info 'Pacote instalado com sucesso' 'Stacer'
	else
		print_erro 'falha na instalação' 'stacer'
	fi
}

_stacer()
{
	case "$OS_ID" in
		debian|ubuntu|linuxmint) _stacer_debian;;
		fedora) _stacer_fedora;;
		arch) 
			system_pkgmanager 'qt5-charts' 'hicolor-icon-theme' 'qt5-declarative' 'qt5-declarative' 'qt5-tools'
			_stacer_appimage
			;;
		*) _stacer_appimage;;
	esac
}

_shm()
{
	local URL_SHM_INSTALLER='https://raw.github.com/Brunopvh/bash-libs/main/setup.sh'
	local SHM_TMP_SCRIPT=$(mktemp -u)
	download "$URL_SHM_INSTALLER" "$SHM_TMP_SCRIPT" || return 1
	chmod +x "$SHM_TMP_SCRIPT"
	"$SHM_TMP_SCRIPT"
	rm -rf "$SHM_TMP_SCRIPT"
	shm --configure
}

_timeshift_debian()
{
	local URL_TIME_SHIFT='https://github.com/teejee2008/timeshift/releases/download/v20.11.1/timeshift_20.11.1_amd64.deb'
	local PATH_TIME_SHIFT="$DirDownloads/$(basename $URL_TIME_SHIFT)"

	download "$URL_TIME_SHIFT" "$PATH_TIME_SHIFT" || return 1
	_APT install "$PATH_TIME_SHIFT"
}

_timeshift()
{
	system_pkgmanager 'timeshift'
}

_virtualbox_extension_pack()
{
	# Após instalar o virtualbox no sistema, devemos executar esta
	# função para instalar o pacote extensionpack (em qualquer distro)
	# uma vez que está função funciona da mesma maneira em qualquer 
	# distribuição linux. 
	#   Baixa o pacote (extensionpack) instala o pacote usando o virtualbox
	# e adiciona o usuário atual no grupo  vboxuser.
	#

	is_executable virtualbox || {
		print_erro "Instale o virtualbox para prosseguir."
		return 1
	}
	
	local VBOX_DOWN_PAGE="https://www.virtualbox.org/wiki/Downloads"
	local URL_EXTENSION_PACK=$(get_html_page "$VBOX_DOWN_PAGE" --find "Oracle.*Ext.*vbox.*" | sed 's/.*href="//g;s/">.*//g')
	local PATH_EXTENSION_PACK="$DirDownloads/$(basename $URL_EXTENSION_PACK)"

	download "$URL_EXTENSION_PACK" "$PATH_EXTENSION_PACK" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	__sudo__ VBoxManage extpack install --replace "$PATH_EXTENSION_PACK"
	question "Deseja adicionar $USER ao grupo ${CGreen}vboxusers${CReset}" || return 1 
	__sudo__ usermod -a -G vboxusers $USER	
}

_virtualbox_additions()
{
	# https://www.blogopcaolinux.com.br/2017/08/Instalando-Adicionais-para-Convidado-no-Debian.html
	# https://4fasters.com.br/2018/09/18/como-deixar-o-centos-em-tela-cheia-no-virtual-box/
	if [[ "$OS_ID" == 'debian' ]]; then
		_APT install -y build-essential module-assistant
		_APT install -y linux-headers-$(uname -r)
		__sudo__ m-a prepare
	elif [[ "$OS_ID" == 'ubuntu' || "$OS_ID" == 'linuxmint' ]]; then
		system_pkgmanager build-essential module-assistant
		system_pkgmanager linux-headers-$(uname -r)
		__sudo__ m-a prepare
		system_pkgmanager virtualbox-guest-x11
	elif [[ -f /etc/fedora-release ]]; then
		system_pkgmanager gcc kernel-devel kernel-headers dkms make bzip2 perl libxcrypt-compat
		system_pkgmanager $(rpm -qa kernel | sort -V | tail -n 1)
		system_pkgmanager kernel-devel-$(uname -r)
		system_pkgmanager virtualbox-guest-additions
	elif [[ "$OS_ID" == 'arch' ]]; then
		system_pkgmanager virtualbox-guest-iso 
		system_pkgmanager virtualbox-guest-dkms
	else
		print_erro "Pacote indisponível para o seu sistema."
		return 1
	fi
	print_line
}

_install_requeriments_virtualbox()
{
	
	if [[ "$BASE_DISTRO" == 'fedora' ]]; then
		local requeriments_virtualbox=(
				bzip2 perl libxkbcommon libxcrypt-compat libgomp
				glibc-headers glibc-devel kernel-headers kernel-devel 
				dkms qt5-qtx11extras binutils gcc automake make patch
			)

	elif [[ "$BASE_DISTRO" == 'debian' ]]; then # Debian/Ubuntu.
		local requeriments_virtualbox=(
				module-assistant build-essential libsdl-ttf2.0-0 dkms
			)

		system_pkgmanager linux-headers-$(uname -r)

	elif [[ "$BASE_DISTRO" == 'archlinux' ]]; then
		local requeriments_virtualbox=(
				virtualbox virtualbox-host-modules-arch linux-headers
			)

	else
		print_erro "(_install_requeriments_virtualbox) BASE_DISTRO não detectado."
		return 1
	fi

	system_pkgmanager "${requeriments_virtualbox[@]}" || return 1 
	return 0
}

_virtualbox_fedora()
{
	# https://www.if-not-true-then-false.com/2010/install-virtualbox-guest-additions-on-fedora-centos-red-hat-rhel/
	# sudo dnf install make automake gcc gcc-c++ kernel-devel
	#    
	
	_install_requeriments_virtualbox
	system_pkgmanager $(rpm -qa kernel | sort -V | tail -n 1) 
	system_pkgmanager kernel-devel-$(uname -r)

	local URL_REPO_VBOX_FEDORA='http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo'
	local URL_KEY_VBOX='https://www.virtualbox.org/download/oracle_vbox.asc'
	_rpm_key_add "$URL_KEY_VBOX" || return 1
	_addrepo_in_fedora "$URL_REPO_VBOX_FEDORA" /etc/yum.repos.d/virtualbox.repo || return 1
	
	case "$VERSION_ID" in
		31) system_pkgmanager 'VirtualBox-6.0' || return 1;;
		32) system_pkgmanager 'VirtualBox-6.1' || return 1;;
		*) print_erro "(_virtualbox_fedora)"; return 1;;
	esac
	
	# Módulos
	msg "Configurando módulos"
	sudo bash -c '/usr/lib/virtualbox/vboxdrv.sh setup'
	sudo bash -c '/sbin/vboxconfig'

	# Instalar o pacote ExtensionPack.
	_virtualbox_extension_pack 
}

_virtualbox_package_deb()
{
	# Instalação do virtualbox no Debian Buster.
	if [[ "$VERSION_CODENAME" != 'buster' ]]; then 
		print_erro "(_virtualbox_package_deb) ... Seu sistema não é Debian Buster"
		return 1
	fi
	
	local URL_VIRTUALBOX_DOW_PAGE='https://www.virtualbox.org/wiki/Linux_Downloads'

	_install_requeriments_virtualbox

	# Informações sobre o pacote '.deb'.
	html_vbox_deb_buster=$(get_html_page "$URL_VIRTUALBOX_DOW_PAGE" --find '6.1.*buster.*.deb')
	url_vbox_deb_buster=$(echo -e "$html_vbox_deb_buster" | sed 's/.*href="//g;s/">.*//g')
	local VIRTUALBOX_PKG_DEB="$DirDownloads/$(basename $url_vbox_deb_buster)"

	# Filtrar versão do virtualbox na string URL
	local vbox_version=$(echo "$url_vbox_deb_buster" | cut -d '/' -f 5)

	# Definir o url de download do arquivo 'SHA256SUMS' com as hashs e seu destino de download.
	local vbox_url_hash="https://www.virtualbox.org/download/hashes/$vbox_version/SHA256SUMS"
	local vbox_path_file_hash="$DirDownloads/virtualbox_hashs_$vbox_version.check"
	
	download "$url_vbox_deb_buster" "$VIRTUALBOX_PKG_DEB" || return 1
	download "$vbox_url_hash" "$vbox_path_file_hash" || return 1

	# Obter hash do arquivo .deb baixado
	hash_debian_file=$(grep -m 1 "buster.*amd64" "$vbox_path_file_hash" | cut -d ' ' -f 1)
	__shasum__ "$VIRTUALBOX_PKG_DEB" "$hash_debian_file" || return 1

	system_pkgmanager "$VIRTUALBOX_PKG_DEB" || _BROKE	
}

_virtualbox_debian()
{
	# Instalação via repositório.
	local url_libvpx='http://ftp.us.debian.org/debian/pool/main/libv/libvpx/libvpx5_1.7.0-3+deb10u1_amd64.deb'
	local path_libvpx="$DirDownloads/$(basename $url_libvpx)"
	local sum_libvpx='72d8466a4113dd97d2ca96f778cad6c72936914165edafbed7d08ad3a1679fec'

	if [[ "$VERSION_CODENAME" == 'buster' ]]; then
		virtualbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib"
	else
		red "Seu sistema ainda não tem suporte a instalação do virtualbox por meio deste script"
		return 1
	fi

	apt_key_add 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' || return 1
	apt_key_add 'https://www.virtualbox.org/download/oracle_vbox.asc' || return 1
	add_repo_apt "$virtualbox_repo" /etc/apt/sources.list.d/virtualbox.list
	_APT update 
	print_line 
	_install_requeriments_virtualbox
	system_pkgmanager 'virtualbox-6.1' || return 1
	_virtualbox_extension_pack
}

_virtualbox_ubuntu()
{
	case "$VERSION_CODENAME" in
		focal|ulyssa) 
				vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian focal contrib"
				;;
		bionic|tricia) 
				vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib"
				;;
		*) 
			_virtualbox_linux_run;;
	esac

	apt_key_add 'https://www.virtualbox.org/download/oracle_vbox_2016.asc' || return 1
	apt_key_add 'https://www.virtualbox.org/download/oracle_vbox.asc' || return 1
	add_repo_apt "$vbox_repo" /etc/apt/sources.list.d/virtualbox.list
	
	system_pkgmanager libvpx6 
	_install_requeriments_virtualbox
	print_line
	system_pkgmanager 'virtualbox-6.1' || return 1
	_virtualbox_extension_pack
}

_virtualbox_archlinux()
{
	# https://sempreupdate.com.br/como-instalar-o-virtualbox-no-arch-linux/
	# https://wiki.archlinux.org/index.php/VirtualBox_(Portugu%C3%AAs)
	# https://www.virtualbox.org/wiki/Linux_Downloads
	# https://www.edivaldobrito.com.br/sbinvboxconfig-nao-esta-funcionando/
	
	_install_requeriments_virtualbox

	msg "Executando ... /sbin/rcvboxdrv setup"; sudo /sbin/rcvboxdrv setup
	msg "Executando ... sudo /sbin/vboxconfig"; sudo /sbin/vboxconfig
	msg "Executando ... sudo modprobe vboxdrv"; sudo modprobe vboxdrv

	# Configuração para carregar o módulo durante o boot.
	# sudo echo vboxdrv >> /etc/modules-load.d/virtualbox.conf

	# Instalar o pacote ExtensionPack.
	_virtualbox_extension_pack 
}

_virtualbox_linux_run()
{
	# Virtualbox para qualquer Linux.
	# Encontar os urls de downloads do executável .run (dor virtualbox)
	# e o arquivo que contém as hashs sha256 para cada versão do virtualbox
	#
	# O download do arquivo contendo as hashs e semelhante ao comando
	# abixo, ATENÇÃO a mudança de versão do virtualbox (6.x)
	# wget https://www.virtualbox.org/download/hashes/6.1.6/SHA256SUMS
	#
	# https://download.virtualbox.org/virtualbox/6.1.6/VirtualBox-6.1.6-137129-Linux_amd64.run
	#
	# sudo /etc/init.d/vboxdrv setup
	# sudo /sbin/vboxconfig
	# sudo /sbin/rcvboxdrv setup
	local HtmlTemporaryFile=$(mktemp -u)

	_install_requeriments_virtualbox || return 1

	# Pagina de download do virtualbox
	vbox_pag='https://www.virtualbox.org/wiki/Linux_Downloads'
	get_html_file 'https://www.virtualbox.org/wiki/Linux_Downloads' "$HtmlTemporaryFile"

	# Encontrar ocorrências .run ou SHA256 no html da pagina de download.
	vbox_html=$(egrep "(https.*download.*64.run|SHA256)" "$HtmlTemporaryFile")
	
	# Filtrar o url do arquivo executável (.run)
	vbox_url_run=$(echo "$vbox_html" | grep -m 1 '64.run' | sed 's/.*href="//g;s/run".*/run/g')

	# Filtrar versão do virtualbox na string URL
	vbox_version=$(echo "$vbox_url_run" | cut -d '/' -f 5)

	# Atribuir path do arquivo a ser baixado.
	path_file_vbox_run="$DirDownloads/$(basename $vbox_url_run)"
	
	# Definir o url de download do arquivo 'SHA256SUMS' com as hashs e seu destino de download.
	vbox_url_hash="https://www.virtualbox.org/download/hashes/$vbox_version/SHA256SUMS"
	vbox_path_file_hash="$DirDownloads/virtualbox_$vbox_version.check"
	msg "Baixando virtualbox versão $vbox_version"	

	download "$vbox_url_run" "$path_file_vbox_run" || return 1
	download "$vbox_url_hash" "$vbox_path_file_hash" || return

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	# Obter a HASH do pacote de instalação com a extensão .run. As informações
	# estão no arquivo '.check'. Em seguida verificar a integridade do pacote.
	shasum_package_vitualbox=$(grep '64.run' "$vbox_path_file_hash" | cut -d' ' -f 1)
	__shasum__ "$path_file_vbox_run" "$shasum_package_vitualbox" || return 1

	chmod +x "$path_file_vbox_run"
	__sudo__ "$path_file_vbox_run"
	__sudo__ /sbin/rcvboxdrv setup
	__sudo__ /sbin/vboxconfig
	_virtualbox_extension_pack
	rm -rf $HtmlTemporaryFile 2> /dev/null
}

_virtualbox()
{
	#is_executable virtualbox && print_info 'Pacote instalado' 'virtualbox' && return 0
	case "$OS_ID" in
		debian) _virtualbox_debian;;
		linuxmint|ubuntu) _virtualbox_ubuntu;;
		fedora) _virtualbox_fedora;;
		arch) 
			_virtualbox_linux_run
			_virtualbox_additions 
			;;	
		*) print_erro 'Programa indisponível para o seu sistema' 'virtualbox'; return 1;;	
	esac
}

_ohmybash()
{
	# https://github.com/ohmybash/oh-my-bash.git
	# https://github.com/ohmybash/oh-my-bash/wiki/Themes#agnoster
	#
	# Temas:
	# I recommend the following:
	# cd home
	# mkdir -p .bash/themes/agnoster-bash
	# git clone https://github.com/speedenator/agnoster-bash.git .bash/themes/agnoster-bash
	# bash -c "$(wget -q -O- https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
	
	local ohmybash_master='https://github.com/ohmybash/oh-my-bash/archive/master.zip'
	local ohmybashZipFile="$DirDownloads/ohmybash.zip"
	local url_installer_ohmybash='https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh'
	local ohmybash_installer="$DirTemp/ohmybash_installer.sh"
	
	if is_executable "$SCRIPT_OHMYBASH_INSTALLER"; then
		"$SCRIPT_OHMYBASH_INSTALLER"
	else 
		download "$url_installer_ohmybash" "$ohmybash_installer" || return 1
		 [[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download.' && return 0
	fi

	download "$ohmybash_master" "$ohmybashZipFile" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download.' && return 0

	unpack_archive "$ohmybashZipFile" $DirUnpack || return 1
	msg "Instalando temas para ohmybash em: $HOME/.bash/themes"
	mkdir -p "$HOME/.bash/themes"
	cp -R -u "$DirUnpack/oh-my-bash-master/themes/" "$HOME/.bash/" || return 1
	sed -i "s|OSH_THEME=.*|OSH_THEME=mairan|g" "$HOME/.bashrc"
	
	question "Gostaria de habilitar um tema para ohmybash" || return 1

	yellow "1 => bakke"
	yellow "2 => bobby"
	yellow "3 => bobby-python"
	yellow "4 => emperor"
	yellow "5 => mairan (recomendado)"
	yellow "6 => rjorgenson"
	yellow "7 => agnoster"
	yellow "8 => kitsune"
	yellow "9 => powerline-plain"
	read -n 1 -t 15 -p "Selecione um numero correspondente a opção desejada: " option
	echo ' '

	case "$option" in
		1) option='bakke';;
		2) option='bobby';;
		3) option='bobby-python';;
		4) option='emperor';;
		5) option='mairan';;
		6) option='rjorgenson';;
		7) option='agnoster';;
		8) option='kitsune';;
		9) option='powerline-plain';;
		*) red "Opção incorreta saindo"; return 1;;
	esac

	msg "Habilitando o tema $option para ohmybash"
	sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" ~/.bashrc
	printf "OK\n"
}

_install_zsh_powerline()
{
	# https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
	local URL_POWERLINE_REPO='https://github.com/powerline/fonts/archive/master.zip'
	local PATH_POWERLINE_FILE="$DirDownloads/powerline.zip"

	download "$URL_POWERLINE_REPO" "$PATH_POWERLINE_FILE" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download.' && return 0

	unpack_archive "$PATH_POWERLINE_FILE" $DirUnpack || return 1
	cd "$DirUnpack"/fonts-master
	chmod +x install.sh
	./install.sh

	_font='agnoster'
	msg "Configurando fonte $_font em ~/.zshrc"
	sed -i "s|ZSH_THEME=.*|ZSH_THEME=$_font|g" ~/.zshrc
}

_ohmyzsh()
{
	# bash -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	# https://github.com/ohmyzsh/ohmyzsh
	#
	local URL_INSTALLER_ZSH='https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh'
	local PATH_ZSH_INSTALLER="$DirTemp/zsh-installer.sh"

	if ! is_executable 'zsh'; then
		question "Para prosseguir é necessário instalar o shell 'zsh'" || return 1
		system_pkgmanager zsh	
	fi
	
	download "$URL_INSTALLER_ZSH" "$PATH_ZSH_INSTALLER" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download.' && return 0

	sh "$PATH_ZSH_INSTALLER"
	rm -rf "$PATH_ZSH_INSTALLER" 2> /dev/null
	_install_zsh_powerline
}

_papirus_debian()
{
	# sudo apt install libreoffice-style-papirus
	system_pkgmanager 'papirus-icon-theme'
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

	download "$url_papirus_master" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 

	unpack_archive "$path_file" $DirUnpack || return 1
	cd "$DirUnpack"
	mv  $(ls -d papirus-*) papirus
	cd papirus
	
	printf "%s" "[>] Instalando Papirus-Dark "
	cp -R -u Papirus-Dark "${destinationFilesPapirus[papirus_dark]}" && echo "OK"

	printf "%s" "[>] Instalando Papirus "
	cp -R -u Papirus "${destinationFilesPapirus[papirus]}" && echo "OK"
	
	printf "%s" "[>] Instalando Papirus-Light " 
	cp -R -u Papirus-Light "${destinationFilesPapirus[papirus_light]}" && echo "OK"

	printf "%s" "[>] Instalando ePapirus "
	cp -R -u ePapirus "${destinationFilesPapirus[epapirus]}" && echo "OK"
	
}

_papirus()
{
	case "$OS_ID" in
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

	case "$OS_ID" in
		fedora) 
				system_pkgmanager 'gtk-murrine-engine' 'gtk2-engines'
				;;

		arch) 
				system_pkgmanager 'gtk-engine-murrine' 'gtk-engines'
				;;

		debian|ubuntu|linuxmint) 
				system_pkgmanager 'gtk2-engines-murrine' 'gtk2-engines-pixbuf'
				;;
	esac

	download "$url_sierra" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0

	unpack_archive "$path_file" $DirUnpack || return 1
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

	gitclone "$url_repo" $DirGitclone || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' && return 0 

	system_pkgmanager make
	cd "$DirGitclone"/dash-to-dock
	make
	make install
	#sudo make install 

	if question "Deseja abrir a jenela de configuração gnome-shell-extension-prefs"; then
		gnome-shell-extension-prefs
	fi

}

_dashtodock()
{
	case "$OS_ID" in
		fedora) system_pkgmanager 'gnome-shell-extension-dash-to-dock.noarch';;
		debian) system_pkgmanager 'gnome-shell-extension-dashtodock';;
		*) _dashtodock_github;;
	esac
}

_drive_menu()
{
	case "$OS_ID" in
		fedora) system_pkgmanager 'gnome-shell-extension-drive-menu';;
		*) print_erro 'Programa indisponível para o seu sistema' 'drive-menu'; return 1;;
	esac
}

_gnome_backgrounds()
{
	case "$OS_ID" in 
		arch) system_pkgmanager 'gnome-backgrounds';;
		fedora) system_pkgmanager 'gnome-backgrounds-extras' 'verne-backgrounds-gnome';;
		*) print_erro 'Programa indisponível para o seu sistema' 'gnome-backgrounds'; return 1;;
	esac
}

_topicons_plus_github()
{
	# https://github.com/phocean/TopIcons-plus/archive/master.zip
	# https://github.com/phocean/TopIcons-plus/archive/master.tar.gz
	# https://github.com/phocean/TopIcons-plus

	local url='https://github.com/phocean/TopIcons-plus/archive/master.tar.gz'
	local path_file="$DirDownloads/topicons_plus.tar.gz"

	download "$url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info 'Feito somente download' "$path_file" && return 0 

	system_pkgmanager make
	unpack_archive "$path_file" $DirUnpack || return 1
	cd "$DirUnpack"
	mv $(ls -d Top*) "$DirUnpack"/topicons_plus
	cd topicons_plus
	
	# make install
	sudo make install INSTALL_PATH=/usr/share/gnome-shell/extensions
	print_line

	if question "Deseja abrir a jenela de configuração para topicons-plus"; then
		gnome-extensions prefs TopIcons@phocean.net
	fi

}

_topicons_plus()
{
	case "$OS_ID" in
		fedora) system_pkgmanager 'gnome-shell-extension-topicons-plus';;
		debian) _topicons_plus_github;; # system_pkgmanager 'gnome-shell-extension-top-icons-plus'
		*) _topicons_plus_github;;
	esac
}

_gnome_tweaks()
{
	system_pkgmanager 'gnome-tweaks'
}


#=============================================================#
# Instalar todos os pacotes da categória Acessorios.
#=============================================================#
_Acessory_All()
{
	question "Instalar todos os pacotes da categória 'Acessórios'" || return 1

	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_acessory[@]}"
		else
			main install --yes "${programs_acessory[@]}"
		fi
	else
		main install "${programs_acessory[@]}"
	fi
}


#=============================================================#
# Instalar todos os pacotes da categória Desenvolvimento.
#=============================================================#
_Dev_All()
{
	question "Instalar todos os pacotes da categória 'Desenvolvimento'" || return 1
	
	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_development[@]}"
		else
			main install --yes "${programs_development[@]}"
		fi
	else
		main install "${programs_development[@]}"
	fi
}



#=============================================================#
# Instalar todos os pacotes da categória Sistema.
#=============================================================#
_System_All()
{
	question "Instalar todos os pacotes da categória 'Sistema'" || return 1 
	
	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_system[@]}"
		else
			main install --yes "${programs_system[@]}"
		fi
	else
		main install "${programs_system[@]}"
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Internet_All()
{
	question "Instalar todos os pacotes da categória 'Internet'" || return 1

	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_internet[@]}"
		else
			main install --yes "${programs_internet[@]}"
		fi
	else
		main install "${programs_internet[@]}"
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Browser_All()
{
	question "Instalar todos os pacotes da categória 'Navegadores'" || return 1

	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_browser[@]}"
		else
			main install --yes "${programs_browser[@]}"
		fi
	else
		main install "${programs_browser[@]}"
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Office.
#=============================================================#
_Office_All()
{
	question "Instalar todos os pacotes da categória 'Escritório'" || return 0

	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_office[@]}"
		else
			main install --yes "${programs_office[@]}"
		fi
	else
		main install "${programs_office[@]}"
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Midia.
#=============================================================#
_Midia_All()
{
	question "Instalar todos os pacotes da categória 'Midia'" || return 1

	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_midia[@]}"
		else
			main install --yes "${programs_midia[@]}"
		fi
	else
		main install "${programs_midia[@]}"
	fi
}


#=============================================================#
# Instalar todos os pacotes da categória Wine.
#=============================================================#
_Wine_All()
{
	question "Instalar todos os pacotes da categória 'Wine'" || return 1

	if [[ "$AssumeYes" == 'True' ]]; then
		if [[ "$DownloadOnly" == 'True' ]]; then
			main install --yes --downloadonly "${programs_wine[@]}"
		else
			main install --yes "${programs_wine[@]}"
		fi
	else
		main install "${programs_wine[@]}"
	fi
}
