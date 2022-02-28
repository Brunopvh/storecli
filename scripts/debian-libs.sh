#!/usr/bin/env bash
#
#


# Regular Text
CRed="\033[0;31m"
CGreen="\033[0;32m"
CYellow="\033[0;33m"
CBlue="\033[0;34m"
CPrurple="\033[0;35m"
CCyan="\033[0;36m"
CGray="\033[0;37m"
CWhite="\033[0;37m"
CReset="\033[0m"

# [S] - Strong text (bold)
CSRed="\033[1;31m"
CSGreen="\033[1;32m"
CSYellow="\033[1;33m"
CSBlue="\033[1;34m"
CSPurple="\033[1;35m"
CSCyan="\033[1;36m"
CSGray="\033[1;37m"
CSWhite="\033[1;37m"


_red()
{
	echo -e "[${CRed}!${CReset}] $@"
}

_green()
{
	echo -e "[${CGreen}*${CReset}] $@"
}

_yellow()
{
	echo -e "[${CYellow}+${CReset}] $@"
}


_blue()
{
	echo -e "[${CBlue}~${CReset}] $@"
}


_white()
{
	echo -e "[${CWhite}>${CReset}] $@"
}


_sred()
{
	echo -e "${CSRed}$@${CReset}"
}

_sgreen()
{
	echo -e "${CSGreen}$@${CReset}"
}

_syellow()
{
	echo -e "${CSYellow}$@${CReset}"
}

_sblue()
{
	echo -e "${CSBlue}$@${CReset}"
}

_msg()
{
	echo '--------------------------------------------------'
	echo -e " $@"
	echo '--------------------------------------------------'
}


# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	printf "\033[0;31m Usuário não pode ser o [root] execute novamente sem o [sudo]\033[m\n"
	exit 1
fi

# Necessário ter o pacote "sudo" intalado.
if [[ ! -x $(command -v sudo 2> /dev/null) ]]; then
	printf "\033[0;31m Instale o pacote [sudo] e adicione [$USER] no arquivo [sudoers] para prosseguir\033[m\n"
	exit 1
fi

# Verificar se a arquitetura do Sistema e 64 bits
if ! uname -m | grep '64' 1> /dev/null; then
	printf "\033[0;31m Seu sistema não e 64 bits. Saindo\033[m\n"
	exit 1
fi


DirDownload="$HOME/.cache/debian-libs/download"
DirTemp='/tmp/debian-libs'
DirUnpack="/$DirTemp/unpack"

mkdir -p "$DirDownload"
mkdir -p "$DirTemp"
mkdir -p "$DirUnpack"

declare -A urlDebPkgs
urlDEBpkgs=(
	[LIBinfo]='http://ftp.us.debian.org/debian/pool/main/n/ncurses/libtinfo5_6.1+20181013-2+deb10u2_amd64.deb'
	[LIBncurses]='http://ftp.us.debian.org/debian/pool/main/n/ncurses/libncurses5_6.1+20181013-2+deb10u2_amd64.deb'
	[LIBcurl4]='http://ftp.us.debian.org/debian/pool/main/c/curl/libcurl4_7.68.0-1_amd64.deb'
	[OPENssl3]='http://ftp.us.debian.org/debian/pool/main/o/openssl/openssl_1.1.0l-1~deb9u1_amd64.deb'
	)

declare -A pathFilesDEB
pathFilesDEB=(
	[pathLIBinfoDEB]="$DirDownloads/libtinfo5_6-amd64.deb"
	[pathLIBncurserDEB]="$DirDownloads/libncurses5_6-amd64.deb"
	[pathLIBcurlDEB]="$DirDownloads/libcurl4_7-amd64.deb"
	[pathOPENsslDEB]="$DirDownloads/openssl_1-amd64.deb"
	)


# Função para se um executável qualquer existe no sistema.
is_executable()
{
	if [[ -x $(which "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}

__sudo__()
{
	# Função para executar comandos com o "sudo" e retornar '0' ou '1'.
	printf "[>] Autênticação necessária para executar: sudo ${@}\n"
	if sudo "$@"; then
		return 0
	else
		_red "Falha: sudo $@"
		return 1
	fi
}

__RMDIR()
{
	# Função para remover diretórios e arquivos, inclusive os arquivos é diretórios
	# que o usuário não tem permissão de escrita, para isso será usado o "sudo".
	#
	# Use:
	#     __RMDIR <diretório> ou
	#     __RMDIR <arquivo>
	[[ -z $1 ]] && return 1

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# A função __sudo__ irá remover o arquivo/diretório.
	while [[ $1 ]]; do
		printf "[>] Removendo: $1 "
		if rm -rf "$1" 2> /dev/null || sudo rm -rf "$1"; then
			_syellow "OK"
		else
			_sred "FALHA"
		fi
		shift
	done
}

__shasum__()
{
	# Esta função compara a hash de um arquivo local no disco com
	# uma hash informada no parametro "$2" (hash original). 
	#   Ou seja "$1" é o arquivo local e "$2" é uma hash

	if [[ ! -f "$1" ]]; then
		_red "(__shasum__) arquivo inválido: $1"
		return 1
	fi

	if [[ -z "$2" ]]; then
		_red "(__shasum__) use: __shasum__ <arquivo> <hash>"
		return 1
	fi

	_white "Gerando hash do arquivo: $1"
	local hash_file=$(sha256sum "$1" | cut -d ' ' -f 1)
	
	echo -ne "[>] Comparando valores "
	if [[ "$hash_file" == "$2" ]]; then
		echo -e "${CYellow}OK${CReset}"
		return 0
	else
		_sred 'FALHA'
		rm -rf "$1"
		_red "(__shasum__) o arquivo inseguro foi removido: $1"
		return 1
	fi
}


__curl__()
{
	# Função para baixar arquivos usando a ferramenta 'curl'.
	url="$1"
	path_file="$2"
	if [[ -z $2 ]]; then
		curl -C - -S -L -O "$url" || {
			_red "Falha: curl -S -L -O"
			return 1
		}
		return 0
	elif [[ $2 ]]; then
		_blue "Destino: $path_file"
		curl -C - -S -L -o "$path_file" "$url" || {
			_red "Falha: curl -S -L -o"
			rm "$path_file" 2> /dev/null
			return 1
		}
		return "$?"
	fi

}

__wget__()
{
	# Função para baixar arquivos usando a ferramenta 'wget'.
	url="$1"
	path_file="$2"
	if [[ -z $2 ]]; then
		wget "$url" || {
			_red "Falha: wget"
			return 1
		}
		return 0
	elif [[ $2 ]]; then
		_blue "Destino: $path_file"
		wget "$url" -O "$path_file" || {
			_red "Falha: wget"
			rm "$path_file" 2> /dev/null
			return 1
		}
		return "$?"
	fi	
}

__download__()
{
	if [[ -f "$2" ]]; then
		_blue "Arquivo encontrado: $2"
		return 0
	fi

	cd "$DirDownload"
	_blue "Baixando: $1"

	if is_executable wget; then
		__wget__ "$@" || return 1
	elif is_executable curl; then
		__curl__ "$@" || return 1
	else
		_red "(__download__) instale o pacote 'wget' ou 'curl'"
		return 1
	fi
}


_unpack()
{
	# Obrigatório informar um arquivo no argumento $1.
	if [[ ! -f "$1" ]]; then
		_red "(_unpack) nenhum arquivo informado como argumento"
		return 1
	fi

	# Destino para descompressão.
	if [[ -d "$2" ]]; then 
		DirUnpack="$2"
	elif [[ -d "$DirUnpack" ]]; then
		DirUnpack="$DirUnpack"
	else
		_red "(_unpack): nenhum diretório para descompressão foi informado"
		return 1
	fi 
	
	cd "$DirUnpack"
	path_file="$1"

	# Detectar a extensão do arquivo.
	if [[ "${path_file: -6}" == 'tar.gz' ]]; then    # tar.gz - 6 ultimos caracteres.
		type_file='tar.gz'
	elif [[ "${path_file: -7}" == 'tar.bz2' ]]; then # tar.bz2 - 7 ultimos carcteres.
		type_file='tar.bz2'
	elif [[ "${path_file: -6}" == 'tar.xz' ]]; then  # tar.xz
		type_file='tar.xz'
	elif [[ "${path_file: -4}" == '.zip' ]]; then    # .zip
		type_file='zip'
	elif [[ "${path_file: -4}" == '.deb' ]]; then    # .deb
		type_file='deb'
	else
		_red "(_unpack) arquivo não suportado: $path_file"
		__RMDIR "$path_file"
		return 1
	fi

	printf "%s" "[>] Descomprimindo: $path_file "
	
	# Descomprimir.	
	case "$type_file" in
		'tar.gz') tar -zxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		'tar.bz2') tar -jxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		'tar.xz') tar -Jxf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		zip) unzip "$path_file" -d "$DirUnpack" 1> /dev/null 2>&1;;
		deb) ar -x "$path_file" --output="$DirUnpack" 1> /dev/null 2>&1;;
		*) return 1;;
	esac

	if [[ "$?" == '0' ]]; then
		_syellow "OK"
		return 0
	else
		_sred "FALHA"
		_red "(_unpack) erro: $path_file"
		__RMDIR "$path_file"
		return 1
	fi
}

