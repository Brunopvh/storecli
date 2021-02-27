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

__script__=$(readlink -f "$0")
__version__='2021-02-22'

case "$1" in
	-h|--help)
		echo "Use: ./$(basename $__script__) para instalar o script storecli." 
		echo "     ./$(basename $__script__) -r|--remove para desinstalar o script storecli."
		exit 0
		;;
esac

URL_STORECLI_MASTER='https://github.com/Brunopvh/storecli/archive/master.tar.gz'
URL_SETUP_BASH_LIBS='https://raw.github.com/Brunopvh/bash-libs/main/setup.sh'
TEMP_DIR=$(mktemp --directory)
UNPACK_DIR="$TEMP_DIR/unpack"
DOWNLOAD_DIR="$TEMP_DIR/download"

mkdir -p "$UNPACK_DIR"
mkdir -p "$DOWNLOAD_DIR"

if [ `id -u` -eq 0 ]; then
	INSTALATION_DIR='/opt/storecli-amd64'
	DESTINATION_LINK='/usr/local/bin/storecli'
else
	INSTALATION_DIR=~/.local/bin/storecli-amd64
	DESTINATION_LINK=~/.local/bin/storecli
fi

is_executable()
{
	command -v "$@" >/dev/null 2>&1
}

# Verificar gerenciador de downloads do sistema.
if is_executable aria2c; then
	clienteDownloader='aria2'
elif is_executable wget; then
	clienteDownloader='wget'
elif is_executable curl; then
	clienteDownloader='curl'
else
	printf "ERRO: Instale uma ferramenta para gerenciar downloads curl|aria2c|wget\n"
	exit 1
fi


_download_storecli()
{
	printf "Conectando ... $URL_STORECLI_MASTER "
	case "$clienteDownloader" in
		aria2) aria2c "$URL_STORECLI_MASTER" -d "$DOWNLOAD_DIR" -o storecli.tar.gz 1> /dev/null;;
		wget) wget -q "$URL_STORECLI_MASTER" -O "$DOWNLOAD_DIR"/storecli.tar.gz;;
		curl) curl -sSL -o "$DOWNLOAD_DIR"/storecli.tar.gz "$URL_STORECLI_MASTER";;
	esac
	
	[ $? -eq 0 ] && {
		printf "OK\n"
		return 0
	}
	printf "ERRO: Falha no download\n"
	return 1
}

_copy_files()
{
	if cp -R -u "$1" "$2" 1> /dev/null; then
		return 0
	else
		echo "ERRO _copy_files ... falha ao tentar copiar o arquivo $1"
		sleep 1
		return 1
	fi
}

_install_storecli()
{
	_download_storecli || return 1
	
	cd "$DOWNLOAD_DIR"
	printf "Descomprimindo ... storecli.tar.gz "
	if tar -zxvf storecli.tar.gz -C $UNPACK_DIR 1> /dev/null; then
		printf "OK\n"
	else
		printf "ERRO\n"
		return 1
	fi

	cd $UNPACK_DIR
	mv $(ls -d storecli-*) storecli-amd64
	! cd storecli-amd64 && {
		printf "ERRO: diretório 'storecli-amd64' não encontrado\n"
		return 1
	}

	echo "Instalando storecli em $INSTALATION_DIR"
	mkdir -p $INSTALATION_DIR
	_copy_files "lib" "$INSTALATION_DIR" 
	_copy_files "scripts" "$INSTALATION_DIR" 
	_copy_files "setup.sh" "$INSTALATION_DIR" 
	_copy_files "storecli.sh" "$INSTALATION_DIR"

	chmod -R a+x $INSTALATION_DIR
	ln -sf $INSTALATION_DIR/storecli.sh $DESTINATION_LINK

	if [ -x $DESTINATION_LINK ]; then
		printf "storecli instalado com sucesso!\n"
		return 0
	else
		printf "ERRO: Falha na instalação, tente novamente.\n"
		return 1
	fi
}

_install_external_modules()
{
	# bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)" 
	printf "Conectando ... $URL_SETUP_BASH_LIBS "
	case "$clienteDownloader" in
		aria2) aria2c "$URL_SETUP_BASH_LIBS" -d "$DOWNLOAD_DIR" -o setup_bash_libs.sh 1> /dev/null;;
		wget) wget -q "$URL_SETUP_BASH_LIBS" -O "$DOWNLOAD_DIR"/setup_bash_libs.sh;;
		curl) curl -sSL -o "$DOWNLOAD_DIR"/setup_bash_libs.sh "$URL_SETUP_BASH_LIBS";;
	esac
	
	[ $? -eq 0 ] || {
		printf "ERRO: Falha no download\n"
		return 1
	}
	printf "OK\n"
	cd $DOWNLOAD_DIR
	chmod +x setup_bash_libs.sh
	./setup_bash_libs.sh || return 1
	return 0
}

main()
{
	
	case "$1" in 
		-r|--remove) 
				printf "Desinstalando storecli ... "
				rm -rf $INSTALATION_DIR
				rm -rf $DESTINATION_LINK
				printf "OK\n"
				return 0
				;;
	esac			
	_install_external_modules || return 1
	_install_storecli || return 1
	printf "Limpando arquivos temporários "
	rm -rf "$TEMP_DIR"
	printf "OK\n"
	return 0
}

main "$@" || exit 1
exit 0