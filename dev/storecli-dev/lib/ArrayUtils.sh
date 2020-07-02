#!/usr/bin/env bash
#

#=============================================================#
# Informação com dirtórios e arquivos de alguns programas, para
# para tornar a instalação e remoção dos programas mais prática.
#   Também serve para gerenciar o destino de alguns programas no 
# disco rígido.
#=============================================================#

#=============================================================#
# Acessorios
#=============================================================#
# Etcher
declare -A destinationFilesEtcher
destinationFilesEtcher=(
	[file_desktop]="$directoryUSERapplications/balena-etcher-electron.desktop"
	[file_appimage]="$directoryUSERbin/balena-etcher-electron"
	)

#=============================================================#
# Desenvolvimento
#=============================================================#
# Android Studio
declare -A destinationFilesAndroidStudio
destinationFilesAndroidStudio=(
	[file_desktop]="$directoryUSERapplications/jetbrains-studio.desktop"
	[file_png]="$directoryUSERicon/studio.png"
	[link]="$directoryUSERbin/studio"
	[dir]="$directoryUSERbin/android-studio"
	)

declare -A destinationFilesPycharm
destinationFilesPycharm=(
	[file_desktop]="$directoryUSERapplications/pycharm.desktop"
	[file_png]="$directoryUSERicon/pycharm.png"
	[link]="$directoryUSERbin/pycharm"
	[dir]="$directoryUSERbin/pycharm-community"
	)

declare -A destinationFilesSublime
destinationFilesSublime=(
	[file_desktop]="$directoryROOTapplications/sublime_text.desktop"
	[file_png]="$directoryROOTicon/256x256/apps/sublime-text.png"
	[link]="$directoryROOTbin/sublime"
	[dir]="/opt/sublime_text"
	)

declare -A destinationFilesVscode
destinationFilesVscode=(
	[file_desktop]="$directoryUSERapplications/code.desktop"  
	[file_png]="$directoryUSERicon/code.png"             
	[link]="$directoryUSERbin/code"                  
	[dir]="$directoryUSERbin/code-amd64"            
)

#=============================================================#
# Escritorio
#=============================================================#

# Libreoffice AppImage.
declare -A destinationFilesLibreofficeAppimage
destinationFilesLibreofficeAppimage=(
	[file_desktop]="$directoryUSERapplications/libreoffice-appimage.desktop"   
	[file_appimage]="$directoryUSERbin/libreoffice-appimage"                            
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
	[file_desktop]="$directoryUSERapplications/telegramdesktop.desktop" 
	[file_png]="$directoryUSERicon/telegram.png"                  
	[link]="$directoryUSERbin/telegram"                       
	[dir]="$directoryUSERbin/telegram-amd64"                  
)


declare -A destinationFilesTixati
destinationFilesTixati=(
	[file_desktop]="$directoryROOTapplications/tixati.desktop"
	[file_png]="$directoryROOTicon/48x48/apps/tixati.png" 
	[file_bin]="$directoryROOTbin/tixati"                                       
)


destinationFilesTeamviewer=(
	'/opt/teamviewer'
	'/usr/bin/teamviewer'
	"$directoryROOTicon/16x16/apps/TeamViewer.png"
	"$directoryROOTicon/20x20/apps/TeamViewer.png"
	"$directoryROOTicon/24x24/apps/TeamViewer.png"
	"$directoryROOTicon/32x32/apps/TeamViewer.png"
	"$directoryROOTicon/48x48/apps/TeamViewer.png"
	"$directoryROOTicon/256x256/apps/TeamViewer.png"
	"$directoryROOTapplications/com.teamviewer.TeamViewer.desktop"
	'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.Desktop.service'
	'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.service'
	'/usr/share/polkit-1/actions/com.teamviewer.TeamViewer.policy'
	'/etc/systemd/system/multi-user.target.wants/teamviewerd.service'
)

#=============================================================#
# Sistema
#=============================================================#
# PeaZip
declare -A destinationFilesPeazip
destinationFilesPeazip=(
	[file_desktop]="$directoryUSERapplications/peazip.desktop" 
	[file_png]="$directoryUSERicon/peazip.png"
	[file_bin]="$directoryUSERbin/peazip"
	[dir]="$directoryUSERbin/peazip-amd64"
)


# Refind
declare -A destinationFilesRefind
destinationFilesRefind=(  
	[file_script]="$directoryROOTbin/refind-install"
	[dir]="/opt/refind"
)

declare -A destinationFilesStacer
destinationFilesStacer=( 
	[file_desktop]="$directoryUSERapplications/stacer.desktop"  
	[file_appimage]="$directoryUSERbin/stacer"                            
)


#=============================================================#
# Preferências
#=============================================================#

# Papirus
declare -A destinationFilesPapirus
destinationFilesPapirus=(
	[papirus_dark]="$directoryUSERicon/Papirus-Dark" 
	[papirus_light]="$directoryUSERicon/Papirus-Light" 
	[epapirus]="$directoryUSERicon/ePapirus"
	[papirus]="$directoryUSERicon/Papirus" 
)

declare -A destinationFilesEpsxe
destinationFilesEpsxe=(
	[file_desktop]="$directoryUSERapplications/epsxe.desktop"
	[file_png]="$directoryUSERicon/ePSxe.svg"
	[link]="$directoryUSERbin/epsxe"
	[dir]="$directoryUSERbin/epsxe-amd64"
)


#=============================================================#
# Listagem de todos os pacotes disponíveis para instalação.
#=============================================================#
programs_acessory=(
	'etcher'
	'gnome-disk'
	'veracrypt'
	'woeusb'
	)

programs_development=(
	'android-studio'
	codeblocks
	pycharm
	'sublime-text'
	vim
	vscode
	)

programs_office=(
	atril
	'fontes-ms'
	libreoffice
	'libreoffice-appimage'
	)

programs_browser=(
	chromium
	firefox
	google-chrome
	opera-stable
	torbrowser
	)

programs_internet=(
	megasync
	proxychains
	qbittorrent
	skype
	teamviewer
	telegram
	tixati
	uget
	youtube-dl
	youtube-dl-gui
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
	gparted
	peazip
	refind
	stacer
	virtualbox
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
