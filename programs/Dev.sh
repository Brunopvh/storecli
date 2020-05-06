#!/usr/bin/env bash
#
#


_android_sdktools()
{
	# https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
	local url_sdktools='https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip'
	local url_commandline_tools='https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip'

	local path_sdktools="$Dir_Downloads/$(basename $url_sdktools)"
	local path_commandline_tools="$Dir_Downloads/$(basename $url_commandline_tools)"

	local hash_commandline_tools='f10f9d5bca53cc27e2d210be2cbc7c0f1ee906ad9b868748d74d62e10f2c8275'
	local hash_skdtools=''

	# Baixar skdtools.
	_dow "$url_sdktools" "$path_sdktools" --curl

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_sdktools"
		return 0 
	fi

	# Descomprimir skdtools.
	_unpack "$path_sdktools" ||  return 1

	#mkdir -p "$HOME/Android/SDK"

}

#-----------------------------------------------------#
function _android_studio_zip()
{
	# https://developer.android.com/studio
	#local url='https://dl.google.com/dl/android/studio/ide-zips/3.5.2.0/android-studio-ide-191.5977832-linux.tar.gz'
	#local soma='f838486ce847db802bdaf1163059033934146c6ccdcdaa9a398bd85cda348d4d' # sha256sum
	local url='https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.1.0/android-studio-ide-192.6241897-linux.tar.gz'
	local hash_studio='e754dc9db31a5c222f230683e3898dcab122dfe7bdb1c4174474112150989fd7'
	local path_file="$Dir_Downloads/$(basename $url)"

	_dow "$url" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_sdktools"
		return 0 
	fi
	
	# Já instalado.
	if _WHICH 'studio'; then
		_INFO 'pkg_are_instaled' 'studio'
		return 0
	fi

	# Lib Check_sum.sh
	echo -e "$space_line"
	_check_sum "$path_file" "$hash_studio" || return 1


	_unpack "$path_file" || return 1

	msg "Instalando android studio em ~/.local/bin"
	cd "$Dir_Unpack" 
	mv $(ls -d android-*) "${array_android_studio_dirs[3]}" 1> /dev/null # ~/.local/bin
	cp -u "${array_android_studio_dirs[3]}"/bin/studio.png "${array_android_studio_dirs[1]}" # .png
	chmod -R +x "${array_android_studio_dirs[3]}" # ~/.local/bin

	# .desktop
	green "Criando arquivo .desktop"
	echo '[Desktop Entry]' > "${array_android_studio_dirs[0]}"
	{
		echo "Version=1.0"
		echo "Type=Application"
		echo "Name=Android Studio"
		echo "Icon=studio.png"
		echo "Exec=sh -c 'cd ${array_android_studio_dirs[3]}/bin && ./studio.sh'"
		echo "Comment=The Drive to Develop"
		echo "Categories=Development;IDE;"
		echo "Terminal=false"
		echo "StartupWMClass=jetbrains-studio"
	} >> "${array_android_studio_dirs[0]}"

	# Atalho para linha de comando.
	echo '#!/bin/sh' > "${array_android_studio_dirs[2]}" # ~/.local/bin/studio
	echo "cd ${array_android_studio_dirs[3]}/bin && ./studio.sh" >> "${array_android_studio_dirs[2]}"

	# Permissão.
	chmod u+x "${array_android_studio_dirs[0]}"
	chmod u+x "${array_android_studio_dirs[2]}"

	# Área de trabalho.
	green "Criando atalho na Área de trabalho"
	cp -u "${array_android_studio_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_android_studio_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_android_studio_dirs[0]}" ~/Desktop/ 2> /dev/null

	if _WHICH 'studio'; then
		_INFO 'pkg_sucess' 'studio'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'studio'
		return 1
	fi
}

#-----------------------------------------------------#

function _android_studio_debian()
{
	# Encerrar a função se os sistema não for baseado em debian.
	if [[ ! -f /etc/debian_version ]]; then
		return 1
	fi

	#------------------------------------------------------------#
	# debian virt utils
	local array_virt_debian=(
		qemu-kvm libvirt-clients libvirt-daemon-system
	)

	# Debian lib utils.
	local array_libutils_debian=(
		lib32z1 lib32stdc++6 lib32gcc1 lib32ncurses6 lib32tinfo6 libc6-i386
	)

	#------------------------------------------------------------#
	# ubuntu virt utils
	local array_virt_ubuntu=(
		qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
	)

	# Ubuntu lib utils.
	local array_libutils_ubuntu=(
		lib32z1 lib32ncurses5 lib32stdc++6 lib32gcc1 lib32tinfo5 libc6-i386
	)
	#------------------------------------------------------------#

	sudo apt update
	echo -e "$space_line"
	green "Instalando: openjdk-8-jdk"
	_package_man_distro 'openjdk-8-jdk'

	#-----------------------------------------------------#
	for c in "${array_virt_debian[@]}"; do
		echo -e "$space_line"
		green "Instalando: $c"
		if !_package_man_distro "$c"; then
			red "Falha: $c"
			sleep 2
			#return 1; break				
		fi
	done
	
	#-----------------------------------------------------#
	for c in "${array_libutils_debian[@]}"; do
		echo -e "$space_line"
		green "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			sleep 2
		fi
	done
	#-----------------------------------------------------#
	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	green "Adicionando $USER aos grupos: ${Yellow}libvirt${Reset} | ${Yellow}libvirt-qemu${Reset}" 
	sudo adduser "$USER" libvirt
	sudo adduser "$USER" libvirt-qemu

	_android_studio_zip || return 1
}

#-----------------------------------------------------#
function _android_archlinux()
{
	_android_studio_zip
}

#-----------------------------------------------------#

function _android_studio_ubuntu()
{
	# Encerrar a função se os sistema não for baseado em debian.
	if [[ ! -f /etc/debian_version ]]; then
		return 1
	fi

	#------------------------------------------------------------#
	# ubuntu virt utils
	local array_virt_ubuntu=(
		qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils
	)

	# Ubuntu lib utils.
	local array_libutils_ubuntu=(
		lib32z1 lib32ncurses5 lib32stdc++6 lib32gcc1 lib32tinfo5 libc6-i386
	)
	#------------------------------------------------------------#

	sudo apt update
	echo -e "$space_line"
	green "Instalando: openjdk-8-jdk"
	_package_man_distro 'openjdk-8-jdk'

	#-----------------------------------------------------#
	for c in "${array_virt_ubuntu[@]}"; do
		echo -e "$space_line"
		green "Instalando: $c"
		if !_package_man_distro "$c"; then
			red "Falha: $c"
			sleep 2
			#return 1; break				
		fi
	done
	
	#-----------------------------------------------------#
	for c in "${array_libutils_ubuntu[@]}"; do
		echo -e "$space_line"
		green "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			sleep 2
		fi
	done
	#-----------------------------------------------------#
	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	green "Adicionando $USER aos grupos: ${Yellow}libvirt${Reset} | ${Yellow}libvirt-qemu${Reset}" 
	sudo adduser "$USER" libvirt
	sudo adduser "$USER" libvirt-qemu

	_android_studio_zip || return 1
}

#-----------------------------------------------------#
function _android_studio_fedora()
{
	local array_libs_fedora=(
			'zlib.i686' 'ncurses-libs.i686' 'bzip2-libs.i686'
			)

	for c in "${array_libs_fedora[@]}"; do
		echo -e "$space_line"
		green "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			sleep 2
		fi
	done

	_android_studio_zip || return 1
	#_android_sdktools
}
#-----------------------------------------------------#

function _android_studio()
{
	# https://www.blogopcaolinux.com.br/2017/09/Instalando-Android-Studio-no-Debian-e-no-Ubuntu.html
	# https://developer.android.com/studio/index.html#downloads

	case "$os_id" in
		debian) _android_studio_debian;;
		linuxmint|ubuntu) _android_studio_ubuntu;;
		fedora) _android_studio_fedora;;
		arch) _android_archlinux;;
		*) _INFO 'pkg_not_found' 'proxychains'; return 1;;
	esac
}

#-----------------------------------------------------#
function _codeblocks_fedora()
{
	# https://sempreupdate.com.br/como-instalar-o-codeblocks-no-fedora/
	#
	# local url_codeblocks_fedora='http://sourceforge.net/projects/codeblocks/files/Binaries/17.12/Linux/Fedora%2028%20(aka%20Rawhide)/codeblock-17.12-1.fc28.x86_64.tar.xz'

	_package_man_distro codeblocks || return 1
	_package_man_distro make automake gcc 'gcc-c++' 'kernel-devel' || return 1
	# sudo dnf groupinstall "Development Tools" "Development Libraries" 
}

#-----------------------------------------------------#
function _codeblocks_archlinux()
{
	# https://www.archlinux.org/packages/community/x86_64/codeblocks/
	_package_man_distro codeblocks
}

#-----------------------------------------------------#
function _codeblocks_debian()
{
	_package_man_distro codeblocks 'codeblocks-common' 'codeblocks-contrib' || return 1
}
#-----------------------------------------------------#

function _codeblocks()
{
	case "$os_id" in
		debian) _codeblocks_debian;;
		fedora) _codeblocks_fedora;;
		archlinux) _codeblocks_archlinux;;
		*) _INFO 'pkg_not_found' 'codeblocks'; return 1;;
	esac
}

#=====================================================#
# Pycharm
#=====================================================#
function _pycharm()
{
	#local url_pycharm='https://download-cf.jetbrains.com/python/pycharm-community-2019.3.3.tar.gz'
	local url_pycharm='https://download-cf.jetbrains.com/python/pycharm-community-2020.1.tar.gz'
	local hash_pycharm='1aa49fd01ec9020c288a583ac90e777df3ae5c5dfcf4cc73d93ac7be1284a9d1'
	local path_file="$Dir_Downloads/$(basename $url_pycharm)"
	
	_dow "$url_pycharm" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Já instalado.
	if _WHICH 'pycharm'; then
		_INFO 'pkg_are_instaled' 'pycharm'
		return 0 
	fi

	_check_sum "$path_file" "$hash_pycharm" || return 1
	_unpack "$path_file" || return 1

	cd "$Dir_Unpack" 
	mv $(ls -d pycharm*) "${array_pycharm_dirs[3]}" 1> /dev/null
	cp -u "${array_pycharm_dirs[3]}"/bin/pycharm.png "${array_pycharm_dirs[1]}"

	# Criar atalho para execução na linha de comando.
	touch "${array_pycharm_dirs[2]}"
	echo "#!/usr/bin/env bash" > "${array_pycharm_dirs[2]}"
	echo -e "\ncd ${array_pycharm_dirs[3]}/bin/ && ./pycharm.sh" >> "${array_pycharm_dirs[2]}"
	chmod +x "${array_pycharm_dirs[2]}"

	# Criar arquivo .desktop
	green "Criando arquivo .desktop"
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

    # Área de trabalho.
	green "Criando atalho na Área de trabalho"
	cp -u "${array_pycharm_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_pycharm_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${array_pycharm_dirs[0]}" ~/Desktop/ 2> /dev/null 

	if _WHICH 'pycharm'; then
		_INFO 'pkg_sucess' 'pycharm'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'pycharm'
		return 1
	fi
}

#=====================================================#
# Sublime-text
#=====================================================#
function _sublime_text()
{
	sublime_pag='https://www.sublimetext.com/3'
	sublime_html=$(grep -m 1 'http.*sublime.*x64.tar.bz2' <<< $(curl -sL "$sublime_pag"))
	sublime_url=$(echo "$sublime_html" | sed 's/">64.*//g;s/.*href="//g')
	path_file="$Dir_Downloads/$(basename $sublime_url)"

	_dow "$sublime_url" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Já instalado.
	if _WHICH 'sublime'; then
		_INFO 'pkg_are_instaled' 'sublime'
		return 0
	fi
	_unpack "$path_file" || return 1

	sudo cp -u "$Dir_Unpack"/sublime_text_3/sublime_text.desktop "${array_sublime_dirs[0]}" # Arquivo .desktop 
	sudo cp -u "$Dir_Unpack"/sublime_text_3/Icon/256x256/sublime-text.png "${array_sublime_dirs[1]}" # .png 
	sudo mv "$Dir_Unpack"/sublime_text_3 "${array_sublime_dirs[3]}" # Deretório.
	sudo ln -sf /opt/sublime_text/sublime_text "${array_sublime_dirs[2]}" # atalho para linha de comando. 
	#sudo gtk-update-icon-cache

	if _WHICH 'sublime'; then
		_INFO 'pkg_sucess' 'sublime'
		sublime &
		return 0
	else
		_INFO 'pkg_instalation_failed' 'sublime'
		return 1
	fi
}


#=====================================================#
# Vim
#=====================================================#
function _vim()
{
	_package_man_distro vim
}

#=====================================================#
# Vscode.
#=====================================================#
function _vscode_debian()
{
	local url_code_debian='https://go.microsoft.com/fwlink/?LinkID=760868'
	local path_file="$dir_user_cache/vscode-amd64.deb"
	_dow "$url_code_debian" "$path_file"

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi
	
	# Já instalado.
	if _WHICH 'code'; then
		_INFO 'pkg_are_instaled' 'code'
		return 0
	fi

	sudo dpkg --install "$path_file" # .deb
}

#-----------------------------------------------------#

function _vscode()
{
	local url_vscode_tar='https://go.microsoft.com/fwlink/?LinkID=620884'
	local path_file="$Dir_Downloads/vscode.tar.gz"

	_dow "$url_vscode_tar" "$path_file"

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Já instalado.
	if _WHICH 'code'; then
		_INFO 'pkg_are_instaled' 'code'
		return 0
	fi

	_unpack "$path_file" || return 1


	cd "$Dir_Unpack"
	mv $(ls -d VSCode*) "${array_vscode_dirs[3]}" 2> /dev/null
	cp -u "${array_vscode_dirs[3]}"/resources/app/resources/linux/code.png "${array_vscode_dirs[1]}"

	# Criar atalho para execução na linha de comando.
	touch "${array_vscode_dirs[2]}"
	echo "#!/usr/bin/env bash" > "${array_vscode_dirs[2]}"
	echo -e "\ncd ${array_vscode_dirs[3]}/bin/ && ./code" >> "${array_vscode_dirs[2]}"
	chmod +x "${array_vscode_dirs[2]}"

	# Criar entrada no menu do sistema.
	green "Criando arquivo .desktop"
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

	green "Criando atalho na Área de trabalho"
	cp -u "${array_vscode_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${array_vscode_dirs[0]}" ~/Desktop/ 2> /dev/null 
	cp -u "${array_vscode_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null

	if _WHICH 'code'; then
		_INFO 'pkg_sucess' 'code'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'code'
		return 1
	fi
}

#=============================================================#
# Instalar todos os pacotes da categória Desenvolvimento.
#=============================================================#
_Dev_All()
{
	if [[ -z "$install_yes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Desenvolvimento'" || return 1
	fi
	
	_android_studio
    _codeblocks
    _pycharm
    _sublime_text
    _vim
    _vscode
}
