#!/usr/bin/env bash
#

#=====================================================#
# Chomium
#=====================================================#

function _chromium_lang()
{
	# Instalar pacote de idioma ptbr se o idioma do usuário for
	# 

	# Verificar se o idioma da sessão e pt_br.
	local lang=$(set | grep -m 1 '^LANG=' | sed 's/.*=//g')
	[[ "$lang" == 'pt_BR.UTF-8' ]] || return 0

	msg "Instalando pacote de idioma para chromium"
	case "$os_id" in
		debian) _package_man_distro 'chromium-l10n';;
		ubuntu) _package_man_distro 'chromium-browser-l10n';;
		*) return 0;;
	esac
}


function _chromium()
{
	case "$os_id" in
		debian) _package_man_distro chromium;;
		ubuntu|linuxmint) _package_man_distro 'chromium-browser';;
		fedora) _package_man_distro chromium;;
		arch) _package_man_distro chromium;;
		opensuse-tumbleweed) _package_man_distro chromium 'chromium-uget-integrator';; 
		freebsd12) _package_man_distro chromium;;
		*) _INFO 'pkg_not_found' 'chromium'; return 1;;
	esac

	_chromium_lang # Instalar pacote de idioma ptbr.
}

#=====================================================#
# Firefox
#=====================================================#
_firefox_lang()
{
	# Verificar se o idioma da sessão e pt_br e em seguida instalar o
	# pacote de idiomas pt_br para firefox.
	local lang=$(set | grep -m 1 '^LANG=' | sed 's/.*=//g')
	[[ "$lang" == 'pt_BR.UTF-8' ]] || return 0

	case "$os_id" in
		arch) _package_man_distro 'firefox-i18n-pt-br';;
		debian) _package_man_distro 'firefox-esr-l10n-pt-br';;
		ubuntu) _package_man_distro 'firefox-locale-pt';;
	esac
}

_firefox()
{
	case "$os_id" in
		arch) _package_man_distro firefox;;
		debian) _package_man_distro firefox-esr;;
		ubuntu) _package_man_distro firefox;;
		*) _INFO 'pkg_not_found' 'firefox'; return 1;;
	esac

	_firefox_lang
}

#=====================================================#
# Google chrome
#=====================================================#
function _google_chrome_debian()
{
	local google_chrome_repo='deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
	local google_chrome_file='/etc/apt/sources.list.d/google-chrome.list'	
	msg "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	#sudo sh -c 'wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | apt-key add -'
	curl -sSL 'https://dl.google.com/linux/linux_signing_key.pub' | sudo apt-key add -

	#find /etc/apt -name *.list | xargs grep "^deb .*google\.com/linux.*stable main" 2> /dev/null
	msg "Adicionando repositório"
	echo "$google_chrome_repo" | sudo tee "$google_chrome_file"

	# sudo apt install libu2f-udev
	sudo apt update
	_package_man_distro 'google-chrome-stable' 
}



function _google_chrome_fedora()
{
	# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
	# dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo dnf install fedora-workstation-repositories
	sudo dnf config-manager --set-enabled google-chrome
	_package_man_distro 'google-chrome-stable'
}



function _google_chrome_tumbleweed()
{
	# wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	msg "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	msg "Adicionando repositório [http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google]"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	_package_man_distro 'google-chrome-stable'
}


function _google_chrome_archlinux()
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
	cd "$dir_temp"/google-chrome

	green "Instalando base-devel"
	_package_man_distro "base-devel"
	_package_man_distro pipewire

	echo -e "$space_line"
	green "Executando: makepkg -s"
	cd "$dir_temp/google-chrome"
	makepkg -s

	echo -e "$space_line"
	green "Executando sudo pacman -U $(ls google*.tar.*)"
	sudo pacman -U $(ls google*.tar.*)
}


function _google_chrome()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _google_chrome_debian;;
		opensuse-tumbleweed|opensuse-leap) _google_chrome_tumbleweed;;
		fedora) _google_chrome_fedora;;
		arch) _google_chrome_archlinux;;
		*) _INFO 'pkg_not_found' 'google-chrome'; return 1;;
	esac	

	if _WHICH 'google-chrome'|| _WHICH 'google-chrome-stable'; then
		_INFO 'pkg_sucess' 'google-chrome'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'google-chrome'
		return 1
	fi
}

#=====================================================#
# Cliente Mega Sync
#=====================================================#

function _megasync_suse_tumbleweed()
{
	# https://www.blogopcaolinux.com.br/2017/02/Instalando-o-MEGA-Sync-no-openSUSE-e-Fedora.html

	msg "Adicionando key [https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key]"
	sudo rpm --import https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key || return 1
	
	msg "Adicionando repositório [https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA]"
	sudo zypper ar -f https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA || return 1
	sudo zypper ref

	msg "Instalando megasync"
	_package_man_distro megasync || return 1	
}


function _megasync_debian()
{
	#sudo sh -c 'wget https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key -O - | apt-key add -'
	# find /etc/apt -name *.list | xargs grep "^deb .*mega\.nz/linux.Debian.*" 2> /dev/null
	local mega_repos="deb https://mega.nz/linux/MEGAsync/Debian_10.0/ ./"	
	local mega_file_list="/etc/apt/sources.list.d/megasync.list"

	if [[ "$os_codename" != 'buster' ]]; then
		red "Este programa está disponível apena para (Debian buster)"
		return 1
	fi

	msg "Adicionando key [https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key]"	
	curl -sSL 'https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key' | sudo apt-key add - || return 1
	msg "Adicionando repositório"
	echo "$mega_repos" | sudo tee "$mega_file_list"
	sudo apt update
	_package_man_distro megasync || return 1
}

function _megasync_ubuntu()
{
	# https://mega.nz/linux/MEGAsync/xUbuntu_19.10/
	# https://mega.nz/linux/MEGAsync/
	#
	local url_libraw16='http://archive.ubuntu.com/ubuntu/pool/main/libr/libraw/libraw16_0.18.8-1ubuntu0.3_amd64.deb'
	local mega_file_list="/etc/apt/sources.list.d/megasync.list"
	path_libraw="$dir_user_cache/$(basename $url_libraw16)" # Requerimento para ubutnu 19.10

	if [[ "$os_codename" == 'bionic' ]] || [[ "$sysname" == 'linuxmint19' ]]; then # Ubuntu 18.04
		local mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./"
		local mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_18.04/Release.key'
		
	elif [[ "$os_codename" == 'eoan' ]]; then # Ubuntu 19.10
		local mega_repos_ubuntu="deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./"
		local mega_url_key='https://mega.nz/linux/MEGAsync/xUbuntu_19.10/Release.key'
		_dow "$url_libraw16" "$path_libraw" || return 1 
		msg "Instalando [$path_libraw]"
		sudo dpkg --install "$path_libraw" || return 1
	else
		_INFO 'pkg_not_found' 'opera' 
		return 1
	fi

	#find /etc/apt -name *.list | xargs grep "^deb .*mega\.nz/linux.*Ubuntu_18\.04" 2> /dev/null
	msg "Adicionando repositório [$mega_repos_ubuntu]"
	echo "$mega_repos_ubuntu" | sudo tee "$mega_file_list"

	msg "Adicionando key [$mega_url_key]"
	curl -sSL "$mega_url_key" -o- | sudo apt-key add -	
	sudo apt update 
	_package_man_distro libc-ares2 libmediainfo0v5 
	_package_man_distro megasync
}



function _megasync_fedora()
{
	msg "Importando key [https://mega.nz/linux/MEGAsync/Fedora_30/repodata/repomd.xml.key]"
	sudo rpm --import https://mega.nz/linux/MEGAsync/Fedora_30/repodata/repomd.xml.key

	echo '[MEGAsync]' | sudo tee /etc/yum.repos.d/megasync.repo
	{
		echo "name=MEGAsync"
		echo "type=rpm-md"
		echo "baseurl=http://mega.nz/linux/MEGAsync/Fedora_30/"
		echo "gpgcheck=1"	
		echo "enabled=1"
		echo "gpgkey=https://mega.nz/linux/MEGAsync/Fedora_30/repodata/repomd.xml.key"	
	} | sudo tee -a /etc/yum.repos.d/megasync.repo

	_package_man_distro megasync
}

function _megasync_archlinux()
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
	local path_mega_tar="$Dir_Downloads/$(basename $mega_url_tar)"

	# Requerimentos para compilação no ArchLinux - libpdfium.
	local array_mega_requeriments_archlinux=(
		crypto++ c-ares libuv libmediainfo  qt5-tools swig doxygen lsb-release
		)

	# Baixar o pacote do repositório MEGA.
	_dow "$mega_url_tar" "$path_mega_tar" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$github_megasync"
		return 0 
	fi

	# Instalar dependências.
	echo -e "$space_line"
	_package_man_distro "${array_mega_requeriments_archlinux[@]}"

	# Copiar o instalador para o diretório temporário e em seguida instalar o pacote.
	echo -e "$space_line"
	cp "$path_mega_tar" "$dir_temp/megasync-x86_64.pkg.tar.xz" || return 1
	cd "$dir_temp"
	sudo pacman -U megasync-x86_64.pkg.tar.xz

	# Syncronizar os repositórios
	echo -e "$space_line"
	sudo pacman -Sy
}

#=====================================================#

function _megasync()
{
	# Já instalado.
	if _WHICH 'megasync'; then
		_INFO 'pkg_are_instaled' 'megasync'
		return 0
	fi

	case "$os_id" in
		opensuse-tumbleweed) _megasync_suse_tumbleweed;;
		debian) _megasync_debian;;
		linuxmint|ubuntu) _megasync_ubuntu;;
		fedora) _megasync_fedora;;
		arch) _megasync_archlinux;;
		*) _INFO 'pkg_not_found' 'megasync'; return 1;;
	esac

	if _WHICH 'megasync'; then
		_INFO 'pkg_sucess' 'megasync'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'megasync'
		return 1
	fi
}


#=============================================================#
# opera
#=============================================================#
function _opera_stable_debian()
{
	local opera_repo='deb [arch=amd64] https://deb.opera.com/opera-stable/ stable non-free'
	local opera_file='/etc/apt/sources.list.d/opera-stable.list'
	
	msg "Importando key"
	sudo sh -c 'curl -sSL http://deb.opera.com/archive.key | apt-key add -' || return 1
	#sudo sh -c 'wget -q -O- http://deb.opera.com/archive.key | apt-key add -'

	find /etc/apt -name *.list | xargs grep "^deb .*deb\.opera.* stable.*free$" 2> /dev/null

	if [[ $? == '0' ]]; then
		msg "Repositório já está disponível 'pulando'"
	else
		msg "Adicionando repositório"
		echo "$opera_repo" | sudo tee "$opera_file"
	fi
	sudo apt update
	_package_man_distro 'opera-stable' || return 1	
}

#-----------------------------------------------------#

function _opera_stable_fedora()
{
	# https://www.blogopcaolinux.com.br/2017/07/Instalando-o-Opera-no-openSUSE-e-no-Fedora.html
	# https://rpm.opera.com/manual.html

	msg "Importando key"
	sudo rpm --import https://rpm.opera.com/rpmrepo.key || return 1

	msg "Adicionando repositório"
	echo '[opera]' | sudo tee /etc/yum.repos.d/opera.repo
	{
		echo "name=Opera packages"
		echo "type=rpm-md"
		echo "baseurl=https://rpm.opera.com/rpm"
		echo "gpgcheck=1"	
		echo "gpgkey=https://rpm.opera.com/rpmrepo.key"
		echo "enabled=1"
	} | sudo tee -a /etc/yum.repos.d/opera.repo

	_package_man_distro 'opera-stable'
}

#-----------------------------------------------------#

function _opera_stable_suse()
{
	# https://www.blogopcaolinux.com.br/2017/07/Instalando-o-Opera-no-openSUSE-e-no-Fedora.html
	
	#sudo zypper ref && sudo zypper up
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

	msg "Syncronizando repositórios"
	sudo zypper ref
	_package_man_distro 'opera-stable'  || return 1
}

#-----------------------------------------------------#

function _opera_stable()
{
case "$os_id" in
	debian|linuxmint|ubuntu) _opera_stable_debian;;
	fedora) _opera_stable_fedora;;
	opensuse-tumbleweed) _opera_stable_suse;;
	*) _INFO 'pkg_not_found' 'opera'; return 1;;
esac	

	if [[ $? == '0' ]]; then 
		_INFO 'pkg_sucess' 'opera'
	else
		_INFO 'pkg_instalation_failed' 'opera'
		return 1
	fi
}


#=============================================================#
# Tor Debian
#=============================================================#
_tor_debian()
{
	local tor_asc='https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc'
	local tor_file_list='/etc/apt/sources.list.d/torproject.list'

	if [[ "$os_codename" == 'bionic' ]] || [[ "$os_codename" == 'tina' ]]; then  # Ubuntu
		local tor_repos='deb https://deb.torproject.org/torproject.org bionic main'
	elif [[ "$os_codename" == 'buster' ]]; then # Debian
		local tor_repos='deb https://deb.torproject.org/torproject.org buster main'
	fi

	yellow "Importando chaves"
	#sudo sh -c 'curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import'
	if ! curl -sSL "$tor_asc" | sudo gpg --import; then
		red "Falha ao tentar importar [$tor_asc]"
		return 1
	fi
	sudo sh -c 'gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -' || return 1

	yellow "Adicionando repositório"
	echo "$tor_repos" | sudo tee "$tor_file_list"
	_APT update

	yellow "Instalando tor deb.torproject.org-keyring"
	_package_man_distro tor deb.torproject.org-keyring
}


#=============================================================#
# Proxychains
#=============================================================#
_proxychains()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		_package_man_distro proxychains-ng || return 1

	elif [[ -x $(command -v dnf 2>/dev/null) ]]; then
		_package_man_distro proxychains || return 1

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		_package_man_distro proxychains || return 1 
		_tor_debian
	else
		_INFO 'pkg_not_found' 'proxychains'
		return 1
	fi
}

#=============================================================#
# Qbitorrent
#=============================================================#
_qbittorrent()
{
	_package_man_distro qbittorrent || return 1
}

#=============================================================#
# TeamViewer
#=============================================================#
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
	local path_file="$Dir_Downloads/teamviewer_amd64.deb"
	
	_dow "$url_deb" "$path_file"

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi	

	# Já instalado.
	if _WHICH 'teamviewer'; then
		_INFO 'pkg_are_instaled' 'teamviewer'
		return 0 
	fi
	_package_man_distro "${array_tw_debian[@]}" || return 1
	_DPKG --install "$path_file"
	_BROKE # Remover pacotes quebrados.
}


_install_teamviewer_fedora()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/' # Página de download.
	local tw_html=$(curl -SsL "$tw_pag" | grep "download.*linux.*64")
	local url_rpm=$(echo "$tw_html" | grep -m 1 'x86_64.rpm' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$Dir_Downloads/teamviewer_x86_64.rpm"
	
	_dow "$url_rpm" "$path_file"

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi	

	# Já instalado.
	if _WHICH 'teamviewer'; then
		_INFO 'pkg_are_instaled' 'teamviewer'
		return 0 
	fi
	sudo dnf install "$path_file" || return 1
}


_teamviewer_tar()
{
	local tw_pag='https://www.teamviewer.com/en/download/linux/'      # Página de download.
	local tw_html=$(curl -sSL "$tw_pag" | grep "download.*linux.*64")
	local url_tar=$(echo "$tw_html" | grep -m 1 'amd64.tar' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local path_file="$Dir_Downloads/teamviewer_amd64.tar.xz"
	
	_dow "$url_tar" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi	

	# Já instalado.
	if _WHICH 'teamviewer'; then
		_INFO 'pkg_are_instaled' 'teamviewer'
		return 0 
	fi

	_unpack "$path_file" || return 1
	
	cd "$Dir_Unpack" && cd teamviewer
	chmod -R +x *
	sudo ./tv-setup install || return 1
}


function _teamviewer()
{
	# https://www.blogopcaolinux.com.br/2018/04/Instalando-o-TeamViewer-no-Debian-Ubuntu-e-Linux-Mint.html
	case "$os_id" in
		debian|linuxmint|ubuntu) _install_teamviewer_debian;;
		fedora) _install_teamviewer_fedora;;
		*) _teamviewer_tar;;
	esac

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		return 0 
	fi	

	if _WHICH 'teamviewer'; then
		_INFO 'pkg_sucess' 'teamviewer'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'teamviewer'
		return 1
	fi
}


#=============================================================#
# Telegram
#=============================================================#
_telegram()
{
	# https://desktop.telegram.org/
	# https://updates.tdesktop.com/tlinux/tsetup.1.8.15.tar.xz
	# curl -vSL -w "%{http_code}" https://telegram.org/dl/desktop/linux
	local url_telegram='https://telegram.org/dl/desktop/linux'
	local path_file="$Dir_Downloads/telegramsetup.tar.xz"

	_dow "$url_telegram" "$path_file" || return 1


	# Instalar gconf2.
	if _WHICH 'zypper'; then # Suse
		_package_man_distro gconf2
	elif _WHICH 'dnf'; then # Fedora
		_package_man_distro GConf2
	elif _WHICH 'apt'; then # Debian distros.
		_package_man_distro gconf2
	fi

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi	
	
	# Já instalado.
	if _WHICH 'telegram'; then
		_INFO 'pkg_are_instaled' 'telegram'
		return 0 
	fi

	_unpack "$path_file" || return 1

	cd "$Dir_Unpack" 
	mv -v $(ls -d Telegra*) "$Dir_User_Bin/telegram-amd64" 1> /dev/null
	chmod -R 755 "$Dir_User_Bin/telegram-amd64"
	ln -sf "$Dir_User_Bin/telegram-amd64/Telegram" "$Dir_User_Bin/telegram"
	telegram&

	if _WHICH 'telegram'; then
		_INFO 'pkg_sucess' 'telegram'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'telegram'
		return 1
	fi
}

#=============================================================#
# Tixati
#=============================================================#
_tixati_tar()
{
	# Obter url de download.
	local tixati_pag_downloads='https://www.tixati.com/download/linux.html'
	local tixati_html=$(curl -sSL "$tixati_pag_downloads" -o - | grep -m 1 'x86_64\.manual')
	local tixati_url_bin=$(echo "$tixati_html" | sed 's/z">.*/z/g;s/.*"//g')
	local tixati_url_key="${tixati_url_bin}.asc"

	local path_file="$Dir_Downloads/$(basename $tixati_url_bin)"
	local path_file_asc="$Dir_Downloads/$(basename $tixati_url_bin).asc"

	msg "Importando key tixati"
	curl -sSL https://www.tixati.com/tixati.key -o- | gpg --import || return 1

	_dow "$tixati_url_key" "$path_file_asc" || return 1
	_dow "$tixati_url_bin" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
			_INFO 'download_only' "$path_file"
			return 0 
	fi

	# Já instalado.
	if _WHICH 'tixati'; then
		_INFO 'pkg_are_instaled' 'tixati'
		return 0
	fi

	# Instalar o pacote Gconf2
	echo -e "$space_line"
	if _WHICH 'zypper'; then # Suse
		_package_man_distro gconf2
	elif _WHICH 'dnf'; then # Fedora
		_package_man_distro GConf2
	elif _WHICH 'apt'; then # Debian distros.
		_package_man_distro gconf2
	fi
	

	# Gpg
	if ! _verify_sig "$path_file_asc" "$path_file"; then
		rm "$path_file" 2> /dev/null
		rm "$path_file_asc" 2> /dev/null 
		return 1
	fi
	_unpack "$path_file" || return 1

	cd "$Dir_Unpack" 
	mv $(ls -d tixati*) "$Dir_Unpack/tixati-amd64" 1> /dev/null
	chmod -R a+x "$Dir_Unpack/tixati-amd64"
	sudo mv "$Dir_Unpack/tixati-amd64" /opt/ 

	cd /opt/tixati-amd64 || return 1
	sudo mv tixati.desktop "${array_tixati_dirs[0]}" # .desktop
	sudo mv tixati.png "${array_tixati_dirs[1]}" # PNG.
	sudo mv tixati "${array_tixati_dirs[2]}" # binario.
	

	# Atalho desktop
	green "Criando atalho na Área de trabalho"
	cp -u "${array_tixati_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_tixati_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_tixati_dirs[0]}" ~/Desktop/ 2> /dev/null

	# Definir tixati como gerenciador bittorrent padrão.
	if _YESNO "Deseja usar tixati como bittorrent padrão"; then
		yellow "Definindo tixati como padrão"
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/command 'tixati "%s"'
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/enabled true
		gconftool-2 --set --type=string /desktop/gnome/url-handlers/magnet/need-terminal false
	fi


	if _WHICH 'tixati'; then
		_INFO 'pkg_sucess' 'tixati'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'tixati'
		return 1
	fi
}

#=============================================================#
# TorBrowser
#=============================================================#
_torbrowser()
{
	if [[ "$download_only" == 'True' ]]; then
		"$Script_TorBrowser" --downloadonly
	else
		"$Script_TorBrowser" --install
	fi
}

#=============================================================#
# Uget
#=============================================================#
_uget()
{
	_package_man_distro uget 
}

#=============================================================#
# youtube-dl
#=============================================================#
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

	local path_file_sig="$Dir_Downloads/youtube-dl.sig"
	local path_file="$Dir_Downloads/youtube-dl"   # Path+Nome.
	local hash_sig='04d2edc85b80b59ffe46fdda3937b0074dfe10ede49fec6c36c609cd87841fcb' # sha256sum - .sig
	
	_dow "$url_ytdl_test" "$path_file" || return 1 
	_dow "$url_ytdl_sig" "$path_file_sig" || return 1
	
	# Asc
	yellow "Importando key"
	curl -# -LS "$url_ytdl_asc_philipp" -o- | gpg --import -
	curl -# -LS "$url_ytdl_asc_sergey" -o- | gpg --import -

	# Gpg
	_verify_sig "$path_file_sig" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi	

	# Já instalado.
	if [[ -x "$Dir_User_Bin/youtube-dl" ]]; then
		_INFO 'pkg_are_instaled' "$Dir_User_Bin/youtube-dl"
		return 0
	fi

	msg "Instalando youtube-dl em ~/.local/bin"
	cp -u "$path_file" "$Dir_User_Bin"/youtube-dl
	chmod a+x "$Dir_User_Bin"/youtube-dl

	if _WHICH 'youtube-dl'; then
		_INFO 'pkg_sucess' 'youtube-dl'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'youtube-dl'
		return 1
	fi
}


#=============================================================#
# Youtube-dl-gui
#=============================================================#
_python_twodict_github()
{
	# Instalar python twodict direto do github.
	_gitclone 'https://github.com/MrS0m30n3/twodict.git' || return 1
	msg "Compilando python2 twodict"

	cd "$dir_temp/twodict"
	if _WHICH 'python2'; then
		sudo python2 setup.py install
	elif _WHICH 'python2.7'; then
		sudo python2.7 setup.py install
	else
		red "Falha: Instale o python2"
		return 1
	fi

	echo -e "$space_line"
	if [[ "$?" == '0' ]]; then 
		_INFO 'pkg_sucess' 'python twodict'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'python twodict'
		return 1
	fi
}

# Baixar e compilar youtube-dl-gui
_youtube_dlgui_compile()
{
	local url_ytdl_gui='https://github.com/MrS0m30n3/youtube-dl-gui/archive/master.zip'
	local path_file="$Dir_Downloads/youtube-dl-gui.zip"

	_dow "$url_ytdl_gui" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	_unpack "$path_file" || return 1
	cd "$Dir_Unpack"/youtube-dl-gui-master || return 1
	echo -e "$space_line"
	yellow "Compilando youtube-dl-gui"
	sudo python2 setup.py install || return 1
	return 0
}

_youtube_dlgui_pip() 
{

	# ppa ubuntu.
	# sudo sh -c 'add-apt-repository ppa:nilarimogard/webupd8; apt update'
	# sudo apt install youtube-dlg --yes
	#

	case "$os_id" in
		ubuntu|linuxmint) echo -e "\r";;
		*) _INFO 'pkg_not_found' 'youtube-dlg-gui'; return 1;;
	esac

	_package_man_distro 'python-wxgtk3.0' gettext 'python-pip' 'python-twodict' || return 1
	pip install youtube-dlg || return 1

	# Criar arquivo .desktop.
	msg "Criando arquivo .desktop"

	arq_ytdl=~/.local/share/applications/youtube-dl-gui.desktop
	echo '[Desktop Entry]' > "$arq_ytdl"
	{
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=youtube-dl-gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} >> "$arq_ytdl"

	msg "Criando atalho na Área de Trabalho"

	chmod u+x "$arq_ytdl"
	cp -u "$arq_ytdl" ~/Desktop/ 2> /dev/null
	cp -u "$arq_ytdl" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "$arq_ytdl" ~/'Área de Trabalho'/ 2> /dev/null
	
	if _WHICH 'youtube-dl-gui'; then
		_INFO 'pkg_sucess' 'youtube-dl-gui'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'youtube-dl-gui'
		return 1
	fi
} 

_youtube_dlgui_ubuntu()
{
	# Ubuntu e Linuxmint.
	if [[ "$os_codename" == 'bionic' ]] || [[ "$os_codename" == 'trica' ]]; then
		_youtube_dlgui_pip || return 1
		return 0
	elif [[ "$os_codename" == 'eoan' ]]; then
		_package_man_distro 'python-wxgtk3.0' gettext || return 1
	else
		_INFO 'pkg_not_found' 'youtube-dlg-gui'
		return 1
	fi
	# Ubuntu eoan.
	_python_twodict_github || return 1
	#_gitclone 'https://github.com/MrS0m30n3/youtube-dl-gui.git' || return 1
	#cd "$dir_temp/youtube-dl-gui"
	#sudo python2 setup.py install || return 1
	_youtube_dlgui_compile || return 1
	return 0	
}


_youtube_dlgui_tumbleweed()
{
	# https://software.opensuse.org/download/package?package=youtube-dl-gui&project=openSUSE%3AFactory
	local url_opensuse_repo='https://download.opensuse.org/repositories/openSUSE:'
	local url_ytdlg_tumbleweed="$url_opensuse_repo/Factory/standard/noarch/youtube-dl-gui-0.4-1.7.noarch.rpm"
	local path_file="$Dir_Downloads/$(basename $url_ytdlg_tumbleweed)"

	_dow "$url_ytdlg_tumbleweed" "$path_file" || return 1 
	_package_man_distro "$path_file" || return 1
	
	echo -e "$space_line"
	if _WHICH 'youtube-dl-gui'; then
		_INFO 'pkg_sucess' 'youtube-dl-gui'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'youtube-dl-gui'
		return 1
	fi
}

_youtube_dlgui_fedora()
{
	_package_man_distro python2-wxpython || return 1
	_python_twodict_github || return 1
	#_gitclone 'https://github.com/MrS0m30n3/youtube-dl-gui.git' || return 1
	#cd "$dir_temp/youtube-dl-gui"
	#sudo python2 setup.py install || return 1
	_youtube_dlgui_compile || return 1
	return 0
}


_youtube_dlgui_debian()
{
	# Testado apenas no debian 10.
	if [[ "$os_codename" != 'buster' ]]; then
		_INFO 'pkg_not_found' 'youtube-dlg-gui'
		return 1
	fi
	_package_man_distro python-wxgtk3.0 gettext python-twodict || return 1
	
	#_gitclone 'https://github.com/MrS0m30n3/youtube-dl-gui.git' || return 1
	#cd "$dir_temp/youtube-dl-gui"
	#sudo python2 setup.py install || return 1
	_youtube_dlgui_compile || return 1
	return 0
}


_youtube_dlgui_archlinux()
{
	_package_man_distro python2-wxpython3 || return 1
	_python_twodict_github || return 1
	#_gitclone 'https://github.com/MrS0m30n3/youtube-dl-gui.git' || return 1
	#cd "$dir_temp/youtube-dl-gui"
	#sudo python2 setup.py install || return 1
	_youtube_dlgui_compile || return 1
	return 0
}

_youtube_dlgui_freebsd()
{
	# freebsd-12.0-release sudo pkg install py27-wxPython30
	sudo pkg install py27-wxPython30 || return 1
	_python_twodict_github || return 1
	_gitclone 'https://github.com/MrS0m30n3/youtube-dl-gui.git' || return 1
	cd "$dir_temp/youtube-dl-gui"
	sudo python2.7 setup.py install || return 1
	return 0
}


_youtube_dlgui()
{
	case "$os_id" in
		debian) _youtube_dlgui_debian || return 1;;
		ubuntu) _youtube_dlgui_ubuntu || return 1;;
		fedora) _youtube_dlgui_fedora || return 1;;
		arch) _youtube_dlgui_archlinux || return 1;;
		freebsd) _youtube_dlgui_freebsd || return 1;;
		opensuse-tumbleweed) _youtube_dlgui_tumbleweed || return 1;;
		*) _INFO 'pkg_not_found' 'youtube-dl-gui'; return 1;;
	esac

	# Criar arquivo .desktop.
	msg "Criando arquivo .desktop"

	arq_ytdl='/usr/share/applications/youtube-dl-gui.desktop' # .desktop
	echo '[Desktop Entry]' | sudo tee "$arq_ytdl"
	{
		echo "Encoding=UTF-8"
		echo "Name=Youtube-Dl-Gui"
		echo "Exec=youtube-dl-gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} | sudo tee -a "$arq_ytdl"

	msg "Criando atalho na Área de Trabalho"

	cp -u "$arq_ytdl" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "$arq_ytdl" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "$arq_ytdl" ~/Desktop/ 2> /dev/null
	
	echo -e "$space_line"
	if _WHICH 'youtube-dl-gui'; then
		_INFO 'pkg_sucess' 'youtube-dl-gui'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'youtube-dl-gui'
		return 1
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Internet_All()
{
	if [[ -z "$install_yes" ]]; then
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
