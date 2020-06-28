#!/usr/bin/env bash
#
#
__version__='2020_06_26_rev1'
#
##=============================================================#
# REFERÊNCIAS
#=============================================================#
# https://www.dicas-l.com.br/arquivo/fatiando_opcoes_com_o_getopts.php
# https://man7.org/linux/man-pages/man1/getopts.1p.html
#

clear

#=============================================================#
# Válidar se o Kernel e Linux.
#=============================================================#
if [[ $(uname -s) != 'Linux' ]]; then
	_red "Execute este programa apenas em sistemas Linux."
	exit 1
fi

# Necessário ter o pacote "sudo" intalado.
if [[ ! -x $(which sudo 2> /dev/null) ]]; then
	_red "Instale o pacote [sudo] e adicione [$USER] no arquivo [sudoers] para prosseguir"
	exit 1
fi

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	red "Usuário não pode ser o [root] execute novamente sem o [sudo]"
	exit 1
fi


#=============================================================#
# Configuração de diretórios para libs, scripts e programas
#=============================================================#
export dirSTORECLIPath=$(dirname $(readlink -f "$0"))
export scriptStorecli=$(readlink -f "$0")
export dirSTORECLIPathLib="$dirSTORECLIPath/lib"
export dirSTORECLIPathPrograms="$dirSTORECLIPath/programs"
export dirSTORECLIPathScripts="$dirSTORECLIPath/scripts"
export dirSTORECLIPathPython="$dirSTORECLIPath/python"

#=============================================================#
# Definir as Libs e scripts a serem usados
#=============================================================#
# módulos/libs.
libColors="$dirSTORECLIPathLib/Colors.sh"
libPrintUtils="$dirSTORECLIPathLib/PrintUtils.sh"
libDirectoryUtils="$dirSTORECLIPathLib/DirectoryUtils.sh"
libCliUtils="$dirSTORECLIPathLib/CliUtils.sh"
libPlatform="$dirSTORECLIPathLib/Platform.sh"
libPkgManagerSys="$dirSTORECLIPathLib/PkgManagerSys.sh"
libMain="$dirSTORECLIPathLib/Main.sh"
libArrayUtils="$dirSTORECLIPathLib/ArrayUtils.sh"
libUnpack="$dirSTORECLIPathLib/Unpack.sh"
libCheckGpg="$dirSTORECLIPathLib/CheckGpg.sh"
libCheckSum="$dirSTORECLIPathLib/CheckSum.sh"
libDownload="$dirSTORECLIPathLib/DownloadLib.sh"

# Programas
libAcessory="$dirSTORECLIPathPrograms/Acessory.sh"

# Scritps
scriptConfigPath="$dirSTORECLIPathScripts/conf-path.sh"

#=============================================================#
# importar libs
#=============================================================#
source "$libColors"
source "$libPrintUtils"
source "$libDirectoryUtils"
source "$libCliUtils"
source "$libPlatform"
source "$libPkgManagerSys"
source "$libMain"
source "$libArrayUtils"
source "$libUnpack"
source "$libCheckSum"
source "$libCheckGpg"
source "$libDownload"

# Programas
source "$libAcessory"

#=============================================================#
# Criar diretórios para arquivos temporários, descompressão dos
# arquivos baixados e para clonar repositórios do github. 
#=============================================================#
#export TemporaryDirectory=$(mktemp --directory)
export TemporaryDirectory="/tmp/storecli_$USER"
export DirTemp="$TemporaryDirectory/temp"
export DirGitclone="$TemporaryDirectory/gitclone"
export DirUnpack="$TemporaryDirectory/unpack"

mkdir -p "$TemporaryDirectory"
mkdir -p "$DirTemp"
mkdir -p "$DirGitclone"
mkdir -p "$DirUnpack"

#=============================================================#
# Arquivos de configuração e Log.
#=============================================================#
# O arquivo de configuração e gravado apenas quando a instalação
# dos requirimentos são instaladas no sistema. Quando o programa 
# inicia ele irá procurar por este arquivo é também irá verificar
# se o conteudo do arquivo tem uma linha com as seguintes informações: requeriments OK 
export configFILE="$directoryUSERconfig/requeriments.conf"
export LogFile="$HOME/.cache/storecliLOG.log"
export LogErro="$HOME/.cache/storecliERROLog.log"

touch "$configFILE"
touch "$LogFile"
touch "$LogErro"

"$scriptConfigPath"

usage()
{
	echo ' '
cat << EOF
    Use: $scriptStorecli -b|-c|-d|-I|-h|-l|-s|-v
         $scriptStorecli install <pacote>
         $scriptStorecli remove <pacote>

    Opções:

       -b|--broke                    Remove pacotes quebrados - (usar em sistemas Debian apenas).
       -c|--configure                Instala requerimentos desse script.
       -d|--downloadonly             Apenas baixa os pacotes, quando disponíveis.
       -h|--help                     Mostra ajuda.
       -I|--ignore-cli               Ignora a verificação dos pacotes/dependências deste script.
                                     $scriptStorecli --ignore-cli install <pacote>

       -l|--list                     Lista aplicativos disponíveis para instalação.
       -s|--self-update              Instala ultima versão desse script disponível no github.
       -v|--version                  Mostra versão.
       -y|--yes                      Assume sim para maioria da indagações.
                                     

       remove <remove>             Remove um pacote.
       install <pacote>            Instala um pacote.


       Instalando vários pacotes:
             $scriptStorecli install etcher sublime-text google-chrome youtube-dl-gui virtualbox

       Instalando uma categoria/grupo de pacotes:
             $scriptStorecli --install Acessorios Desenvolvimento Escritorio Internet

EOF
}

# Função para se um executável qualquer existe no sistema.
is_executable()
{
	if [[ -x $(command -v "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}


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

#=============================================================#
# Verificar se todos os utilitários de linha de comando 
# estão instalados - esta função será IGNORADA caso o parametro
# $1 for igual a '--ignore-cli' exemplo:
#   
#     storecli --ignore-cli install <pacote>
#
#=============================================================#
if [[ "$1" != '--ignore-cli' ]]; then
	if ! check_requeriments_sys; then
		_run_configuration_dep || exit 1
	fi
fi

# Se a string 'requeriments OK' não estiver no arquivo de configuração
# significa que a função de configuração (_run_configuration_dep) ainda não foi
# executada no sistema atual, ou seja, se o GREP abaixo retornar status
# diferente de '0' a função _run_configuration_dep será invocada.
if [[ "$1" != '--ignore-cli' ]]; then
	grep -q 'requeriments OK' "$configFILE" || {
		_run_configuration_dep || exit 1
	}
fi

#=============================================================#
# Função para executar comandos com o "sudo" e retornar '0' ou '1'.
#=============================================================#
__sudo__()
{
	_white "${CYellow}A${CReset}utênticação necessária para executar: sudo $@"
	if sudo "$@"; then
		return 0
	else
		_red "Falha: sudo $@"
		return 1
	fi
}

# Função para remover diretórios e arquivos, inclusive os arquivos é diretórios
# que o usuário não tem permissão de escrita, para isso será usado o "sudo".
__RMDIR()
{
	# Use:
	#     _RMDIR <diretório> ou
	#     _RMDIR <arquivo>
	if [[ -z $1 ]]; then
		return 1
	fi

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# A função __sudo__ irá remover o arquivo/diretório.
	for i in "$@"; do
		_red "Removendo: $i"
		rm -rf "$1" 2> /dev/null || __sudo__ rm -rf "$i"
	done

}

for option in "$@"; do
	case "$option" in
		-d|--downloadonly) export DownloadOnly='True';;
		-y|--yes) export AssumeYes='True';;
		-v|--version) echo "$(basename $scriptStorecli) V${__version__}"; exit 0; break;;
		-h|--help) usage; exit 0; break;;
	esac
done

argument_parser()
{
	while [[ $1 ]]; do
		case "$1" in
			-b|--broke) ;;
			-c|--configure) _run_configuration_dep;;
			-d|--downloadonly) ;;
			-I|--ignore-cli) ;;
			-l|--list) ;;
			-s|--self-update) ;;
			-y|--yes) ;;
			install) shift; _pkg_manager_storecli "$@";;
			remove) ;;
			*) _red "(argument_parser) comando não encontrado: $1"; return 1;;
		esac
		shift
	done
}

main()
{	
	argument_parser "$@"

}

main "$@"
echo "$?"

