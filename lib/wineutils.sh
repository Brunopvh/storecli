#!/usr/bin/env bash

# Variáveis globais para o wine.
path_python3_portable=~/".wine/drive_c/python37/python.exe"


_python37_windows32()
{
	# Instalar o executável do python3
	local url_python37_windows32='https://www.python.org/ftp/python/3.7.6/python-3.7.6rc1-amd64.exe'
	local path_file_python37="$DirDownloads/$(basename $url_python37_windows32)"

	if ! is_executable wine; then
		red "Necessário ter o wine instalado para prosseguir"
		_install_wine	
	fi

	if ! is_executable winetricks; then
		system_pkgmanager winetricks
	fi

	download "$url_python37_windows32" "$path_file_python37" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar
	msg "Executando: winetricks atmlib cmd"
	"$SCRIPT_WINETRICKS_LOCAL" atmlib cmd
	msg "Instalando: python37" 
	wine "$path_file_python37"
}

_python37_windows32_portable()
{
	# Instalar o python 3.7 versão portable em C:\python37
	local url_python37_portable='https://www.python.org/ftp/python/3.7.6/python-3.7.6-embed-win32.zip'
	local path_file_python37_portable="$DirDownloads/$(basename $url_python37_portable)"

	if ! is_executable wine; then
		question "Necessário ter o wine instalado para prosseguir - deseja continuar" || return 1
		_install_wine
	fi

	if ! is_executable winetricks; then
		_install_script_winetricks
	fi

	download "$url_python37_portable" "$path_file_python37_portable" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar
	echo -e "(_python37_windows32_portable) - executando: winetricks atmlib dotnet45 cmd"
	"$SCRIPT_WINETRICKS_LOCAL" atmlib dotnet45 cmd

	unpack_archive "$path_file_python37_portable" $DirUnpack || return 1
	mkdir -p "$HOME"/.wine/drive_c/python37
	cd "$DirUnpack"
	echo -e "Copiando arquivos para ... $HOME/.wine/drive_c/python37/"
	cp -n * "$HOME"/.wine/drive_c/python37/ 1> /dev/null
	echo -e "(_python37_windows32_portable) - executando: wine $HOME/.wine/drive_c/python37/python.exe -V"
	wine "$HOME"/.wine/drive_c/python37/python.exe -V
}

_get_pip_windows()
{
	# Instalar o pip via wine.
	local url_get_pip='https://bootstrap.pypa.io/get-pip.py'
	local path_file_getpip="$DirDownloads/get-pip.py"
	local path_python3_portable="$HOME/.wine/drive_c/python37/python.exe"

	_python37_windows32_portable
	if [[ ! -f "$path_python3_portable" ]]; then
		sred "(_get_pip_windows): python3 não encontrado em ... $path_python3_portable"
		return 1
	fi

	download "$url_get_pip" "$path_file_getpip" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar

	cd "$HOME"/.wine/drive_c/python37/
	echo -e "Executando: wine $path_python3_portable $path_file_getpip"
	wine "$path_python3_portable" "$path_file_getpip"
}

_install_wxpython_win32()
{
	# https://wxpython.org/pages/downloads/
	local url_wxpython_win32='https://sourceforge.net/projects/wxpython/files/wxPython/3.0.2.0/wxPython3.0-win32-3.0.2.0-py27.exe/download'
	local path_file_wxpython="$DirDownloads/wxPython3.0-win32-3.0.2.0-py27.exe"
	download "$url_wxpython_win32" "$path_file_wxpython" || return 1
	msg "Instalando ... $path_file_wxpython"
	wine "$path_file_wxpython" || return 1
	return 0
}

_python_twodict_github_windows()
{
	# Instalar python twodict (python versão 2).
	cd $DirGitclone
	gitclone 'https://github.com/MrS0m30n3/twodict.git' $DirGitclone || return 1
	cd twodict
	msg "Executando ... wine python.exe setup.py install --user"
	wine python.exe setup.py install --user 1> /dev/null 2>&1
}


_youtube_dlgui_file_desktop_windows()
{
	[[ $(id -u) == 0 ]] && return 1
	
	# Criar arquivo .desktop na HOME para o usuario atual.
	print_info "Criando arquivo .desktop"
	local file_desktop=~/".local/share/applications/youtube-dl-gui-windows.desktop"

	echo '[Desktop Entry]' > "$file_desktop"
	{
		echo "Encoding=UTF-8"
		echo "Name=Youtube-DLG-Wine"
		echo "Exec=wine python.exe -m youtube_dl_gui"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=youtube-dl-gui"
		echo "Type=Application"
		echo "Categories=Internet;Network;"
	} >> "$file_desktop"

	chmod u+x "$file_desktop"
	cp -u "$file_desktop" ~/Desktop/ 2> /dev/null
	cp -u "$file_desktop" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "$file_desktop" ~/'Área de Trabalho'/ 2> /dev/null
	is_executable gtk-update-icon-cache && gtk-update-icon-cache
}


_youtube_dlgui_windows_exe()
{
	# O youtube-dl-gui para windows via wine está funcionando perfeitamente no fedora 32, porém
	# não funciona nas outras distros.
	# https://mrs0m30n3.github.io/youtube-dl-gui/
	# https://github.com/MrS0m30n3/youtube-dl-gui
	# https://pypi.org/project/twodict/
	# https://www.python.org/downloads/release/python-278/

	local url_youtube_dlgui_win='https://github.com/MrS0m30n3/youtube-dl-gui/releases/download/0.4/youtube-dl-gui-0.4-win-setup.zip'
	local url_youtube_dl='https://yt-dl.org/downloads/2020.07.28/youtube-dl.exe'
	local url_visual_c='https://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe'
	local url_gnu_gettext='https://github.com/mlocati/gettext-iconv-windows/releases/download/v0.20.2-v1.16/gettext0.20.2-iconv1.16-static-32.exe'
	local url_python27='https://www.python.org/ftp/python/2.7.8/python-2.7.8.msi'
	local path_file_youtube_dl="$DirDownloads/youtube-dl.exe"
	local path_file_youtube_dlgui="$DirDownloads/youtube-dl-gui-0.4-win-setup.zip"
	local path_file_visual_c="$DirDownloads/$(basename $url_visual_c)"
	local path_file_gnu_gettext="$DirDownloads/$(basename $url_gnu_gettext)"
	local path_file_python27="$DirDownloads/$(basename $url_python27)"
	
	download "$url_youtube_dlgui_win" "$path_file_youtube_dlgui" || return 1
	download "$url_visual_c" "$path_file_visual_c" || return 1 
	download "$url_gnu_gettext" "$path_file_gnu_gettext" || return 1
	
	if ! is_executable wine; then
		red "Necessário ter o wine instalado para prosseguir"
		question "Gostaria de instalar o wine e winetricks agora" || return 1
		_install_wine || return 1	
	fi

	if ! is_executable winetricks; then
		_install_script_winetricks
	fi
	
	echo -e "Entrando no diretório ... $DirDownloads"
	cd "$DirDownloads"
	msg "Instalando ... atmlib"; winetricks atmlib
	msg "Instalando: dotnet45"; winetricks dotnet45
	msg "Instalando: visual C"; wine "$path_file_visual_c"
	msg "Instalando: GNU gettext"
	wine "$path_file_gnu_gettext"
	msg "Instalando: python2.7"
	winetricks python27
	_python37_windows32_portable
	_get_pip_windows  
	_install_wxpython_win32
	
	unpack_archive "$path_file_youtube_dlgui" || return 1
	cd "$DirUnpack"
	msg "Executando: wine pip.exe install twodict"
	wine pip.exe install twodict
	msg "Instalando: youtubedlg-0.4.exe" 
	wine youtubedlg-0.4.exe
}


_youtube_dlgui_windows_from_source()
{
	# O youtube-dl-gui para windows via wine está funcionando perfeitamente no fedora 32, porém
	# não funciona nas outras distros.
	# https://mrs0m30n3.github.io/youtube-dl-gui/
	# https://github.com/MrS0m30n3/youtube-dl-gui
	# https://pypi.org/project/twodict/
	# https://www.python.org/downloads/release/python-278/

	local url_youtube_dlgui_win='https://github.com/MrS0m30n3/youtube-dl-gui/releases/download/0.4/youtube-dl-gui-0.4-win-setup.zip'
	local url_youtube_dl_gui_master='https://github.com/MrS0m30n3/youtube-dl-gui/archive/master.zip'
	local url_visual_c='https://download.microsoft.com/download/5/B/C/5BC5DBB3-652D-4DCE-B14A-475AB85EEF6E/vcredist_x86.exe'
	local url_python27='https://www.python.org/ftp/python/2.7.8/python-2.7.8.msi'
	local REPO_GETTEXT='https://github.com/mlocati/gettext-iconv-windows/releases/download'
	local url_gnu_gettext="$REPO_GETTEXT/v0.20.2-v1.16/gettext0.20.2-iconv1.16-static-32.exe"

	local path_file_youtube_dlgui="$DirDownloads/youtube-dl-gui.zip"
	local path_file_visual_c="$DirDownloads/$(basename $url_visual_c)"
	local path_file_gnu_gettext="$DirDownloads/$(basename $url_gnu_gettext)"
	local path_file_python27="$DirDownloads/$(basename $url_python27)"
	
	download "$url_youtube_dl_gui_master" "$path_file_youtube_dlgui" || return 1
	download "$url_visual_c" "$path_file_visual_c" || return 1 
	download "$url_gnu_gettext" "$path_file_gnu_gettext" || return 1
	
	if ! is_executable wine; then
		red "Necessário ter o wine instalado para prosseguir"
		question "Gostaria de instalar o wine e winetricks agora" || return 1
		_install_wine || return 1	
	fi

	is_executable winetricks || _install_script_winetricks
	
	echo -e "Entrando no diretório ... $DirDownloads"
	cd "$DirDownloads"
	msg "Instalando ... atmlib"; winetricks atmlib
	msg "Instalando: dotnet45"; winetricks dotnet45
	msg "Instalando: visual C"; wine "$path_file_visual_c"
	msg "Instalando: GNU gettext"; wine "$path_file_gnu_gettext"
	msg "Instalando: python2.7"; winetricks python27              # Instalar python2.7 para windows
	_python_twodict_github_windows   # Instalar twodict versão do github.  
	_install_wxpython_win32          # Instalar wxpython versão python2
	
	unpack_archive "$path_file_youtube_dlgui" $DirUnpack || return 1
	cd "$DirUnpack"
	mv youtube-* youtube-dl-gui
	cd youtube-dl-gui || return 1
	cp -u ./youtube_dl_gui/data/pixmaps/youtube-dl-gui.png "$DIR_ICONS"/youtube-dl-gui.png 1> /dev/null
	msg "Executando ... wine python.exe setup.py install --user"
	wine python.exe setup.py install --user
	_youtube_dlgui_file_desktop_windows
}

_youtube_dlgui_windows()
{
	_youtube_dlgui_windows_exe
	#_youtube_dlgui_windows_from_source
}

_epsxe_windows()
{
	# ePSXe win 32
	# CONFIGURAÇÃO PATH NO WINE
	# https://www.windows-commandline.com/set-path-command-line/
	#
	# echo %path%
	# setx path "%path%;c:\directoryPath" 
	# setx path "%path%;c:\epsxe-win"
	# setx path "%path%;c:\dir1\dir2"
	# pathman /as C:\epsxe-win
	#
	# REMOVE DIRETÓRIO DO PATH
	# pathman /rs directoryPath	
	#
	#
	local URL_EPSXE_WIN='http://www.epsxe.com/files/ePSXe205.zip'  # V2.0.5
	local PATH_FILE_EPSXE="$DirDownloads/$(basename $URL_EPSXE_WIN)"
	local HASH_FILE_ZIP='46e1a7ad3dc9c75763440c153465cdccc9a3ba367e3158542953ece4bcdb7b4f' # V2.0.5

	# Criar o diretório de instalação para epsxe.
	mkdir -p "${destinationFilesEpsxeWin32[dir]}"
	_clear_temp_dirs

	download "$URL_EPSXE_WIN" "$PATH_FILE_EPSXE" || return 1
	__shasum__ "$PATH_FILE_EPSXE" "$HASH_FILE_ZIP" || return 1
	unpack_archive "$PATH_FILE_EPSXE" || return 1
	cd "$DirUnpack"
	cp -R -n * "${destinationFilesEpsxeWin32[dir]}"/

	yellow "Criando script para execução do ePSXe"
	echo '#!/bin/sh' > "${destinationFilesEpsxeWin32[file_script]}"
	echo -e "\nWINEPREFIX=$HOME/.wine"  >> "${destinationFilesEpsxeWin32[file_script]}"
	echo -e "\ncd ${destinationFilesEpsxeWin32[dir]}" >> "${destinationFilesEpsxeWin32[file_script]}"
	echo -e "wine ePSXe.exe" >> "${destinationFilesEpsxeWin32[file_script]}"


	echo "[Desktop Entry]" > "${destinationFilesEpsxeWin32[file_desktop]}"
	{
	  echo "Type=Application"
	  echo "Terminal=false"
	  echo "Exec=${destinationFilesEpsxeWin32[file_script]}"
	  echo "Name=ePSXe-Win32"
	  echo "Comment=Instalado via storecli github: https://github.com/Brunopvh/storecli"
	  echo "Categories=Game;Emulator;"
	} >> "${destinationFilesEpsxeWin32[file_desktop]}"

	chmod +x "${destinationFilesEpsxeWin32[file_script]}"
	chmod +rwx "${destinationFilesEpsxeWin32[file_desktop]}"

	if ! is_executable wine; then
		sred "Necessário ter o wine instalado para prosseguir"
		_install_wine
	fi

	if ! is_executable winetricks; then
		sred "Necessário ter o winetricks instalado para prosseguir"
		_install_script_winetricks 
	fi
	
	yellow "Instalado: directx9 atmlib"
	winetricks directx9 atmlib
	"${destinationFilesEpsxeWin32[file_script]}"
}


_install_wine_ubuntu()
{
	# Instalação do wine no Ubuntu/Linuxmint.
	cd "$DirTemp"
	_clear_temp_dirs

	case "$VERSION_CODENAME" in
		tricia|bionic) 
			repo_wine_stable='deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
			repo_libfaudio='deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./'
			url_key_libfaudio='https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key'
			;;
		focal|ulyana)
			system_pkgmanager 'wine' || return 1
			return 0 
			;;
		*) red "Intale o wine manualmente usado o 'apt'" 
			return 1
			;;
	esac
	# Adicionar suporte a ARCH i386.
	_DPKG --add-architecture i386
	apt_key_add 'https://dl.winehq.org/wine-builds/winehq.key'
	apt_key_add "$url_key_libfaudio"
	add_repo_apt "$repo_wine_stable" /etc/apt/sources.list.d/wine-stable.list
	add_repo_apt "$repo_libfaudio" /etc/apt/sources.list.d/libfaudio.list
	system_pkgmanager 'libfaudio0:i386' || return 1

	requeriments_wine_debian=(
		'wine-stable-i386' 
		'wine-stable-amd64' 
		'wine-stable' 
		'winehq-stable'
		)

	for APP in "${requeriments_wine_debian[@]}"; do
		system_pkgmanager "$APP" || break
	done
}

_install_wine_debian()
{
	# Instalação do wine no Debian buster.
	cd "$DirTemp"
	_clear_temp_dirs

	case "$VERSION_CODENAME" in
		buster) 
			url_key_wine_stable='https://dl.winehq.org/wine-builds/winehq.key'
			repo_wine_stable='deb https://dl.winehq.org/wine-builds/debian/ buster main'
			repo_libfaudio='deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./'
			url_key_libfaudio='https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key'
			;;
		*) red "Intale o wine manualmente usado o 'apt'"
			return 1
			;;
	esac
	# Adicionar suporte a ARCH i386.
	_DPKG --add-architecture i386
	apt_key_add "$url_key_wine_stable" || return 1
	apt_key_add "$url_key_libfaudio" || return 1
	add_repo_apt "$repo_wine_stable" /etc/apt/sources.list.d/wine.list
	add_repo_apt "$repo_libfaudio" /etc/apt/sources.list.d/libfaudio.list
	_APT update || return 1
	system_pkgmanager 'libfaudio0:i386' || return 1

	requeriments_wine_debian=('wine-stable-i386' 'wine-stable-amd64' 'wine-stable' 'winehq-stable')
	for APP in "${requeriments_wine_debian[@]}"; do
		system_pkgmanager "$APP" || break
	done
}

_install_wine_fedora()
{
	system_pkgmanager "wine"
}

_install_wine_archlinux()
{
	echo -e "Entrando no diretório ... $dir_of_executable/scripts"
	cd "$dir_of_executable/scripts"
	echo -e "Executando ... sudo ./addrepo.py --repo arch"
	# Adicionar suporte ao repositório multilib no archlinux.
	sudo ./addrepo.py --repo arch
	_PACMAN -Sy
	system_pkgmanager wine 'wine-mono' 'wine-gecko'
}

_install_script_winetricks()
{
	if ! is_executable wine; then
		red "(_install_script_winetricks): necessário instalar o 'wine' antes de prosseguir."
		return 1
	fi

	# Instalar o script winetricks
	URL_WINETRICKS='https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'
	PATH_FILE_WINETRICKS="$DirDownloads/winetricks.sh"
	SCRIPT_WINETRICKS="/usr/local/bin/winetricks"

	# Winetricks requeriments
	requeriments_winetricks=(zenity cabextract unzip aria2)
	requeriments_winetricks_debian=(binutils fuseiso p7zip-full policykit-1 xz-utils)
	requeriments_winetricks_suse=(binutils fuseiso p7zip polkit xdg-utils xz)

	# Instalar as dependências de acordo com cada distro.
	system_pkgmanager "${requeriments_winetricks[@]}"

	if [[ -f '/etc/debian_version' ]]; then # Sistemas baseados em debian.
		system_pkgmanager "${requeriments_winetricks_debian[@]}"
	elif [[ "$OS_ID" == 'fedora' ]]; then
		system_pkgmanager "${requeriments_winetricks_suse[@]}"
	elif [[ "$OS_ID" == 'arch' ]]; then
		system_pkgmanager "${requeriments_winetricks[@]}"

	else
		red "Seu sistema não tem suporte a instalação do winetricks apartir deste programa."
		return 1
	fi

	download "$URL_WINETRICKS" "$PATH_FILE_WINETRICKS" || return 1
	echo -e "Instalando winetricks em ... /usr/local/bin/winetricks"
	sudo cp -u "$PATH_FILE_WINETRICKS" "$SCRIPT_WINETRICKS"
	sudo chown root:root "$SCRIPT_WINETRICKS"
	sudo chmod a+x "$SCRIPT_WINETRICKS"
	if is_executable winetricks; then
		yellow "Winetricks instalado com sucesso"
		return 0
	else
		red "(_install_script_winetricks): falha na instalação de winetricks"
		return 1
	fi
}

_install_wine()
{
	case "$OS_ID" in
		debian) _install_wine_debian;;
		ubuntu|linuxmint) _install_wine_ubuntu;;
		fedora) _install_wine_fedora;;
		arch) _install_wine_archlinux;;
	esac
}

