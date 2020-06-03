#!/usr/bin/env bash
#
#
#
#
VERSION='2020_06_03_rev1'
#
#
#---------------------- INSTALAÇÃO --------------------------------#
# sudo sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#
#
#----------------------- SOBRE O PROGRAMA --------------------------#
#   Este script serve para automatizar/facilitar a instalação de softwares
# em sistemas baseados em Linux, atualmente tem suporte para os siguites
# sistemas: Debian, Ubuntu, LinuxMint, Fedora e ArchLinux. É util para ser 
# utilizado em uma pós formatação para instalar NAVEGADORES, CODECS, IDEs,
# ferrramentas para linha de comando entre outros ultilitários para desktop.  
#
#
#----------------------- USO BÁSICO -------------------------------#
# storecli --help
# storecli --list
# storecli install <pacote>
# storecli remove <pacote>
# storecli --update -----------------------> Instala a ultima versão do 'storecli' disponível no github
# storecli --configure --------------------> Instala dependências do storecli	
# storecli --ignore-cli install <pacote> --> Instala um pacote sem verificar as dependências do storecli
# 
#
#----------------------- DEPENDÊNCIAS ------------------------------#
# Alguns progras precisam ser baixados via curl ou wget, como por 
# exemplo chaves de assinatura digital e pacotes tar.gz, tar.xz etc
# outros precisam do python versão 2 e 3.
#    Para evitar erros na instalação dos pacotes este programa checa todas
# as dependências de linha de comando ao iniciar, só não e verificado os 
# módulos do python, porem quando a função (_config_system_requeriments)
# e executada com sucesso, ou seja, retorna status '0' é gravado um log
# no arquivo da váriavel "Config_File" com o valor 'requeriments OK' 
# atraves de um "grep" neste arquivo e possível saber se a função _config_system_requeriments
# foi executada pelo menos uma vez para que não seja necessário repetir
# a execução da mesma toda vez que o programa iniciar.
#
# LISTA de pacotes cli
#   wget curl git unzip xterm python2|python2.7 python3 awk|gawk
#
#
# LISTA python e módulos
#   python2 python3 python-setuptools python3-setuptools pip3 pip
#
#----------------------- ESQUELETO DO PROGRAMA -----------------------#
# 1 - Detectar o diretório do script principal (storcli.sh)
#
# 2 - Atribuir variáveis para o diretório atual (dirname) e para
#     libs e scripts, importar as libs/módulos.
#
# 3 - Verificar se o Kernel do sistema é linux ou freebsd e checar
#     se o programa está sendo executado pelo 'root'. Neste caso
#     o programa irá encerrar pois não pode ser executado pelo root.
#
# 4 - Verificar se todos os pacotes de linha de comando estão disponíveis
#     no sitema com a função "_check_cli_utils" que está no arquivo CliUtils.sh
#     se faltar algum requerimeto a função que instala os requerimetos 
#     será executada automáticament (_config_system_requeriments).
#     
#        Para evitar esta verificação basta passar o argumento --ignore-cli
#     exemplo:
#        storecli --ignore-cli install <vscode> - porém isto podera causar 
#     erro dependendo do pacote que você pretende instalar. 
#
# INSTALAÇÃO DOS PROGRAMAS
#   A função que gerencia os módulos para baixar, descompactar e instalar 
# os programas está no arquivo "PkgManStorecli.sh" (_packmanager_storecli)
# EX:
#   se o usuáro executar (storecli install telegram) o argumento install que está
#   no arquivo storecli.sh passa todos os parametros seguintes para a função 
#   (_packmanager_storecli) que por sua vez executa a função _telegram.
#
#
#
# storecli install telegram -> _packmanager_storecli telegram -> _telegram =====> (Comandos e funções)
# |    storecli.sh          |      PkgManStorecli.sh          | Internet.sh | ==> (Arquivos)
#
#
#
# storecli install vscode -> _packmanager_storecli vscode -> _vscode   ======> (Comandos e funções)
# |    storecli.sh        |      PkgManStorecli.sh        |   Dev.sh  | ==> (Arquivos)
#
#
#
# storecli install etcher -> _packmanager_storecli etcher -> _etcher     ======> (Comandos e funções)
# |    storecli.sh      |      PkgManStorecli.sh        | Acessory.sh | ==> (Arquivos)
#
#
#
# storecli install youtube-dl-gui -> _packmanager_storecli youtube-dl-gui -> _youtube_dlgui =====> (Comandos e funções)
# |    storecli.sh                |            PkgManStorecli.sh          |   Internet.sh   | ==> (Arquivos)
#
#
##---------------------- REFERÊNCIAS --------------------------------#
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
# Shell bot.
# http://shellscriptx.blogspot.com/2017/03/criando-bot-do-telegram-em-shell-script-com-shellbot.html
#


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
#export Script_TorBrowser="$Dir_Storecli_Scripts/tor.sh"
export Script_TorBrowser="$HOME/.local/bin/tor-setup.sh"
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

#=============================================================#
# Parametros que não precisam de verificação para serem exibidos
# ao usuário.
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
# 
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
# significa que a função de configuração (configura_all) ainda não foi
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
# Verificar por atualizações.
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


# Função para remover diretórios que o usuário não tem permissão de escrita.
_RMDIR()
{
	if [[ -z $1 ]]; then
		return 1
	fi
	
	LocalDir=$(pwd)
	if [[ $(echo "${LocalDir:0:4}") != '/tmp' ]]; then # Expansão de variáveis.
		red "CUIDADO: rm -rf $1"
		return 1
	fi
	
	_SUDO rm -rf "$1"
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
	white "Sistema: $(uname -s) $os_id"
	
	while [[ $1 ]]; do
		case "$1" in
			install) shift; _packmanager_storecli "$@";;
			remove) shift; _pack_remove "$@";;

			-b|--broke) _BROKE;;
			-c|--configure) configure_all;;
			-d|--downloadonly) export download_only='True';;
			-u|--upgrade) _install_update_storecli; exit;;
		esac
		shift
	done
else
	#usage
	"$Dir_Storecli/gui.sh"
fi


