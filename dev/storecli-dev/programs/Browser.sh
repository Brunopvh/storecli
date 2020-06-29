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

	_white "Instalando pacote de idioma para chromium"
	case "$os_id" in
		debian) _pkg_manager_sys 'chromium-l10n';;
		ubuntu) _pkg_manager_sys 'chromium-browser-l10n';;
		*) return 0;;
	esac
}


function _chromium()
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
		ubuntu) _pkg_manager_sys firefox;;
		fedora) _pkg_manager_sys 'firefox.x86_64' 'mozilla-ublock-origin.noarch';;
		'opensuse-leap') _pkg_manager_sys MozillaFirefox;;
		*) _show_info 'ProgramNotFound' 'firefox'; return 1;;
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
	_white "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	curl -sSL 'https://dl.google.com/linux/linux_signing_key.pub' | sudo apt-key add -

	# find /etc/apt -name *.list | xargs grep "^deb .*google\.com/linux.*stable main" 2> /dev/null
	_white "Adicionando repositório"
	echo "$google_chrome_repo" | sudo tee "$google_chrome_file"

	# sudo apt install libu2f-udev
	_APT update
	_pkg_manager_sys 'google-chrome-stable' 
}


function _google_chrome_fedora()
{
	# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
	# dnf install https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	sudo dnf install fedora-workstation-repositories
	sudo dnf config-manager --set-enabled google-chrome
	_pkg_manager_sys 'google-chrome-stable'
}

function _google_chrome_opensuse()
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

function _google_chrome_tumbleweed()
{
	
	_white "Adicionando key [https://dl.google.com/linux/linux_signing_key.pub]"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub || return 1

	_white "Adicionando repositório [http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google]"
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google || return 1
	_pkg_manager_sys 'google-chrome-stable'
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


function _google_chrome()
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

#=============================================================#
# opera
#=============================================================#
function _opera_stable_debian()
{
	local opera_repo='deb [arch=amd64] https://deb.opera.com/opera-stable/ stable non-free'
	local opera_file='/etc/apt/sources.list.d/opera-stable.list'
	
	_white "Importando key"
	sudo sh -c 'curl -sSL http://deb.opera.com/archive.key | apt-key add -' || return 1
	#sudo sh -c 'wget -q -O- http://deb.opera.com/archive.key | apt-key add -'

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

#-----------------------------------------------------#

function _opera_stable_fedora()
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

#-----------------------------------------------------#

function _opera_stable_suse()
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

#-----------------------------------------------------#

function _opera_stable()
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


#=============================================================#
# TorBrowser
#=============================================================#
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

#=============================================================#
# Instalar todos os pacotes da categória internet.
#=============================================================#
_Browser_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Navegadores'" || return 1
	fi
	_chromium
    _google_chrome
    _opera_stable
    _torbrowser
}
