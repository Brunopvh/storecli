#!/usr/bin/env bash
#     
#    
#

source "$Lib_array"

function _msg_pack_instaled()
{
echo "==> já instalado para remove-lo use $( basename $0) $(cl 32)r$(cl)emove $1"
}

#-----------------------------------------------------#

function _c()
{
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

#=====================================================#
# Quebrado
#=====================================================#
function _quebrado()
{
[[ ! -x $(command -v apt 2> /dev/null) ]] && { _prog_not_found; return 1; }	

echo "$(cl 32)==> $(cl)Limpando cache aguarde..."
sudo sh -c 'apt-get clean; apt-get remove -y; apt-get autoremove -y'

echo "$(cl 32)==> $(cl)Executando dpkg --configure -a"
sudo sh -c 'apt-get install -f -y; dpkg --configure -a; apt --fix-broken install'

echo "$(cl 32)==> $(cl)Executando apt update"
sudo apt update 
#sudo apt-get install --yes --force-yes -f 

echo -e "\n$(cl 33)[OK]$(cl)"
}

#-----------------------------------------------------#

#=====================================================#
# Gnome-Disk
#=====================================================#
function _gnome_disk()
{
	case "$sysname" in
		debian10) sudo apt install gnome-disk-utility;;
		*) _prog_not_found; return 1;;
	esac
}

#-----------------------------------------------------#

#=====================================================#
# Veracrypt
#=====================================================#
function _veracrypt()
{
url_veracrypt_default='https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2'
veracrypt_pag='https://www.veracrypt.fr/en/Downloads.html'
veracrypt_html=$(wget -q "$veracrypt_pag" -O- | grep -m 1 "http.*verac.*tar.bz2" | awk '{print $2}')
veracrypt_url_dow=$(echo "$veracrypt_html" | sed 's/bz2\".*/bz2/g;s/.*\"//g' | sed 's/&#43\;/+/g')
veracrypt_pacote=$(basename "$veracrypt_url_dow")
local path_arq="$dir_user_cache/$veracrypt_pacote"

_dow "$veracrypt_url_dow" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v veracrypt 2> /dev/null) ]] && { _msg_pack_instaled 'veracrypt'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv $(ls veracrypt*setup-gui-x64) "$dir_temp/veracryptx64" 1> /dev/null
chmod +x "$dir_temp/veracryptx64"
sudo "$dir_temp/veracryptx64"
[[ -d "$dir_temp" ]] && { cd "$dir_temp" && sudo rm -rf *; }
}

#=====================================================#
#=====================================================#
# Desenvolvimento.
#=====================================================#
#=====================================================#

#=====================================================#
# Pycharm
#=====================================================#
function _pycharm()
{
local url_pycharm='https://download.jetbrains.com/python/pycharm-community-2019.1.2.tar.gz'
local path_arq="$dir_user_cache/pycharm-community-2019.1.2.tar.gz"

_dow "$url_pycharm" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v pycharm 2> /dev/null) ]] && { _msg_pack_instaled 'pycharm'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv $(ls -d pycharm*) "${array_pycharm_dirs[3]}" 1> /dev/null
cp -u "${array_pycharm_dirs[3]}"/bin/pycharm.png "${array_pycharm_dirs[1]}"

# Criar atalho para execução na linha de comando.
touch "${array_pycharm_dirs[2]}"
echo "#!/usr/bin/env bash" > "${array_pycharm_dirs[2]}"
echo -e "\ncd ${array_pycharm_dirs[3]}/bin/ && ./pycharm.sh" >> "${array_pycharm_dirs[2]}"
chmod +x "${array_pycharm_dirs[2]}"

	touch "${array_pycharm_dirs[0]}"
	echo "[Desktop Entry]" > "${array_pycharm_dirs[0]}"
    {
        echo "Name=Pycharm Community"
        echo "Version=1.0"
        echo "Icon=${array_pycharm_dirs[1]}"
        echo "Exec=pycharm"
        echo "Terminal=false"
        echo "Categories=Development;IDE;"
        echo "Type=Application"
    } >> "${array_pycharm_dirs[0]}"

cp -u "${array_pycharm_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
cp -u "${array_pycharm_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null 
cp -u "${array_pycharm_dirs[0]}" ~/Desktop/ 2> /dev/null 

if [[ -x $(which pycharm 2> /dev/null) ]]; then
	_info_msgs 'pycharm instalado com sucesso'
	#pycharm

else
	echo "==> Função $(cl 31)_pycharm$(cl) retornou [erro]"
	return 1	
fi
}

#-----------------------------------------------------#

#=====================================================#
# Sublime-text
#=====================================================#
function _sublime_text()
{
"$Script_PackTargz" install sublime-text
}

#=====================================================#
# Vscode.
#=====================================================#
function _vscode_debian()
{
local url_code_debian='https://go.microsoft.com/fwlink/?LinkID=760868'
local path_arq="$dir_user_cache/vscode-amd64.deb"
_dow "$url_code_debian" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	[[ -x $(command -v code) ]] && { _msg_pack_instaled 'code'; return 0; }

sudo dpkg --install "$path_arq"

}

#-----------------------------------------------------#

function _vscode()
{
local url_vscode_tar='https://go.microsoft.com/fwlink/?LinkID=620884'
local path_arq="$dir_user_cache/vscode.tar.gz"

_dow "$url_vscode_tar" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v code) ]] && { _msg_pack_instaled 'code'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv $(ls -d VSCode*) "${array_vscode_dirs[3]}" 2> /dev/null
cp -u "${array_vscode_dirs[3]}"/resources/app/resources/linux/code.png "${array_vscode_dirs[1]}"

# Criar atalho para execução na linha de comando.
touch "${array_vscode_dirs[2]}"
echo "#!/usr/bin/env bash" > "${array_vscode_dirs[2]}"
echo -e "\ncd ${array_vscode_dirs[3]}/bin/ && ./code" >> "${array_vscode_dirs[2]}"
chmod +x "${array_vscode_dirs[2]}"

# Criar entrada no menu do sistema.
echo "[Desktop Entry]" > "${array_vscode_dirs[0]}" 
	{
		echo "Name=Code"
		echo "Version=1.0"
		echo "Icon=code"
		echo "Exec=${array_vscode_dirs[3]}/bin/code"
		echo "Terminal=false"
		echo "Categories=Development;IDE;" 
		echo "Type=Application"
	} >> "${array_vscode_dirs[0]}"

cp -u "${array_vscode_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null 
cp -u "${array_vscode_dirs[0]}" ~/Desktop/ 2> /dev/null 
cp -u "${array_vscode_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null

if [[ -x "$(which code 2> /dev/null)" ]]; then
	_info_msgs 'code instalado'
	code
else
	echo "==> Função $(cl 31)_vscode$(cl) retornou [erro]"
	return 1
fi 

}

#=====================================================#
#=====================================================#
# Internet
#=====================================================#
#=====================================================#

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

#-----------------------------------------------------#

#=====================================================#
# Midia
#=====================================================#

#=====================================================#
# Codecs
#=====================================================#

function _codecs_debian()
{
local deb_multimidia='http://www.deb-multimedia.org'
local url_wcodecs="$deb_multimidia/pool/non-free/w/w64codecs/w64codecs_20071007-dmo2_amd64.deb"
local soma_wcodecs="cc36b9ff0dce8d4f89031756163d54acdd4e800d6106f07db2031fdf77e90392"
local path_arq="$dir_user_cache/w64codecs_amd64.deb"

_dow "$url_wcodecs" "$path_arq" --curl
	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }

_check_sum "$path_arq" "$soma_wcodecs"
if [[ $? == '0' ]]; then
	sudo apt install -y --install-recommends ffmpeg ffmpegthumbnailer
	sudo apt install lame
	sudo dpkg --install "$path_arq"

else
	echo "$(cl 31)==> $(cl)Abortando a instalação"; exit 1

fi
}

#-----------------------------------------------------#

# Codecs
function _codecs()
{
case "$sysname" in
	freebsd12.0-release) sudo pkg install -y ffmpeg ffmpegthumbnailer gstreamer-ffmpeg;;
	debian10) _codecs_debian;;
	*) _prog_not_found;;

esac
}

# Vlc
function _vlc()
{
case "$sysname" in
	debian10) sudo apt install -y vlc;;
	freebsd12.0-release) sudo pkg install -y vlc;;
	*) _prog_not_found;;

esac
}

#-----------------------------------------------------#

#=====================================================#
# Parole
#=====================================================#
function _parole()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y parole

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y parole

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y parole

	else
		_prog_not_found; return 1

	fi

}

#-----------------------------------------------------#

#=====================================================#
# Gnome mpv
#=====================================================#
function _gnome_mpv()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y gnome-mpv

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y gnome-mpv smplayer-themes

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y gnome-mpv

	else
		_prog_not_found; return 1

	fi

}


#-----------------------------------------------------#

#=====================================================#
# Smplayer
#=====================================================#
function _smplayer()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y smplayer

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y smplayer

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y smplayer

	else
		_prog_not_found; return 1

	fi

}

#-----------------------------------------------------#

#=====================================================#
# Sistema
#=====================================================#

#=====================================================#
# Gparted
#=====================================================#
function _gparted()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y gparted

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y gparted

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y gparted

	else
		_prog_not_found; return 1

	fi

}

#=====================================================#
# PeaZip
#=====================================================#
function _peazip()
{
peazip_server='https://osdn.net/dl/peazip'
peazip_pag='https://osdn.net/projects/peazip/downloads'

peazip_html=$(wget -q "$peazip_pag" -O- | grep -m 1 "portable.*tar.gz" | awk '{print $6}')
peazip_pacote=$(echo "$peazip_html" | sed 's/.*peazip_portable/peazip_portable/g;s/\/\".*//g')
peazip_url_download="$peazip_server/$peazip_pacote"
local path_arq="$dir_user_cache/$peazip_pacote"

_dow "$peazip_url_download" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	
	[[ -x $(command -v peazip 2> /dev/null) ]] && { _msg_pack_instaled 'peazip'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"

[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv -v $(ls -d peazip*) "$dir_temp/peazip-amd64" 1> /dev/null
chmod -R +x "$dir_temp/peazip-amd64"

sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.desktop "${array_peazip_dirs[0]}" # .desktop
sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.png "${array_peazip_dirs[1]}" # PNG.
sudo mv "$dir_temp"/peazip-amd64/peazip "${array_peazip_dirs[2]}" # binario.
sudo mv "$dir_temp"/peazip-amd64 "${array_peazip_dirs[3]}" # dir.

if [[ -x $(which peazip 2> /dev/null) ]]; then
	_info_msgs; echo "==> peazip instalado com sucesso."
	return 0

else
	echo "$(cor 31)==> $(cor)Falha"
	return 1

fi
}

#-----------------------------------------------------#

#=====================================================#
# Preferencias.
#=====================================================#
function _papirus()
{
# Está função NÃO está em uso no momento.
#
local url_papirus='https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh'
local path_arq="$dir_user_cache/papirus.run"

	_dow "$url_papirus" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	chmod +x "$path_arq"
	"$path_arq"
}


#=====================================================#
# packmanager install
#=====================================================#
function _packmanager_install()
{
for arg in "$@"; do
	if [[ "$arg" == '--downloadonly' ]] || [[ "$arg" == '-d' ]]; then
		export download_only='on'
	fi
done

while [[ "$1" ]]; do
	case "$1" in
#-------------------- desenvolvimento -------------------#
		gnome-disk) _gnome_disk;;
		veracrypt) _veracrypt;;

#-------------------- desenvolvimento -------------------#
		pycharm) _pycharm;;
		sublime-text) _sublime_text;;
		vscode) _vscode;;

#-------------------- internet --------------------------#
		google-chrome) _google_chrome;;
		megasync) _megasync;;
		opera-stable) _opera_stable;;
		proxychains) _proxychains;;
		qbittorrent) _qbittorrent;;
		telegram) _telegram;;
		tixati) _tixati;;
		torbrowser) _torbrowser;;
		uget) _uget;;

#-------------------- midia --------------------------#
		codecs) _codecs;;
		vlc) _vlc;;
		parole) _parole;;
		gnome-mpv) _gnome_mpv;;
		smplayer) _smplayer;;

#-------------------- sistema ---------------------------#
		gparted) _gparted;;
		peazip) _peazip;;

#-------------------- preferencias ---------------------------#
		icones-papirus) "$Script_Papirus";;

		--downloadonly) echo -en "\r";;
		-d) echo -en "\r";;
		install) echo -ne "\r";;
		*) echo "==> Programa indisponível: $(cl 31)$1 $(cl)";;
	esac
	shift
done

}
