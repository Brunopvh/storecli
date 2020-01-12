#!/usr/bin/env bash
#
#

#-----------------------------------------------------#

function _android_studio_debian()
{
	sudo apt install openjdk-8-jdk

	case "$os_id" in
		debian) sudo apt install qemu-kvm libvirt-clients libvirt-daemon-system;;
		ubuntu|linuxmint) sudo apt install qemu-kvm libvirt-bin ubuntu-vm-builder bridge-utils;;
		*) return 1;;
	esac


	# adicionar o seu usuário aos grupos "libvirt" e "libvirt-qemu"
	echo "=> Adicionando $USER aos grupos: $(_c 32)libvirt libvirt-qemu$(_c)" 
	sudo adduser "$USER" libvirt
	sudo adduser "$USER" libvirt-qemu

	echo "$(_c 32)=> $(_c)Instalando: lib32z1 lib32ncurses5 lib32stdc++6 lib32gcc1 lib32tinfo5 libc6-i386"
	sudo apt install lib32z1 lib32ncurses5 lib32stdc++6 lib32gcc1 lib32tinfo5 libc6-i386

local url='https://dl.google.com/dl/android/studio/ide-zips/3.5.2.0/android-studio-ide-191.5977832-linux.tar.gz'
local soma='f838486ce847db802bdaf1163059033934146c6ccdcdaa9a398bd85cda348d4d' # sha256sum
local path_arq="$dir_user_cache/$(basename $url)"

_dow "$url" "$path_arq" --curl
# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(_c 32)=> $(_c)Feito somente download."; return 0; }
[[ -x $(command -v studio 2> /dev/null) ]] && { _msg_pack_instaled 'android-studio'; return 0; }

	 # Lib ShaSum.sh
	_check_sum "$path_arq" "$soma" || { 
		echo "Erro função $(_c 31)_check_sum $(_c)retornou erro"
		echo "$(_c 31)=> Arquivo não confialvél: $path_arq $(_c)" 
		return 1 
	}


	"$Script_UnPack" "$path_arq" "$dir_temp" || { 
		echo "$(cor 31)=> $(cor)Falha: (unpack) retornou [Erro]"; return 1; 
	}

echo "$(_c 32)=> $(_c)Instalando android studio em ~/.local/bin"

cd "$dir_temp" && mv $(ls -d android-*) "${array_android_studio_dirs[3]}" 1> /dev/null # ~/.local/bin
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

	if [[ -x $(command -v studio 2> /dev/null) ]]; then
		_info_msgs 'android-studio instalado com sucesso'
		#studio
		return 0

	else
		echo "=> Função $(_c 31)_android_studio $(_c)retornou [erro]"
		return 1	
	fi
}

#-----------------------------------------------------#

function _android_studio()
{
# https://www.blogopcaolinux.com.br/2017/09/Instalando-Android-Studio-no-Debian-e-no-Ubuntu.html
# https://developer.android.com/studio/index.html#downloads

	case "$sysname" in
		debian10|linuxmint19|ubuntu18.04) _android_studio_debian;;
		*) _prog_not_found; return 1;;
	esac
}

#-----------------------------------------------------#

#=====================================================#
# Pycharm
#=====================================================#
function _pycharm()
{
local url_pycharm='https://download.jetbrains.com/python/pycharm-community-2019.1.2.tar.gz'
local path_arq="$dir_user_cache/pycharm-community-2019.1.2.tar.gz"

_dow "$url_pycharm" "$path_arq" --curl

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(_c 32)=> $(_c)Feito somente download."; return 0; }
[[ -x $(command -v pycharm 2> /dev/null) ]] && { _msg_pack_instaled 'pycharm'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)=> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(_c 32)=> $(_c)Instalando"

cd "$dir_temp" && mv $(ls -d pycharm*) "${array_pycharm_dirs[3]}" 1> /dev/null
cp -u "${array_pycharm_dirs[3]}"/bin/pycharm.png "${array_pycharm_dirs[1]}"

# Criar atalho para execução na linha de comando.
touch "${array_pycharm_dirs[2]}"
echo "#!/usr/bin/env bash" > "${array_pycharm_dirs[2]}"
echo -e "\ncd ${array_pycharm_dirs[3]}/bin/ && ./pycharm.sh" >> "${array_pycharm_dirs[2]}"
chmod +x "${array_pycharm_dirs[2]}"

	touch "${array_pycharm_dirs[0]}" # .desktop
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
	_info_msgs 'pycharm instalado com sucesso'
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
"$Script_PackTargz" install sublime-text
}


#=====================================================#
# Vim
#=====================================================#
function _vim()
{
if [[ -x $(command -v zypper 2> /dev/null) ]]; then
	sudo zypper in vim

elif [[ -x $(command -v dnf 2>/dev/null) ]]; then
	sudo dnf install vim

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
_dow "$url_code_debian" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(_c 32)=> $(_c)Feito somente download."; return 0; }
	[[ -x $(command -v code) ]] && { _msg_pack_instaled 'code'; return 0; }

sudo dpkg --install "$path_arq" # .deb
}

#-----------------------------------------------------#

function _vscode()
{
local url_vscode_tar='https://go.microsoft.com/fwlink/?LinkID=620884'
local path_arq="$dir_user_cache/vscode.tar.gz"

_dow "$url_vscode_tar" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(_c 32)=> $(_c)Feito somente download."; return 0; }
[[ -x $(command -v code) ]] && { _msg_pack_instaled 'code'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)=> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)=> $(cor)Instalando"

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
	_info_msgs 'code instalado'
	code
else
	echo "=> Função $(_c 31)_vscode$(_c) retornou [erro]"
	return 1
fi 

}
