#!/usr/bin/env bash
#
#

#-----------------------------------------------------#
function _android_sdktools()
{
	# https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip
	local url_sdktools='https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip'
	local url_commandline_tools='https://dl.google.com/android/repository/commandlinetools-linux-6200805_latest.zip'

	local path_sdktools="$dir_user_cache/$(basename $url_sdktools)"
	local path_commandline_tools="$dir_user_cache/$(basename $url_commandline_tools)"

	local hash_commandline_tools='f10f9d5bca53cc27e2d210be2cbc7c0f1ee906ad9b868748d74d62e10f2c8275'
	local hash_skdtools=''

	# Baixar skdtools.
	_dow "$url_sdktools" "$path_sdktools" --curl

	# --download-only
	[[ "$download_only" == 'on' ]] && { 
		_green "Feito somente download."
		return 0 
	}

	# Descomprimir skdtools.
	"$Script_UnPack" "$path_sdktools" "$dir_temp" || { 
		_red "Falha função [unpack] retornou erro"
		return 1
	}


	#mkdir -p "$HOME/Android/SDK"

}

#-----------------------------------------------------#
function _android_studio_zip()
{
	# https://developer.android.com/studio
	#local url='https://dl.google.com/dl/android/studio/ide-zips/3.5.2.0/android-studio-ide-191.5977832-linux.tar.gz'
	#local soma='f838486ce847db802bdaf1163059033934146c6ccdcdaa9a398bd85cda348d4d' # sha256sum
	local url='https://redirector.gvt1.com/edgedl/android/studio/ide-zips/3.6.1.0/android-studio-ide-192.6241897-linux.tar.gz'
	local soma='e754dc9db31a5c222f230683e3898dcab122dfe7bdb1c4174474112150989fd7'
	local path_arq="$dir_user_cache/$(basename $url)"

	_dow "$url" "$path_arq" --curl
	
	# --download-only
	[[ "$download_only" == 'on' ]] && { 
		_green "Feito somente download."
		return 0 
	}
	
	# Verificar se studio já está instalado.
	_WHICH 'studio' && { 
		_msg_pack_instaled 'android-studio'
		return 0
	}

	# Lib ShaSum.sh
	echo -e "$space_line"
	_check_sum "$path_arq" "$soma" || { 
		_red "Erro função [_check_sum] retornou erro"
		_red "Arquivo não confiavel: $path_arq" 
		return 1 
	}


	"$Script_UnPack" "$path_arq" "$dir_temp" || { 
		_red "Falha: [unpack] retornou erro" 
		return 1 
	}

	_white "Instalando android studio em ~/.local/bin"
	cd "$dir_temp" 
	mv $(ls -d android-*) "${array_android_studio_dirs[3]}" 1> /dev/null # ~/.local/bin
	cp -u "${array_android_studio_dirs[3]}"/bin/studio.png "${array_android_studio_dirs[1]}" # .png
	chmod -R +x "${array_android_studio_dirs[3]}" # ~/.local/bin

	# .desktop
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
	cp -u "${array_android_studio_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_android_studio_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_android_studio_dirs[0]}" ~/Desktop/ 2> /dev/null

	if _WHICH 'studio'; then
		_white 'android-studio instalado com sucesso'
		#studio
	else
		_red "Função [_android_studio] retornou erro"
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

	# debian utils
	local array_virt_debian=(
		qemu-kvm 
		libvirt-clients 
		libvirt-daemon-system
	)

	# ubuntu utils
	local array_virt_ubuntu=(
		qemu-kvm 
		libvirt-bin 
		ubuntu-vm-builder 
		bridge-utils
	)

	# Debian lib utils.
	local array_libutils_debian=(
		lib32z1  
		lib32stdc++6 
		lib32gcc1 
		lib32ncurses6
		lib32tinfo6
		libc6-i386
	)

	# Ubuntu lib utils.
	local array_libutils_ubuntu=(
		lib32z1 
		lib32ncurses5 
		lib32stdc++6 
		lib32gcc1 
		lib32tinfo5 
		libc6-i386
	)

	sudo apt update
	echo -e "$space_line"
	_white "Instalando: openjdk-8-jdk"
	sudo apt install openjdk-8-jdk

	#-----------------------------------------------------#
	for c in "${array_virt_debian[@]}"; do
		echo -e "$space_line"
		_white "Instalando: $c"
		sudo apt install -y "$c" || {
			_red "Falha: $c"
			sleep 1
			#return 1; break				
			}
	done
	#-----------------------------------------------------#

	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	_white "Adicionando $USER aos grupos: $(_c 32)libvirt | libvirt-qemu$(_c)" 
	sudo adduser "$USER" libvirt
	sudo adduser "$USER" libvirt-qemu

	#-----------------------------------------------------#
	for c in "${array_libutils_debian[@]}"; do
		echo -e "$space_line"
		_white "Instalando: $c"
		sudo apt install -y "$c" || {
				_red "Falha: $c"
				sleep 1
				#return 1; break
			}
	done

	_android_studio_zip
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

	# ubuntu utils
	local array_virt_ubuntu=(
		'qemu-kvm' 'libvirt-bin' 'ubuntu-vm-builder' 'bridge-utils'
	)

	# Ubuntu lib utils.
	local array_libutils_ubuntu=(
		'lib32z1' 'lib32ncurses5' 'lib32stdc++6' 'lib32gcc1' 'lib32tinfo5' 'libc6-i386'
	)

	sudo apt update
	echo -e "$space_line"
	_white "Instalando: openjdk-8-jdk"
	sudo apt install openjdk-8-jdk

	#-----------------------------------------------------#
	for c in "${array_virt_ubuntu[@]}"; do
		echo -e "$space_line"
		_white "Instalando: $c"
		sudo apt install -y "$c" || {
			_red "Falha: $c"
			sleep 1
			#return 1; break				
			}
	done
	#-----------------------------------------------------#

	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	_white "Adicionando $USER aos grupos: $(_c 32)libvirt | libvirt-qemu$(_c)" 
	sudo adduser "$USER" libvirt
	sudo adduser "$USER" libvirt-qemu

	#-----------------------------------------------------#
	for c in "${array_libutils_ubuntu[@]}"; do
		echo -e "$space_line"
		_white "Instalando: $c"
		sudo apt install -y "$c" || {
				_red "Falha: $c"
				sleep 1
				#return 1; break
			}
	done

	_android_studio_zip
}

#-----------------------------------------------------#
function _android_studio_fedora()
{
	local array_libs_fedora=('zlib.i686' 'ncurses-libs.i686' 'bzip2-libs.i686')

	for c in "${array_libs_fedora[@]}"; do
		echo -e "$space_line"
		_white "Instalando: $c"
		sudo dnf install "$c" || {
			_red "[!] Falha: $c"
			sleep 1
		}
	done

	_android_studio_zip 
	_android_sdktools
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
		*) _prog_not_found; return 1;;
	esac
}

#-----------------------------------------------------#
function _codeblocks_fedora()
{
	# https://sempreupdate.com.br/como-instalar-o-codeblocks-no-fedora/
	#
	# local url_codeblocks_fedora='http://sourceforge.net/projects/codeblocks/files/Binaries/17.12/Linux/Fedora%2028%20(aka%20Rawhide)/codeblock-17.12-1.fc28.x86_64.tar.xz'

	sudo dnf install -y codeblocks || return 1
	sudo dnf install make automake gcc gcc-c++ kernel-devel || return 1
	# sudo dnf groupinstall "Development Tools" "Development Libraries" 
}

#-----------------------------------------------------#
function _codeblocks_archlinux()
{
	# https://www.archlinux.org/packages/community/x86_64/codeblocks/
	sudo pacman -S codeblocks
}

#-----------------------------------------------------#
function _codeblocks_debian()
{
	sudo apt install -y codeblocks codeblocks-common codeblocks-contrib || {
		_red "[!] Falha ao tentar instalar codeblocks"
		return 1
	}
}
#-----------------------------------------------------#

function _codeblocks()
{
	case "$os_id" in
		debian) _codeblocks_debian;;
		fedora) _codeblocks_fedora;;
		archlinux) _codeblocks_archlinux;;
		*) _prog_not_found;;
	esac
}

#=====================================================#
# Pycharm
#=====================================================#
function _pycharm()
{
#local url_pycharm='https://download.jetbrains.com/python/pycharm-community-2019.1.2.tar.gz'
local url_pycharm='https://download-cf.jetbrains.com/python/pycharm-community-2019.3.3.tar.gz'
local path_arq="$dir_user_cache/$(basename $url_pycharm)"
local hash_pycharm='ad796856195b574534ba6f9b49edad175b99465b5536d520c3e442527f63c353'

	_dow "$url_pycharm" "$path_arq" --curl

	# --download-only
	[[ "$download_only" == 'on' ]] && { 
		white "Feito somente download" 
		return 0 
	}

	_WHICH 'pycharm' && { 
		_msg_pack_instaled 'pycharm'
		return 0 
	}

	# Lib ShaSum.sh
	_check_sum "$path_arq" "$hash_pycharm" || { 
		_red "Falha função [_check_sum] retornou erro"
		_red "Arquivo não confialvél: [$path_arq]" 
		rm "$path_arq"
		return 1 
	}

	# Descomprimir
	"$Script_UnPack" "$path_arq" "$dir_temp" || { 
		_red "Falha função [unpack] retornou erro"
		return 1
	}

_white "Instalando"

cd "$dir_temp" && mv $(ls -d pycharm*) "${array_pycharm_dirs[3]}" 1> /dev/null
cp -u "${array_pycharm_dirs[3]}"/bin/pycharm.png "${array_pycharm_dirs[1]}"

# Criar atalho para execução na linha de comando.
touch "${array_pycharm_dirs[2]}"
echo "#!/usr/bin/env bash" > "${array_pycharm_dirs[2]}"
echo -e "\ncd ${array_pycharm_dirs[3]}/bin/ && ./pycharm.sh" >> "${array_pycharm_dirs[2]}"
chmod +x "${array_pycharm_dirs[2]}"

	# Criar arquivo .desktop
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
	_msg 'pycharm instalado com sucesso'
	#pycharm
	return 0

else
	echo "=> Função $(_c 31)_pycharm $(_c)retornou [erro]"
	return 1	
fi
}

#=====================================================#
# Sublime-text
#=====================================================#
function _sublime_text()
{
#"$Script_PackTargz" install sublime-text
local pag_sublime='https://www.sublimetext.com/3'
local url_sublime=$(curl -s "$pag_sublime" | grep -m 1 'http.*sublime.*x64.tar.bz2' | sed 's/">64.*//g;s/.*href="//g')
local path_arq="$dir_user_cache/$(basename $url_sublime)"

	_dow "$url_sublime" "$path_arq" --curl
	# --download-only
	[[ "$download_only" == 'on' ]] && { 
		_white "Feito somente download"
		return 0 
	}

	_WHICH 'sublime'  && { _msg_pack_instaled 'sublime-text'; return 0; }

	# Descomprimir
	"$Script_UnPack" "$path_arq" "$dir_temp" || {
		_red "Falha função [unpack] retornou erro."
		return 1
	}

	sudo cp -u "$dir_temp"/sublime_text_3/sublime_text.desktop "${array_sublime_dirs[0]}" # Arquivo .desktop 
	sudo cp -u "$dir_temp"/sublime_text_3/Icon/256x256/sublime-text.png "${array_sublime_dirs[1]}" # .png 
	sudo mv "$dir_temp"/sublime_text_3 "${array_sublime_dirs[3]}" # Deretório.
	sudo ln -sf /opt/sublime_text/sublime_text "${array_sublime_dirs[2]}" # atalho para linha de comando. 
	#sudo gtk-update-icon-cache

	if [[ -x $(command -v sublime 2> /dev/null) ]]; then
		_msg 'sublime-text instalado com sucesso'
		sublime # Abrir o programa.
		return 0
	else
		echo "$(_c 31)=> Função [_sublime_text] retornou erro $(_c)"
		return 1	
	fi
}


#=====================================================#
# Vim
#=====================================================#
function _vim()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper install -y vim

	elif [[ -x $(command -v dnf 2>/dev/null) ]]; then
		sudo dnf install -y vim

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y vim

	else
		_prog_not_found; return 1

	fi	
}

#=====================================================#
# Vscode.
#=====================================================#
function _vscode_debian()
{
	local url_code_debian='https://go.microsoft.com/fwlink/?LinkID=760868'
	local path_arq="$dir_user_cache/vscode-amd64.deb"
	_dow "$url_code_debian" "$path_arq" --curl

	# --download-only
	[[ "$download_only" == 'on' ]] && { 
		echo "$(_c 32)=> $(_c)Feito somente download."
		return 0 
	}
	
	[[ -x $(command -v code) ]] && { 
		_msg_pack_instaled 'code'
		return 0
	}

	sudo dpkg --install "$path_arq" # .deb
}

#-----------------------------------------------------#

function _vscode()
{
	local url_vscode_tar='https://go.microsoft.com/fwlink/?LinkID=620884'
	local path_arq="$dir_user_cache/vscode.tar.gz"

	_dow "$url_vscode_tar" "$path_arq" --curl

	# --download-only
	[[ "$download_only" == 'on' ]] && { 
		_green "Feito somente download."
		return 0
	}

	[[ -x $(command -v code) ]] && { 
		_msg_pack_instaled 'code'
		return 0
	}

	"$Script_UnPack" "$path_arq" "$dir_temp" || { 
		_red "Falha: [unpack] retornou erro"
		return 1 
	}


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
	_green 'code instalado com sucesso'
	code
else
	_red "Função [_vscode] retornou erro"
	return 1
fi 

}
