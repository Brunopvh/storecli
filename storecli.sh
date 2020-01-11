#!/usr/bin/env bash
#
# StoreCli a sua loja de aplicativos via linha de comando.
# Download Configuração e Instalaçao de programas.
# Sistemas suportados, (Debian/Ubuntu/Mint Fedora)
#
VERSION='2020-01-10'
#
#
#-----------------------------------------------------#
# REPOSITÓRIO.
# https://github.com/Brunopvh/storecli.git 
#
# Instalação.
# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/install.sh)" 
# sh -c "$(wget -q https://raw.github.com/Brunopvh/storecli/master/install.sh -O-)"
#
#-----------------------------------------------------#
# REFERÊNCIAS
# http://shellscriptx.blogspot.com/2016/12/utilizando-expansao-de-variaveis.html
#

function cl() { 
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

function _c()
{
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

# root.
[[ $(id -u) == '0' ]] && { 
	echo "$(_c 31)==> $(_c)Falha o usuário não pode ser o $(_c 31)[root]$(_c)"
	exit 1
}

#========================================================#
# local path dirs.
#========================================================#
export readonly StoreCli_Path=$(dirname $(readlink -f "$0"))      # path deste arquivo.
export readlink StoreCli_Path_Lib="$StoreCli_Path/lib"            # path para libs.
export readlink StoreCli_Path_Scripts="$StoreCli_Path/scripts"    # path para scripts.
export readlink StroreCli_Path_Programs="$StoreCli_Path/programs" # path das categorias.

#========================================================#
# Scripts
#========================================================#
export Script_TorBrowser="$StoreCli_Path_Scripts/TorBrowser.sh"
export Script_UnPack="$StoreCli_Path_Scripts/UnPack.sh"
export Script_PackTargz="$StoreCli_Path_Scripts/PackTargz.sh"
export Script_Papirus="$StoreCli_Path_Scripts/papirus.sh"
export Script_AddRepo="$StoreCli_Path_Scripts/AddRepo.sh"

#========================================================#
# Libs
#========================================================#
export Lib_array="$StoreCli_Path_Lib/array.sh"
export Lib_platform="$StoreCli_Path_Lib/platform.sh"            # Detecta o sistema.
export Lib_Info="$StoreCli_Path_Lib/info.sh"
export Lib_SysUtils="$StoreCli_Path_Lib/SysUtils.sh"
export Lib_HttpsTransfer="$StoreCli_Path_Lib/HttpsTransfer.sh"
#export Lib_PackManager="$StoreCli_Path_Lib/PackManager.sh"     # Gerencia instalação dos pacotes.
export Lib_PackRemove="$StoreCli_Path_Lib/PackRemove.sh"        # Gerencia remoção dos pacotes.
export Lib_ShaSum="$StoreCli_Path_Lib/ShaSum.sh"
export Lib_GitClone="$StoreCli_Path_Lib/GitClone.sh"
export Lib_CheckUpdate="$StoreCli_Path_Lib/CheckUpdate.sh"
export Lib_Gpg="$StoreCli_Path_Lib/Gpg.sh"

#========================================================#
# Programs.
#========================================================#
export Lib_Acessorios="$StroreCli_Path_Programs/Acessorios.sh"
export Lib_Dev="$StroreCli_Path_Programs/Dev.sh"
export Lib_Escritorio="$StroreCli_Path_Programs/Escritorio.sh"
export Lib_Internet="$StroreCli_Path_Programs/Internet.sh"
export Lib_Midia="$StroreCli_Path_Programs/Midia.sh"
export Lib_Sistema="$StroreCli_Path_Programs/Sistema.sh"
export Lib_Preferencias="$StroreCli_Path_Programs/Preferencias.sh"

#========================================================#
# Config.
#========================================================#
export Config_File=~/.config/"$(basename $0).conf" # Arquivo de configuração para o usuário atual.

#========================================================#
# Import
#========================================================#
source "$Lib_array"
source "$Lib_platform"
source "$Lib_Info"
source "$Lib_SysUtils"
source "$Lib_HttpsTransfer"
source "$Lib_PackRemove"
source "$Lib_ShaSum"
source "$Lib_Gpg"
#source "$Lib_PackManager" # esta "lib" atualmente não está em uso.

source "$Lib_Acessorios"
source "$Lib_Dev"
source "$Lib_Escritorio"
source "$Lib_Internet"
source "$Lib_Midia"
source "$Lib_Sistema"
source "$Lib_Preferencias"

#--------------------------------------------------------#
if [[ "$os_id" == 'opensuse-tumbleweed' ]]; then
	sysname=$(echo "$sysname" | sed 's/[0-9]\+//g') # Remover números do final.
fi

# linuxmint 19.x
if [[ "$os_id" == 'linuxmint' ]] && [[ $(echo "$os_version" | cut -c -2) -ge 19 ]]; then
	sysname="${os_id}$(echo $os_version | cut -c -2)" # Usar apenas o número 19.
fi

esp='----------'

#========================================================#
function _space_msg()
{
	num="$((35-$1))"

	while [[ "$num" != '0' ]]; do
		echo -ne "-"
		num="$(($num-1))"
	done
}

#========================================================#
# Info
#========================================================#
function _info_msgs()
{
	if [[ -z $1 ]]; then
		local msg='INFO'

	elif [[ $1 ]]; then
		local msg="$1"

	fi

	echo -e "$(_c 32 1)->$(_c) [${msg}]"
}

#========================================================#
# Check cli programs
#========================================================#
function _check_executable_cli()
{
while [[ $1 ]]; do

	if [[ ! -x $(which "$1" 2> /dev/null) ]]; then	
		echo "$(_c 31)==> $(_c)$1 $(_space_msg ${#1}) [ERRO]"
		return 1; break
	fi
	shift
done
}

#=====================================================#
# Configure system
#=====================================================#
function _configure_system()
{
# requeriments cli
	while ! _install_requeriments; do
		echo -ne "[Erro] pressione $(_c 32)r$(_c) para repetir ou $(_c 31)s$(_c) para sair: "
		read -n 1 _input
		echo ' '
		if [[ "${_input,,}" == 'r' ]]; then continue; else return 1; break; fi		
	done

# requeriments python/python3
	while ! _python_requeriments; do
		echo -ne "[Falha] selecione $(_c 32)continuar $(_c)ou $(_c 32)repetir $(_c)[c/r]: "
		read -n 1 cr
		echo ' '

		if [[ "${cr,,}" == 'r' ]]; then continue; else return 1; break; fi		
	done

}

#=====================================================#
# Args
#=====================================================#
if [[ "$1" == '--help' ]]; then
	usage; exit 0

elif [[ "$1" == '--version' ]]; then
	echo -e "$(basename $0) V${VERSION}"; exit 0

elif [[ "$1" == '--logo' ]]; then
	_logo; exit 0 # LibInfo

elif [[ "$1" == '--configure' ]]; then
	# Lib SysUtils.sh
	_configure_system || { echo "$(_c 31)Encerrando com erro. $(_c)"; exit 1; }

fi 


#=====================================================#
# Check system
#=====================================================#
# Cli
_check_executable_cli "${array_cli_requeriments[@]}" || {

	echo "==> Falha: função $(_c 31)_check_executable_cli $(_c) retornou [erro]" 
	echo "==> Execute:$(_c 31) $(basename $0) --configure $(_c) para resolver este erro"
	exit 1 
}

# Config_File
[[ ! -f "$Config_File" ]] && echo ' ' > "$Config_File"

if ! grep -q 'requeriments false' "$Config_File"; then
	echo -e "$esp $(_c 32)[INFO]$(_c) $esp"

	echo "=> Necessário executar a opção $(_c 32 0)--configure$(_c) pela primeira vez em seu sistema."
	echo -ne "=> Deseja executar esta ação agora $(_c 32)[s/n]$(_c)? : "

	read _input
	if [[ "${_input,,}" == 's' ]]; then
		_configure_system || echo "$(_c 31)Encerrando com [erro] $(_c)"; exit 1

	else
		echo "Execute manualmente: $(_c 32)$(basename $0) --configure$(_c)"
		exit 0

	fi
	
fi

# SysUtils.sh
_create_dirs_user
_conf_path_bash 
_conf_path_zsh

#=====================================================#
#------------------ End check system -----------------#
#=====================================================#

function _prog_not_found()
{
echo "$(_c 31)==> $(_c)Programa indisponível para o seu sistema [$os_id]"
}

#=====================================================#
# Verificar e instalar atualização se disponível.
#=====================================================#

function _day_update()
{

local REPO='https://github.com/Brunopvh/storecli.git'
local RAWREPO="https://raw.githubusercontent.com/Brunopvh/storecli/master/storecli.sh"
local DESTINATION_FILE="$dir_temp/storecli.sh"

	mkdir -p "$dir_temp"
	[[ -f "$DESTINATION_FILE" ]] && rm "$DESTINATION_FILE"

	_info_msgs "Verificando atualização no github aguarde..."
	curl -# -LS "$RAWREPO" -o "$DESTINATION_FILE"

	NEW_VERSION=$(grep -m 1 'VERSION=' "$DESTINATION_FILE" | sed "s/.*=//g;s/'//g")	
	CURRENT_VERSION="$VERSION"

	if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then

		echo "${esp}$esp"
		echo -e "Nova versão disponível: $NEW_VERSION"
		echo -e "Instalando atualização"
		echo "${esp}$esp"
		"$StoreCli_Path/install.sh" || return 1

	else
		echo "${esp}$esp"
		echo "Ultima versão já instalada."
		echo "${esp}$esp"

	fi

	# Deletar linha que contém o dia da ultima verificação.
	sed -i '/^check_day/d' "$Config_File"

	# Gravar o dia atual no arquivo de configuração.
	echo -e "check_day $(date | awk '{print $3}')" >> "$Config_File"
}


#=====================================================#
# Verificar nova versão uma vez por dia.
#=====================================================#
_info_msgs "$os_type $os_id $os_version"

grep 'check_day' "$Config_File" 1> /dev/null || _day_update

current_day=$(date | awk '{print $3}') # Dia atual
old_day=$(grep 'check_day' "$Config_File" | awk '{print $2}') # Dia da ultima verificação.

if [[ "$current_day" != "$old_day" ]]; then 
	_day_update || { 
		echo "=> Falha ao tentar instalar atualização. Execute $(_c 31)$(basename $0) --upgrade $(_c)"
	}
	
fi

#=====================================================#
# Gerenciar instalação dos pacotes atraves das libs.
#=====================================================#

function _msg_pack_instaled()
{
	echo "=> já instalado para remove-lo use: $(basename $0) $(_c 32)r$(_c)emove $1"
}

#=====================================================#
# Remover pacotes quebrados. Debian/Ubuntu/Mint.
#=====================================================#

function _quebrado()
{
[[ ! -x $(command -v apt 2> /dev/null) ]] && { _prog_not_found; return 1; }	

echo "$(_c 32)==> $(_c)Limpando cache aguarde..."
sudo sh -c 'apt-get clean; apt-get remove -y; apt-get autoremove -y'

echo "$(_c 32)==> $(_c)Executando dpkg --configure -a"
sudo sh -c 'apt-get install -f -y; dpkg --configure -a; apt --fix-broken install'

echo "$(_c 32)==> $(_c)Executando apt update"
sudo apt update 
#sudo apt-get install --yes --force-yes -f 

echo -e "$(_c 33)[OK]$(_c)"
}

#=====================================================#
# Executar funções de instalação de acordo com 
# o(s) argumento(s) recebidos.
#=====================================================#

function _packmanager_install()
{
	for arg in "$@"; do
		if [[ "$arg" == '--downloadonly' ]] || [[ "$arg" == '-d' ]]; then
			export download_only='on'
		fi
	done

while [[ "$1" ]]; do
	echo "=> Instalando: $1"
	case "$1" in
#-------------------- Acessórios ------------------------#
		gnome-disk) _gnome_disk;;
		veracrypt) _veracrypt;;

#-------------------- desenvolvimento -------------------#
		android-studio) _android_studio;;
		pycharm) _pycharm;;
		sublime-text) _sublime_text;;
		vim) _vim;;
		vscode) _vscode;;

#-------------------- Escritório ------------------------#
		atril) _atril;;
		fontes-ms) _fontes_microsoft;;
		libreoffice) _libreoffice;;
		libreoffice-appimage) _libreoffice_appimage;;

#-------------------- internet --------------------------#
		google-chrome) _google_chrome;;
		megasync) _megasync;;
		opera-stable) _opera_stable;;
		proxychains) _proxychains;;
		qbittorrent) _qbittorrent;;
		teamviewer) _teamviewer;;
		telegram) _telegram;;
		tixati) _tixati;;
		torbrowser) _torbrowser;;
		uget) _uget;;
		youtube-dl) _youtube_dl;;
		youtube-dl-gui) _youtube_dl_gui_github;;

#-------------------- midia ----------------------------#
		codecs) _codecs;;
		vlc) _vlc;;
		parole) _parole;;
		gnome-mpv) _gnome_mpv;;
		smplayer) _smplayer;;

#-------------------- sistema ---------------------------#
		bluetooth) _bluetooth;;
		compactadores) _compactadores;;
		firmware-*) _firmware "$1";;
		gparted) _gparted;;
		peazip) _peazip;;
		virtualbox) _virtualbox;;

#-------------------- preferencias ---------------------------#
		hacking-parrot) _hacking_parrot;;
		icones-papirus) "$Script_Papirus";;
		ohmybash) _ohmybash;;
		ohmyzsh) _ohmyzsh;;
		sierra) _sierra;;

		--downloadonly) echo -en "\r";;
		-d) echo -en "\r";;
		install) echo -ne "\r";;
		*) echo "==> Programa indisponível: $(_c 31)$1 $(_c)";;
	esac
	shift
done

}

#=====================================================#
# Execução do programa atraves dos argumentos recebidos.
#=====================================================#


if [[ ! -z $1 ]]; then
	#_logo
while [[ $1 ]]; do
	case "$1" in
		install) shift; _packmanager_install "$@"; exit "$?";; # PackManager.sh
		remove)  _packremove "$@"; exit "$?";; # PackRemove.sh
		--list) _list_applications; exit "$?";;
		--quebrado) _quebrado; exit "$?";;
		--upgrade) "$StoreCli_Path/install.sh"; exit "$?";;
		*) echo "$(_c 31)Comando não encontrado: $1 $(_c)"
	esac
	shift
done

else
	_logo

fi

exit "$?"
