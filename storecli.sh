#!/usr/bin/env bash
#
# StoreCli a sua loja de aplicativos via linha de comando.
# Download Configuração e Instalaçao de programas.
# Sistemas suportados, (Debian, Fedora, OpenSuse)
#
VERSION='2019-11-25 - (dev)'
#
# https://github.com/helmuthdu/aui
#
# https://github.com/Brunopvh/storecli.git 
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

[[ $(id -u) == '0' ]] && { 
	echo "$(cl 31)==> $(cl)Falha o usuário não pode ser o $(cl 31)[root]$(cl)"
	exit 1
}

#========================================================#
# local path dir.
#========================================================#
export readonly StoreCli_Path=$(dirname $(readlink -f "$0")) 
export readlink StoreCli_Path_Lib="$StoreCli_Path/lib"
export readlink StoreCli_Path_Scripts="$StoreCli_Path/scripts"

#========================================================#
# Scripts
#========================================================#
export appsutils="$StoreCli_Path/$(basename $0)"
export Script_TorBrowser="$StoreCli_Path_Scripts/TorBrowser.sh"
export Script_UnPack="$StoreCli_Path_Scripts/UnPack.sh"
export Script_PackTargz="$StoreCli_Path_Scripts/PackTargz.sh"
export Script_Papirus="$StoreCli_Path_Scripts/papirus.sh"
export Script_AddRepo="$StoreCli_Path_Scripts/AddRepo.sh"

#========================================================#
# Libs
#========================================================#
export Lib_array="$StoreCli_Path_Lib/array.sh"
export Lib_platform="$StoreCli_Path_Lib/platform.sh" # Detecta o sistema.
export Lib_Info="$StoreCli_Path_Lib/info.sh"
export Lib_SysUtils="$StoreCli_Path_Lib/SysUtils.sh"
export Lib_HttpsTransfer="$StoreCli_Path_Lib/HttpsTransfer.sh"
export Lib_PackManager="$StoreCli_Path_Lib/PackManager.sh" # Gerencia instalação.
export Lib_PackRemove="$StoreCli_Path_Lib/PackRemove.sh"   # Gerencia remoção.
export Lib_ShaSum="$StoreCli_Path_Lib/ShaSum.sh"
export Lib_GitClone="$StoreCli_Path_Lib/GitClone.sh"

# Categorias.
export Lib_Acessorios="$StoreCli_Path_Lib/Acessorios.sh"
export Lib_Dev="$StoreCli_Path_Lib/Dev.sh"
export Lib_Midia="$StoreCli_Path_Lib/Midia.sh"
export Lib_Internet="$StoreCli_Path_Lib/Internet.sh"
export Lib_Sistema="$StoreCli_Path_Lib/Sistema.sh"
export Lib_Preferencias="$StoreCli_Path_Lib/Preferencias.sh"

#========================================================#
# Config.
#========================================================#
export Config_File=~/.config/"$(basename $0).conf"

#========================================================#
# Import
#========================================================#
source "$Lib_array"
source "$Lib_platform"
source "$Lib_Info"
source "$Lib_SysUtils"
source "$Lib_HttpsTransfer"
source "$Lib_PackManager"
source "$Lib_PackRemove"
source "$Lib_ShaSum"

#--------------------------------------------------------#
if [[ "$os_id" == 'opensuse-tumbleweed' ]]; then
	sysname=$(echo "$sysname" | sed 's/[0-9]\+//g') # Remover números do final.
fi

# linuxmint 19
if [[ "$os_id" == 'linuxmint' ]] && [[ $(echo "$os_version" | cut -c -2) -ge 19 ]]; then
	sysname="${os_id}$(echo $os_version | cut -c -2)"

fi

esp='--------------'

#========================================================#
function _space_msg()
{
n=40
num="$((30-$1))"

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

echo -e "$esp[ $(_c 32 0)${msg}$(_c) ]$esp"
}

#========================================================#
# Check cli programs
#========================================================#
function _check_executable_cli()
{
while [[ $1 ]]; do
	if [[ -x $(which "$1" 2> /dev/null) ]]; then
		#echo "$(cl 32)==> $(cl)$1 $(_space_msg ${#1}) [OK]"
		echo -ne "\r"

	else
		echo "$(cl 31)==> $(cl)$1 $(_space_msg ${#1}) [ERROR]"
		return 1; break
	fi
	shift; #sleep 0.05
done
}

#=====================================================#
# Configure system
#=====================================================#
function _configure_system()
{
# requeriments cli
_info_msgs 'instalando requerimentos cli'
	while ! _install_requeriments; do
		echo -ne "[Erro] pressione $(cl 32)c$(cl) para repetir ou $(cl 31)e$(cl) para sair: "
		read -n 1 _input
		echo ' '
		if [[ "${_input,,}" == 'c' ]]; then continue; else return 1; break; fi		
	done

#requeriments python
_info_msgs 'Instalando requerimentos python'
	while ! _python_requeriments; do
		echo -ne "[Falha] selecione $(_c 32)continuar $(_c)ou $(_c 32)repetir $(_c)[c/r]: "
		read -n 1 cr
		echo ' '

		if [[ "${cr,,}" == 'r' ]]; then continue; else return 1; break; fi		
	done

}

#-----------------------------------------------------#

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
	_configure_system 
	[[ "$?" == '0' ]] || { echo "$(_c 31)Encerrando com [erro] $(_c)"; exit 1; }

fi 


#=====================================================#
# Check system
#=====================================================#
# Cli
_check_executable_cli "${array_cli_requeriments[@]}" 
if [[ $? != '0' ]]; then 
	echo "$(cl 31)==> $(cl)Falha: função $(cl 31)_check_executable_cli $(cl) retornou [erro]" 
	echo "$(cl 31)==> Execute:$(cl) $(basename $0) --configure para resolver este erro"
	exit 1 
fi

# Config_File
[[ ! -f "$Config_File" ]] && echo ' ' > "$Config_File"

if ! grep -q 'requeriments false' "$Config_File"; then
	echo -e "$esp $(cl 32)[INFO]$(cl) $esp"

	echo "==> Necessário executar a opção $(cl 32 0)--configure$(cl) pela primeira vez em seu sistema."
	echo -ne "==> Deseja executar esta ação agora $(cl 35)[s/n]$(cl) ?: "

	read _input
	if [[ "${_input,,}" == 's' ]]; then
		_configure_system || echo "$(_c 31)Encerrando com [erro] $(_c)"; exit 1
	else
		echo "Execute manualmente: $(cl 32)$(basename $0) --configure$(cl)"
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


#=====================================================#
# Instalação dos programas.
#=====================================================#
function _prog_not_found()
{
echo "$(cl 31)==> $(cl)Programa indisponível para o seu sistema."
}

#-----------------------------------------------------#
_info_msgs "Sistema: $os_type $sysname"

if [[ ! -z $1 ]]; then

while [[ $1 ]]; do
	case "$1" in
		install) shift; _packmanager_install "$@";; # PackManager.sh
		remove)  _packremove "$@";; # PackRemove.sh
		--list) _list_applications;;
		--downloadonly) echo -en "\r";;
		-d) echo -en "\r";;
		--quebrado) _quebrado;;
		--upgrade) "$StoreCli_Path/install.sh";;
		*) echo -en "\r";;
	esac
	shift
done

else
	_logo
fi

exit "$?"
