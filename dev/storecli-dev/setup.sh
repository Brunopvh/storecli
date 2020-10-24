#!/bin/sh
#
# Este script automatiza a instalação do script storecli em sistemas linux.
#
#
__version__='2020-10-12'
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

_msg()
{
	echo "$@"
}

_red()
{
	echo "$(printf $Red)$@$(printf $Reset)"
}

_green()
{
	echo "$(printf $Green)$@$(printf $Reset)"
}

_yellow()
{
	echo "$(printf $Yellow)$@$(printf $Reset)"
}

# URLs
github='https://github.com'
url_proj="$github/Brunopvh/storecli"
url_repo="${url_proj}.git"
url_master="${url_proj}/archive/master.tar.gz"



# Definir o destino de instalação do script storecli, se o usuário for 'root'
# a instalação será em /opt com link simbolico em /usr/local/bin/storecli - se 
# não, o destino de instalação será na HOME do usuário em ~/.local/bin/storecli-amd64
# com link simbolico em ~/.local/bin/storecli

if [ $(id -u) -eq 0 ]; then
	destination_storecli='/opt/storecli-amd64'
	destination_link_storecli='/usr/local/bin/storecli'
else
	destination_storecli="$HOME/.local/bin/storecli-amd64"
	destination_link_storecli="$HOME/.local/bin/storecli"
fi

dir_temp=$(mktemp --directory) || dir_temp="/tmp/$USER/update_storecli"
dir_unpack="$dir_temp/unpack"
storecli_tar_file="$dir_temp/storecli.tar.gz"
mkdir -p "$dir_temp"
mkdir -p "$dir_unpack"

#----------------------------------------------------------#

is_executable()
{
	# Verificar se uma executável existe na variável PATH.
	# retorna 0 se sim, ou 1 se não existir.
	executable_app=$(command -v "$1" 2> /dev/null)
	if [ -x "$executable_app" ]; then
		return 0
	else
		return 1
	fi
}

#----------------------------------------------------------#

if ! is_executable curl && ! is_executable wget; then
	_red "Instale a ferramenta 'curl' ou 'wget'"
	exit 1
fi

_download_repo()
{
	# Usar a ferramenta curl ou wget para baixar o pacote de instalação.
	printf "Baixando ... $url_master "
	if is_executable wget; then
        wget -q "$url_master" -O "$storecli_tar_file" || {
		_red "Falha no download"
		return 1
        }
    elif is_executable curl; then
	    curl -sSL "$url_master" -o "$storecli_tar_file" || {
		_red "Falha no download"
		return 1
        }
	fi
	_msg "OK"
	return 0
}


__rmdir__()
{
	# Remove um arquivo ou diretório informado no parametro $1
	# $1 = arquivo/diretório
	while [ $1 ]; do
		printf "Removendo ... $1 "
		if rm -rf "$1"; then
			_yellow "OK"
		else
			_red "Falha"
		fi
		shift
	done
}

_uninstall()
{
	# Desintalar o script storecli.
	[ -d "$destination_storecli" ] && __rmdir__ "$destination_storecli"
	[ -L "$destination_link_storecli" ] && __rmdir__ "$destination_link_storecli"
	return 0
}


_unpack()
{
	[ -z $1 ] && return 1
	local path_file="$1"

	# Limpar o diretório antes da descompressão.
	cd "$dir_unpack" || return 1
	__rmdir__ $(ls)
	
	# Descomprimir
	printf "Descomprimindo: $path_file "
	tar -zxvf "$path_file" -C "$dir_unpack" 1> /dev/null
	if [ $? -eq 0 ]; then
		_yellow "OK"
		return 0
	else
		_red "(_unpack): Erro"
		__rmdir__ "$path_file"
		return 1
	fi
}

_install()
{
	if [ -z "$destination_storecli" ]; then
		_red "(_install): 'destination_storecli' tem valor nulo."
		return 1
	fi
	mkdir -p "$destination_storecli"

	printf "Instalando em: $destination_storecli "
	cd "$dir_unpack" || return 1
	mv $(ls -d storecli*) storecli 
	cd storecli
	mv * "$destination_storecli"/ || return 1
	ln -sf "$destination_storecli"/storecli.sh "$destination_link_storecli" || return 1
	chmod -R a+x "$destination_storecli"
	chmod a+x "$destination_link_storecli" 
	
	if is_executable 'storecli' || [ -x "$HOME/.local/bin/storecli" ] || [ -x "/usr/local/bin/storecli" ]; then
		_yellow "OK"
		return 0
	else
		_red "(_install): Falha"
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
	_unpack "$storecli_tar_file" || return 1
	_install || return 1
	
	_yellow "Execute ... storecli --help"

}

main "$@" || exit 1

if [ -d "$dir_temp" ]; then 
	__rmdir__ "$dir_temp" 1> /dev/null
fi
exit 0



