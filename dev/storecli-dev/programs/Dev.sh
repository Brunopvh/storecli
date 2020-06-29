#!/usr/bin/env bash
#
#
_android_sdktools()
{
	# https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
	local url_sdktools='https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip'
	local url_commandline_tools='https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip'
	local url_emulator='https://dl.google.com/android/repository/emulator-linux-6466327'

	local path_sdktools="$DirDownloads/$(basename $url_sdktools)"
	local path_commandline_tools="$DirDownloads/$(basename $url_commandline_tools)"
	local hash_commandline_tools='f10f9d5bca53cc27e2d210be2cbc7c0f1ee906ad9b868748d74d62e10f2c8275'
	local hash_skdtools=''
	local JDKloaction="$HOME/.local/bin/android-studio/jre"
	local SDKlocation="$HOME/Android/Sdk"

	# Baixar skdtools.
	__download__ "$url_sdktools" "$path_sdktools"

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
}


_android_studio_zip()
{
	# https://developer.android.com/studio
	local url='https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.1.0/android-studio-ide-192.6241897-linux.tar.gz'
	local hash_studio='e754dc9db31a5c222f230683e3898dcab122dfe7bdb1c4174474112150989fd7'
	local path_file="$DirDownloads/$(basename $url)"

	__download__ "$url" "$path_file" || return 1
	
	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	
	__shasum__ "$path_file" "$hash_studio" || return 1
	_unpack "$path_file" || return 1

	_white "Instalando android studio em ~/.local/bin"
	cd "$DirUnpack" 
	mv $(ls -d android-*) "${destinationFilesAndroidStudio[dir]}" 1> /dev/null # ~/.local/bin/androi-studio
	cp -u "${destinationFilesAndroidStudio[dir]}"/bin/studio.png "${destinationFilesAndroidStudio[file_png]}" # .png
	chmod -R +x "${destinationFilesAndroidStudio[dir]}" # ~/.local/bin/androi-studio

	# arquivo de configuração ".desktop"
	_show_info 'AddFileDesktop'
	echo '[Desktop Entry]' > "${destinationFilesAndroidStudio[file_desktop]}"
	{
		echo "Version=1.0"
		echo "Type=Application"
		echo "Name=Android Studio"
		echo "Icon=studio.png"
		echo "Exec=sh -c 'cd ${destinationFilesAndroidStudio[dir]}/bin && ./studio.sh'"
		echo "Comment=The Drive to Develop"
		echo "Categories=Development;IDE;"
		echo "Terminal=false"
		echo "StartupWMClass=jetbrains-studio"
	} >> "${destinationFilesAndroidStudio[file_desktop]}"

	# Atalho para linha de comando.
	echo '#!/bin/sh' > "${destinationFilesAndroidStudio[link]}" # ~/.local/bin/studio
	echo "cd ${destinationFilesAndroidStudio[dir]}/bin && ./studio.sh" >> "${destinationFilesAndroidStudio[link]}"

	# Permissão.
	chmod u+x "${destinationFilesAndroidStudio[file_desktop]}"
	chmod u+x "${destinationFilesAndroidStudio[link]}"

	# Área de trabalho.
	cp -u "${destinationFilesAndroidStudio[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesAndroidStudio[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${destinationFilesAndroidStudio[file_desktop]}" ~/Desktop/ 2> /dev/null

}

#-----------------------------------------------------#

_android_studio_debian()
{
	# Encerrar a função se os sistema não for baseado em debian.
	if [[ ! -f /etc/debian_version ]]; then
		return 1
	fi

	local debianBusterRequeriments=(
		'qemu-kvm' 
		'libvirt-clients' 
		'libvirt-daemon-system'
		lib32z1 
		'lib32stdc++6' 
		lib32gcc1 
		lib32ncurses6 
		lib32tinfo6 
		'libc6-i386'
		)

	_APT update
	_green "Instalando: openjdk-11-jdk"
	_pkg_manager_sys 'openjdk-11-jdk'

	#-----------------------------------------------------#
	for c in "${debianBusterRequeriments[@]}"; do
		_msg "Instalando: $c"
		_pkg_manager_sys "$c"
	done
	
	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	_msg "Adicionando $USER aos grupos: | libvirt | libvirt-qemu |" 
	__sudo__ adduser "$USER" libvirt
	__sudo__ adduser "$USER" 'libvirt-qemu'

	_android_studio_zip || return 1
}

#-----------------------------------------------------#
_android_archlinux()
{
	_android_studio_zip
}

#-----------------------------------------------------#

_android_studio_ubuntu()
{
	# Encerrar a função se os sistema não for baseado em debian.
	if [[ ! -f /etc/debian_version ]]; then
		return 1
	fi

	local ubuntuBionicRequeriments=(
		'qemu-kvm' 
		'libvirt-bin' 
		'ubuntu-vm-builder' 
		'bridge-utils'
		lib32z1 
		lib32ncurses5 
		'lib32stdc++6' 
		lib32gcc1 
		lib32tinfo5 
		'libc6-i386'
		)

	_APT update
	_msg "Instalando: openjdk-8-jdk"
	_pkg_manager_sys 'openjdk-8-jdk'

	for c in "${ubuntuBionicRequeriments[@]}"; do
		_msg "Instalando: $c"
		_pkg_manager_sys "$c"
	done
	
	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	_msg "Adicionando $USER aos grupos: | libvirt | libvirt-qemu |" 
	__sudo__ adduser "$USER" libvirt
	__sudo__ adduser "$USER" 'libvirt-qemu'

	_android_studio_zip || return 1
}


_android_studio_fedora()
{
	local array_libs_fedora=(
			'zlib.i686' 'ncurses-libs.i686' 'bzip2-libs.i686'
			)

	__msg "Instalando: ${array_libs_fedora[@]}"
	_pkg_manager_sys "${array_libs_fedora[@]}"

	_android_studio_zip || return 1
	#_android_sdktools
}


_android_studio_opensuseleap()
{
	_pkg_manager_sys 'java-1_8_0-openjdk-devel' 'qemu-kvm'

	local requerimentsOpenSuse=(
			'libstdc++6-32bit' 
			'zlib-devel-32bit' 
			'libncurses5-32bit' 
			'libbz2-1-32bit'
		)
	_yellow "Instalando: ${requerimentsOpenSuse[@]}"
	_pkg_manager_sys "${requerimentsOpenSuse[@]}"
	_android_studio_zip
}

#-----------------------------------------------------#

_android_studio()
{
	# https://www.blogopcaolinux.com.br/2017/09/Instalando-Android-Studio-no-Debian-e-no-Ubuntu.html
	# https://www.blogopcaolinux.com.br/2017/05/Instalando-Android-Studio-no-openSUSE-e-Fedora.html
	# https://developer.android.com/studio/index.html#downloads

	# Já instalado.
	is_executable 'studio' && _show_info 'PkgInstalled' 'android-studio' && return 0

	case "$os_id" in
		debian) _android_studio_debian;;
		linuxmint|ubuntu) _android_studio_ubuntu;;
		'opensuse-leap') _android_studio_opensuseleap;;
		fedora) _android_studio_fedora;;
		arch) _android_archlinux;;
		*) _show_info 'ProgramNotFound' 'android-studio'; return 1;;
	esac

	if is_executable 'studio'; then
		_show_info 'SuccessInstalation' 'android-studio'
		return 0
	else
		_show_info 'InstalationFailed' 'android-studio'
		return 1
	fi
}

#-----------------------------------------------------#
_codeblocks_fedora()
{
	# https://sempreupdate.com.br/como-instalar-o-codeblocks-no-fedora/
	#
	# local url_codeblocks_fedora='http://sourceforge.net/projects/codeblocks/files/Binaries/17.12/Linux/Fedora%2028%20(aka%20Rawhide)/codeblock-17.12-1.fc28.x86_64.tar.xz'

	_pkg_manager_sys codeblocks || return 1
	_pkg_manager_sys make automake gcc 'gcc-c++' 'kernel-devel' || return 1
	# sudo dnf groupinstall "Development Tools" "Development Libraries" 
}

#-----------------------------------------------------#

_codeblocks_archlinux()
{
	# https://www.archlinux.org/packages/community/x86_64/codeblocks/
	_pkg_manager_sys codeblocks
}

#-----------------------------------------------------#
_codeblocks_debian()
{
	_pkg_manager_sys codeblocks 'codeblocks-common' 'codeblocks-contrib' || return 1
}
#-----------------------------------------------------#

_codeblocks()
{
	case "$os_id" in
		debian) _codeblocks_debian;;
		fedora) _codeblocks_fedora;;
		archlinux) _codeblocks_archlinux;;
		*) _show_info 'ProgramNotFound' 'codeblocks'; return 1;;
	esac
}


_pycharm()
{
	local url_pycharm='https://download-cf.jetbrains.com/python/pycharm-community-2020.1.tar.gz'
	local hash_pycharm='1aa49fd01ec9020c288a583ac90e777df3ae5c5dfcf4cc73d93ac7be1284a9d1'
	local path_file="$DirDownloads/$(basename $url_pycharm)"
	
	__download__ "$url_pycharm" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	# Já instalado.
	is_executable 'pycharm' && _show_info 'PkgInstalled' && return 0

	__shasum__ "$path_file" "$hash_pycharm" || return 1
	_unpack "$path_file" || return 1

	cd "$DirUnpack" 
	mv $(ls -d pycharm*) "${destinationFilesPycharm[dir]}" 1> /dev/null
	cp -u "${destinationFilesPycharm[dir]}"/bin/pycharm.png "${dedestinationFilesPycharm[file_png]}"

	# Criar atalho para execução na linha de comando.
	echo "#!/usr/bin/env bash" > "${destinationFilesPycharm[link]}"
	echo -e "\ncd ${destinationFilesPycharm[dir]}/bin/ && ./pycharm.sh" >> "${destinationFilesPycharm[link]}"
	chmod +x "${destinationFilesPycharm[link]}"

	_show_info 'AddFileDesktop' 
	echo "[Desktop Entry]" > "${destinationFilesPycharm[file_desktop]}"
    {
        echo "Name=Pycharm Community"
        echo "Version=1.0"
        echo "Icon=${dedestinationFilesPycharm[file_png]}"
        echo "Exec=pycharm"
        echo "Terminal=false"
        echo "Categories=Development;IDE;"
        echo "Type=Application"
    } >> "${destinationFilesPycharm[file_desktop]}"

    
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${destinationFilesPycharm[file_desktop]}" ~/Desktop/ 2> /dev/null 

	if is_executable 'pycharm'; then
		_show_info 'SuccessInstalation' 'pycharm'
		return 0
	else
		_show_info 'InstalationFailed' 'pycharm'
		return 1
	fi
}

#=====================================================#
# Sublime-text
#=====================================================#
_sublime_text()
{
	sublime_pag='https://www.sublimetext.com/3'
	sublime_html=$(grep -m 1 'http.*sublime.*x64.tar.bz2' <<< $(curl -sL "$sublime_pag"))
	sublime_url=$(echo "$sublime_html" | sed 's/">64.*//g;s/.*href="//g')
	path_file="$DirDownloads/$(basename $sublime_url)"

	__download__ "$sublime_url" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$DownloadOnly" == 'True' ]]; then
		_show_info 'DownloadOnly' "$path_file"
		return 0 
	fi

	# Já instalado.
	if is_executable 'sublime'; then
		_show_info 'PkgInstalled' 'sublime-text'
		return 0
	fi
	_unpack "$path_file" || return 1

	sudo cp -u "$DirUnpack"/sublime_text_3/sublime_text.desktop "${destinationFilesSublime[file_desktop]}"  
	sudo cp -u "$DirUnpack"/sublime_text_3/Icon/256x256/sublime-text.png "${destinationFilesSublime[file_png]}" 
	sudo mv "$DirUnpack"/sublime_text_3 "${destinationFilesSublime[dir]}"
	sudo ln -sf "${destinationFilesSublime[dir]}"/sublime_text "${destinationFilesSublime[link]}" 
	
	is_executable 'gtk-update-icon-cache' && sudo 'gtk-update-icon-cache'

	if is_executable 'sublime'; then
		_show_info 'SuccessInstalation' 'sublime'
		sublime &
		return 0
	else
		_show_info 'InstalationFailed' 'sublime'
		return 1
	fi
}


#=====================================================#
# Vim
#=====================================================#
_vim()
{
	_pkg_manager_sys vim
}

#=====================================================#
# Vscode.
#=====================================================#
_vscode_package_deb()
{
	local url_code_debian='https://go.microsoft.com/fwlink/?LinkID=760868'
	local path_file="$DirDownloads/vscode-amd64.deb"
	__download__ "$url_code_debian" "$path_file" || return 1

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0
	_DPKG --install "$path_file" # .deb
}

#-----------------------------------------------------#

_vscode_tarfile()
{
	local url_vscode_tar='https://go.microsoft.com/fwlink/?LinkID=620884'
	local path_file="$DirDownloads/vscode.tar.gz"

	__download__ "$url_vscode_tar" "$path_file"

	# Somente baixar
	[[ "$DownloadOnly" == 'True' ]] && _show_info 'DownloadOnly' && return 0

	_unpack "$path_file" || return 1

	cd "$DirUnpack"
	mv $(ls -d VSCode*) "${destinationFilesVscode[dir]}" 
	cp -u "${destinationFilesVscode[dir]}"/resources/app/resources/linux/code.png "${destinationFilesVscode[file_png]}"

	# Criar atalho para execução na linha de comando.
	echo "#!/usr/bin/env bash" > "${destinationFilesVscode[link]}"
	echo -e "\ncd ${destinationFilesVscode[dir]}/bin/ && ./code" >> "${destinationFilesVscode[link]}"
	chmod +x "${destinationFilesVscode[link]}"

	# Criar entrada no menu do sistema.
	_show_info "AddFileDesktop"
	echo "[Desktop Entry]" > "${destinationFilesVscode[file_desktop]}" 
	{
		echo "Name=Code"
		echo "Version=1.0"
		echo "Icon=code"
		echo "Exec=${destinationFilesVscode[dir]}/bin/code"
		echo "Terminal=false"
		echo "Categories=Development;IDE;" 
		echo "Type=Application"
	} >> "${destinationFilesVscode[file_desktop]}"

	ln -sf "${destinationFilesVscode[file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null 
	ln -sf "${destinationFilesVscode[file_desktop]}" ~/Desktop/ 2> /dev/null 
	ln -sf "${destinationFilesVscode[file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null	
}

_vscode()
{
	# Já instalado.
	is_executable 'code' && _show_info 'PkgInstalled' 'code' && return 0

	case "$os_id" in
		debian|ubuntu|linuxmint) _vscode_package_deb;;
		*) _vscode_tarfile;;
	esac
	

	if is_executable 'code'; then
		_show_info 'SuccessInstalation' 'code'
		return 0
	else
		_show_info 'InstalationFailed' 'code'
		return 1
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Desenvolvimento.
#=============================================================#
_Dev_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Desenvolvimento'" || return 1
	fi
	
	_android_studio
    _codeblocks
    _pycharm
    _sublime_text
    _vim
    _vscode
}
