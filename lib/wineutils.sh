#!/usr/bin/env bash

# Variáveis globais para o wine.
path_python3_portable="$HOME/.wine/drive_c/python37/python.exe"


_python37_windows32()
{
	# Instalar o executável do python3
	local url_python37_windows32='https://www.python.org/ftp/python/3.7.6/python-3.7.6rc1-amd64.exe'
	local path_file_python37="$DirDownloads/$(basename $url_python37_windows32)"

	if ! is_executable wine; then
		_red "Necessário ter o wine instalado para prosseguir"
		_install_wine	
	fi

	if ! is_executable winetricks; then
		__pkg__ winetricks
	fi

	__download__ "$url_python37_windows32" "$path_file_python37" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar
	_msg "Executando: winetricks atmlib cmd"
	"$SCRIPT_WINETRICKS_LOCAL" atmlib cmd
	_msg "Instalando: python37" 
	wine "$path_file_python37"
}

_python37_windows32_portable()
{
	# Instalar o python 3.7 versão portable em C:\python37
	local url_python37_portable='https://www.python.org/ftp/python/3.7.6/python-3.7.6-embed-win32.zip'
	local path_file_python37_portable="$DirDownloads/$(basename $url_python37_portable)"

	if ! is_executable wine; then
		_sred "Necessário ter o wine instalado para prosseguir"
		_install_wine
	fi

	if ! is_executable winetricks; then
		_install_script_winetricks
	fi

	__download__ "$url_python37_portable" "$path_file_python37_portable" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar
	_print "(_python37_windows32_portable) - executando: winetricks atmlib dotnet45 cmd"
	"$SCRIPT_WINETRICKS_LOCAL" atmlib dotnet45 cmd

	_unpack "$path_file_python37_portable" || return 1
	mkdir -p "$HOME"/.wine/drive_c/python37
	cd "$DirUnpack"
	_print "Copiando arquivos para ... $HOME/.wine/drive_c/python37/"
	cp -n * "$HOME"/.wine/drive_c/python37/
	_print "(_python37_windows32_portable) - executando: wine $HOME/.wine/drive_c/python37/python.exe -V"
	wine "$HOME"/.wine/drive_c/python37/python.exe -V
}

_get_pip_windows()
{
	# Instalar o pip via wine.
	local url_get_pip='https://bootstrap.pypa.io/get-pip.py'
	local path_file_getpip="$DirDownloads/get-pip.py"
	local path_python3_portable="$HOME/.wine/drive_c/python37/python.exe"

	if [[ ! -f "$path_python3_portable" ]]; then
		_sred "(_get_pip_windows): python3 não encontrado em ... $path_python3_portable"
		return 1
	fi

	__download__ "$url_get_pip" "$path_file_getpip" || return 1
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0 # Somente baixar

	cd "$HOME"/.wine/drive_c/python37/
	_print "Executando: wine $path_python3_portable $path_file_getpip"
	wine "$path_python3_portable" "$path_file_getpip"
}

_install_wxpython_win32()
{
	# https://wxpython.org/pages/downloads/
	local url_wxpython_win32='https://sourceforge.net/projects/wxpython/files/wxPython/3.0.2.0/wxPython3.0-win32-3.0.2.0-py27.exe/download'
	local path_file_wxpython="$DirDownloads/wxPython3.0-win32-3.0.2.0-py27.exe"
	__download__ "$url_wxpython_win32" "$path_file_wxpython" || return 1
	_msg "Instalando ... $path_file_wxpython"
	wine "$path_file_wxpython"
	return 0
}

_youtube_dlgui_windows()
{
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
	
	__download__ "$url_youtube_dlgui_win" "$path_file_youtube_dlgui" || return 1
	__download__ "$url_visual_c" "$path_file_visual_c" || return 1 
	__download__ "$url_gnu_gettext" "$path_file_gnu_gettext" || return 1
	
	if ! is_executable wine; then
		_red "Necessário ter o wine instalado para prosseguir"
		_YESNO "Gostaria de instalar o wine e winetricks agora" || return 1
		_install_wine || return 1	
	fi

	if ! is_executable winetricks; then
		_install_script_winetricks
	fi
	
	_print "Entrando no diretório ... $DirDownloads"
	cd "$DirDownloads"
	_msg "Instalando ... atmlib"; winetricks atmlib
	_msg "Instalando: dotnet45"; winetricks dotnet45
	_msg "Instalando: visual C"; wine "$path_file_visual_c"
	_msg "Instalando: GNU gettext"
	wine "$path_file_gnu_gettext"
	_msg "Instalando: python2.7"
	winetricks python27
	_python37_windows32_portable
	_get_pip_windows  
	_install_wxpython_win32
	
	_unpack "$path_file_youtube_dlgui" || return 1
	cd "$DirUnpack"
	_msg "Executando: wine pip.exe install twodict"
	wine pip.exe install twodict
	_msg "Instalando: youtubedlg-0.4.exe" 
	wine youtubedlg-0.4.exe
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

	__download__ "$URL_EPSXE_WIN" "$PATH_FILE_EPSXE" || return 1
	__shasum__ "$PATH_FILE_EPSXE" "$HASH_FILE_ZIP" || return 1
	_unpack "$PATH_FILE_EPSXE" || return 1
	cd "$DirUnpack"
	cp -R -n * "${destinationFilesEpsxeWin32[dir]}"/

	_yellow "Criando script para execução do ePSXe"
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
		_sred "Necessário ter o wine instalado para prosseguir"
		_install_wine
	fi

	if ! is_executable winetricks; then
		_sred "Necessário ter o winetricks instalado para prosseguir"
		_install_script_winetricks 
	fi
	
	_yellow "Instalado: directx9 atmlib"
	winetricks directx9 atmlib
	"${destinationFilesEpsxeWin32[file_script]}"
}


_install_wine_ubuntu()
{
	# Instalação do wine no Ubuntu/Linuxmint.

	_yellow "Entrando no diretório ... $DirTemp"
	cd "$DirTemp"
	# Limpar arquivos temporarios.
	_clear_temp_dirs

	url_key_wine_stable='https://dl.winehq.org/wine-builds/winehq.key'
	case "$os_codename" in
		tricia|bionic) 
			repo_wine_stable='deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
			repo_libfaudio='deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./'
			url_key_libfaudio='https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key'
			;;
		focal|ulyana)
			__pkg__ 'wine' || return 1
			return 0 
			;;
		*) _red "Intale o wine manualmente usado o 'apt'" 
			return 1
			;;
	esac

	_println "Adicionado key wine-stable " 
	wget -q "$url_key_wine_stable" -O wine.key
	sudo apt-key add wine.key

	_println "Adicionado key libfaudio "
	wget -q "$url_key_libfaudio" -O libfaudio.key
	sudo apt-key add libfaudio.key

	_print "Adicionado repositórios"
	sudo add-apt-repository "$repo_wine_stable"
	sudo add-apt-repository "$repo_libfaudio"

	# Adicionar suporte a ARCH i386.
	_yellow "Executando ... sudo dpkg --add-architecture i386"
	_DPKG --add-architecture i386
	_APT update
	__pkg__ 'libfaudio0:i386' || return 1

	requeriments_wine_debian=(
		'wine-stable-i386' 
		'wine-stable-amd64' 
		'wine-stable' 
		'winehq-stable'
		)

	for APP in "${requeriments_wine_debian[@]}"; do
		__pkg__ "$APP" || break
	done
}

_install_wine_debian()
{
	# Instalação do wine no Debian buster.
	_yellow "Entrando no diretório ... $DirTemp"
	cd "$DirTemp"
	_clear_temp_dirs

	case "$os_codename" in
		buster) 
			url_key_wine_stable='https://dl.winehq.org/wine-builds/winehq.key'
			repo_wine_stable='deb https://dl.winehq.org/wine-builds/debian/ buster main'
			repo_libfaudio='deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./'
			url_key_libfaudio='https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key'
			;;
		*) _red "Intale o wine manualmente usado o 'apt'"; return 1;;
	esac

	_println "Adicionado key wine-stable "
	if ! wget -q "$url_key_wine_stable" -O- | sudo apt-key add -; then
		_sred "FALHA"
		return 1
	fi

	_println "Adicionado key libfaudio "
	if ! wget -q "$url_key_libfaudio" -O- | sudo apt-key add -; then
		_sred "FALHA"
		return 1
	fi
	
	_print "Adicionado repositórios"
	echo "$repo_wine_stable" | sudo tee /etc/apt/sources.list.d/wine.list
	echo "$repo_libfaudio" |sudo tee /etc/apt/sources.list.d/libfaudio.list
	
	# Adicionar suporte a ARCH i386.
	_print "Executando ... sudo dpkg --add-architecture i386"
	_DPKG --add-architecture i386
	_APT update
	__pkg__ 'libfaudio0:i386' || return 1

	requeriments_wine_debian=('wine-stable-i386' 'wine-stable-amd64' 'wine-stable' 'winehq-stable')
	for APP in "${requeriments_wine_debian[@]}"; do
		__pkg__ "$APP" || break
	done

}

_install_wine_fedora()
{
	__pkg__ "wine"
}

_install_wine_archlinux()
{
	_print "(_install_wine_archlinux): entrando no diretório ... $dir_of_executable/scripts"
	cd "$dir_of_executable/scripts"
	_print "(_install_wine_archlinux): executando ... sudo ./addrepo.py --repo arch"
	# Adicionar suporte ao repositório multilib no archlinux.
	sudo ./addrepo.py --repo arch
	_PACMAN -Sy
	__pkg__ wine 'wine-mono' 'wine-gecko'
}

_install_script_winetricks()
{
	if is_executable winetricks; then
		_yellow 'winetricks já está instalado'
		return 0
	fi

	if ! is_executable wine; then
		_red "(_install_script_winetricks): necessário instalar o 'wine' antes de prosseguir."
		return 1
	fi

	# Instalar o script winetricks
	URL_WINETRICKS='https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'
	PATH_FILE_WINETRICKS="$DirDownloads/winetricks.sh"
	SCRIPT_WINETRICKS="/usr/local/bin/winetricks"

	# Winetricks requeriments
	requeriments_winetricks=(zenity cabextract unrar unzip wget)
	requeriments_winetricks_debian=(binutils fuseiso p7zip-full policykit-1 xz-utils)
	requeriments_winetricks_suse=(binutils fuseiso p7zip polkit xdg-utils xz)

	# Instalar as dependências de acordo com cada distro.
	__pkg__ "${requeriments_winetricks[@]}"

	if [[ -f '/etc/debian_version' ]]; then # Sistemas baseados em debian.
		__pkg__ "${requeriments_winetricks_debian[@]}"
	elif [[ "$os_id" == 'fedora' ]]; then
		__pkg__ "${requeriments_winetricks_suse[@]}"
	elif [[ "$os_id" == 'arch' ]]; then
		__pkg__ "${requeriments_winetricks[@]}"

	else
		_red "Seu sistema não tem suporte a instalação do winetricks apartir deste programa."
		return 1
	fi

	__download__ "$URL_WINETRICKS" "$PATH_FILE_WINETRICKS" || return 1
	_print "Instalando winetricks em ... /usr/local/bin/winetricks"
	sudo cp -u "$PATH_FILE_WINETRICKS" "$SCRIPT_WINETRICKS"
	sudo chown root:root "$SCRIPT_WINETRICKS"
	sudo chmod a+x "$SCRIPT_WINETRICKS"
	if is_executable winetricks; then
		_yellow "Winetricks instalado com sucesso"
		return 0
	else
		_red "(_install_script_winetricks): falha na instalação de winetricks"
		return 1
	fi
}

_install_wine()
{
	case "$os_id" in
		debian) _install_wine_debian;;
		ubuntu|linuxmint) _install_wine_ubuntu;;
		fedora) _install_wine_fedora;;
		arch) _install_wine_archlinux;;
	esac
}

