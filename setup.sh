#!/bin/sh
#
__version__='2020-09-06'
#
# https://github.com/Brunopvh/storecli.git
# https://github.com/Brunopvh/storecli/archive/master.zip
# https://github.com/Brunopvh/storecli/archive/master.tar.gz
#
# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#


Red="\033[0;31m"
Green="\033[0;32m"
CBGreen='\033[5;32m'
Yellow="\033[0;33m"
White="\033[0;37m"
Reset="\033[0m"

space_line='------------------------------------------------'

_msg()
{
	echo "[>] $@"
}

_red()
{
	echo "$(printf $Red)[!]$(printf $Reset) $@"
}

_green()
{
	echo "$(printf $Green)[*]$(printf $Reset) $@"
}

_yellow()
{
	echo "$(printf $Yellow)[+]$(printf $Reset) $@"
}

#----------------------------------------------------------#
# Urls
#----------------------------------------------------------#
github='https://github.com'
url_proj="$github/Brunopvh/storecli"
url_repo="${url_proj}.git"
url_master="${url_proj}/archive/master.tar.gz"


#----------------------------------------------------------#
# Diretórios e arquivos.
#----------------------------------------------------------#

if [ $(id -u) -eq 0 ]; then
	dir_storecli="/opt/storecli-amd64"
	path_link='/usr/local/bin/storecli'
	mkdir -p /opt
else
	dir_storecli="$HOME/.local/bin/storecli-amd64"
	path_link="$HOME/.local/bin/storecli"
	mkdir -p "$HOME/.local/bin"
fi

dir_temp=$(mktemp --directory) || dir_temp="/tmp/$USER/update"
dir_unpack="$dir_temp/unpack"

mkdir -p "$dir_temp"
mkdir -p "$dir_unpack"
mkdir -p "$dir_storecli"

path_file_repo="$dir_temp/storecli.tar.gz"


#----------------------------------------------------------#

_WHICH()
{
	cli=$(command -v "$1" 2> /dev/null)
	if [ -x "$cli" ]; then
		return 0
	else
		return 1
	fi
}

#----------------------------------------------------------#

if ! _WHICH curl && ! _WHICH wget; then
	_red "Instale a ferramenta 'curl' ou 'wget'"
	exit 1
fi

_download_repo()
{
	_msg "Baixando: $url_master"
	_msg "Destino: $path_file_repo"
    if _WHICH curl; then
	    curl -sSL "$url_master" -o "$path_file_repo" || {
		_red "Falha no download"
		return 1
        }
    elif _WHICH wget; then
        wget -q "$url_master" -O "$path_file_repo" || {
		_red "Falha no download"
		return 1
        }
	fi
	return 0
}


_RMDIR()
{
	# Remove um arquivo ou diretório informado no parametro $1
	# $1 = arquivo/diretório

	while [ $1 ]; do
		_red "Removendo: $1"
		rm -rf "$1"
		shift
	done
}

_uninstall()
{
	if [ -d "$dir_storecli" ]; then
		_RMDIR "$dir_storecli" || return 1
	fi


	if [ -L "$path_link" ]; then
		_RMDIR "$path_link" || return 1
	fi

	if [ -L "$path_link_gui" ]; then
		_RMDIR "$path_link_gui" || return 1
	fi
	return 0
}


_unpack()
{
	if [ -z $1 ]; then 
		return 1
	fi

	local path_file="$1"

	# Limpar o diretório antes da descompressão.
	cd "/tmp"
	cd "$dir_unpack" && rm -rf *
	
	# Descomprimir
	_msg "Descomprimindo: $path_file"
	tar -zxvf "$path_file" -C "$dir_unpack" 1> /dev/null

	if [ $? -eq 0 ]; then
		return 0
	else
		_red "(_unpack) erro"
		_red "Removendo: $path_file"
		rm -rf "$path_file"
		return 1
	fi
}

_install()
{
	_msg "Instalando em: $dir_storecli"
	cd "$dir_unpack"
	mv $(ls -d storecli*) "$dir_storecli"            # Diretório dos arquivos
	ln -sf "$dir_storecli"/storecli.sh "$path_link"  # Link do executável
	chmod -R a+x "$dir_storecli"
	chmod a+x "$path_link" 
	
	if _WHICH 'storecli' || [ -x "$HOME/.local/bin/storecli" ]; then
		_msg "OK"
		return 0
	else
		_red "(_install) falha"
		return 1
	fi
}

main()
{
	case "$1" in
		-r|--remove) _uninstall; return 0;;
	esac

	_download_repo || return 1
	_uninstall || return 1
	_unpack "$path_file_repo" || return 1
	_install || return 1
	
	echo "$space_line"
	_yellow "Execute ... storecli --help"
	echo "$space_line"
}

main "$@" || exit 1

if [ -d "$dir_temp" ]; then rm -rf "$dir_temp"; fi
exit 0



