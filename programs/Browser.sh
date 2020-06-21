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

	white "Instalando pacote de idioma para chromium"
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
		'opensuse-tumbleweed'|'opensuse-leap') _package_man_distro chromium;; 
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
		debian) _package_man_distro 'firefox-esr';;
		ubuntu) _package_man_distro firefox;;
		fedora) _package_man_distro 'firefox.x86_64' 'mozilla-ublock-origin.noarch';;
		'opensuse-leap') _package_man_distro MozillaFirefox;;
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
	white "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	curl -sSL 'https://dl.google.com/linux/linux_signing_key.pub' | sudo apt-key add -

	# find /etc/apt -name *.list | xargs grep "^deb .*google\.com/linux.*stable main" 2> /dev/null
	white "Adicionando repositório"
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

function _google_chrome_opensuse()
{
	# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-openSUSE-Leap-15
	# wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	# curl -SL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	yellow "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	yellow "Adicionando repositório: http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	_package_man_distro 'google-chrome-stable'
}

function _google_chrome_tumbleweed()
{
	
	white "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	white "Adicionando repositório [http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google]"
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
	sudo pacman -U --noconfirm $(ls google*.tar.*)
}


function _google_chrome()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _google_chrome_debian;;
		opensuse-tumbleweed|opensuse-leap) _google_chrome_opensuse;;
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

#=============================================================#
# opera
#=============================================================#
function _opera_stable_debian()
{
	local opera_repo='deb [arch=amd64] https://deb.opera.com/opera-stable/ stable non-free'
	local opera_file='/etc/apt/sources.list.d/opera-stable.list'
	
	white "Importando key"
	sudo sh -c 'curl -sSL http://deb.opera.com/archive.key | apt-key add -' || return 1
	#sudo sh -c 'wget -q -O- http://deb.opera.com/archive.key | apt-key add -'

	find /etc/apt -name *.list | xargs grep "^deb .*deb\.opera.* stable.*free$" 2> /dev/null

	if [[ $? == '0' ]]; then
		white "Repositório já está disponível 'pulando'"
	else
		white "Adicionando repositório"
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

	white "Importando key"
	sudo rpm --import https://rpm.opera.com/rpmrepo.key || return 1

	white "Adicionando repositório"
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

	white "Syncronizando repositórios"
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
# TorBrowser
#=============================================================#
_torbrowser()
{
	# Url do script de instalação do torbrowser.
	local url_master_script_torbrowser='https://raw.github.com/Brunopvh/torbrowser/master/tor.sh'

	if ! _WHICH "$Script_TorBrowser"; then
		_dow "$url_master_script_torbrowser" "$Script_TorBrowser" || return 1
		chmod +x "$Script_TorBrowser"
	fi

	if [[ "$download_only" == 'True' ]]; then
		"$Script_TorBrowser" --install --downloadonly
	else
		"$Script_TorBrowser" --install
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Browser_All()
{
	if [[ -z "$install_yes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Navegadores'" || return 1
	fi
	_chromium
    _google_chrome
    _opera_stable
    _torbrowser
}
