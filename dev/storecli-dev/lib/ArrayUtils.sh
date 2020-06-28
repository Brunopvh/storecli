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
	java
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