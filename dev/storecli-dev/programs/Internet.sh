#!/usr/bin/env bash
#


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

# Requeriments teamviewer Fedora
array_tw_fedora=(
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
	
	__download__ "$url_rpm" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0	
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
	
	# Já instalado.
	is_executable 'tixati' && _show_info 'PkgInstalled' 'tixati' && return 0

	echo -ne "[>] Importando key tixati "
	if curl -sSL https://www.tixati.com/tixati.key -o- | gpg --import 1>> "$LogFile" 2>> "$LogErro"; then
		echo -e "${CYellow}OK${CReset}"
	else
		echo ' '
		_red "Falha: gpg --import"
		return 1
	fi

	# Gpg
	__gpg__ "$signatureFile" "$TarFile" || return 1

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
	is_executable "$directoryUSERbin/youtube-dl" && {
		_show_info 'PkgInstalled' "youtube-dl" 
		return 0
	}

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

	cd "$DirTemp/twodict"
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
	} | sudo tee -a "$file_desktop_tubedl_gui" 1>> "$LogFile"

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
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' "$path_file" && return 0 

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
	
	if is_executable 'youtube-dl-gui'; then
		_show_info 'SuccessInstalation' 'youtube-dl-gui'
		return 0
	else
		_show_info 'InstalationFailed' 'youtube-dl-gui'
		return 1
	fi
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

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Internet_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Internet'" || return 1
	fi
	_chromium
    _google_chrome
    _megasync
    _opera_stable
    _proxychains
    _qbittorrent
    _teamviewer
    _telegram
    _tixati
    _torbrowser
    _uget
    _youtube_dl
    _youtube_dlgui
}
