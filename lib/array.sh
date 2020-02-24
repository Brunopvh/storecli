#!/usr/bin/env bash
#
#
# Este arquivo contém varias listas "arrays" que são usados
# por varios módulos é scripts deste conjunto de programas.
# RESUMO: é um compartilhamento de "arrays" que são usados varias vezes.
#

#==================================================#
#
#==================================================#
array_commands=(
'--configure'
'--downloadonly'
'-d'
'--help'
'--list'
'--logo'
'--quebrado'
'--upgrade'
'--version'
'install'
'remove'
)


#==================================================#
# Dir requeriments
#==================================================#
dir_user_bin=~/.local/bin
dir_themes=~/.themes
dir_user_applications=~/.local/share/applications
dir_user_icons=~/.local/share/icons
dir_user_cache=~/.cache/downloads
dir_user_config=~/.config
dir_temp="/tmp/StoreCli_$USER"

export array_user_dirs=(
"$dir_user_bin"
"$dir_user_applications"
"$dir_user_icons"
"$dir_user_cache"
"$dir_user_config"
"$dir_temp"
"$dir_themes"
)

#==================================================#
# Diretórios do [root]
#==================================================#
dir_root_applications='/usr/share/applications' # .desktops.
dir_root_icons='/usr/share/icons/hicolor' # .PGN.
dir_root_bin='/usr/local/bin'

export array_root_dirs=(
"$dir_root_applications"
"$dir_root_icons"
"$dir_root_bin"
)

#--------------------------------------------------#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#///////////////////////////////////////////////////////////////////
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Arrays dirs programs
#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#////////////////////////////////////////////////////////////
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#

# Android studio.
array_android_studio_dirs=(
"$dir_user_applications/jetbrains-studio.desktop" # .desktop
"$dir_user_icons/studio.png"
"$dir_user_bin/studio" # Link
"$dir_user_bin/android-studio" # Dir
)

# Libreoffice AppImage.
array_libreoffice_dirs=(
"$dir_user_applications/libreoffice.desktop" # .desktop
"$dir_user_bin/libreoffice-amd64.AppImage" # .AppImage
)

# Papirus
array_papirus_dirs=(
"$HOME/.icons/Papirus-Dark" 
"$HOME/.icons/Papirus" 
"$HOME/.icons/Papirus-Light" 
"$HOME/.icons/ePapirus"
)

# Pycharm
array_pycharm_dirs=( 
"$dir_user_applications/pycharm.desktop" # Lançador .desktop.
"$dir_user_icons/pycharm.png" # Icone png.
"$dir_user_bin/pycharm" # Atalho para execução.
"$dir_user_bin/pycharm-community" # Diretório de instalação.
)

# Sublime-text
array_sublime_dirs=(
"$dir_root_applications/sublime_text.desktop" # .desktop.
"$dir_root_icons/256x256/apps/sublime-text.png" # .png.
"$dir_root_bin/sublime" # Atalho para linha de comando.
'/opt/sublime_text' # Diretório.
)

# PeaZip
array_peazip_dirs=(
"$dir_root_applications/peazip.desktop" # .desktop
"$dir_root_icons/256x256/apps/peazip.png" # .png
"$dir_root_bin/peazip" # bin
'/opt/peazip-amd64' # Dir peazip
)

# Teamviewer
array_teamviewer_dirs=(
'/opt/teamviewer'
'/usr/bin/teamviewer'
"$dir_root_icons/16x16/apps/TeamViewer.png"
"$dir_root_icons/20x20/apps/TeamViewer.png"
"$dir_root_icons/24x24/apps/TeamViewer.png"
"$dir_root_icons/32x32/apps/TeamViewer.png"
"$dir_root_icons/48x48/apps/TeamViewer.png"
"$dir_root_icons/256x256/apps/TeamViewer.png"
"$dir_root_applications/com.teamviewer.TeamViewer.desktop"
'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.Desktop.service'
'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.service'
'/usr/share/polkit-1/actions/com.teamviewer.TeamViewer.policy'
'/etc/systemd/system/multi-user.target.wants/teamviewerd.service'
)

# Telegram
array_telegram_dirs=(
"$dir_user_applications/telegramdesktop.desktop" # .desktop
"$dir_user_icons/telegram.png" # .png
"$dir_user_bin/telegram" # bin
"$dir_user_bin/telegram-amd64" # Dir 
)

# Tixati
array_tixati_dirs=(
"$dir_root_applications/tixati.desktop" # .desktop
"$dir_root_icons/48x48/apps/tixati.png" # .png
"$dir_root_bin/tixati" # bin
'/opt/tixati-amd64' # Dir tixati
)

# Vscode
array_vscode_dirs=(
"$dir_user_applications/code.desktop" # Arquivo .desktop
"$dir_user_icons/code.png" # Icone png.
"$dir_user_bin/code" # Atalho para execução.
"$dir_user_bin/code-amd64" # Diretório de instalção.
)

#--------------------------------------------------#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#///////////////////////////////////////////////////////////////////
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#
# Arrays "Listas de programs disponíveis para instalação."
#
#\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
#////////////////////////////////////////////////////////////
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Acessórios
array_acessorios=(
'gnome-disk'
'veracrypt'
'woeusb'
)

# Desenvolvimento
array_dev=(
'android-studio'
'pycharm'
'sublime-text'
'vim'
'vscode'
)

# Escritório
array_escritorio=(
'atril'
'fontes-ms'
'libreoffice'
'libreoffice-appimage'
)

# Internet
array_internet=(
'google-chrome'
'megasync'
'opera-stable'
'proxychains'
'qbittorrent'
'teamviewer'
'telegram'
'tixati'
'torbrowser'
'uget'
'youtube-dl'
'youtube-dl-gui'
)

# Midia
array_midia=(
'codecs'
'gnome-mpv'
'parole'
'smplayer'
'vlc'
)

# Sistema
array_sistema=(
'bluetooth'
'compactadores'
'firmware-atheros'
'firmware-linux-nonfree'
'firmware-ralink'
'firmware-realtek'
'gnome-disk'
'peazip'
'virtualbox'
)

# Preferencias
array_preferencias=(
'papirus'
'ohmybash'
'ohmyzsh'
'sierra'
)

