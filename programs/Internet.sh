#!/usr/bin/env bash
#
#

source "$Lib_GitClone"

#=====================================================#
# Google chrome
#=====================================================#
function _google_chrome_debian()
{
local google_chrome_repo='deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
local google_chrome_file='/etc/apt/sources.list.d/google-chrome.list'	
_msg "Adicionando key"
sudo sh -c 'wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | apt-key add -'

find /etc/apt -name *.list | xargs grep "^deb .*google\.com/linux.*stable main" 2> /dev/null

if [[ $? == '0' ]]; then
	_msg "Repositório $(_c 35)já$(_c) está disponível 'pulando'"

else
	_msg "Adicionando repositório"
	echo "$google_chrome_repo" | sudo tee "$google_chrome_file"

fi

# sudo apt install libu2f-udev
sudo sh -c 'aptitude update; aptitude install google-chrome-stable -y'	
}

#-----------------------------------------------------#

function _google_chrome_fedora()
{
	sudo dnf install fedora-workstation-repositories
	sudo dnf config-manager --set-enabled google-chrome
	sudo dnf install -y google-chrome-stable
}

#-----------------------------------------------------#

function _google_chrome_tumbleweed()
{
	#wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
	_msg "Adicionando key e repo"
	sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub 
	sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google 

	_msg "Instalando google-chrome"


	if sudo zypper in google-chrome-stable; then
		return 0
	else
		return 1

	fi
}

#-----------------------------------------------------#

function _google_chrome()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _google_chrome_debian;;
		opensuse-tumbleweed|opensuse-leap) _google_chrome_tumbleweed;;
		fedora) _google_chrome_fedora;;
		*) _prog_not_found; return 1;;
	esac	

	if [[ $? == '0' ]]; then 
		_msg 'google-chrome instalado com sucesso'
		return 0
	else
		_red "Função _google_chrome retornou erro"
		return 1
	fi
}

#=====================================================#
# Cliente Mega Sync
#=====================================================#
function _megasync_suse_tumbleweed()
{
# https://www.blogopcaolinux.com.br/2017/02/Instalando-o-MEGA-Sync-no-openSUSE-e-Fedora.html

echo "$(_c 32 0)=> $(_c)Adicionando key e repo"
sudo rpm --import https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key
sudo zypper ar -f https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA
sudo zypper ref

echo "$(_c 32)=> $(_c)Instalando megasync"
if sudo zypper in megasync; then
	return 0
else
	return 1

fi
}

#-----------------------------------------------------#

function _megasync_debian10()
{
local mega_repos="deb https://mega.nz/linux/MEGAsync/Debian_10.0/ ./"	
local mega_file="/etc/apt/sources.list.d/megasync.list"

find /etc/apt -name *.list | xargs grep "^deb .*mega\.nz/linux.Debian.*" 2> /dev/null
if [[ $? == '0' ]]; then # Pular 
	echo "=> $(_c 33)R$(_c)epositório $(_c 32)já$(_c) está disponível 'pulando'"

else
	_msg "Adicionando repositório"
	echo "$mega_repos" | sudo tee "$mega_file"

fi

	_msg "Adicionando key."	
	sudo sh -c 'wget https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key -O - | apt-key add -'
	sudo sh -c 'apt update; apt install -y megasync'
}


#-----------------------------------------------------#

function _megasync_ubuntu18()
{
local mega_repos_ubuntu18="deb https://mega.nz/linux/MEGAsync/xUbuntu_18.04/ ./"
local mega_file="/etc/apt/sources.list.d/megasync.list"

find /etc/apt -name *.list | xargs grep "^deb .*mega\.nz/linux.*Ubuntu_18\.04" 2> /dev/null
if [[ $? == '0' ]]; then
	echo "=> $(_c 33)R$(_c)epositório $(_c 32)já$(_c) está disponível 'pulando'"

else
	_msg "Adicionando repositório"
	echo "$mega_repos_ubuntu18" | sudo tee "$mega_file"

fi

	_msg "Adicionando key."	
	sudo sh -c 'wget -c https://mega.nz/linux/MEGAsync/xUbuntu_18.04/Release.key -O- | apt-key add -'
	sudo sh -c 'apt update; apt install -y megasync'
}

#-----------------------------------------------------#

function _megasync_fedora()
{
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

sudo dnf install megasync
}

#-----------------------------------------------------#

function _megasync()
{
 
case "$sysname" in
	opensuse-tumbleweed) _megasync_suse_tumbleweed;;
	debian10) _megasync_debian10;;
	linuxmint19|ubuntu18.04) _megasync_ubuntu18;;
	fedora30|fedora31) _megasync_fedora;;
	*) _prog_not_found; return 1;;

esac

if [[ $? == '0' ]]; then 
	_msg 'megasync instalado com sucesso'
	return 0
else
	_red "Função [_megasync] retornou erro."
	return 1
fi
}

#-----------------------------------------------------#

#=====================================================#
# opera
#=====================================================#
function _opera_stable_debian()
{
local opera_repo='deb [arch=amd64] https://deb.opera.com/opera-stable/ stable non-free'
local opera_file='/etc/apt/sources.list.d/opera-stable.list'
echo "$(_c 32)=> $(_c)Adicionando chaves agurade..."
sudo sh -c 'wget -q -O- http://deb.opera.com/archive.key | apt-key add -'

find /etc/apt -name *.list | xargs grep "^deb .*deb\.opera.* stable.*free$" 2> /dev/null

if [[ $? == '0' ]]; then
	_msg "Repositório $(_c 35)já$(_c) está disponível 'pulando'"

else
	echo "$opera_repo" | sudo tee "$opera_file"
	
fi

sudo sh -c 'apt update; apt install opera-stable -y'	
}

#-----------------------------------------------------#

function _opera_stable_fedora()
{
# https://www.blogopcaolinux.com.br/2017/07/Instalando-o-Opera-no-openSUSE-e-no-Fedora.html
# https://rpm.opera.com/manual.html

	sudo rpm --import https://rpm.opera.com/rpmrepo.key

	echo '[opera]' | sudo tee /etc/yum.repos.d/opera.repo
	{
		echo "name=Opera packages"
		echo "type=rpm-md"
		echo "baseurl=https://rpm.opera.com/rpm"
		echo "gpgcheck=1"	
		echo "gpgkey=https://rpm.opera.com/rpmrepo.key"
		echo "enabled=1"
	} | sudo tee -a /etc/yum.repos.d/opera.repo

sudo dnf install opera-stable
}

#-----------------------------------------------------#

function _opera_stable_suse()
{
# https://www.blogopcaolinux.com.br/2017/07/Instalando-o-Opera-no-openSUSE-e-no-Fedora.html

	sudo zypper ref && sudo zypper up
	sudo rpm --import https://rpm.opera.com/rpmrepo.key

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

	sudo zypper ref && sudo zypper in opera-stable 
}

#-----------------------------------------------------#

function _opera_stable()
{
case "$sysname" in
	debian10|linuxmint19|ubuntu18.04) _opera_stable_debian;;
	fedora30|fedora31) _opera_stable_fedora;;
	opensuse-tumbleweed) _opera_stable_suse;;
	*) _prog_not_found; return 1;;
esac	


if [[ $? == '0' ]]; then 
	_msg 'opera-stable instalado com sucesso'

else
	echo "=> Função $(_c 31)_opera_stable $(_c) retornou [erro]"
	return 1
fi
}

#=====================================================#
# tor
#=====================================================#
function _tor_debian()
{
local tor_asc='https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc'
local tor_arq='/etc/apt/sources.list.d/torproject.list'

if [[ "$os_codename" == 'bionic' ]] || [[ "$os_codename" == 'tina' ]]; then
	local tor_repos='deb https://deb.torproject.org/torproject.org bionic main'

elif [[ "$os_codename" == 'buster' ]]; then
	local tor_repos='deb https://deb.torproject.org/torproject.org buster main'

fi

_msg "Adicionando chaves key e repositório"
echo "$tor_repos" | sudo tee "$tor_arq"
sudo sh -c 'curl https://deb.torproject.org/torproject.org/A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89.asc | gpg --import'
sudo sh -c 'gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -'
sudo sh -c 'apt update; apt install -y tor deb.torproject.org-keyring'
}


#=====================================================#
# proxychains
#=====================================================#
function _proxychains()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in proxychains-ng

	elif [[ -x $(command -v dnf 2>/dev/null) ]]; then
		sudo dnf install proxychains

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y proxychains && _tor_debian

	else
		_prog_not_found; return 1

	fi
}

#=====================================================#
# Qbittorrent.
#=====================================================#
function _qbittorrent()
{

if [[ -x $(command -v zypper 2> /dev/null) ]]; then
	sudo zypper in -y qbittorrent

elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
	sudo dnf install -y qbittorrent 

elif [[ -x $(command -v apt 2> /dev/null) ]]; then
	sudo apt install -y qbittorrent

fi
return "$?"
}

#=====================================================#
# TeamViwer
#=====================================================#

#-----------------------------------------------------#
# Requeriments teamviewer.
#-----------------------------------------------------#
# Debian/Ubuntu/Mint
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

# Fedora
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

#-----------------------------------------------------#

function _get_teamviewer()
{
# Função que apenas faz o download do teamviewer
# Se o sistema for Ubuntu/Debian/Mint está função faz o download do pacote ".deb"
# Se o sistema for Fedora, será feito o download do pacote ".rpm"
# Caso seja outra distro será baixado os pacotes ".tar.xz".
	
	local tw_pag='https://www.teamviewer.com/en/download/linux/' # Página de download.
	local tw_html=$(curl -SsL "$tw_pag" | grep "download.*linux.*64")

	local url_deb=$(echo "$tw_html" | grep -m 1 'amd64.deb' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local url_rpm=$(echo "$tw_html" | grep -m 1 'x86_64.rpm' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')
	local url_tar=$(echo "$tw_html" | grep -m 1 'amd64.tar' | awk '{print $2}' | sed 's/.*="//g;s/\".*//g')

	# Definir qual url será usada para baixar, de acordo com o sistema.
	case "$sysname" in
		debian10|linuxmint19|ubuntu18.04) local url="$url_deb";;
		fedora30|fedora31) local url="$url_rpm";;
		*) local url="$url_tar";;
	esac

	# Definir path + nome do arquivo de acordo com o sistema.
	case "$sysname" in
		debian10|linuxmint19|ubuntu18.04) local path_arq="$dir_user_cache/teamviewer_amd64.deb";;
		fedora30|fedora31) local path_arq="$dir_user_cache/teamviewer_x86_64.rpm";;
		*) local path_arq="$dir_user_cache/teamviewer_amd64.tar.xz";;
	esac
	

	_dow "$url" "$path_arq" --curl || return 1
}

#-----------------------------------------------------#

function _install_teamviewer_debian()
{
# https://www.teamviewer.com/en/download/linux/
# wget -O- https://download.teamviewer.com/download/linux/signature/TeamViewer2017.asc | sudo apt-key add -
# echo 'deb http://linux.teamviewer.com/deb stable main' > /etc/apt/sources.list.d/teamviewer.list
# echo 'deb http://linux.teamviewer.com/deb preview main' >> /etc/apt/sources.list.d/teamviewer.list
# sudo apt update; sudo apt install teamviewer
#
#local url='https://download.teamviewer.com/download/linux/teamviewer_amd64.deb'
#
	local path_arq="$dir_user_cache/teamviewer_amd64.deb"
	_get_teamviewer || return 1 # Download do arquivo ".deb".

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "=> Feito somente download."; return 0; }
	[[ -x $(command -v teamviewer 2> /dev/null) ]] && { _msg_pack_instaled 'teamviewer'; return 0; }

	_msg "Instalando os seguintes pacotes: ${array_tw_debian[@]}"
	echo ' '
	read -p "Pressione enter: " enter
	
	sudo apt install -y "${array_tw_debian[@]}"
	sudo dpkg --install "$path_arq"
	_quebrado # Remover pacotes quebrados.
}

#-----------------------------------------------------#

function _install_teamviewer_fedora()
{
	local path_arq="$dir_user_cache/teamviewer_x86_64.rpm"
	_get_teamviewer || return 1 # Download do arquivo ".rpm".

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "=> Feito somente download."; return 0; }
	[[ -x $(command -v teamviewer 2> /dev/null) ]] && { _msg_pack_instaled 'teamviewer'; return 0; }

	echo " "
	read -p "Pressione enter: " enter

	sudo dnf install "$path_arq"
}

#-----------------------------------------------------#

function _teamviewer_tar()
{
	local path_arq="$dir_user_cache/teamviewer_amd64.tar.xz"
	_get_teamviewer || return 1 # Download do arquivo ".tar.xz".

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "=> Feito somente download."; return 0; }
	[[ -x $(command -v teamviewer 2> /dev/null) ]] && { _msg_pack_instaled 'teamviewer'; return 0; }

	_msg "Instale os pacotes a seguir manualmente: ${array_tw_debian[@]}"
	echo " "
	read -p "Pressione enter: " enter

	"$Script_UnPack" "$path_arq" "$dir_temp" || {
		echo "=> Falha: $(_c 31)[unpack]$(_c) retornou erro."; return 1; 
	}

	cd "$dir_temp" && cd teamviewer
	chmod -R +x *
	sudo ./tv-setup install
}

#-----------------------------------------------------#

function _teamviewer()
{
# https://www.blogopcaolinux.com.br/2018/04/Instalando-o-TeamViewer-no-Debian-Ubuntu-e-Linux-Mint.html
	
	case "$sysname" in
		debian10|linuxmint19|ubuntu18.04) _install_teamviewer_debian;;
		fedora30|fedora31) _install_teamviewer_fedora;;
		*) _teamviewer_tar;;
	esac
}

#-----------------------------------------------------#

#=====================================================#
# Telegram
#=====================================================#
function _telegram()
{
# https://desktop.telegram.org/
# https://updates.tdesktop.com/tlinux/tsetup.1.8.15.tar.xz

	# Instalar gconf2.
	if [[ -x $(which zypper 2> /dev/null) ]]; then # Suse
		sudo zypper in gconf2

	elif [[ -x $(which dnf 2> /dev/null) ]]; then # Fedora
		sudo dnf install GConf2

	elif [[ -x $(which apt 2> /dev/null) ]]; then # Debian distros.
		sudo apt install -y gconf2

	fi

	local url_telegram='https://updates.tdesktop.com/tlinux/tsetup.1.8.15.tar.xz'
	local path_arq="$dir_user_cache/telegramsetup.1.8.15.tar.xz"

	_dow "$url_telegram" "$path_arq" --wget

	# --downloadonly
	[[ "$download_only" == 'on' ]] && { echo "$(_c 32)=> $(_c)Feito somente download."; return 0; }
	[[ -x $(command -v telegram 2> /dev/null) ]] && { _msg_pack_instaled 'telegram'; return 0; }

	"$Script_UnPack" "$path_arq" "$dir_temp"
	[[ $? == '0' ]] || { echo "$(cor 31)=> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

	_msg "Instalando"

	cd "$dir_temp" && mv -v $(ls -d Telegra*) "$dir_user_bin/telegram-amd64" 1> /dev/null
	chmod -R 755 "$dir_user_bin/telegram-amd64"
	ln -sf "$dir_user_bin/telegram-amd64/Telegram" "$dir_user_bin/telegram"
	telegram

	if [[ -x $(command -v telegram 2> /dev/null) ]]; then
		_msg 'telegram instalado com sucesso'
		return 0
	else
		echo "=> Função $(_c 31)_telegram $(_c) retornou [erro]"
		return 1
	fi
}

#=====================================================#
# Tixati
#=====================================================#
function _tixat_tar()
{
local path_arq="$1"

	"$Script_UnPack" "$path_arq" "$dir_temp" || { 
		echo "$(cor 31)=> $(cor)Falha: (unpack) retornou [Erro]"; return 1; 
	}

	echo "$(cor 32)=> $(cor)Instalando"

	cd "$dir_temp" && mv $(ls -d tixati*) "$dir_temp/tixati-amd64" 1> /dev/null
	chmod -R a+x "$dir_temp/tixati-amd64"

	sudo mv "$dir_temp"/tixati-amd64/tixati.desktop "${array_tixati_dirs[0]}" # .desktop
	sudo mv "$dir_temp"/tixati-amd64/tixati.png "${array_tixati_dirs[1]}" # PNG.
	sudo mv "$dir_temp"/tixati-amd64/tixati "${array_tixati_dirs[2]}" # binario.
	sudo mv "$dir_temp"/tixati-amd64 "${array_tixati_dirs[3]}" # dir /opt.

	# Atalho desktop
	cp -u "${array_tixati_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_tixati_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_tixati_dirs[0]}" ~/Desktop/ 2> /dev/null
	
	if [[ -x $(command -v tixati 2> /dev/null) ]]; then
		_msg 'tixati instalado com sucesso.' 
		#tixati & 
		return 0

	else
		echo "$(_c 31)=> Falha: tixati$(_c)"; return 1
	
	fi
}

#-----------------------------------------------------#

function _tixati()
{
# https://support.tixati.com/Release%20Verification

pag_tixati='https://www.tixati.com/download/linux.html' # Pagina de download do programa.
#local html=$(wget -q "$pag_tixati" -O- | egrep '(amd64.deb|x86_64.rpm|tar.gz)') # Html
local html=$(curl -sSL "$pag_tixati" | egrep '(amd64.deb|x86_64.rpm|tar.gz)') # Html

local url_deb=$(echo "$html" | grep -m 1 'amd64.deb' | sed 's/amd64.deb\".*/amd64.deb/g;s/.*\"//g') # .deb
local url_rpm=$(echo "$html" | grep -m 1 'x86_64.rpm' | sed 's/x86_64.rpm\".*/x86_64.rpm/g;s/.*\"//g') # .rpm
local url_tar=$(echo "$html" | grep -m 1 '.tar.gz' | sed 's/.tar.gz\".*/.tar.gz/g;s/.*\"//g') # .tar.gz
local url_tar_asc="${url_tar}.asc" # Arquivo .tar.gz.asc

local path_arq="$dir_user_cache/$(basename $url_tar)" # path_arq tar.gz
local path_arq_asc="$dir_user_cache/$(basename $url_tar_asc)"

_dow "$url_tar" "$path_arq" --curl # baixar somente .tar.gz - (qualquer linux)
_dow "$url_tar_asc" "$path_arq_asc" --curl # Arquivo de verificação .asc

	# --downloadonly
	[[ "$download_only" == 'on' ]] && { 
		echo "$(_c 32)=> $(_c)Feito somente download."
		return 0 
	}

	[[ -x $(command -v tixati 2> /dev/null) ]] && { 
		_msg_pack_instaled 'tixati' 
		return 0 
	}

	# Instalar gconf2.
	echo -e "$space_line"
	if _WHICH 'zypper'; then # Suse
		sudo zypper in gconf2

	elif _WHICH 'dnf'; then # Fedora
		sudo dnf install GConf2

	elif _WHICH 'apt'; then # Debian distros.
		sudo apt install -y gconf2

	elif _WHICH 'pacman'; then
		sudo pacman -S gtk2

	fi

	_green "Importando key tixati"
	curl -# -LS https://www.tixati.com/tixati.key -o- | gpg --import 

	# Gpg
	_verify_sig "$path_arq_asc" "$path_arq" || { 
		echo "$(_c 31)Falha gpg --verify $(_c)"
		rm "$path_arq" 2> /dev/nul
		rm "$path_arq_asc" 2> /dev/nul 
		return 1
	} 

	_tixat_tar "$path_arq" # Instalar o pacote baixado .tar.gz
}

#=====================================================#
# Tor
#=====================================================#

function _torbrowser()
{
	if [[ "$download_only" == 'on' ]]; then
		"$Script_TorBrowser" --install --downloadonly
	else
		"$Script_TorBrowser" --install
	fi
}

#-----------------------------------------------------#

#=====================================================#
# Uget
#=====================================================#
function _uget()
{
if [[ -x $(which zypper 2> /dev/null) ]]; then # Suse
	sudo zypper in -y uget

elif [[ -x $(which dnf 2> /dev/null) ]]; then # Fedora
	sudo dnf install uget

elif [[ -x $(which apt 2> /dev/null) ]]; then # Debian distros.
	sudo apt install -y uget

elif [[ -x $(which pkg 2> /dev/null) ]]; then # Freebsd.
	sudo pkg install -y uget

fi
}

#=====================================================#
# Youtube-dl
#=====================================================#
function _youtube_dl()
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

local path_arq_sig="$dir_user_cache/youtube-dl.sig"
local path_arq="$dir_user_cache/youtube-dl"   # Path+Nome.
local soma_sig='04d2edc85b80b59ffe46fdda3937b0074dfe10ede49fec6c36c609cd87841fcb' # sha256sum - .sig
	
	_dow "$url_ytdl_test" "$path_arq" --curl && _dow "$url_ytdl_sig" "$path_arq_sig" --curl
	
	# Asc
	_msg "Importando key."
	curl -# -LS "$url_ytdl_asc_philipp" -o- | gpg --import -
	curl -# -LS "$url_ytdl_asc_sergey" -o- | gpg --import -

	# Gpg
	_verify_sig "$path_arq_sig" "$path_arq" || { 
		_red"Falha [gpg --verify]"
		rm "$path_arq" 2> /dev/nul
		rm "$path_arq_sig" 2> /dev/nul 
		return 1
	}

	_msg "Instalando youtube-dl em ~/.local/bin"
	cp -u "$path_arq" "$dir_user_bin"/youtube-dl
	chmod +x "$dir_user_bin"/youtube-dl

	if [[ -x $(command -v youtube-dl 2> /dev/null) ]]; then
		_green "youtube-dl instalado com sucesso."; return 0

	else
		_red "Falha ao tentar instalar [youtube-dl]"; return 1

	fi

}

#=====================================================#
# Youtube-Dl-Gui
#=====================================================#
function _twodict_github()
{
	[[ -d "$dir_temp/twodict" ]] && sudo rm -rf "$dir_temp/twodict"

	github_twodict="https://github.com/MrS0m30n3/twodict.git"
	_gitclone "$github_twodict" || { _red "Função [_gitclone] retornou erro"; return 1; }

	_green "Instalando: twodict"

	cd "$dir_temp/twodict"
	if _WHICH 'python2'; then
		sudo python2 setup.py install
	elif _WHICH 'python2.7'; then
		sudo python2.7 setup.py install
	else
		_red "Falha: Instale o python2"
		return 1
	fi

	
	if [[ $? == '0' ]]; then 
		_white "twodict instalado com sucesso"
	else
		_red "Falha na instalação de: twodict"
		return 1
	fi
	echo -e "$space_line"

	if [[ -d "$dir_temp/twodict" ]]; then 
		cd "$dir_temp" && sudo rm -rf twodict
	fi
}

#--------------------------------------------------------#
function _youtube_dl_gui_tumbleweed()
{
# https://software.opensuse.org/download/package?package=youtube-dl-gui&project=openSUSE%3AFactory
url_opensuse_repo='https://download.opensuse.org/repositories'
url_youtube_dlg_tumbleweed="$url_opensuse_repo/openSUSE:/Factory/standard/noarch/youtube-dl-gui-0.4-1.7.noarch.rpm"
local path_arq="$dir_user_cache/$(basename $url_youtube_dlg_tumbleweed)"

	wget "$url_youtube_dlg_tumbleweed" -O "$path_arq" 
	if sudo zypper in "$path_arq"; then
		echo "$(_c 32 0)youtube-dl-gui instalado $(_c)"
		return 0
	else
		echo "$(_c 31)Falha youtube-dl-gui $(_c)"
		return 1
	fi
}

#--------------------------------------------------------#

function _youtube_dl_gui_pip() 
{

# ppa ubuntu.
# sudo sh -c 'add-apt-repository ppa:nilarimogard/webupd8; apt update'
# sudo apt install youtube-dlg --yes
#

# dependências.
sudo apt install python-wxgtk3.0 gettext python-pip python-twodict
pip install youtube-dlg 

# Prosseguir se a ação anterior não falhar.
if [[ -x $(command -v youtube-dl-gui 2> /dev/null) ]]; then

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

	chmod u+x "$arq_ytdl"
	cp -u "$arq_ytdl" ~/Desktop/ 2> /dev/null
	cp -u "$arq_ytdl" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "$arq_ytdl" ~/'Área de Trabalho'/ 2> /dev/null
	_green "Youtube-dl-gui instalado com sucesso." && return 0	
	
else
	_red "[-] A instalação de youtube-dl-gui falhou."
	return 1

fi
} 

#--------------------------------------------------------#

function _youtube_dl_gui_github()
{
	if _WHICH 'youtube-dl-gui'; then
		_msg "$(_c 32 2)Já$(_c) instalado, deseja reinstalar novamente $(_c 32 2)[s/n]$(_c) ?: "
		read sn
		[[ "${sn,,}" == 's' ]] || { return 0; }
	fi

#--------------------------------------------------------#

case "$sysname" in
	debian10) sudo apt install -y python-wxgtk3.0 gettext python-twodict;; 
	linuxmint19|ubuntu18.04) _youtube_dl_gui_pip; return 0;;
	ubuntu19.10) sudo apt install python-wxgtk3.0 gettext; _twodict_github;;
	fedora30|fedora31) sudo dnf install -y python2-wxpython; _twodict_github;;
	freebsd-12.0-release) sudo pkg install py27-wxPython30; _twodict_github;;
	opensuse-tumbleweed) _youtube_dl_gui_tumbleweed; return 0;;
	arch) sudo pacman -S python2-wxpython3; _twodict_github;;
	*) _prog_not_found; return 1;;
esac

#--------------------------------------------------------#

	github_youtube_dl_gui="https://github.com/MrS0m30n3/youtube-dl-gui.git"
	_gitclone "$github_youtube_dl_gui" || { _red "Função [_gitclone] retornou erro."; return 1; }

	cd "$dir_temp/youtube-dl-gui" && {
		if [[ -x $(command -v python2 2> /dev/null) ]]; then # Linux
			sudo python2 setup.py install

		elif [[ -x $(command -v python2.7 2> /dev/null) ]]; then # FreeBSD
			sudo python2.7 setup.py install
		fi
		}

	sudo rm -rf "$dir_temp/youtube-dl-gui" 2> /dev/null

	if _WHICH 'youtube-dl-gui'; then

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

		cp -u "$arq_ytdl" ~/'Área de Trabalho'/ 2> /dev/null
		cp -u "$arq_ytdl" ~/'Área de trabalho'/ 2> /dev/null
		cp -u "$arq_ytdl" ~/Desktop/ 2> /dev/null
		_green "Youtube-dl-gui instalado com sucesso."

	else
		# Falhou.
		_red "[-] Falha ao tentar instalar youtube-dl-gui."
		return 1
	fi
}

