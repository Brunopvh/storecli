#!/usr/bin/env bash
#
#


#=====================================================#
# Google chrome
#=====================================================#
function _google_chrome_debian()
{
local google_chrome_repo='deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main'
local google_chrome_file='/etc/apt/sources.list.d/google-chrome.list'	
echo "==> Adicionando key"
sudo sh -c 'wget -q -O- https://dl.google.com/linux/linux_signing_key.pub | apt-key add -'

find /etc/apt -name *.list | xargs grep "^deb .*google\.com/linux.*stable main" 2> /dev/null

if [[ $? == '0' ]]; then
	echo "==> $(cl 33)R$(cl)epositório $(cl 35)já$(cl) está disponível 'pulando'"

else
	echo "$(cl 32)==> $(cl)Adicionando repositório"
	echo "$google_chrome_repo" | sudo tee "$google_chrome_file"

fi

sudo sh -c 'aptitude update; aptitude install google-chrome-stable -y'	
}

#-----------------------------------------------------#

function _google_chrome_tumbleweed()
{
#wget -c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.rpm
echo "$(_c 32 0)==> $(_c)Adicionando key e repo"
sudo rpm --import https://dl.google.com/linux/linux_signing_key.pub 
sudo zypper ar -f http://dl.google.com/linux/chrome/rpm/stable/x86_64/ Google 

echo "$(_c 32)==> $(_c)Instalando google-chrome"


if sudo zypper in google-chrome-stable; then
	return 0
else
	return 1

fi
}

#-----------------------------------------------------#

function _google_chrome()
{
case "$sysname" in
	debian10) _google_chrome_debian;;
	opensuse-tumbleweed) _google_chrome_tumbleweed;;
	*) _prog_not_found; return 1;;
esac	

if [[ $? == '0' ]]; then 
	_info_msgs 'google-chrome instalado com sucesso'
	return 0
else
	echo "==> Função $(_c 31)_google_chrome $(_c) retornou [erro]"
	return 1
fi
}

#=====================================================#
# Cliente Mega Sync
#=====================================================#
function _megasync_suse_tumbleweed()
{
# https://www.blogopcaolinux.com.br/2017/02/Instalando-o-MEGA-Sync-no-openSUSE-e-Fedora.html

echo "$(_c 32 0)==> $(_c)Adicionando key e repo"
sudo rpm --import https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/repodata/repomd.xml.key
sudo zypper ar -f https://mega.nz/linux/MEGAsync/openSUSE_Tumbleweed/ MEGA
sudo zypper ref

echo "$(_c 32)==> $(_c)Instalando megasync"
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

	echo "$(_c 32)==> $(_c)Adicionando repositório e chaves agurade..."
	echo "$mega_repos" | sudo tee "$mega_file"

	sudo sh -c 'wget https://mega.nz/linux/MEGAsync/Debian_10.0/Release.key -O - | apt-key add -'
	sudo sh -c 'apt update; apt install -y megasync'
}


#-----------------------------------------------------#

function _megasync()
{
 
case "$sysname" in
	opensuse-tumbleweed) _megasync_suse_tumbleweed;;
	debian10) _megasync_debian10;;
	*) _prog_not_found; return 1;;

esac

if [[ $? == '0' ]]; then 
	_info_msgs 'megasync instalado com sucesso'
	return 0
else
	echo "==> Função $(_c 31)_megasync$(_c) retornou [erro]"
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
echo "$(cl 32)==> $(cl)Adicionando chaves agurade..."
sudo sh -c 'wget -q -O- http://deb.opera.com/archive.key | apt-key add -'

find /etc/apt -name *.list | xargs grep "^deb .*deb\.opera.* stable.*free$" 2> /dev/null

if [[ $? == '0' ]]; then
	echo "==> $(cl 33)R$(cl)epositório $(cl 35)já$(cl) está disponível 'pulando'"

else
	echo "$opera_repo" | sudo tee "$opera_file"
	
fi

sudo sh -c 'apt update; apt install opera-stable -y'	
}

#-----------------------------------------------------#

function _opera_stable()
{
case "$sysname" in
	debian10) _opera_stable_debian;;
	*) _prog_not_found; return 1;;
esac	


if [[ $? == '0' ]]; then 
	_info_msgs 'opera-stable instalado com sucesso'

else
	echo "==> Função $(_c 31)_opera_stable $(_c) retornou [erro]"
	return 1
fi
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
	sudo apt install -y proxychains

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
# Telegram
#=====================================================#
function _telegram()
{
# https://desktop.telegram.org/
# https://updates.tdesktop.com/tlinux/tsetup.1.8.15.tar.xz

local url_telegram='https://updates.tdesktop.com/tlinux/tsetup.1.8.15.tar.xz'
local path_arq="$dir_user_cache/telegramsetup.1.8.15.tar.xz"

_dow "$url_telegram" "$path_arq" --wget

# --downloadonly
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v telegram 2> /dev/null) ]] && { _msg_pack_instaled 'telegram'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv -v $(ls -d Telegra*) "$dir_user_bin/telegram-amd64" 1> /dev/null
chmod -R 755 "$dir_user_bin/telegram-amd64"
ln -sf "$dir_user_bin/telegram-amd64/Telegram" "$dir_user_bin/telegram"
telegram

if [[ -x $(command -v telegram 2> /dev/null) ]]; then
	_info_msgs 'telegram instalado com sucesso'
	return 0
else
	echo "==> Função $(_c 31)_telegram $(_c) retornou [erro]"
	return 1
fi
}

#=====================================================#
# Tixati
#=====================================================#
function _tixat_tar()
{
local path_arq="$1"
"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv $(ls -d tixati*) "$dir_temp/tixati-amd64" 1> /dev/null
chmod -R a+x "$dir_temp/tixati-amd64"

sudo mv "$dir_temp"/tixati-amd64/tixati.desktop "${array_tixati_dirs[0]}" # .desktop
sudo mv "$dir_temp"/tixati-amd64/tixati.png "${array_tixati_dirs[1]}" # PNG.
sudo mv "$dir_temp"/tixati-amd64/tixati "${array_tixati_dirs[2]}" # binario.
sudo mv "$dir_temp"/tixati-amd64 "${array_tixati_dirs[3]}" # dir.
	
_info_msgs 'tixati instalado'
tixati &	
}

#-----------------------------------------------------#

function _tixati()
{
pag_tixati='https://www.tixati.com/download/linux.html' # Pagina de download do programa.
local html=$(wget -q "$pag_tixati" -O- | egrep '(amd64.deb|x86_64.rpm|tar.gz)') # Html
local url_deb=$(echo "$html" | grep -m 1 'amd64.deb' | sed 's/amd64.deb\".*/amd64.deb/g;s/.*\"//g') # .deb
local url_rpm=$(echo "$html" | grep -m 1 'x86_64.rpm' | sed 's/x86_64.rpm\".*/x86_64.rpm/g;s/.*\"//g') # .rpm
local url_tar=$(echo "$html" | grep -m 1 '.tar.gz' | sed 's/.tar.gz\".*/.tar.gz/g;s/.*\"//g') # .tar.gz

# Atribuir path_arq tar.gz
path_arq="$dir_user_cache/$(basename $url_tar)"

_dow "$url_tar" "$path_arq" --curl # baixar somente .tar.gz - (qualquer linux)

# --downloadonly
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v tixati 2> /dev/null) ]] && { _msg_pack_instaled 'tixati'; return 0; }

# Instalar gconf2.
if [[ -x $(which zypper 2> /dev/null) ]]; then # Suse
	sudo zypper in gconf2

elif [[ -x $(which dnf 2> /dev/null) ]]; then # Fedora
	sudo dnf install GConf2

elif [[ -x $(which apt 2> /dev/null) ]]; then # Debian distros.
	sudo apt install -y gconf2

fi

_tixat_tar "$path_arq"
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


