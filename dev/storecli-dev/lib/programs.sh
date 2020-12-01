#!/usr/bin/env bash
#

github='https://github.com'

_etcher_package_deb()
{
	# https://github.com/balena-io/etcher/releases
	local url_etcher='https://github.com/balena-io/etcher/releases/download/v1.5.100/balena-etcher-electron_1.5.100_amd64.deb'
	local PathFileEtcher="$DirDownloads/$(basename $url_etcher)"

	__download__ "$url_etcher" "$PathFileEtcher" || return 1
	_APT update || return 1
	_APT install "$PathFileEtcher" || _BROKE
	return 0
}

_etcher_debian()
{
	# https://github.com/balena-io/etcher#debian-and-ubuntu-based-package-repository-gnulinux-x86x64
	# https://github.com/balena-io/etcher/releases
	_yellow "Adicionando key e repositório"
	sudo apt-key adv --keyserver hkps://keyserver.ubuntu.com:443 --recv-keys 379CE192D401AB61 || return 1 
	echo "deb https://deb.etcher.io stable etcher" | sudo tee '/etc/apt/sources.list.d/balena-etcher.list'
	_APT update || return 1
	__pkg__ balena-etcher-electron || return 1	
}

_etcher_archlinux()
{
	# https://aur.archlinux.org/packages/balena-etcher/
	url_pkgbuild='https://aur.archlinux.org/cgit/aur.git/tree/PKGBUILD?h=balena-etcher'
	url_snapshot='https://aur.archlinux.org/cgit/aur.git/snapshot/balena-etcher.tar.gz'
	path_file="$DirDownloads/etcher_archlinux.tar.gz"
	
	__download__ "$url_snapshot" "$path_file" || return 1
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
	# _yellow "Executando ... curl -sSL https://balena.io/etcher/static/etcher-rpm.repo -o /etc/yum.repos.d/etcher-rpm.repo"
	__sudo__ curl -sSL https://balena.io/etcher/static/etcher-rpm.repo -o /etc/yum.repos.d/etcher-rpm.repo
	__pkg__ 'balena-etcher-electron'
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
		ubuntu|linuxmint|debian) _etcher_debian;;
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
	__pkg__ 'gnome-disk-utility'
}

_plank()
{
	if [[ "$os_id" == 'fedora' ]]; then # Fedora
		# https://diolinux.com.br/2020/02/como-utilizar-plank-com-zoom-nos-icones-no-fedora.html
		_yellow "Plank será instalado apartir de um repositório ${CSYellow}externo${CReset} ... copr:copr.fedorainfracloud.org:gqman69:plank"
		_yellow "Versões de outros repositórios serão removidas"
		_YESNO "Deseja prosseguir com a instalação" || return 1
		_DNF copr enable 'gqman69/plank'
		is_executable plank && {
			_yellow "Desinstalando versão anterior"
			_DNF remove plank
		}
		__pkg__ 'plank-0.11.4-99.fc31.x86_64' || return 1
	else
		__pkg__ plank
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
	# 'https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2'
	# https://launchpad.net/veracrypt/trunk/1.24-update4/&#43;download/veracrypt-1.24-Update4-setup.tar.bz2
	#
	# libgtk-x11-2.0.so.0 (ArchLinux)

	# Necessário sessão gráfica para instalar esse programa.
	if [[ -z "$DISPLAY" ]]; then
		_red "Necessário sessão gráfica (Xorg) para instalar esse pacote"
		return 1
	fi

	if ! is_executable xterm; then
		__pkg__ xterm
	fi

	# Já instalado?.
	is_executable 'veracrypt' && _show_info 'PkgInstalled' 'veracrypt' && return 0
	
	get_html 'https://www.veracrypt.fr/en/Downloads.html'
	url_package_tar=$(grep -m 1 'download.*.tar' "$HtmlTemporaryFile" | sed 's/.*="//g;s/".*//g;s/&#43;/+/g')
	url_signature_file="${url_package_tar}.sig"	
	VeracryptTarFile="$DirDownloads/$(basename $url_package_tar)"
	VeracryptSigFile="${VeracryptTarFile}.sig"

	__download__ "$url_package_tar" "$VeracryptTarFile" || return 1
	__download__ "$url_signature_file" "$VeracryptSigFile" || return 1
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	
	gpg_import 'https://www.idrix.fr/VeraCrypt/VeraCrypt_PGP_public_key.asc' || return 1
	__gpg__ --verify "$VeracryptSigFile" "$VeracryptTarFile" || return 1
	_unpack "$VeracryptTarFile" || return 1
	cp "$DirUnpack"/$(ls veracrypt*setup-gui-x64) "$DirTemp"/veracrypt-setupx64
	chmod +x "$DirTemp"/veracrypt-setupx64
	
	xterm -title 'Instalando veracrypt' "$DirTemp"/veracrypt-setupx64

	case "$os_id" in
		arch) __pkg__ gtk2;;
	esac

	if is_executable 'veracrypt'; then
		_show_info 'SuccessInstalation' 'veracrypt'
		return 0
	else
		_show_info 'InstalationFailed' 'veracrypt'
		return 1
	fi
}

_woeusb_cli_linux()
{
	local URL_SCRIPT_WOEUSB='https://github.com/WoeUSB/WoeUSB/raw/master/sbin/woeusb'
	local WOEUSB_TEMP_FILE="$DirTemp"/woeusb.tmp

	_print "Baixando ... $WOEUSB_TEMP_FILE"
	_println "Conectando ... $URL_SCRIPT_WOEUSB "
	if is_executable curl; then
		if curl -sSL "$URL_SCRIPT_WOEUSB" -o "$WOEUSB_TEMP_FILE"; then
			_syellow "OK"
		else
			_sred "FALHA"
			return 1
		fi
	elif is_executable wget; then
		if wget -q "$URL_SCRIPT_WOEUSB" -O "$WOEUSB_TEMP_FILE"; then
			_syellow "OK"
		else
			_sred "FALHA"
			return 1
		fi
	fi
	__sudo__ mv "$WOEUSB_TEMP_FILE" '/usr/local/bin/woeusb'
	__sudo__ chmod +x '/usr/local/bin/woeusb'
}

_woeusb_ng_github()
{
	# Instalar WoeUSB-ng apartir do código fonte no github.
	# https://github.com/WoeUSB/WoeUSB-ng
	local REPO_WOEUSB_NG='https://github.com/WoeUSB/WoeUSB-ng.git'
	
	_gitclone "$REPO_WOEUSB_NG" || return 1
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
		__pkg__ "${requeriments_woeusb_ng_debian[@]}"
		__sudo__ pip3 install WoeUSB-ng
	elif [[ -f /etc/fedora-release ]]; then
		__pkg__ "${requeriments_woeusb_ng_fedora[@]}"
		_woeusb_ng_github
	elif [[ "$os_id" == 'arch' ]]; then
		_woeusb_ng_github
	fi

}

_woeusb()
{
	_woeusb_cli_linux
	_woeusb_ng

	if is_executable 'woeusb'; then
		_show_info 'SuccessInstalation' 'woeusb'
		return 0
	else
		_show_info 'InstalationFailed' 'woeusb'
		return 1
	fi
}

_android_studio_zip()
{
	# https://developer.android.com/studio
	local url='https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.1.0/android-studio-ide-192.6241897-linux.tar.gz'
	local hash_android_studio='e754dc9db31a5c222f230683e3898dcab122dfe7bdb1c4174474112150989fd7'
	local path_file="$DirDownloads/$(basename $url)"

	__download__ "$url" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	
	__shasum__ "$path_file" "$hash_android_studio" || return 1
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
		_red "Seu sistema não é baseado em Debian."
		return 1
	fi

	local debianBusterRequeriments=(
		qemu-kvm
		libvirt-clients 
		libvirt-daemon-system
		lib32z1 
		lib32stdc++6 
		lib32gcc1 
		lib32ncurses6 
		lib32tinfo6 
		libc6-i386
		)

	_APT update
	__pkg__ 'openjdk-11-jdk'

	for c in "${debianBusterRequeriments[@]}"; do
		__pkg__ "$c"
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
		qemu-kvm
		libvirt-bin 
		ubuntu-vm-builder 
		bridge-utils
		lib32z1 
		lib32ncurses5 
		lib32stdc++6 
		lib32gcc1 
		lib32tinfo5 
		libc6-i386
		)

	#_APT update
	__pkg__ 'openjdk-8-jdk'

	for c in "${ubuntuBionicRequeriments[@]}"; do
		__pkg__ "$c"
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
			zlib.i686
			ncurses-libs.i686
			bzip2-libs.i686
			)

	__pkg__ "${array_libs_fedora[@]}"

	_android_studio_zip || return 1
}


_android_studio_opensuseleap()
{
	__pkg__ 'java-1_8_0-openjdk-devel' 'qemu-kvm'

	local requerimentsOpenSuse=(
			'libstdc++6-32bit' 
			'zlib-devel-32bit' 
			'libncurses5-32bit' 
			'libbz2-1-32bit'
		)
	__pkg__ "${requerimentsOpenSuse[@]}"
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

	__pkg__ codeblocks || return 1
	__pkg__ make automake gcc 'gcc-c++' 'kernel-devel' || return 1
	# sudo dnf groupinstall "Development Tools" "Development Libraries" 
}

_codeblocks_archlinux()
{
	# https://www.archlinux.org/packages/community/x86_64/codeblocks/
	__pkg__ codeblocks
}


_codeblocks()
{
	case "$os_id" in
		debian|ubuntu) __pkg__ codeblocks 'codeblocks-common' 'codeblocks-contrib' || return 1;;
		fedora) _codeblocks_fedora;;
		archlinux) _codeblocks_archlinux;;
		*) _show_info 'ProgramNotFound' 'codeblocks'; return 1;;
	esac
}

_idea_ic()
{
	is_executable 'idea' && _show_info 'PkgInstalled' 'ideaIC' && return 0
	local idea_url='https://download-cf.jetbrains.com/idea/ideaIC-2020.2.1.tar.gz'
	local idea_sha256='a107f09ae789acc1324fdf8d22322ea4e4654656c742e4dee8a184e265f1b014'
	local path_file="$DirDownloads/$(basename $idea_url)"

	__download__ "$idea_url" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	__shasum__ "$path_file" "$idea_sha256" || return 1
	_unpack "$path_file" || return 1
	cd "$DirUnpack" 
	mv $(ls -d idea-*) idea-IC
	_println "Movendo ... idea-IC => ${destinationFilesIdeaic[dir]} "
	mv idea-IC "${destinationFilesIdeaic[dir]}" || return 1
	_syellow 'OK'
	_print "Entrando no diretório ... ${destinationFilesIdeaic[dir]}"
	cd "${destinationFilesIdeaic[dir]}"
	cp -v ./bin/idea.png "${destinationFilesIdeaic[file_png]}"

	_print "Criando arquivo '.desktop'"
	echo "[Desktop Entry]" > "${destinationFilesIdeaic[file_desktop]}"
	{
		echo -e "Name=IntelliJ IDEA Ultimate Edition"
		echo -e "Version=1.0"
		echo -e "Comment=java"
		echo -e "Icon=${destinationFilesIdeaic[file_png]}"
		echo -e "Exec=${destinationFilesIdeaic[dir]}/bin/idea.sh %f"
		echo -e "Terminal=false"
		echo -e "Categories=Development;IDE"
		echo -e "Type=Application"
	} >> "${destinationFilesIdeaic[file_desktop]}"

	_print "Criando atalho para execução"
	echo -e "#!/bin/sh" > "${destinationFilesIdeaic[file_script]}"
	echo -e "cd ${destinationFilesIdeaic[file_desktop]}/bin" >> "${destinationFilesIdeaic[file_script]}"
	echo -e "./idea.sh \$\@" >> "${destinationFilesIdeaic[file_script]}"
	chmod +x "${destinationFilesIdeaic[file_script]}"

	cp -u "${destinationFilesIdeaic[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesIdeaic[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesIdeaic[file_desktop]}" ~/Desktop/ 2> /dev/null 

	if is_executable idea; then
		_show_info 'SuccessInstalation' 'ideaic'
		return 0
	else
		_show_info 'InstalationFailed' 'ideaic'
		return 1
	fi
}


_pycharm()
{
	# Já instalado.
	is_executable 'pycharm' && _show_info 'PkgInstalled' 'pycharm' && return 0
	local url_pycharm='https://download-cf.jetbrains.com/python/pycharm-community-2020.2.tar.gz'
	local sha256_pycharm='60b2eeea5237f536e5d46351fce604452ce6b16d037d2b7696ef37726e1ff78a'
	local path_file="$DirDownloads/$(basename $url_pycharm)"
	
	__download__ "$url_pycharm" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	__shasum__ "$path_file" "$sha256_pycharm" || return 1
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
	
	_yellow "Obtendo url de download aguarde..."
	sublime_pag='https://www.sublimetext.com/3'
	sublime_html=$(wget -q -O- "$sublime_pag" | grep -m 1 'http.*sublime.*x64.tar.bz2')
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
	__pkg__ vim
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
	echo "#!/bin/sh" > "${destinationFilesVscode[link]}"
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

	cp -u "${destinationFilesVscode[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesVscode[file_desktop]}" ~/Desktop/ 2> /dev/null 
	cp -u "${destinationFilesVscode[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null	
}

_vscode()
{
	# Já instalado.
	is_executable 'code' && _show_info 'PkgInstalled' 'code' && return 0

	case "$os_id" in
		debian|ubuntu|linuxmint) _vscode_tarfile;;
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
		_yellow "Instalando [$c]"
		__pkg__ "$c"		
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
		__pkg__ "$i"
	done

}

_codecs_ubuntu()
{
	__pkg__ --install-recommends ffmpeg ffmpegthumbnailer
	__pkg__ 'ubuntu-restricted-extras'
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

	__pkg__ --install-recommends ffmpeg ffmpegthumbnailer
	__pkg__ lame

	__shasum__ "$path_file" "$hash_wcodecs" || return 1
	
	_msg "Instalando: $path_file"
	_DPKG --install "$path_file" || return 1
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

	_msg "Instalando: ${array_codecs_fedora[@]}"
	__pkg__ "${array_codecs_fedora[@]}"

	_msg "Instalando: ${array_gstreamer_fedora[@]}"	
	__pkg__ "${array_gstreamer_fedora[@]}"
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
		_msg "Instalando" "$x"
		__pkg__ "$x"
	done

	
	for x in "${list_codecs_parole[@]}"; do 
		_msg "Instalando" "$x"
		__pkg__ "$x"
	done
	
}

_codecs()
{
case "$os_id" in
	freebsd12.0-release) __pkg__ ffmpeg ffmpegthumbnailer 'gstreamer-ffmpeg';;
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
	__pkg__ 'celluloid'
}

_cinema()
{
	__pkg__ 'cinema'
}

_gnome_mpv()
{
	if is_executable 'dnf'; then
		__pkg__ 'gnome-mpv' 'smplayer-themes'
	elif [[ -f '/etc/debian_version' ]]; then
		__pkg__ 'gnome-mpv'
	else
		__pkg__ 'gnome-mpv' 
	fi
}

_parole()
{
	__pkg__ parole	
}

_smplayer()
{
	__pkg__ smplayer
}

_spotify_debian()
{
	# https://wiki.debian.org/spotify
	# https://www.spotify.com/br/download/linux/
	# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4773BD5E130D1D45 || return 1
	local url_key_spotify='https://download.spotify.com/debian/pubkey_0D811D58.gpg'
	_isroot || return 1
	_println "(_spotify_debian): adicionando key spotify "
	if ! curl -sS "$url_key_spotify" | sudo apt-key add -; then
		_sred "FALHA"
		_print "Visite 'https://www.spotify.com/br/download/linux/' para instalar spotify manualmente."
		return 1
	fi

	_println "Adicioando repositório spotify "	
	echo 'deb http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list
	_APT update || return 1
	__pkg__ 'spotify-client'
}

_spotify_ubuntu()
{
	# https://www.spotify.com/br/download/linux/
	# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 4773BD5E130D1D45 || return 1
	local url_key_spotify='https://download.spotify.com/debian/pubkey_0D811D58.gpg'
	_isroot || return 1
	_println "(_spotify_ubuntu): adicionando key spotify "
	if ! curl -sS "$url_key_spotify" | sudo apt-key add -; then
		_sred "FALHA"
		_print "Visite 'https://www.spotify.com/br/download/linux/' para instalar spotify manualmente."
		return 1
	fi

	_println "Adicioando repositório spotify "	
	echo 'deb http://repository.spotify.com stable non-free' | sudo tee /etc/apt/sources.list.d/spotify.list
	_APT update || return 1
	__pkg__ 'spotify-client'
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
		_msg "Instalando: $X"
		__pkg__ "$X"
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

	is_executable flatpak || __pkg__ flatpak

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
	__pkg__ totem
}

_vlc_fedora()
{
	local repos_fusion_free='https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release'
	local repos_fusion_non_free='https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release'
	print_line
	_yellow "Adicionando os seguintes repositórios: "
	_print "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm"
	_print "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm"
	_print "fedora-workstation-repositories"
	print_line

	_DNF install "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm"
	_DNF install "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm" 
	_DNF install fedora-workstation-repositories 

	__pkg__ vlc 'python-vlc' || return 1
}

_vlc()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) __pkg__ vlc;;
		'opensuse-leap') __pkg__ vlc;;
		fedora) _vlc_fedora;;
		arch) __pkg__ vlc;;
	esac

	if is_executable 'vlc'; then
		_show_info 'SuccessInstalation' 'vlc'
	else
		_show_info 'InstalationFailed' 'vlc'
	fi
}

_atril()
{
	__pkg__ atril
}

_ubuntu_msttcorefonts()
{
	local url_msttcorefonts='http://ftp.us.debian.org/debian/pool/contrib/m/msttcorefonts/ttf-mscorefonts-installer_3.7_all.deb'
	local path_file="$DirDownloads/$(basename $url_msttcorefonts)"

	__download__ "$url_msttcorefonts" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0
	 
	__pkg__ cabextract || return 1
	_DPKG --install "$path_file" || return 1
	return 0

}

_fontes_microsoft()
{
	case "$os_id" in
		linuxmint|ubuntu) _ubuntu_msttcorefonts;;
		debian) __pkg__ msttcorefonts 'ttf-mscorefonts-installer';;
		fedora) __pkg__ 'mscore-fonts';;
		'opensuse-tumbleweed'|'opensuse-leap') __pkg__ fetchmsttfonts;;
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
	case "$lang" in
		pt_BR.UTF-8) ;;
		pt_BR.utf8) ;;
		*) return 0;;
	esac

	case "$os_id" in
		debian) __pkg__ 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		ubuntu|linuxmint) __pkg__ 'libreoffice-help-pt-br' 'libreoffice-l10n-pt-br';;
		fedora) __pkg__ 'libreoffice-langpack-pt-BR';;
		'open-suse') __pkg__ 'libreoffice-l10n-pt_BR';;
		arch) __pkg__ 'libreoffice-fresh-pt-br';;
		freebsd) __pkg__ 'pt_BR-libreoffice';;
	esac
}

_libreoffice()
{
	case "$os_id" in 
		debian|ubuntu|linuxmint) __pkg__ libreoffice;;
		fedora) __pkg__ libreoffice;;
		'open-suse') __pkg__ 'libreoffice-l10n-pt_BR';;
		arch) __pkg__ libreoffice;;
		freebsd) __pkg__ libreoffice;;
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
		debian) __pkg__ 'chromium-l10n';;
		ubuntu) __pkg__ 'chromium-browser-l10n';;
		*) return 0;;
	esac
}

_chromium()
{
	case "$os_id" in
		debian) __pkg__ chromium;;
		ubuntu|linuxmint) __pkg__ 'chromium-browser';;
		fedora) __pkg__ chromium;;
		arch) __pkg__ chromium;;
		'opensuse-tumbleweed'|'opensuse-leap') __pkg__ chromium;; 
		freebsd12) __pkg__ chromium;;
		*) _show_info 'ProgramNotFound' 'chromium'; return 1;;
	esac

	_chromium_lang # Instalar pacote de idioma ptbr.
}


_edge()
{
	# https://www.microsoftedgeinsider.com/pt-br/download/
	if [[ "$os_id" == 'fedora' ]]; then
		_RPM --import https://packages.microsoft.com/keys/microsoft.asc || return 1
		_DNF config-manager --add-repo https://packages.microsoft.com/yumrepos/edge || return 1
		__sudo__ mv /etc/yum.repos.d/packages.microsoft.com_yumrepos_edge.repo /etc/yum.repos.d/microsoft-edge-dev.repo
		__pkg__ microsoft-edge-dev
	elif [[ -f /etc/debian_version ]]; then
		_println "Adicionando key ... https://packages.microsoft.com/keys/microsoft.asc "
		curl -sSLf https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
		_println "Adicionando repositório ... "
		echo "deb [arch=amd64] https://packages.microsoft.com/repos/edge stable main" | sudo tee /etc/apt/sources.list.d/microsoft-edge-dev.list
		_APT update || return 1
		__pkg__ microsoft-edge-dev
	else
		_show_info 'ProgramNotFound' 'edge' 
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
	
	case "$os_id" in
		arch) __pkg__ 'firefox-i18n-pt-br';;
		debian) __pkg__ 'firefox-esr-l10n-pt-br';;
		ubuntu) __pkg__ 'firefox-locale-pt';;
	esac
}

_firefox()
{
	case "$os_id" in
		arch) __pkg__ firefox;;
		debian) __pkg__ 'firefox-esr';;
		ubuntu|linuxmint) __pkg__ firefox;;
		fedora) __pkg__ 'firefox.x86_64' 'mozilla-ublock-origin.noarch';;
		'opensuse-leap') __pkg__ MozillaFirefox;;
		*) _show_info 'ProgramNotFound' 'firefox'; return 1;;
	esac

	_firefox_lang
}

_google_chrome_debian()
{
	local google_chrome_repo='deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
	local url_key_google_chrome='https://dl.google.com/linux/linux_signing_key.pub'
	local google_chrome_file='/etc/apt/sources.list.d/google-chrome.list'
	local google_chrome_path_key="$DirTemp/linux_signing_key.pub"	
	
	# Baixar e adicionar o arquivo '.pub'
	_isroot || return 1
	_println "Executando ... curl -sSL $url_key_google_chrome | sudo apt-key add - "
	if ! curl -sSL "$url_key_google_chrome" | sudo apt-key add -; then
		_sred "FALHA"
		return 1
	fi
	
	find /etc/apt -name *.list | xargs grep "^deb .*http.*google\.com/linux/chrome/deb/.*stable main" 2> /dev/null
	if [[ $? == '0' ]]; then
		_yellow "Repositório google-chrome encontrado pulando..."
	else
		_println "Adicionando repositório ... "
		echo "$google_chrome_repo" | sudo tee "$google_chrome_file"
	fi
	# sudo apt install libu2f-udev
	_APT update || return 1
	__pkg__ 'google-chrome-stable' 
}


_google_chrome_fedora()
{
	# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
	# sudo dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	{
		_DNF install -y fedora-workstation-repositories
		_DNF config-manager --set-enabled google-chrome
		__pkg__ 'google-chrome-stable'
	} || _DNF install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
}

_google_chrome_opensuse()
{
	# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-openSUSE-Leap-15
	# wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	_yellow "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	_yellow "Adicionando repositório: http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	__pkg__ 'google-chrome-stable'
}

_google_chrome_tumbleweed()
{
	_white "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	_white "Adicionando repositório [http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google]"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	__pkg__ 'google-chrome-stable'
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
	cd "$DirGitclone"/google-chrome
	__pkg__ "base-devel" pipewire
	 
	_msg "Executando: makepkg -s"
	cd "$DirGitclone/google-chrome"
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
	sudo sh -c 'wget -q http://deb.opera.com/archive.key -O- | apt-key add -' || return 1
	
	find /etc/apt -name *.list | xargs grep "^deb .*deb\.opera.* stable.*free$" 2> /dev/null

	if [[ $? == '0' ]]; then
		_white "Repositório já está disponível 'pulando'"
	else
		_white "Adicionando repositório"
		echo "$opera_repo" | sudo tee "$opera_file"
	fi
	_APT update
	__pkg__ 'opera-stable' || return 1	
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

	__pkg__ 'opera-stable'
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
	__pkg__ 'opera-stable'  || return 1
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
	# local url_script_torbrowser_installer='https://raw.github.com/Brunopvh/torbrowser/master/tor.sh'
	if [[ "$DownloadOnly" == 'True' ]]; then
		_print "Executando $SCRIPT_TORBROWSER_INSTALLER --install --downloadonly"
		"$SCRIPT_TORBROWSER_INSTALLER" --install --downloadonly
	else
		_print "Executando $SCRIPT_TORBROWSER_INSTALLER --install"
		"$SCRIPT_TORBROWSER_INSTALLER" --install
	fi
}

_clipgrab_appimage()
{
	# Instalar o clipgrab na versão AppImage.
	if is_executable clipgrab; then
		_show_info 'PkgInstalled' 'clipgrab'
		return 0
	fi

	local url_clipgrab_appimage='https://download.clipgrab.org/ClipGrab-3.8.13-x86_64.AppImage'
	local path_file="$DirDownloads/$(basename $url_clipgrab_appimage)"

	__download__ "$url_clipgrab_appimage" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	cp -u "$path_file" "$DIR_BIN_USER"/clipgrab
	chmod +x "$DIR_BIN_USER"/clipgrab
	clipgrab&

	if is_executable clipgrab; then
		_show_info 'SuccessInstalation' 'clipgrab'
		return 0
	else
		_show_info 'InstalationFailed' 'clipgrab'
		return 1
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
	__pkg__ megasync || return 1	
}

_megasync_debian()
{
	local url_key_megasync='https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key'
	local mega_repos="deb https://mega.nz/linux/MEGAsync/Debian_10.0/ ./"	
	local mega_file_list="/etc/apt/sources.list.d/megasync.list"

	if [[ "$os_codename" != 'buster' ]]; then
		_red "A instalação de MegaSync não está disponível para o seu sistema"
		return 1
	fi

	_println "Executando ... curl -sSL $url_key_megasync | sudo apt-key add - "
	if ! curl -sSL "$url_key_megasync" | sudo apt-key add -; then
		_sred "FALHA"
		return 1
	fi

	find /etc/apt -name *.list | xargs grep "^deb https.*mega.nz.*Debian.*" 2> /dev/null
	if [[ $? == '0' ]]; then
		_yellow "Repositório megasync encontrado pulando..."
	else
		_println "Adicionando repositório ... "	
		echo "$mega_repos" | sudo tee "$mega_file_list"
	fi
	_APT update
	__pkg__ megasync || return 1
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
		focal|ulyana)
			mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_20.04/ ./"
			mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_20.04/Release.key'
			;;
		*)
			_show_info 'ProgramNotFound' 'megasync' 
			return 1
			;;
	esac

	_msg "Adicionando key e repositório"
	wget -q -O- "$mega_url_key" -o- | sudo apt-key add - || return 1
	echo "$mega_repos_ubuntu" | sudo tee "$mega_file_list" 1> /dev/null
	_APT update 
	__pkg__ 'libc-ares2' libmediainfo0v5 
	__pkg__ megasync
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

	__pkg__ megasync
}

_libpdfium_archlinux()
{
	local repos_libpdfium='https://aur.archlinux.org/libpdfium-nojs.git'
	_gitclone "$repos_libpdfium" || return 1
	_print "Entrando no diretório ... $DirGitclone/libpdfium-nojs"
	cd "$DirGitclone/libpdfium-nojs"
	_msg "Executando ... makepkg -s"
	makepkg -s
	_msg "Executando sudo pacman -U $(ls libpdfium-*x86_64.pkg.tar*)"
	_PACMAN -U --noconfirm $(ls libpdfium-*x86_64.pkg.tar*) 
}

_megasync_archlinux()
{
	# https://unix.stackexchange.com/questions/200311/how-to-install-megasync-client-in-arch-based-antergos-linux
	# https://oxylabs.directorioforuns.com/t6-como-instalar-o-megasync-no-arch-linux
	# https://github.com/meganz/MEGAsync/archive/master.tar.gz
	# git clone --recursive https://github.com/meganz/MEGAsync.git

	# Obter url de download dos pacotes.
	get_html 'https://mega.nz/linux/MEGAsync/Arch_Extra/x86_64'
	HTML_MEGASYNC=$(grep -m 1 'megasync.*pkg.tar.zst' "$HtmlTemporaryFile")
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
		__pkg__ "$app"
	done
	_libpdfium_archlinux

	# Baixar o pacote de instalação e o arquivo .sig do repositório MEGA.
	gpg_import "$URL_MEGA_KEY" || return 1
	__download__ "$URL_MEGA_TARFILE" "$PATH_MEGA_TARFILE" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	# Verificar integridade do pacote baixado.
	_print "Conectando ... $URL_MEGA_SIGNATURE_FILE"
	curl -sSL "$URL_MEGA_SIGNATURE_FILE" -o "$PATH_MEGA_SIGNATURE_FILE" || return 1
	__gpg__ --verify "$PATH_MEGA_SIGNATURE_FILE" "$PATH_MEGA_TARFILE" || return 1
	rm -rf "$PATH_MEGA_SIGNATURE_FILE" 2> /dev/null

	# Copiar o instalador para o diretório temporário e em seguida instalar o pacote.
	cp "$PATH_MEGA_TARFILE" "$DirTemp/megasync-x86_64.pkg.tar.xz.zst" || return 1
	_print "Entrando no diretório ... $DirTemp"
	cd "$DirTemp"
	_PACMAN -U megasync-x86_64.pkg.tar.xz.zst
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
	local URL_TOR_ASC='https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc'
	local TOR_FILE_SOURCE_LIST='/etc/apt/sources.list.d/torproject.list'

	if [[ "$os_codename" == 'bionic' ]] || [[ "$os_codename" == 'tricia' ]]; then  # Ubuntu bionic
		TOR_REPO_MAIN='deb https://deb.torproject.org/torproject.org bionic main'
	elif [[ "$os_codename" == 'buster' ]]; then                                  # Debian buster
		TOR_REPO_MAIN='deb https://deb.torproject.org/torproject.org buster main'
	else
		_show_info 'ProgramNotFound' 'tor'
		return
	fi

	_println "Executando ... curl -sSL $URL_TOR_ASC | sudo gpg --import "
	if curl -sSL "$URL_TOR_ASC" | sudo gpg --import 1> /dev/null 2>&1; then
		echo "OK"
	else
		_sred "FALHA"
		return 1
	fi
	
	_println "Executando ... gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add - "
	if ! sudo sh -c 'gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -'; then
		_sred "FALHA"
		return 1
	fi

	# Verificar se o repositório já exite no diretório ou subdiretório /etc/apt.
	find /etc/apt -name *.list | xargs grep '^deb https.*deb.torproject.org/torproject.org buster main'
	if [[ $? == '0' ]]; then
		_yellow "Repositório encontrado pulando..."
	else
		_println "Adicionando repositório "
		echo "$TOR_REPO_MAIN" | sudo tee "$TOR_FILE_SOURCE_LIST" 
	fi
	_APT update
	__pkg__ tor deb.torproject.org-keyring
	__pkg__ proxychains || return 1
}

_tor_fedora()
{
	case "$os_version" in
		32) __pkg__ tor;;
		*) _show_info 'ProgramNotFound' 'tor';;
	esac

	__pkg__ proxychains || return 1
}

_proxychains()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _tor_debian;;
		arch) __pkg__ 'proxychains-ng' 'tor';;
		fedora) _tor_fedora;;
		*) _show_info 'ProgramNotFound' 'proxychains tor';;
	esac
}

_qbittorrent()
{
	__pkg__ qbittorrent || return 1
}

_skype_debian()
{
	local skype_url='https://go.skype.com/skypeforlinux-64.deb'
	local path_file="$DirDownloads/$(basename $skype_url)"

	__download__ "$skype_url" "$path_file" || return 1
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	_APT install "$path_file" || return 1
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
	local tw_html=$(wget -q -O- "$tw_pag" | grep "download.*linux.*64")
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
		__pkg__ "$i" 
	done
	_DPKG --install "$path_file" || _BROKE # Remover pacotes quebrados.
}

_install_teamviewer_fedora()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/' # Página de download.
	local tw_html=$(wget -q -O- "$tw_pag" | grep "download.*linux.*64")
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


	# Instalar dependências
	__pkg__ 'qt5-qtquickcontrols'
	_RPM --install "$path_file" || return 1
}


_teamviewer_tar()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/'      # Página de download.
	local tw_html=$(wget -q -O- "$tw_pag" | grep "download.*linux.*64")
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
	case "$os_id" in
		'opensuse-tumbleweed'|'opensuse-leap') __pkg__ gconf2;;
		ubuntu|linuxmint|debian) __pkg__ gconf2;;
		fedora) __pkg__ GConf2;;
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

	# Salvar o html da pagina de download no arquivo html temporário padrão. 
	# Ver a variável "HtmlTemporaryFile".
	get_html 'https://www.tixati.com/download/linux.html' || return 1
	local tixati_html=$(grep -m 1 'tixati.*64.*tar.gz' "$HtmlTemporaryFile")
	local url_tarfile=$(echo "$tixati_html" | sed 's/gz".*/gz/g;s/.*="//g')
	local url_signature_file="${url_tarfile}.asc"
	local TarFile="$DirDownloads/$(basename $url_tarfile)"
	local signatureFile="${TarFile}.asc"

	__download__ "$url_tarfile" "$TarFile" || return 1
	__download__ "$url_signature_file" "$signatureFile" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0 

	# Importar key com a função gpg_import
	gpg_import https://www.tixati.com/tixati.key || return 1

	# verificar integridade com a fução __gpg__
	__gpg__ --verify "$signatureFile" "$TarFile" || return 1

	# Instalar gconf2.
	case "$os_id" in
		'opensuse-tumbleweed'|'opensuse-leap') __pkg__ gconf2;;
		ubuntu|linuxmint|debian) __pkg__ gconf2;;
		fedora) __pkg__ GConf2;;
	esac	

	_unpack "$TarFile" || return 1
	cd "$DirUnpack"
	mv $(ls -d tixati*) tixati-amd64 
	sudo chown -R root:root tixati-amd64
	cd "$DirUnpack/tixati-amd64"

	sudo mv tixati.desktop "${destinationFilesTixati[file_desktop]}" # .desktop
	sudo mv tixati.png "${destinationFilesTixati[file_png]}"         # PNG.
	sudo mv tixati "${destinationFilesTixati[file_bin]}"             # bin.
	
	sudo chmod a+x "${destinationFilesTixati[file_desktop]}"
	sudo chmod a+x "${destinationFilesTixati[file_bin]}"

	cp -u "${destinationFilesTixati[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesTixati[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesTixati[file_desktop]}" ~/Desktop/ 2> /dev/null

	# Definir tixati como gerenciador bittorrent padrão.
	if _YESNO "Deseja usar tixati como bittorrent padrão"; then
		_yellow "Definindo tixati como padrão"
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/command 'tixati "%s"'
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/enabled true
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/need-terminal false
	fi

	if is_executable gtk-update-icon-cache; then
		sudo gtk-update-icon-cache
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
	__pkg__ uget 
}


_youtube_dl()
{
	# https://youtube-dl.org/
	# http://ytdl-org.github.io/youtube-dl/download.html
	# https://youtube-dl.org/downloads/latest/youtube-dl-2019.11.28.tar.gz
	# https://github.com/ytdl-org/youtube-dl/releases/download/2019.11.28/youtube-dl-2019.11.28.tar.gz.sig
	# https://yt-dl.org/downloads/latest/youtube-dl

	# Já instalado.
	#is_executable "$DIR_BIN_USER/youtube-dl" && _show_info 'PkgInstalled' "youtube-dl" && return 0

	local URL_YOUTUBE_DL_LATEST='https://yt-dl.org/downloads/latest/youtube-dl'
	local URL_YOUTUBE_DL_SIG='https://yt-dl.org/downloads/latest/youtube-dl.sig'
	local URL_ASC_SERGEY='https://dstftw.github.io/keys/18A9236D.asc'

	local PATH_SIGNATURE_FILE="$DirDownloads/youtube-dl.sig"
	local PATH_YTDL="$DirDownloads/youtube-dl"   
	local hash_sig='04d2edc85b80b59ffe46fdda3937b0074dfe10ede49fec6c36c609cd87841fcb' # sha256sum - .sig
	
	__download__ "$URL_YOUTUBE_DL_LATEST" "$PATH_YTDL" || return 1 
	__download__ "$URL_YOUTUBE_DL_SIG" "$PATH_SIGNATURE_FILE" || return 1 
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$PATH_YTDL" && return 0

	gpg_import 'https://dstftw.github.io/keys/18A9236D.asc' || return 1
	
	# Verificar integridade do script youtube-dl.
	__gpg__ --verify "$PATH_SIGNATURE_FILE" "$PATH_YTDL" || return 1
	
	_msg "Instalando youtube-dl em ~/.local/bin"
	cp -u "$PATH_YTDL" "$DIR_BIN_USER"/youtube-dl
	chmod a+x "$DIR_BIN_USER"/youtube-dl

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

	echo '[Desktop Entry]' > "${destinationFilesYoutubeDlGuiUser[file_desktop]}"
	{
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=youtube-dl-gui"
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
	# Criar arquivo desktop para todos os usuarios.
	local file_desktop_youtube_dl_gui='/usr/share/applications/youtube-dl-gui.desktop' # .desktop

	_show_info "AddFileDesktop"
	{
		echo '[Desktop Entry]'
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=/usr/bin/youtube-dl-gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} | sudo tee "$file_desktop_youtube_dl_gui" 

	_yellow "Criando atalho na Área de Trabalho"
	cp -u "$file_desktop_youtube_dl_gui" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "$file_desktop_youtube_dl_gui" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "$file_desktop_youtube_dl_gui" ~/Desktop/ 2> /dev/null
	is_executable gtk-update-icon-cache && __sudo__ gtk-update-icon-cache
}

_youtube_dlgui_compile()
{
	# Baixar e compilar o codigo fonte do youtube-dl-gui no github.
	# Instalação no sistema em /usr/local/bin/youtube-dl-gui 
	local url_youtube_dl_gui_master='https://github.com/MrS0m30n3/youtube-dl-gui/archive/master.zip'
	local path_file="$DirDownloads/youtube-dl-gui.zip"

	__download__ "$url_youtube_dl_gui_master" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 

	_unpack "$path_file" || return 1
	cd "$DirUnpack"/youtube-dl-gui-master || return 1
	_msg "Compilando youtube-dl-gui"
	
	if is_executable python2; then
		sudo python2 setup.py install 1> /dev/null || return 1
	elif is_executable python2.7; then
		sudo python2.7 setup.py install 1> /dev/null || return 1
	elif is_executable python27; then
		sudo python27 setup.py install 1> /dev/null || return 1
	fi
		
	# Criar o arquivo ".desktop" após compilar o programa.
	_youtube_dlgui_file_desktop_root
	_youtube_dlgui_file_desktop_user
	return 0
}

_youtube_dlgui_user_installer()
{
	local url_youtube_dl_gui_master='https://github.com/MrS0m30n3/youtube-dl-gui/archive/master.zip'
	local path_file="$DirDownloads/youtube-dl-gui.zip"
	
	__download__ "$url_youtube_dl_gui_master" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar
	_unpack "$path_file" || return 1

	_yellow "Copiando arquivos"
	mkdir -p "${destinationFilesYoutubeDlGuiUser[pixmaps]}"
	cd "$DirUnpack"/youtube-dl-gui-master
	cp -R -u youtube_dl_gui "${destinationFilesYoutubeDlGuiUser[dir]}"
	cd "${destinationFilesYoutubeDlGuiUser[dir]}"
	cp -R -u data/icons/hicolor/128x128/apps/youtube-dl-gui.png "${destinationFilesYoutubeDlGuiUser[file_png]}"
	cp -R -u data/pixmaps/. "${destinationFilesYoutubeDlGuiUser[pixmaps]}"/. 

	# Criar script para execução via linha de comando
	echo -e "#!/bin/sh" > "${destinationFilesYoutubeDlGuiUser[file_script]}"
	echo -e "\ncd ${destinationFilesYoutubeDlGuiUser[dir]}" >> "${destinationFilesYoutubeDlGuiUser[file_script]}"

	if is_executable python2; then
		echo -e "python2 __main__.py" >> "${destinationFilesYoutubeDlGuiUser[file_script]}"
	elif is_executable python; then
		echo -e "python __main__.py" >> "${destinationFilesYoutubeDlGuiUser[file_script]}"
	else
		_red "Necessário ter o 'python 2' instalado em seu sistema."
		return 1
	fi

	chmod +x "${destinationFilesYoutubeDlGuiUser[file_script]}" 
	_youtube_dlgui_file_desktop_user
	return 0
}

_youtube_dlgui_pip() 
{
	# ppa ubuntu.
	# sudo sh -c 'add-apt-repository ppa:nilarimogard/webupd8; apt update'
	# sudo apt install youtube-dlg --yes
	__pkg__ 'python-wxgtk3.0' gettext 'python-pip' 'python-twodict' || return 1
	pip install wheel --user
	pip install 'youtube-dlg' --user || return 1
	_youtube_dlgui_file_desktop_user
	return 0
} 

_youtube_dlgui_ubuntu()
{
	# https://github.com/MrS0m30n3/youtube-dl-gui.git
	case "$os_codename" in
		bionic|tricia) 
			_youtube_dlgui_pip || return 1
			;;
		eoan|focal|ulyana)
			__pkg__ 'python-wxgtk3.0' gettext || return 1
			_python_twodict_github || return 1
			_youtube_dlgui_compile || return 1
			;;
		*)
			_show_info 'ProgramNotFound' 'youtube-dl-gui'	
			return 1
			;;
	esac

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
	local f_packages='https://download-ib01.fedoraproject.org/pub/fedora/linux/releases/31/Everything/x86_64/os/Packages/p'
	local wxpython_rpm='python2-wxpython-3.0.2.0-26.fc31.x86_64.rpm'
	local url="$f_packages/$wxpython_rpm"
	local path_file="$DirDownloads/$wxpython_rpm"
	
	# Instalar dependências.
	if [[ "$os_version" == '32' ]] || [[ "$os_version" == '33' ]]; then
		__pkg__ 'wxGTK3' 'wxGTK3-gl' 'wxGTK3-media' 'python2' || return 1
		__download__ "$url" "$path_file" || return 1 
		#_RPM --install "$path_file" 
		_DNF install "$path_file"
	else
		_show_info 'ProgramNotFound' 'youtube-dlg-gui'
		return 1
	fi
	
	_python_twodict_github || return 1
	_youtube_dlgui_compile || return 1
	return 0
}

_youtube_dlgui_debian()
{
	# Testado apenas no debian 10.
	if [[ "$os_codename" == 'buster' ]]; then
		__pkg__ python python-pip python-setuptools python-wxgtk3.0 python-twodict gettext || return 1
		
	else
		_show_info 'ProgramNotFound' 'youtube-dlg-gui'
		return 1
	fi

	__sudo__ pip install wheel
	_youtube_dlgui_compile || return 1

}

_youtube_dlgui_archlinux()
{
	_msg "Instalando: python2 python2-pip python2-setuptools python2-wxpython3"
	__pkg__ python2 python2-pip python2-setuptools python2-wxpython3 || return 1
	_python_twodict_github || return 1
	_youtube_dlgui_compile || return 1
	return 0
}


_youtube_dlgui_freebsd()
{
	# freebsd-12.0-release sudo pkg install py27-wxPython30
	_yellow "Instalando: py27-wxPython30"
	__pkg__ py27-wxPython30 || return 1
	_python_twodict_github || return 1
	_gitclone 'https://github.com/MrS0m30n3/youtube-dl-gui.git' || return 1
	cd "$DirTemp/youtube-dl-gui"
	sudo python2.7 setup.py install || return 1
	return 0
}

_youtube_dlgui()
{
	if [[ -f /etc/debian_version ]]; then
		if [[ "$os_codename" == 'buster' ]]; then
			_youtube_dlgui_debian || return 1
		elif [[ "$os_id" == 'ubuntu' ]] || [[ "$os_id" == 'linuxmint' ]]; then
			_youtube_dlgui_ubuntu || return 1
		fi
	elif [[ "$os_id" == 'fedora' ]]; then
		_youtube_dlgui_fedora || return 1
	elif [[ "$os_id" == 'arch' ]]; then
		_youtube_dlgui_archlinux || return 1
	else
		_show_info 'ProgramNotFound' 'youtube-dl-gui'; return 1
	fi
	
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

	__pkg__ bluez 'bluez-firmware' 'bluez-hcidump'
	print_line
	_white "1 - ${CGreen}G${CReset}NOME"
	_white "2 - ${CGreen}K${CReset}DE"
	_white "3 - ${CGreen}L${CReset}XDE/${CGreen}X${CReset}FCE/${CGreen}L${CReset}XQT/${CGreen}M${CReset}ATE"
	
	while true; do

		_white "Selecione a sua interface gráfica: ${CGreen}(1 / 2 / 3): ${CReset}" 
		read -t 10 -n 1 desktop; echo ' '

		case "${desktop,,}" in
			1) __pkg__ 'gnome-bluetooth';;
			2) __pkg__ bluedevil;;
			3) __pkg__ blueman;;
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

_bspwm_config()
{
	# Esta função deve ser executada depois de instalar o bspwm e suas dependências.
	# https://github.com/windelicato/dotfiles/wiki/bspwm-for-dummies
	# https://ricebr.github.io/Not-A-Blog//instalando-e-configurando-bspwm/
	touch ~/.xinitrc

	_print "Criando diretórios ... ~/.config/{bspwm,sxhkd}"
	mkdir -p ~/.config/{bspwm,sxhkd}
	cp -vr /usr/share/doc/bspwm/examples/bspwmrc ~/.config/bspwm
	cp -vr /usr/share/doc/bspwm/examples/sxhkdrc ~/.config/sxhkd

	grep 'xsetroot -cursor_name left_ptr &' ~/.config/bspwm/bspwmrc || {
		_print "Configurando ... ~/.config/bspwm/bspwmrc"
		echo 'xsetroot -cursor_name left_ptr &' >> ~/.config/bspwm/bspwmrc
	} 

	grep 'exec bspwm' ~/.xinitrc || {
		_print "Configurando ... ~/.xinitrc"
		echo 'exec bspwm' >> ~/.xinitrc
	}

	chmod +x ~/.config/bspwm/bspwmrc
}


_bspwm()
{
	
	case "$os_id" in
		fedora) __pkg__ bspwm sxhkd xsetroot st;;
		*) _show_info "ProgramNotFound"; return 1;;
	esac

	_bspwm_config
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
		__pkg__ "${compactadores_fedora[@]}"
	elif is_executable 'dnf'; then
		__pkg__ "${compactadores_fedora[@]}"
	elif is_executable 'apt'; then
		__pkg__ "${compactadores_debian[@]}"
	elif is_executable 'pacman'; then
		__pkg__ "${compactadores_arch[@]}"
	else
		_show_info 'ProgramNotFound' 'compactadores'
		return 1
	fi
}

_firmware()
{
	if [[ "$os_id" != 'debian' ]]; then
		_red "Este pacote está disponível apenas para sistemas Debian"
		return 1
	fi

	case "$1" in
		firmware-ralink) __pkg__ 'firmware-ralink';;
		firmware-atheros) __pkg__ 'firmware-atheros';;
		firmware-realtek) __pkg__ 'firmware-realtek';;
		firmware-linux-nonfree) __pkg__ 'firmware-linux-nonfree';;
	esac
}

_cpux_appimage()
{
	local URL_CPUX_APPIMAGE='https://github.com/X0rg/CPU-X/releases/download/v4.0.1/CPU-X-v4.0.1-x86_64.AppImage'
	local path_cpux_appimage="$DirDownloads/$(basename $URL_CPUX_APPIMAGE)"
	
	is_executable cpux && _show_info 'PkgInstalled' 'cpux' && return 0
	
	__download__ "$URL_CPUX_APPIMAGE" "$path_cpux_appimage" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
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
		_show_info 'PkgInstalled' 'cpu-x'
		return 0
	else
		_show_info 'InstalationFailed' 'cpux'
		return 1
	fi
}

_cpux()
{
	# https://github.com/X0rg/CPU-X
	if [[ -f /etc/fedora-release ]]; then
		__pkg__ cpu-x
	else
		_cpux_appimage
	fi
}

_google_earth_debian()
{
	# https://sempreupdate.com.br/como-instalar-o-google-earth-no-ubuntu-18-04-e-linux-mint-19/
	url_google_earth='http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb'
	path_file="$DirDownloads/$(basename $url_google_earth)"
	__download__ "$url_google_earth" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	_APT install "$path_file" || return 1
	return 0
}

_google_earth_fedora()
{
	# https://edpsblog.wordpress.com/2013/06/25/google-earth-no-debian-fedora-e-opensuse/
	url_google_earth='http://dl.google.com/dl/earth/client/current/google-earth-stable_current_x86_64.rpm'
	path_file="$DirDownloads/$(basename $url_google_earth)"
	__download__ "$url_google_earth" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
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
		_show_info 'ProgramNotFound' 'google-earth'
		return 1 
	fi
}

_gparted()
{
	__pkg__ gparted
}

_peazip()
{
	# 'http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
	# https://github.com/peazip/PeaZip/releases/download/7.4.2/peazip_portable-7.4.2.LINUX.x86_64.GTK2.tar.gz
	# https://peazip.github.io/peazip-linux.html

	# Já instalado
	is_executable 'peazip' &&  _show_info 'PkgInstalled' 'peazip' && return 0
	local peazip_download_page='http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
	local path_file="$DirDownloads/$(basename $peazip_download_page)"

	__download__ "$peazip_download_page" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar 
	
	_unpack "$path_file" || return 1
	_print "Entrando no diretório ... $DirUnpack"
	cd "$DirUnpack"
	mv -v $(ls -d peazip*) "peazip-amd64" 1> /dev/null || return 1
	__sudo__ mv "$DirUnpack/peazip-amd64" "${destinationFilesPeazip[dir]}"
	__sudo__ chown -R root:root "${destinationFilesPeazip[dir]}"
	__sudo__ chmod a+x "${destinationFilesPeazip[dir]}"/peazip
	_print "Entrando no diretório ... ${destinationFilesPeazip[dir]}"
	cd "${destinationFilesPeazip[dir]}" 
	__sudo__ cp -u FreeDesktop_integration/peazip.png "${destinationFilesPeazip[file_png]}"     
	# __sudo__ cp -u FreeDesktop_integration/peazip.desktop "${destinationFilesPeazip[file_desktop]}"

	_yellow "Criando arquivo '.desktop'"
	{
		echo '[Desktop Entry]'
		echo 'Version=1.0'
		echo 'Encoding=UTF-8'
		echo 'Name=PeaZip'
		echo 'MimeType=application/x-gzip;application/x-tar;application/x-deb;bzip;application/x-rar'
		echo 'GenericName=Archiving Tool'
		echo 'Exec=peazip %F'
		echo "Icon=${destinationFilesPeazip[file_png]}"
		echo 'Type=Application'
		echo 'Terminal=false'
		echo 'X-KDE-HasTempFileOption=true'
		echo 'Categories=GTK;KDE;Utility;System;Archiving;'
	} | sudo tee -a "${destinationFilesPeazip[file_desktop]}" 1> /dev/null
                               
	_yellow "Criando script para execução via linha de comando"
	{
		echo -e "#!/bin/sh\n"
		echo -e "cd ${destinationFilesPeazip[dir]}"
		echo -e "./peazip \$@"
	} | sudo tee "${destinationFilesPeazip[script]}" 1> /dev/null
	__sudo__ chmod a+x "${destinationFilesPeazip[script]}"

	_show_info 'AddFileDesktop'
	cp -u "${destinationFilesPeazip[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesPeazip[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesPeazip[file_desktop]}" ~/Desktop/ 2> /dev/null

	is_executable 'gtk-update-icon-cache' && sudo gtk-update-icon-cache

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
		debian|ubuntu|linuxmint|arch) __pkg__ refind;;
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

	_APT install -y "$path_file"
}

_stacer_fedora()
{
	__pkg__ stacer	
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
	cp -u "${destinationFilesStacer[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesStacer[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesStacer[file_desktop]}" ~/Desktop/ 2> /dev/null

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
		fedora) _stacer_fedora;;
		arch) 
			__pkg__ 'qt5-charts' 'hicolor-icon-theme' 'qt5-declarative' 'qt5-declarative' 'qt5-tools'
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
	
	get_html "https://www.virtualbox.org/wiki/Downloads"
	virtualbox_html=$(grep -m 1 "Oracle.*Ext.*vbox.*" "$HtmlTemporaryFile")
	virtualbox_url_extension_pack=$(echo "$virtualbox_html" | sed 's/.*href="//g;s/">.*//g')
	local path_file="$DirDownloads/$(basename $virtualbox_url_extension_pack)"

	__download__ "$virtualbox_url_extension_pack" "$path_file" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	# Instalação
	__sudo__ VBoxManage extpack install --replace "$path_file"

	_YESNO "Deseja adicionar $USER ao grupo ${CGreen}vboxusers${CReset}" || return 1
	
	# sudo gpasswd -a "$USER" vboxusers  
	__sudo__ usermod -a -G vboxusers $USER	
}

_virtualbox_fedora()
{
	# sudo dnf install make automake gcc gcc-c++ kernel-devel
	local requeriments_virtualbox_fedora=(
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
		'automake'
		'make' 
		'patch'
	)

	__pkg__ "${requeriments_virtualbox_fedora[@]}"
	__pkg__ $(rpm -qa kernel | sort -V | tail -n 1) 
	__pkg__ kernel-devel-$(uname -r)

	__download__ "https://www.virtualbox.org/download/oracle_vbox.asc" "$DirDownloads/oracle_vbox.asc"
	_yellow "Importando: $DirDownloads/oracle_vbox.asc"
	sudo rpm --import "$DirDownloads/oracle_vbox.asc"
	__rmdir__ "$DirDownloads/oracle_vbox.asc"
	
	_white "Adicionando repositório: http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo"
	sudo sh -c 'wget -q -O /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo'
	
	case "$os_version" in
		31) __pkg__ 'VirtualBox-6.0' || return 1;;
		32) __pkg__ 'VirtualBox-6.1' || return 1;;
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
	local url_libvpx='http://ftp.us.debian.org/debian/pool/main/libv/libvpx/libvpx5_1.7.0-3+deb10u1_amd64.deb'
	local path_libvpx="$DirDownloads/$(basename $url_libvpx)"
	local sum_libvpx='72d8466a4113dd97d2ca96f778cad6c72936914165edafbed7d08ad3a1679fec'
	local virtualbox_sources_list="/etc/apt/sources.list.d/virtualbox.list"
	local url_key_virtualbox_2016='https://www.virtualbox.org/download/oracle_vbox_2016.asc'
	local url_key_virtualbox='https://www.virtualbox.org/download/oracle_vbox.asc'
	
	_println "Executando ... curl -sSL $url_key_virtualbox | sudo apt-key add - "
	curl -sSL $url_key_virtualbox | sudo apt-key add - || {
		_sred "FALHA"
		return 1
	}

	_println "Executando ... curl -sSL $url_key_virtualbox_2016 | sudo apt-key add - "
	curl -sSL $url_key_virtualbox_2016 | sudo apt-key add - || {
		_sred "FALHA"
		return 1
	}
	
	if [[ "$os_codename" == 'buster' ]]; then
		vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib"
	else
		_red "Seu sistema ainda não tem suporte a instalação do virtualbox por meio deste script"
		return 1
	fi	
	
	# Verificar se já existe repositório do virtualbox nos diretórios e subdiretórios /etc/apt/sources.list
	find /etc/apt -name *.list | xargs grep "^deb .*download\.virtualbox\.org.*debian.*contrib$" 2> /dev/null
	if [[ "$?" == '0' ]]; then
		_print "Repositório virtualbox encontrado pulando"
	else
		_println "Adicionando repositório virtualbox ... "
		echo "$vbox_repo" | sudo tee "$virtualbox_sources_list"
	fi
	
	# Atualizar o cache 'apt update' apartir da função _APT.
	_APT update  
	__pkg__ 'module-assistant' 'build-essential' 'libsdl-ttf2.0-0' dkms
	__pkg__ linux-headers-$(uname -r)
	__pkg__ 'virtualbox-6.1' || return 1
	_virtualbox_extpack
}

_virtualbox_ubuntu()
{
	local virtualbox_sources_list="/etc/apt/sources.list.d/virtualbox.list"
	local url_key_virtualbox_2016='https://www.virtualbox.org/download/oracle_vbox_2016.asc'
	local url_key_virtualbox='https://www.virtualbox.org/download/oracle_vbox.asc'
	
	# Adicionar keys
	_println "Executando ... curl -sSL $url_key_virtualbox | sudo apt-key add - "
	curl -sSL $url_key_virtualbox | sudo apt-key add - || {
		_sred "FALHA"
		return 1
	}

	_println "Executando ... curl -sSL $url_key_virtualbox_2016 | sudo apt-key add - "
	curl -sSL $url_key_virtualbox_2016 | sudo apt-key add - || {
		_sred "FALHA"
		return 1
	}

	case "$os_codename" in
		focal|ulyana) vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian focal contrib";;
		bionic|tricia) vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib";;
		*) _red "Seu sistema ainda não tem suporte a instalação do virtualbox por meio deste script"; return 1;;
	esac

	find /etc/apt -name *.list | xargs grep "^deb .*download\.virtualbox\.org.*debian.*contrib$" 2> /dev/null
	if [[ "$?" == '0' ]]; then
		_print "Repositório virtualbox encontrado pulando"
	else
		_println "Adicionando repositório virtualbox ... "
		echo "$vbox_repo" | sudo tee "$virtualbox_sources_list"
	fi
	
	# Atualizar o cache 'apt update' apartir da função _APT.
	_APT update 
	
	# __pkg__ libvpx6 
	__pkg__ 'module-assistant' 'build-essential' 'libsdl-ttf2.0-0' dkms
	__pkg__ linux-headers-$(uname -r)
	print_line
	__pkg__ 'virtualbox-6.1' || return 1
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
		'virtualbox' 'virtualbox-host-modules-arch' 'linux-headers'
	)

	for c in "${array_vb_archlinux[@]}"; do
		__pkg__ "$c" || _red "Falha: $c"
	done

	# /etc/modules-load.d/virtualbox.conf
	# sudo depmod -a
	_msg "Executando ... /sbin/rcvboxdrv setup"; sudo /sbin/rcvboxdrv setup
	_msg "Executando ... sudo /sbin/vboxconfig"; sudo /sbin/vboxconfig
	_msg "Executando ... sudo modprobe vboxdrv"; sudo modprobe vboxdrv

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
	# wget https://www.virtualbox.org/download/hashes/6.1.6/SHA256SUMS
	#
	# https://download.virtualbox.org/virtualbox/6.1.6/VirtualBox-6.1.6-137129-Linux_amd64.run
	#
	# sudo /etc/init.d/vboxdrv setup
	# sudo /sbin/vboxconfig
	# sudo /sbin/rcvboxdrv setup

	# Pagina de download do virtualbox
	vbox_pag='https://www.virtualbox.org/wiki/Linux_Downloads'
	get_html 'https://www.virtualbox.org/wiki/Linux_Downloads'

	# Encontrar ocorrências .run ou SHA256 no html da pagina de download.
	vbox_html=$(egrep "(https.*download.*64.run|SHA256)" "$HtmlTemporaryFile")
	
	# Filtrar o url do arquivo executável (.run)
	vbox_url_run=$(echo "$vbox_html" | grep -m 1 '64.run' | sed 's/.*href="//g;s/run".*/run/g')

	# Filtrar versão do virtualbox na string URL
	vbox_version=$(echo "$vbox_url_run" | cut -d '/' -f 5)

	# Atribuir path do arquivo a ser baixado.
	path_file="$DirDownloads/$(basename $vbox_url_run)"
	
	# Definir o url de download do arquivo 'SHA256SUMS' com as hashs e seu destino de download.
	vbox_url_hash="https://www.virtualbox.org/download/hashes/$vbox_version/SHA256SUMS"
	vbox_path_file_hash="$DirDownloads/virtualbox_$vbox_version.check"
	_msg "Baixando virtualbox versão $vbox_version"	

	__download__ "$vbox_url_run" "$path_file" || return 1
	__download__ "$vbox_url_hash" "$vbox_path_file_hash" || return

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	# Obter a HASH do pacote de instalação com a extensão .run. As informações
	# estão no arquivo '.check'. Em seguida verificar a integridade do pacote.
	shasum_package_vitualbox=$(grep '64.run' "$vbox_path_file_hash" | cut -d' ' -f 1)
	__shasum__ "$path_file" "$shasum_package_vitualbox" || return 1
	chmod +x "$path_file"
	__sudo__ "$path_file"
	__sudo__ /sbin/rcvboxdrv setup
	__sudo__ /sbin/vboxconfig
	_virtualbox_extpack
}

_virtualbox()
{
	#is_executable virtualbox && _show_info 'PkgInstalled' 'virtualbox' && return 0
	case "$os_id" in
		debian) _virtualbox_debian;;
		linuxmint|ubuntu) _virtualbox_ubuntu;;
		fedora) _virtualbox_fedora;;
		arch) _virtualbox_linux_run;;	
		*) _show_info 'ProgramNotFound' 'virtualbox'; return 1;;	
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
	# sh -c "$(wget -q -O- https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
	
	local ohmybash_master='https://github.com/ohmybash/oh-my-bash/archive/master.zip'
	local ohmybashZipFile="$DirDownloads/ohmybash.zip"
	local url_installer='https://raw.github.com/ohmybash/oh-my-bash/master/tools/install.sh'
	local ohmybash_installer="$DirDownloads/ohmybash_installer.sh"
	
	if is_executable "$SCRIPT_OHMYBASH_INSTALLER"; then
		"$SCRIPT_OHMYBASH_INSTALLER"
	else 
		sh -c "$(wget -q -O- https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)" 
	fi

	__download__ "$ohmybash_master" "$ohmybashZipFile" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar 

	_unpack "$ohmybashZipFile" || return 1
	_msg "Instalando temas para ohmybash em: $HOME/.bash/themes"
	mkdir -p "$HOME/.bash/themes"
	cp -R -u "$DirUnpack/oh-my-bash-master/themes/" "$HOME/.bash/" || return 1
	sed -i "s|OSH_THEME=.*|OSH_THEME=mairan|g" "$HOME/.bashrc"
	
	_YESNO "Gostaria de habilitar um tema para ohmybash" || return 1

	_yellow "1 => bakke"
	_yellow "2 => bobby"
	_yellow "3 => bobby-python"
	_yellow "4 => emperor"
	_yellow "5 => mairan (recomendado)"
	_yellow "6 => rjorgenson"
	_yellow "7 => agnoster"
	_yellow "8 => kitsune"
	_yellow "9 => powerline-plain"
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
		*) _red "Opção incorreta saindo"; return 1;;
	esac

	_msg "Habilitando o tema $option para ohmybash"
	sed -i "s|OSH_THEME=.*|OSH_THEME=$option|g" "$HOME/.bashrc"
	_white "OK"
	
}

_ohmyzsh()
{
	# sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	# https://github.com/ohmyzsh/ohmyzsh
	#
	if ! is_executable 'zsh'; then
		_yellow "Necessário instalar shell [zsh]"
		__pkg__ zsh	
	fi
	
	_yellow "Instalando ohmyzsh"
	sh -c "$(wget -q -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"	
}

_papirus_debian()
{
	# sudo apt install libreoffice-style-papirus
	__pkg__ 'papirus-icon-theme'
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
				__pkg__ 'gtk-murrine-engine' 'gtk2-engines'
				;;

		arch) 
				__pkg__ 'gtk-engine-murrine' 'gtk-engines'
				;;

		debian|ubuntu|linuxmint) 
				__pkg__ 'gtk2-engines-murrine' 'gtk2-engines-pixbuf'
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

	__pkg__ make
	cd "$DirGitclone"/dash-to-dock
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
		fedora) __pkg__ 'gnome-shell-extension-dash-to-dock.noarch';;
		debian) __pkg__ 'gnome-shell-extension-dashtodock';;
		*) _dashtodock_github;;
	esac
}

_drive_menu()
{
	case "$os_id" in
		fedora) __pkg__ 'gnome-shell-extension-drive-menu';;
		*) _show_info 'ProgramNotFound' 'drive-menu'; return 1;;
	esac
}

_gnome_backgrounds()
{
	case "$os_id" in 
		arch) __pkg__ 'gnome-backgrounds';;
		fedora) __pkg__ 'gnome-backgrounds-extras' 'verne-backgrounds-gnome';;
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
	__pkg__ make

	cd "$DirUnpack"
	mv $(ls -d Top*) "$DirUnpack"/topicons_plus
	cd topicons_plus
	
	# make install
	sudo make install INSTALL_PATH=/usr/share/gnome-shell/extensions
	print_line

	if _YESNO "Deseja abrir a jenela de configuração para topicons-plus"; then
		gnome-extensions prefs TopIcons@phocean.net
	fi

}

_topicons_plus()
{
	case "$os_id" in
		fedora) __pkg__ 'gnome-shell-extension-topicons-plus';;
		debian) __pkg__ 'gnome-shell-extension-top-icons-plus';;
		*) _topicons_plus_github;;
	esac
}

_gnome_tweaks()
{
	__pkg__ 'gnome-tweaks'
}


#=============================================================#
# Instalar todos os pacotes da categória Acessorios.
#=============================================================#
_Acessory_All()
{
	_YESNO "Instalar todos os pacotes da categória 'Acessórios'" || return 1

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
	_YESNO "Instalar todos os pacotes da categória 'Desenvolvimento'" || return 1
	
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
	_YESNO "Instalar todos os pacotes da categória 'Sistema'" || return 1 
	
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
	_YESNO "Instalar todos os pacotes da categória 'Internet'" || return 1

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
	
	_YESNO "Instalar todos os pacotes da categória 'Navegadores'" || return 1


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
	_YESNO "Instalar todos os pacotes da categória 'Escritório'" || return 0

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
	
	_YESNO "Instalar todos os pacotes da categória 'Midia'" || return 1
	

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
	_YESNO "Instalar todos os pacotes da categória 'Wine'" || return 1

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

