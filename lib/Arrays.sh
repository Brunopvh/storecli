#!/usr/bin/env bash
#
# Este módulo/lib tem informações na forma de lista/arrays sobre
# os programas disponíveis para instalação e também sobre os 
# diretórios e arquivos de alguns programas depois de instalados
# no sistema, principalmente dos programas instalados via TAR.GZ
# muitos tem básicamente os arquivos .PNG, .DESKTOP, .BIN, etc
# para facilitar a remoção destes pacotes (storecli remove <pacote>)
# na propria instalação este script usa estes arrays para mover os 
# arquivos e diretório (em $HOME/.local/bin, /opt, /usr/local/bin)
#
# EX:
#   Na instalação do editor sublime-text, ele e descompactado
# no diretório de descompactação (variável "$Dir_Unpack") e
# em seguida cada arquivo e movido para seu destino especifico
# .desktop, .icon, .bin, etc todos estes caminhos absolutos estão 
# no array "$array_sublime_dirs" que é usado tanto para instalção 
# quanto para remoção deste pacote - (storecli install sublime-texte -
# storecli remove sublime-text).
#

#=============================================================#
# Diretórios que devem ser compartilhados com os outros scripts e libs.
#=============================================================#
dir_temp="/tmp/space_storecli_$USER/temp"
Dir_Unpack="/tmp/space_storecli_$USER/unpack"
Dir_User_Bin="$HOME/.local/bin"
Dir_User_Themes="$HOME/.themes"
Dir_User_Application="$HOME/.local/share/applications"
Dir_User_Icons="$HOME/.local/share/icons"
#Dir_User_Icons="$HOME/.icons"
Dir_Downloads="$HOME/.cache/downloads"
Dir_User_Config="$HOME/.config"

export array_user_dirs=(
	"$dir_temp"
	"$Dir_Unpack"
	"$Dir_User_Bin"
	"$Dir_User_Themes"
	"$Dir_User_Application"
	"$Dir_User_Icons"
	"$Dir_Downloads"
	"$Dir_User_Config"
)

# Criar diretórios na HOME.
for dir in "${array_user_dirs[@]}"; do
	mkdir -p "$dir"
done

#=============================================================#
# Diretórios do [root]
#=============================================================#
Dir_Root_Applications='/usr/share/applications' # .desktops.
Dir_Root_icons='/usr/share/icons/hicolor'       # .PGN.
Dir_Root_bin='/usr/local/bin'

export array_root_dirs=(
	"$Dir_Root_Applications"
	"$Dir_Root_icons"
	"$Dir_Root_bin"
)

#=============================================================#
# Arrays com informações sobre alguns pacotes.
#=============================================================#

# Android studio.
array_android_studio_dirs=(
"$Dir_User_Application/jetbrains-studio.desktop" # .desktop
"$Dir_User_Icons/studio.png"
"$Dir_User_Bin/studio" # Link
"$Dir_User_Bin/android-studio" # Dir
)

# Libreoffice AppImage.
array_libreoffice_dirs=(
"$Dir_User_Application/libreoffice.desktop" # .desktop
"$Dir_User_Bin/libreoffice-amd64.AppImage" # .AppImage
)

# Etcher
array_etcher_dirs=( 
	"$Dir_Root_Applications/balena-etcher-electron.desktop"  # .desktop
	"/opt/etcher-amd64.AppImage"                             # .AppImage
	"/usr/bin/balena-etcher-electron"                        # Link simbólico
)

# Papirus
array_papirus_dirs=(
	"$Dir_User_Icons/Papirus-Dark" 
	"$Dir_User_Icons/Papirus-Light" 
	"$Dir_User_Icons/ePapirus"
	"$Dir_User_Icons/Papirus" 
)

# Pycharm
array_pycharm_dirs=( 
"$Dir_User_Application/pycharm.desktop" # Lançador .desktop.
"$Dir_User_Icons/pycharm.png"           # Icone png.
"$Dir_User_Bin/pycharm"                 # Atalho para execução.
"$Dir_User_Bin/pycharm-community"       # Diretório de instalação.
)

# Sublime-text
array_sublime_dirs=(
"$Dir_Root_Applications/sublime_text.desktop" # .desktop.
"$Dir_Root_icons/256x256/apps/sublime-text.png" # .png.
"$Dir_Root_bin/sublime" # Atalho para linha de comando.
'/opt/sublime_text' # Diretório.
)

# PeaZip
array_peazip_dirs=(
"$Dir_Root_Applications/peazip.desktop" # .desktop
"$Dir_Root_icons/256x256/apps/peazip.png" # .png
"$Dir_Root_bin/peazip" # bin
'/opt/peazip-amd64' # Dir peazip
)

# Refind
array_refind_dirs=(
"/opt/refind"   # Diretório
"$Dir_Root_bin/refind-install"              # Script
)

# Teamviewer
array_teamviewer_dirs=(
'/opt/teamviewer'
'/usr/bin/teamviewer'
"$Dir_Root_icons/16x16/apps/TeamViewer.png"
"$Dir_Root_icons/20x20/apps/TeamViewer.png"
"$Dir_Root_icons/24x24/apps/TeamViewer.png"
"$Dir_Root_icons/32x32/apps/TeamViewer.png"
"$Dir_Root_icons/48x48/apps/TeamViewer.png"
"$Dir_Root_icons/256x256/apps/TeamViewer.png"
"$Dir_Root_Applications/com.teamviewer.TeamViewer.desktop"
'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.Desktop.service'
'/usr/share/dbus-1/services/com.teamviewer.TeamViewer.service'
'/usr/share/polkit-1/actions/com.teamviewer.TeamViewer.policy'
'/etc/systemd/system/multi-user.target.wants/teamviewerd.service'
)

# Telegram
array_telegram_dirs=(
"$Dir_User_Application/telegramdesktop.desktop" # .desktop
"$Dir_User_Icons/telegram.png" # .png
"$Dir_User_Bin/telegram" # bin
"$Dir_User_Bin/telegram-amd64" # Dir 
)

# Tixati
array_tixati_dirs=(
"$Dir_Root_Applications/tixati.desktop" # .desktop
"$Dir_Root_icons/48x48/apps/tixati.png" # .png
"$Dir_Root_bin/tixati"                  # bin
'/opt/tixati-amd64'                     # Dir tixati
)

# Vscode
array_vscode_dirs=(
"$Dir_User_Application/code.desktop"  # Arquivo .desktop
"$Dir_User_Icons/code.png"             # Icone png.
"$Dir_User_Bin/code"                   # Atalho para execução.
"$Dir_User_Bin/code-amd64"             # Diretório de instalção.
)


#=============================================================#
# Lista dos programas disponíveis para instalação.
#=============================================================#

# Acessórios
array_acessorios=(
'etcher'
'gnome-disk'
'veracrypt'
'woeusb'
)

# Desenvolvimento
array_dev=(
'android-studio'
'codeblocks'
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
	'chromium'
	'firefox'
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
	'celluloid'
	'cinema'
	'codecs'
	'spotify'
	'gnome-mpv'
	'parole'
	'smplayer'
	'totem'
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
	'gparted'
	'peazip'
	'refind'
	'stacer'
	'virtualbox'
)

# Wine
array_wine=(
'wine'
'winetricks'
)

# Preferencias
array_preferencias=(
'papirus'
'ohmybash'
'ohmyzsh'
)

# Gnome Shell Extensões
# Fedora
array_gnome_shell_fedora=(
	'gnome-tweaks' 
	'gnome-shell-extension-topicons-plus'
	'gnome-shell-extension-drive-menu' 
	'gnome-shell-extension-dash-to-dock.noarch'
	'gnome-backgrounds-extras'
	'verne-backgrounds-gnome'
)

# OpenSuse
array_gnome_shell_suse=(
	'gnome-tweaks' 
)

# ArchLinux
array_gnome_shell_archlinux=(
	'gnome-tweaks' 'gnome-backgrounds'
)

# Debian
array_gnome_shell_debian=(
	'gnome-tweaks' 
	'gnome-shell-extension-top-icons-plus' 
	'gnome-shell-extension-dashtodock'
)
