#!/usr/bin/env bash
#
#
VERSION='2020_06_28_rev1'
#
#
#---------------------- REFERÊNCIAS --------------------------------#
# Viva Ao Linux
# https://www.vivaolinux.com.br/dica/Instalando-o-Etcher-no-LMDE-4-Debbie
# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-Arch-com-Git
# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
#
# Blog Opção Linux
# https://www.blogopcaolinux.com.br/2016/12/Instalando-o-Spotify-no-openSUSE-e-no-Fedora.html
# https://www.blogopcaolinux.com.br/2017/11/Guia-pos-instalacao-Fedora-27-Workstation.html
#
# Outros
# http://shellscriptx.blogspot.com/2016/12/utilizando-expansao-de-variaveis.html
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

# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]] && [[ $(uname -s) != 'FreeBSD' ]]; then
	red "Execute este programa em sistemas Linux ou FreeBSD"
	exit 1
fi

# Necessário ter o pacote "sudo" intalado.
if [[ ! -x $(which sudo 2> /dev/null) ]]; then
	red "Instale o pacote [sudo] e adicione [$USER] no arquivo [sudoers] para prosseguir"
	exit 1
fi

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	red "Usuário não pode ser o [root] execute novamente sem o [sudo]"
	exit 1
fi

#=============================================================#
# Diretórios
#=============================================================#
export readonly Dir_Storecli=$(dirname $(readlink -f "$0"))  # path deste arquivo no disco.
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
export Programs_Browser="$Dir_Programs/Browser.sh"
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
export Script_root=$(readlink -f "$0")
#export Script_TorBrowser="$Dir_Storecli_Scripts/tor.sh"
export Script_TorBrowser="$HOME/.local/bin/tor-installer.sh"
export Script_AddRepo="$Dir_Storecli_Scripts/addrepo.sh"
export Script_ohmybash="$Dir_Storecli_Scripts/ohmybash.run"
export Script_Setup_Storecli="$Dir_Storecli/setup.sh"


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
source "$Programs_Browser"
source "$Programs_Internet"
source "$Programs_Dev"
source "$Programs_Gnomeshell"
source "$Programs_Preferences"
source "$Programs_Office"

#=============================================================#
# Arquivos de configuração e Log.
#=============================================================#
# O arquivo de configuração e gravado apenas quando a instalação
# dos requirimentos são instaladas no sistema. Quando o programa 
# inicia ele irá procurar por este arquivo é também irá verificar
# se o conteudo do arquivo tem as seguintes informações 
Config_File="$HOME/.config/storecli_script.conf"
LogFile="$HOME/.cache/storecli_Log.log"
LogErro="$HOME/.cache/storecli_Erro.log"

touch "$Config_File"
touch "$LogFile"
touch "$LogErro"

echo -e "$space_line" >> "$LogFile"
echo -e "Programa executado em [ $(date) ]" >> "$LogFile"
echo -e "$space_line" >> "$LogFile"
echo ' ' >> "$LogFile"

echo -e "$space_line" >> "$LogErro"
echo ' ' >> "$LogErro"

#=============================================================#

space_line='-----------------------------------------------'

SPACE_TEXT()
{
	# Espaçamento entre textos ou mensagens, o distânciamento
	# padrão e 45, esse valor será subraido do tamanho da string "${#string}"
	# Exemplo echo "texto1 $(SPACE_TEXT 'texto1') texto2"
	
	local line='-'
	num="$((40-${#@}))" # Subtrair (45) - (tamanho da string recebida com $@) 

	for n in $(seq "$num"); do
		line="${line}-"
	done
	echo -ne "$line"
}

_space_text()
{
	if [[ "${#@}" != '2' ]]; then
		red "Falha: informe apenas 2 argumentos para serem exibidos como string"
		return 1
	fi

	local line='-'
	num="$((45-${#2}))"  
	#num="$(($num-${#1}))"

	for i in $(seq "$num"); do
		line="${line}-"
	done
	
	echo -e "$1 ${line}> $2"

}



#=============================================================#
# Parametros que não precisam de verificação para serem exibidos
# ao usuário.
case "$1" in
	-h|--help) usage; exit 0;;
	-v|--version) echo -e "$(basename $0) $VERSION"; exit 0;;
	-l|--list) _list_applications; exit 0;;
esac
#=============================================================#

# Verificar se o usuário atual é adiministrador.
_isroot()
{
	if [[ $(sudo id -u) == '0' ]]; then
		return 0
	else
		return 1
	fi
}


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
# $1 for igual a '--ignore-cli' exemplo:
#   
#     storecli --ignore-cli install <pacote>
#
#=============================================================#
if [[ "$1" != '--ignore-cli' ]]; then
	if ! _check_cli_utils; then
		configure_all || exit 1
	fi
fi

# Se a string 'requeriments OK' não estiver no arquivo de configuração
# significa que a função de configuração (configure_all) ainda não foi
# executada no sistema atual, ou seja, se o GREP abaixo retornar status
# diferente de '0' a função configure_all será invocada.
if [[ "$1" != '--ignore-cli' ]]; then
	grep -q 'requeriments OK' "$Config_File" || {
		configure_all || exit 1
	}
fi

# SEMPRE CHECAR PATH AO INICIAR.
"$Script_config_path"


#=============================================================#
# Verificar por atualizações uma vez por dia.
#=============================================================#
_check_update_storecli 

#=============================================================#
# Função para executar comandos com o "sudo" e retornar '0' ou '1'.
#=============================================================#
_SUDO()
{
	white "${Yellow}A${Reset}utênticação necessária para executar: sudo $@"
	if sudo "$@"; then
		return 0
	else
		red "Falha: sudo $@"
		return 1
	fi
}


# Função para remover diretórios e arquivos, inclusive os arquivos é diretórios
# que o usuário não tem permissão de escrita, para isso será usado o "sudo".
_RMDIR()
{
	# Use:
	#     _RMDIR <diretório> ou
	#     _RMDIR <arquivo>
	if [[ -z $1 ]]; then
		return 1
	fi

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# A função _SUDO irá remover o arquivo/diretório.
	for i in "$@"; do
		red "Removendo: $i"
		rm -rf "$1" 2> /dev/null || _SUDO rm -rf "$i"
	done

}


_clear_temp_dirs()
{
	# Limpar o diretório temporário sempre ao iniciar
	cd /tmp
	cd "$dir_temp"
	
	for X in $(ls); do
		white "Limpando: $X"
		rm -rf "$X" 2>> "$LogErro" || _RMDIR "$X"
	done
	
	cd "$Dir_Unpack" 
	for X in $(ls); do
		white "Limpando: $X"
		rm -rf "$X" 2>> "$LogErro" || _RMDIR "$X"
	done
}

_clear_temp_dirs

for c in "${@}"; do
	case "$c" in
		-d|--downloadonly) export download_only='True';;
		-y|--yes) export install_yes='True';;
	esac
done
 
if [[ ! -z $1 ]]; then
	# Mostrar o tipo de sistema.
	white "Sistema: $os_id $os_version $os_codename"
	
	while [[ $1 ]]; do
		case "$1" in
			install) shift; _packmanager_storecli "$@"; exit;;
			remove) shift; _pack_remove "$@"; exit;;

			-b|--broke) _BROKE;;
			-c|--configure) configure_all;;
			-d|--downloadonly) export download_only='True';;
			-u|--upgrade) _install_update_storecli; exit;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			--ignore-cli) ;;
			*) red "Comando não encontrado: $1";;
		esac
		shift
	done
else
	# usage
	#"$Dir_Storecli/scripts/gui.sh"
	"$Dir_Storecli/python/pygui.py"
fi


