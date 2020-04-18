#!/usr/bin/env bash
#
#
#
#
VERSION='V2020-04-18_rev4'
#
#---------------------- INSTALAÇÃO --------------------------------#
# sudo sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/apps-buster/master/setup.sh)"
#
#----------------------- SOBRE O PROGRAM --------------------------#
#   Este script serve para automatizar/facilitar a instalação de softwares
# em sistemas baseados em Linux, atualmente tem suporte para os siguites
# sistemas: Debian, Ubuntu, LinuxMint, Fedora e ArchLinux. É util para ser 
# utilizado em uma pós formatação para instalar NAVEGADORES, CODECS, IDEs,
# ferrramentas para linha de comando entre outros ultilitários para desktop.  
#
#
##---------------------- REFERÊNCIAS --------------------------------#
# https://www.vivaolinux.com.br/dica/Instalando-o-Etcher-no-LMDE-4-Debbie
# http://shellscriptx.blogspot.com/2016/12/utilizando-expansao-de-variaveis.html
# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-Arch-com-Git
# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
# https://www.blogopcaolinux.com.br/2016/12/Instalando-o-Spotify-no-openSUSE-e-no-Fedora.html
# https://www.blogopcaolinux.com.br/2017/11/Guia-pos-instalacao-Fedora-27-Workstation.html
#
# Dica rápida: Como buscar recursivamente usando o grep
# https://terminalroot.com.br/2017/01/como-buscar-recursivamente-usando-o-grep.html
#
# 20 EXEMPLOS DO COMANDO FIND
# https://terminalroot.com.br/2015/07/20-exemplos-do-comando-find.html
#
# 30 exemplos do comando sed - com regex
# https://terminalroot.com.br/2015/07/30-exemplos-do-comando-sed-com-regex.html
#
# Como iterar em um intervalo de números definido por variáveis ​​no Bash?
# https://stackoverflow.com/questions/169511/how-do-i-iterate-over-a-range-of-numbers-defined-by-variables-in-bash
#
# Expansão de variáveis.
# http://shellscriptx.blogspot.com/2016/12/utilizando-expansao-de-variaveis.html
#
# Shell bot.
# http://shellscriptx.blogspot.com/2017/03/criando-bot-do-telegram-em-shell-script-com-shellbot.html
#


#clear

#=============================================================#
# Diretórios
#=============================================================#
export readonly Dir_Storecli=$(dirname $(readlink -f "$0"))       # path deste arquivo no disco.
export Dir_Storecli_Lib="$Dir_Storecli/lib"
export Dir_Programs="$Dir_Storecli/programs"
export Dir_Storecli_Scripts="$Dir_Storecli/scripts"


#=============================================================#
# Libs
#=============================================================#
export Lib_Colors="$Dir_Storecli_Lib/Colors.sh"
export Lib_Arrays="$Dir_Storecli_Lib/Arrays.sh"
export Lib_CliUtils="$Dir_Storecli_Lib/CliUtils.sh"
export Lib_Platform="$Dir_Storecli_Lib/Platform.sh"
export Lib_ShowInfo="$Dir_Storecli_Lib/ShowInfo.sh"
export Lib_PkgManStorecli="$Dir_Storecli_Lib/PkgManStorecli.sh"
export Lib_Unpack="$Dir_Storecli_Lib/Unpack.sh"
export Lib_Curl="$Dir_Storecli_Lib/Curl.sh"
export Lib_Wget="$Dir_Storecli_Lib/Wget.sh"
export Lib_PkgManSystem="$Dir_Storecli_Lib/PkgManSystem.sh"
export Lib_CheckSum="$Dir_Storecli_Lib/CheckSum.sh"
export Lib_CheckGpg="$Dir_Storecli_Lib/CheckGpg.sh"
export Lib_PkgRemove="$Dir_Storecli_Lib/PkgRemove.sh"
export Lib_GitClone="$Dir_Storecli_Lib/GitClone.sh"
export Lib_CheckUpdate="$Dir_Storecli_Lib/CheckUpdate.sh"


#=============================================================#
# Programas
#=============================================================#
export Programs_System="$Dir_Programs/System.sh"
export Programs_Midia="$Dir_Programs/Midia.sh"
export Programs_Internet="$Dir_Programs/Internet.sh"
export Programs_Dev="$Dir_Programs/Dev.sh"
export Programs_Gnomeshell="$Dir_Programs/GnomeShell.sh"
export Programs_Acessory="$Dir_Programs/Acessory.sh"
export Programs_Preferences="$Dir_Programs/Preferences.sh"
export Programs_Office="$Dir_Programs/Office.sh"

#=============================================================#
# Scripts
#=============================================================#
export Script_config_path="$Dir_Storecli_Scripts/config_path.sh"
export Script_root=$(basename $(readlink -f "$0"))
export Script_TorBrowser="$Dir_Storecli_Scripts/tor.sh"
export Script_AddRepo="$Dir_Storecli_Scripts/addrepo.sh"
export Script_ohmybash="$Dir_Storecli_Scripts/ohmybash.run"


#=============================================================#
# Importar
#=============================================================#
source "$Lib_Colors"
source "$Lib_Arrays"
source "$Lib_ShowInfo"
source "$Lib_CliUtils"
source "$Lib_PkgManStorecli"
source "$Lib_Unpack"
#source "$Lib_Curl"
source "$Lib_Wget"
source "$Lib_PkgManSystem"
source "$Lib_CheckSum"
source "$Lib_CheckGpg"
source "$Lib_GitClone"
source "$Lib_PkgRemove"
source "$Lib_CheckUpdate"

source "$Programs_Acessory"
source "$Programs_System"
source "$Programs_Midia"
source "$Programs_Internet"
source "$Programs_Dev"
source "$Programs_Gnomeshell"
source "$Programs_Preferences"
source "$Programs_Office"


space_line='-----------------------------------------------'

# O arquivo de configuração e gravado apenas quando a instalação
# dos requirimentos são instaladas no sistema. Quando o programa 
# inicia ele irá procurar por este arquivo é também irá verificar
# se o conteudo do arquivo tem as seguintes informações 
Config_File="$HOME/.config/storecli_script.conf"
[[ ! -f "$Config_File" ]] && echo ' ' > "$Config_File"



#=============================================================#
# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]]; then
	red "Seu sistema não é Linux"
	exit 1
fi

# Necessário ter o pacote "sudo" intalado.
if [[ ! -x $(which sudo 2> /dev/null) ]]; then
	red "Instale o pacote [sudo] e adicione [$USER] no arquivo [sudoers] para prosseguir"
	exit 1
fi

#=============================================================#
case "$1" in
	-h|--help) usage; exit 0;;
	-v|--version) echo -e "$Script_root $VERSION"; exit 0;;
	-l|--list) _list_applications; exit 0;;
esac
#=============================================================#

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	red "Usuário não pode ser o [root] execute novamente sem o [sudo]"
	exit 1
fi

# Verificar se o usuário atual é adiministrador.
#if [[ $(sudo id -u) != '0' ]]; then
#	red "Você não é adiministrador, portanto só poderá instalar/remover pacotes na sua HOME"
#	read -p "Pressione enter: " enter
#fi


#=============================================================#
# Verificar conexão com a internet.
_ping()
{
	echo -ne "[>] Aguardando conexão "

	if ping -c 2 8.8.8.8 1> /dev/null; then
		echo "[Conectado]"
		return 0
	else
		echo ' '
		red "Falha - AVISO: você está OFF-LINE"
		read -p "Pressione enter: " enter
		return 1
	fi
}


# Função para retornar o caminho de um executável.
_WHICH()
{
	if [[ -x $(which "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}


#=============================================================#
# Verificar se todos os utilitários de linha de comando 
# estão instalados - esta função será IGNORADA caso o parametro
# $1 for igual a '--ignore-cli'. 
#    Ex storecli --ignore-cli install <pacote>
#=============================================================#
if [[ "$1" != '--ignore-cli' ]]; then
	_check_cli_utils || {
		configure_all || exit 1
	}
fi

# Se a string 'requeriments OK' não estiver no arquivo de configuração
# significa que a função de configuração (configura_all) ainda não foi executada
if [[ "$1" != '--ignore-cli' ]]; then
	grep -q 'requeriments OK' "$Config_File" || {
		configure_all || exit 1
	}
fi

# SEMPRE CHECAR PATH AO INICIAR.
"$Script_config_path"

# Mostrar o tipo de sistema.
msg "Sistema: $os_id"

#=============================================================#
# Instalar ultima versão do programa disponível no github
#=============================================================#
_install_update_storecli()
{
	_ping || return 1
	sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/apps-buster/master/setup.sh)" || return 1
	return 0
}

# Verificar por atualizações.
_check_update_storecli

# Limpar o diretóri temporário sempre ao iniciar
cd "$dir_temp" && rm -rf *

for c in "${@}"; do
	case "$c" in
		-d|--downloadonly) export download_only='True';;
		-y|--yes) export install_yes='True';;
	esac
done


if [[ ! -z $1 ]]; then
	while [[ $1 ]]; do
		case "$1" in
			install) shift; _packmanager_storecli "$@";;
			remove) shift; _pack_remove "$@";;

			-c|--configure) configure_all;;
			-d|--downloadonly) export download_only='True';;
			-u|--upgrade) _install_update_storecli; exit;;
		esac
		shift
	done
else
	usage
	#"$Dir_Storecli/gui.sh"
fi
