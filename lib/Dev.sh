#!/usr/bin/env bash
#
#


#=====================================================#
# Pycharm
#=====================================================#
function _pycharm()
{
local url_pycharm='https://download.jetbrains.com/python/pycharm-community-2019.1.2.tar.gz'
local path_arq="$dir_user_cache/pycharm-community-2019.1.2.tar.gz"

_dow "$url_pycharm" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v pycharm 2> /dev/null) ]] && { _msg_pack_instaled 'pycharm'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

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
	echo "==> Função $(cl 31)_pycharm$(cl) retornou [erro]"
	return 1	
fi
}

#-----------------------------------------------------#

#=====================================================#
# Sublime-text
#=====================================================#
function _sublime_text()
{
"$Script_PackTargz" install sublime-text
}

#-----------------------------------------------------#

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

#-----------------------------------------------------#

#=====================================================#
# Vscode.
#=====================================================#
function _vscode_debian()
{
local url_code_debian='https://go.microsoft.com/fwlink/?LinkID=760868'
local path_arq="$dir_user_cache/vscode-amd64.deb"
_dow "$url_code_debian" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	[[ -x $(command -v code) ]] && { _msg_pack_instaled 'code'; return 0; }

sudo dpkg --install "$path_arq"

}

#-----------------------------------------------------#

function _vscode()
{
local url_vscode_tar='https://go.microsoft.com/fwlink/?LinkID=620884'
local path_arq="$dir_user_cache/vscode.tar.gz"

_dow "$url_vscode_tar" "$path_arq" --wget

# --download-only
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
[[ -x $(command -v code) ]] && { _msg_pack_instaled 'code'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"
[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

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
	echo "==> Função $(cl 31)_vscode$(cl) retornou [erro]"
	return 1
fi 

}
