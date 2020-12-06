#!/usr/bin/env bash
#

#
# Este arquivo guarda informações como dirtórios e arquivos de alguns programas
# para tornar a instalação e remoção dos programas mais prática.
#   Também serve para guardar o destino de alguns programas no 
# disco rígido, essas informações são guardadas em ARRAYS para facilitar
# a idendificação desses arquivos e diretórios.

# Verificar se as variáveis com os diretórios de configuração e instalação dos
# aplicativos foram definidas.
[[ -z $DIR_DESKTOP_USER ]] && DIR_DESKTOP_USER=~/.local/share/applications
[[ -z $DIR_BIN_USER ]] && DIR_BIN_USER=~/.local/bin
[[ -z $DIR_ICON_USER ]] && DIR_ICON_USER=~/.local/share/icons
[[ -z $DIR_THEMES_USER ]] && DIR_THEMES_USER=~/.themes

[[ ! -d $DIR_DESKTOP_USER ]] && mkdir "$DIR_DESKTOP_USER"
[[ ! -d $DIR_BIN_USER ]] && mkdir "$DIR_BIN_USER"
[[ ! -d $DIR_ICON_USER ]] && mkdir "$DIR_ICON_USER"
[[ ! -d $DIR_THEMES_USER ]] && mkdir "$DIR_THEMES_USER"
[[ ! -d $DIR_DESKTOP_USER ]] && mkdir "$DIR_DESKTOP_USER"

#=============================================================#
# Diretórios do root
#=============================================================#

[[ -z $DIR_BIN_ROOT ]] && DIR_BIN_ROOT='/usr/local/bin'
[[ -z $DIR_ICON_ROOT ]] && DIR_ICON_ROOT='/usr/share/icons/hicolor'
[[ -z $DIR_THEME_ROOT ]] && DIR_THEME_ROOT='/usr/share/themes/'
[[ -z $DIR_DESKTOP_ROOT ]] && DIR_DESKTOP_ROOT='/usr/share/applications'

if [[ ! -d "$DIR_BIN_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_BIN_ROOT"
	sudo mkdir "$DIR_BIN_ROOT"
fi


if [[ ! -d "$DIR_ICON_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_ICON_ROOT"
	sudo mkdir "$DIR_ICON_ROOT"
fi


if [[ ! -d "$DIR_THEME_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_THEME_ROOT"
	sudo mkdir "$DIR_THEME_ROOT"
fi


if [[ ! -d "$DIR_DESKTOP_ROOT" ]]; then
	echo -e "Criando o diretório: $DIR_DESKTOP_ROOT"
	sudo mkdir "$DIR_DESKTOP_ROOT"
fi


#=============================================================#
# Acessorios
#=============================================================#
# Etcher
declare -A destinationFilesEtcher
destinationFilesEtcher=(
	[file_desktop]="$DIR_DESKTOP_USER/balena-etcher-electron.desktop"
	[file_appimage]="$DIR_BIN_USER/balena-etcher-electron"
	)

declare -A destinationFilesStorecli
destinationFilesStorecli=(
	[file_desktop]="$DIR_DESKTOP_USER/storecli.desktop"
	[link]="$DIR_BIN_USER/storecli"
	[dir]="$DIR_BIN_USER/storecli-amd64"
	)

#=============================================================#
# Desenvolvimento
#=============================================================#
# Android Studio
declare -A destinationFilesAndroidStudio
destinationFilesAndroidStudio=(
	[file_desktop]="$DIR_DESKTOP_USER/jetbrains-studio.desktop"
	[file_png]="$DIR_ICON_USER/studio.png"
	[link]="$DIR_BIN_USER/studio"
	[dir]="$DIR_BIN_USER/android-studio"
	)

declare -A destinationFilesIdeaic
destinationFilesIdeaic=(
	[file_desktop]="$DIR_DESKTOP_USER/jetbrains-idea.desktop"
	[file_png]="$DIR_ICON_USER/idea.png"
	[file_script]="$DIR_BIN_USER/idea"
	[dir]="$DIR_BIN_USER/idea-IC"
	)

declare -A destinationFilesPycharm
destinationFilesPycharm=(
	[file_desktop]="$DIR_DESKTOP_USER/pycharm.desktop"
	[file_png]="$DIR_ICON_USER/pycharm.png"
	[link]="$DIR_BIN_USER/pycharm"
	[dir]="$DIR_BIN_USER/pycharm-community"
	)

declare -A destinationFilesSublime
destinationFilesSublime=(
	[file_desktop]="$DIR_DESKTOP_ROOT/sublime_text.desktop"
	[file_png]="$DIR_ICON_ROOT/256x256/apps/sublime-text.png"
	[link]="$DIR_BIN_ROOT/sublime"
	[dir]="/opt/sublime_text"
	)

declare -A destinationFilesVscode
destinationFilesVscode=(
	[file_desktop]="$DIR_DESKTOP_USER/code.desktop"  
	[file_png]="$DIR_ICON_USER/code.png"             
	[link]="$DIR_BIN_USER/code"                  
	[dir]="$DIR_BIN_USER/code-amd64"            
)

#=============================================================#
# Escritorio
#=============================================================#

# Libreoffice AppImage.
declare -A destinationFilesLibreofficeAppimage
destinationFilesLibreofficeAppimage=(
	[file_desktop]="$DIR_DESKTOP_USER/libreoffice-appimage.desktop"   
	[file_appimage]="$DIR_BIN_USER/libreoffice-appimage"                            
)

#=============================================================#
# Midia
#=============================================================#


#=============================================================#
# Navegadores
#=============================================================#

#=============================================================#
# Internet
#=============================================================#

declare -A destinationFilesTelegram
destinationFilesTelegram=(
	[file_desktop]="$DIR_DESKTOP_USER/telegramdesktop.desktop" 
	[file_png]="$DIR_ICON_USER/telegram.png"                  
	[link]="$DIR_BIN_USER/telegram"                       
	[dir]="$DIR_BIN_USER/telegram-amd64"                  
)


declare -A destinationFilesTixati
destinationFilesTixati=(
	[file_desktop]="$DIR_DESKTOP_ROOT/tixati.desktop"
	[file_png]="$DIR_ICON_ROOT/48x48/apps/tixati.png" 
	[file_bin]="$DIR_BIN_ROOT/tixati"                                       
)

destinationFilesTeamviewer=(
	'/opt/teamviewer'
	'/usr/bin/teamviewer'
	"$DIR_ICON_ROOT/16x16/apps/TeamViewer.png"
	"$DIR_ICON_ROOT/20x20/apps/TeamViewer.png"
	"$DIR_ICON_ROOT/24x24/apps/TeamViewer.png"
	"$DIR_ICON_ROOT/32x32/apps/TeamViewer.png"
	"$DIR_ICON_ROOT/48x48/apps/TeamViewer.png"
	"$DIR_ICON_ROOT/256x256/apps/TeamViewer.png"
	"$DIR_DESKTOP_ROOT/com.teamviewer.TeamViewer.desktop"
	'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.Desktop.service'
	'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.service'
	'/usr/share/polkit-1/actions/com.teamviewer.TeamViewer.policy'
	'/etc/systemd/system/multi-user.target.wants/teamviewerd.service'
)

declare -A destinationFilesYoutubeDlGuiUser
destinationFilesYoutubeDlGuiUser=(
	[file_desktop]="$DIR_DESKTOP_USER/youtube-dl-gui.desktop"
	[file_png]="$DIR_ICON_USER/youtube-dl-gui.png" 
	[pixmaps]="$DIR_ICON_USER/youtube-dl-gui"
	[file_script]="$DIR_BIN_USER/youtube-dl-gui"  
	[dir]="$DIR_BIN_USER/youtube_dl_gui"                                     
)

#=============================================================#
# Sistema
#=============================================================#
# Cpu-X

declare -A destinationFilesCpux
destinationFilesCpux=(
	[file_desktop]="$DIR_DESKTOP_USER/cpux.desktop"  
	[file]="$DIR_BIN_USER/cpux"                        
)


# PeaZip
declare -A destinationFilesPeazip
destinationFilesPeazip=(
	[file_desktop]="$DIR_DESKTOP_ROOT/peazip.desktop" 
	[file_png]="$DIR_ICON_ROOT/256x256/apps/peazip.png"
	[script]="/usr/local/bin/peazip"
	[dir]="/opt/peazip-amd64"
)


# Refind
declare -A destinationFilesRefind
destinationFilesRefind=(  
	[file_script]="$DIR_BIN_ROOT/refind-install"
	[dir]="/opt/refind"
)

declare -A destinationFilesStacer
destinationFilesStacer=( 
	[file_desktop]="$DIR_DESKTOP_USER/stacer.desktop"  
	[file_appimage]="$DIR_BIN_USER/stacer"                            
)


#=============================================================#
# Preferências
#=============================================================#

# Papirus
declare -A destinationFilesPapirus
destinationFilesPapirus=(
	[papirus_dark]="$DIR_ICON_USER/Papirus-Dark" 
	[papirus_light]="$DIR_ICON_USER/Papirus-Light" 
	[epapirus]="$DIR_ICON_USER/ePapirus"
	[papirus]="$DIR_ICON_USER/Papirus" 
)

declare -A destinationFilesEpsxe
destinationFilesEpsxe=(
	[file_desktop]="$DIR_DESKTOP_USER/epsxe.desktop"
	[file_png]="$DIR_ICON_USER/ePSxe.svg"
	[link]="$DIR_BIN_USER/epsxe"
	[dir]="$DIR_BIN_USER/epsxe-amd64"
)

declare -A destinationFilesEpsxeWin32
destinationFilesEpsxeWin32=(
	[file_desktop]="$DIR_DESKTOP_USER/epsxe-win.desktop"
	[file_script]="$DIR_BIN_USER/epsxe-win"
	[dir]="$HOME/.wine/drive_c/epsxe-win"
	)


#=============================================================#
# Listagem de todos os pacotes disponíveis para instalação.
#=============================================================#
programs_acessory=(
	etcher
	gnome-disk
	microsoft-teams
	storecli-gui
	veracrypt
	woeusb
	)

programs_development=(
	android-studio
	codeblocks
	idea
	pycharm
	sublime-text
	vim
	vscode
	python37-windows
	python37-windows-portable
	)

programs_office=(
	atril
	'fontes-ms'
	libreoffice
	'libreoffice-appimage'
	)

programs_browser=(
	chromium
	edge
	firefox
	google-chrome
	opera-stable
	torbrowser
	)

programs_internet=(
	clipgrab
	megasync
	proxychains
	qbittorrent
	skype
	teamviewer
	telegram
	tixati
	uget
	'youtube-dl'
	'youtube-dl-gui'
	)


programs_midia=(
	celluloid
	cinema
	codecs
	spotify
	gnome-mpv
	parole
	smplayer
	totem
	vlc
	)

programs_system=(
	bluetooth
	compactadores
	cpu-x
	genymotion
	google-earth
	gparted
	peazip
	refind
	stacer
	timeshift
	virtualbox
	virtualbox-additions
	virtualbox-extensionpack
	)

programs_preferences=(
	ohmybash
	ohmyzsh
	papirus
	sierra
	)

programs_gnomeshell=(
	dash-to-dock
	drive-menu
	gnome-backgrounds
	gnome-tweaks
	topicons-plus
	)


programs_wine=(
	wine
	winetricks
	epsxe-win
	python37-windows
	python37-windows-portable
	youtube-dl-gui-windows
	)
