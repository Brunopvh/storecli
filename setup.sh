#!/bin/sh
#
# Este script automatiza a instalação do script storecli em sistemas linux.
#
#
__version__='2020-12-08'
#
# https://github.com/Brunopvh/storecli.git
# https://github.com/Brunopvh/storecli/archive/master.zip
# https://github.com/Brunopvh/storecli/archive/master.tar.gz
#
# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#

URL_STORECLI_MASTER='https://github.com/Brunopvh/storecli/archive/master.tar.gz'
TEMP_DIR="$(mktemp --directory)-installer-storecli"
UNPACK_DIR="$TEMP_DIR/unpack"
mkdir -p "$UNPACK_DIR"

if [ `id -u` -eq 0 ]; then
	INSTALATION_DIR='/opt/storecli-amd64'
	DESTINATION_LINK='/usr/local/bin/storecli'
else
	INSTALATION_DIR=~/.local/bin/storecli-amd64
	DESTINATION_LINK=~/.local/bin/storecli
fi

_download_storecli()
{
	printf "Conectando ... $URL_STORECLI_MASTER "
	if [ -x $(command -v aria2c 2> /dev/null) ]; then
		aria2c "$URL_STORECLI_MASTER" -d "$TEMP_DIR" -o storecli.tar.gz 1> /dev/null
	elif [ -x $(command -v wget 2> /dev/null) ]; then
		wget -q "$URL_STORECLI_MASTER" -O "$TEMP_DIR"/storecli.tar.gz
	elif [ -x $(command -v curl 2> /dev/null) ]; then
		curl -sSL -o "$TEMP_DIR"/storecli.tar.gz
	else
		printf "ERRO: Instale uma ferramenta para gerenciar downloads curl|aria2c|wget\n"
		return 1
	fi
	
	[ $? -eq 0 ] && {
		printf "OK\n"
		return 0
	}
	printf "ERRO: Falha no download\n"
	return 1
}

_copy_files()
{
	# Libs
	printf "Copiando lib ==> $INSTALATION_DIR/lib "
	if cp -R -u lib $INSTALATION_DIR; then
		printf "OK\n"
	else
		printf "ERRO"
		return 1
	fi

	# Scripts
	printf "Copiando scripts ==> $INSTALATION_DIR/scripts "
	if cp -R -u scripts $INSTALATION_DIR; then
		printf "OK\n"
	else
		printf "ERRO"
		return 1
	fi

	# Stable
	printf "Copiando stable ==> $INSTALATION_DIR/stable "
	if cp -R -u stable $INSTALATION_DIR; then
		printf "OK\n"
	else
		printf "ERRO"
		return 1
	fi

	# Setup
	printf "Copiando setup.sh ==> $INSTALATION_DIR/setup.sh "
	if cp -R -u setup.sh $INSTALATION_DIR; then
		printf "OK\n"
	else
		printf "ERRO"
		return 1
	fi

	# Storecli
	printf "Copiando storecli.sh ==> $INSTALATION_DIR/storecli.sh "
	if cp -R -u storecli.sh $INSTALATION_DIR; then
		printf "OK\n"
	else
		printf "ERRO"
		return 1
	fi
	return 0
	# cp -R -v -u storecli-amd64 $INSTALATION_DIR
}

_install_storecli()
{
	_download_storecli || return 1
	
	printf "Entrando no diretório ... $TEMP_DIR\n"
	cd "$TEMP_DIR"
	printf "Descomprimindo ... storecli.tar.gz "
	if tar -zxvf storecli.tar.gz -C $UNPACK_DIR 1> /dev/null; then
		printf "OK\n"
	else
		printf "ERRO: Falha na descompressão\n"
		return 1
	fi

	cd $UNPACK_DIR
	mv $(ls -d storecli-*) storecli-amd64
	! cd storecli-amd64 && {
		printf "ERRO: diretório 'storecli-amd64' não encontrado\n"
		return 1
	}

	mkdir -p $INSTALATION_DIR
	_copy_files || return 1
	chmod -R a+x $INSTALATION_DIR
	ln -sf $INSTALATION_DIR/storecli.sh $DESTINATION_LINK


	if [ -x $DESTINATION_LINK ]; then
		printf "\033[0;33mstorecli instalado com sucesso!\033[m\n"
		return 0
	else
		printf "ERRO: Falha na instalação, tente novamente."
		return 1
	fi
}


main()
{
	
	case "$1" in 
		--remove) 
				printf "Desinstalando storecli ... "
				rm -rf $INSTALATION_DIR
				rm -rf $DESTINATION_LINK
				printf "OK\n"
				return
				;;
	esac			
	_install_storecli || return 1
	printf "Limpando arquivos temporários "
	rm -rf "$TEMP_DIR"
	printf "OK\n"
}

main "$@" || exit 1
exit 0