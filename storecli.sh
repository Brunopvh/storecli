#!/usr/bin/env bash
#
# StoreCli a sua loja de aplicativos via linha de comando.
# Download Configuração e Instalaçao de programas.
# Sistemas suportados, (Debian/Ubuntu/Mint Fedora)
#
VERSION='2020-02-16'
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

function _c()
{
	[[ -z $2 ]] && { echo -e "\033[1;$1m"; return 0; }
	echo -e "\033[$2;$1m"
}

# root.
[[ $(id -u) == '0' ]] && { 
	echo "$(_c 31)=> $(_c)Falha o usuário não pode ser o $(_c 31)[root]$(_c)"
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
source "$Lib_CheckUpdate"
#source "$Lib_PackManager" # esta "lib" NÃO está em uso.

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
function _msg()
{
	[[ -z $1 ]] && {
		echo -e "$(_c 32 2)=> INFO $(_c)"
		return 0
	}

	echo -e "=> $(_c)$@"
}

# Red
function _red(){
	echo -e "=> $(_c 31)$@$(_c)"
}

# Green
function _green(){
	echo -e "=> $(_c 32 2)$@$(_c)"
}

# Yellow
function _yellow(){
	echo -e "=> $(_c 33)$@$(_c)"
}

#========================================================#
# Check cli programs
#========================================================#
function _check_executable_cli()
{
while [[ $1 ]]; do

	[[ ! -x $(which "$1" 2> /dev/null) ]] && {
		_red "$1 $(_space_msg ${#1}) ERRO."
		return 1 
		break
	}
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
	exit 0

elif [[ "$1" == '--upgrade' ]]; then
	_msg 'Aguarde...'
	"$StoreCli_Path/install.sh"
	exit "$?"

fi 


#=====================================================#
# Check system
#=====================================================#
# Cli
_check_executable_cli "${array_cli_requeriments[@]}" || {

	_msg "Função $(_c 31)[_check_executable_cli]$(_c) retornou erro." 
	_msg "Execute:$(_c 31) $(basename $0) --configure $(_c) para resolver este erro."
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
		_msg "Execute manualmente: $(_c 32)$(basename $0) --configure$(_c)"
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
echo "$(_c 31)=> $(_c)Programa indisponível para o seu sistema [$os_id]"
}

#=====================================================#
# Verificar e instalar atualização se disponível.
#=====================================================#

function _day_update()
{
	# Função que verifica atualização.
	if _check_update; then
		"$StoreCli_Path/install.sh" # Baixar e instalar a atualização.
	fi

	# Deletar linha que contém o dia da ultima verificação.
	sed -i '/^check_day/d' "$Config_File"

	# Gravar o dia atual no arquivo de configuração.
	echo -e "check_day $(date | awk '{print $3}')" >> "$Config_File"
}

#=====================================================#
_msg "Sistema $(_space_msg 7) $os_type $os_id $os_version"
_msg "Downloads $(_space_msg 9) $dir_user_cache"

#=====================================================#
# Verificar nova versão uma vez por dia.
#=====================================================#
# O programa deve procurar por atualização no github uma vez por dia.
# Se não houver a string 'check_day' no arquivo de configuração então
# Será "chamada" a função _day_update que verifica se existe atualização
# disponível, e se houver ela sera instalada.
grep 'check_day' "$Config_File" 1> /dev/null || _day_update

# Dia atual
current_day=$(date | awk '{print $3}') 
# Dia da ultima verificação.
old_day=$(grep 'check_day' "$Config_File" | awk '{print $2}') 

# Se o dia de "hoje" for diferente do dia da ultima verificação, então execute a função _day_update.
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
	_msg "$(_c 32 2)Já$(_c) instalado para remove-lo use: $(basename $0) $(_c 32)r$(_c)emove $1"
}

#=====================================================#
# Remover pacotes quebrados. Debian/Ubuntu/Mint.
#=====================================================#

function _quebrado()
{
[[ ! -x $(command -v apt 2> /dev/null) ]] && { _prog_not_found; return 1; }	

_msg "Limpando cache aguarde..."
sudo sh -c 'apt-get clean; apt-get remove -y; apt-get autoremove -y'

_msg "Executando dpkg --configure -a"
sudo sh -c 'apt-get install -f -y; dpkg --configure -a; apt --fix-broken install'

_msg "Executando apt update"
sudo apt update 
#sudo apt-get install --yes --force-yes -f 

_green "OK"
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
	_msg "Instalando ............... $1"
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
		papirus) _papirus;; # Instalar diretamente pelo arquivo ./scripts/papirus.sh "$Script_Papirus"
		ohmybash) _ohmybash;;
		ohmyzsh) _ohmyzsh;;
		sierra) _sierra;;

		--downloadonly) echo -en "\r";;
		-d) echo -en "\r";;
		install) echo -ne "\r";;
		*) _red "Programa indisponível ............... $1";;
	esac
	shift
done

}

#=====================================================#
# Execução do programa atraves dos argumentos recebidos.
#=====================================================#

if [[ ! -z $1 ]]; then
	while [[ $1 ]]; do
		case "$1" in
			install) shift; _packmanager_install "$@"; exit "$?";; # PackManager.sh
			remove)  _packremove "$@"; exit "$?";; # PackRemove.sh
			--list) _list_applications; exit "$?";;
			--quebrado) _quebrado; exit "$?";;
			*) _red "Comando não encontrado ............... $1"
		esac
		shift
	done
else
	_logo
fi

exit "$?"
