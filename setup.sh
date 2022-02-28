#!/bin/sh
#
# Este script automatiza a instalação do script storecli em sistemas linux.
# Instala módulos locais para o programa storecli e módulos externos de uso 
# geral em scripts bash.
# Os módulos externos são desenvolvidos no seguinte repositório:
#  https://github.com/Brunopvh/bash-libs
#
#
# Repositório:
# https://github.com/Brunopvh/storecli.git
# 
# Pacote tar para instalação manual.
# https://github.com/Brunopvh/storecli/archive/master.tar.gz
#
# Script para automatizar a instalação.
# bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#
# OBS: seu computador precisa estar conectado a internet para executar este instalador.
# 

__version__='2021-03-09'
__script__=$(readlink -f "$0")
dir_of_project=$(dirname "$__script__")


usage()
{
cat <<EOF
	Use:
	    $(basename $__script__)             Para instalação online (Necessário conexão com a internet). 

	    $(basename $__script__) install     Para instalação offline - se o código fonte completo
	                                        Existir no diretório atual.

	    $(basename $__script__) uninstall   Para desinstalar o script storecli.

EOF
}


URL_ARCHIVE='https://github.com/Brunopvh/storecli/archive'
URL_TARFILE_MASTER="$URL_ARCHIVE/master.tar.gz"
URL_TARFILE_DEVELOPMENT="$URL_ARCHIVE/development.tar.gz"
URL_SETUP_BASH_LIBS='https://raw.github.com/Brunopvh/bash-libs/master/setup.sh'
URL_SRC="$URL_TARFILE_MASTER"

clienteDownloader=''

TEMPORARY_DIR=$(mktemp --directory)
TEMPORARY_FILE=$(mktemp -u)
DIR_UNPACK="$TEMPORARY_DIR/unpack"
DIR_DOWNLOAD="$TEMPORARY_DIR/download"

if [ `id -u` -eq 0 ]; then
	PREFIX_DIR='/opt'
	DIR_BIN='/usr/local/bin'
	DESTINATION_LINK='/usr/local/bin/storecli'
else
	PREFIX_DIR=~/.local/share
	DIR_BIN=~/.local/bin
	
fi

INSTALATION_DIR="$PREFIX_DIR/storecli-x86_64"
DESTINATION_LINK="$DIR_BIN/storecli"

create_dirs()
{
	mkdir -p "$DIR_UNPACK"
	mkdir -p "$DIR_DOWNLOAD"
	mkdir -p "$DIR_BIN"
	mkdir -p "$PREFIX_DIR"
}

clean_cache()
{
	rm -rf $TEMPORARY_DIR 2> /dev/null
	rm -rf $TEMPORARY_FILE 2> /dev/null
}

is_executable()
{
	command -v "$@" >/dev/null 2>&1
}

_ping()
{
	if ! ping -c 1 8.8.8.8 1> /dev/null 2>&1; then
		echo "Verifique sua conexão com a internet."
		sleep 1
		return 1
	fi
	return 0
}

set_client_downloader()
{
	# Verificar gerenciador de downloads do sistema.
	if is_executable aria2c; then
		clienteDownloader='aria2c'
	elif is_executable wget; then
		clienteDownloader='wget'
	elif is_executable curl; then
		clienteDownloader='curl'
	else
		printf "ERRO: Instale uma ferramenta para gerenciar downloads curl|aria2c|wget\n"
		sleep 1
		return 1
	fi
}

download()
{
	set_client_downloader || return 1
	_ping || return 1
	if [ -z $2 ]; then
		echo '(download) ... parâmetro incorreto detectado.'
		return 1
	fi 

	url="$1"
	output_file="$2"

	printf "Conectando ... $url "
	case "$clienteDownloader" in
		aria2c) aria2c "$url" -d $(dirname "$output_file") -o $(basename "$output_file") 1> /dev/null;;
		wget) wget -q "$url" -O "$output_file";;
		curl) curl -fsSL "$url" -o "$output_file";;
		*) echo "ERRO ... nenhum clienteDownloader instalado."; return 1;;
	esac

	if [ $? -eq 0 ]; then
		printf "OK\n"
	else
		printf "ERRO\n"
		return 1
	fi
	return 0
}

_copy_files()
{
	printf "Instalando ... $1 "
	if cp -R -u "$1" "$2" 1> /dev/null; then
		printf "OK\n"
		return 0
	else
		echo "ERRO (_copy_files) ... $1"
		sleep 1
		return 1
	fi
}

offline_installer()
{
	cd "$dir_of_project"
	[ ! -d ./lib ] && echo "ERRO (offline_installer) ... diretório ./lib não encontrado" && return 1
	[ ! -d ./scripts ] && echo "ERRO (offline_installer) ... diretório ./scripts não encontrado" && return 1
	[ ! -f ./storecli.sh ] && echo "ERRO (offline_installer) ... arquivo ./storecli.sh não encontrado" && return 1
	[ ! -f ./setup.sh ] && echo "ERRO (offline_installer) ... arquivo ./setup.sh não encontrado" && return 1

	mkdir -p $INSTALATION_DIR
	_copy_files lib $INSTALATION_DIR
	_copy_files scripts $INSTALATION_DIR
	_copy_files setup.sh $INSTALATION_DIR
	_copy_files storecli.sh $INSTALATION_DIR
	chmod -R a+x $INSTALATION_DIR
	ln -sf $INSTALATION_DIR/storecli.sh $DESTINATION_LINK

	if [ -x $DESTINATION_LINK ]; then
		printf "storecli instalado com sucesso.\n"
		return 0
	else
		printf "ERRO (online_installer): Falha na instalação, tente novamente\n"
		return 1
	fi
}

online_installer()
{
	download "$URL_SRC" "$DIR_DOWNLOAD/storecli.tar.gz" || return 1
	cd "$DIR_DOWNLOAD"
	printf "Descomprimindo ... storecli.tar.gz "
	if tar -zxvf storecli.tar.gz -C $DIR_UNPACK 1> /dev/null; then
		printf "OK\n"
	else
		printf "ERRO\n"
		return 1
	fi

	cd $DIR_UNPACK
	mv $(ls -d storecli-*) storecli
	if ! cd storecli; then
		printf "ERRO (online_installer): diretório 'storecli' não encontrado\n"
		return 1
	fi

	mkdir -p $INSTALATION_DIR
	_copy_files "lib" "$INSTALATION_DIR" 
	_copy_files "scripts" "$INSTALATION_DIR" 
	_copy_files "setup.sh" "$INSTALATION_DIR" 
	_copy_files "storecli.sh" "$INSTALATION_DIR" || return 1

	chmod -R a+x $INSTALATION_DIR
	ln -sf $INSTALATION_DIR/storecli.sh $DESTINATION_LINK

	if [ -x $DESTINATION_LINK ]; then
		printf "storecli instalado com sucesso.\n"
		return 0
	else
		printf "ERRO (online_installer): Falha na instalação, tente novamente\n"
		return 1
	fi
}

_install_external_modules()
{
	# bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)" 
	local script_installer_bash_libs="$TEMPORARY_FILE"
	download "$URL_SETUP_BASH_LIBS" "$script_installer_bash_libs" || return 1
	chmod +x "$script_installer_bash_libs"
	env AssumeYes='True' "$script_installer_bash_libs" || return 1
	return 0
}

main()
{
	create_dirs
	if [ -z $1 ]; then
		_install_external_modules || return 1
		online_installer || return 1
		clean_cache
		return 0
	fi

	case "$1" in 
		-h|--help) usage; return 0;;
		install) 
				offline_installer || return 1
				_install_external_modules || return 1 
				;;

		uninstall) 
				printf "Desinstalando storecli ... "
				rm -rf $INSTALATION_DIR
				rm -rf $DESTINATION_LINK
				printf "OK\n"
				;;
	esac			
	clean_cache
}

main "$@" || exit 1
exit 0