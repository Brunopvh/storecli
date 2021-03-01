#!/bin/sh
#
# Este script automatiza a instalação do script storecli em sistemas linux.
#
__version__='2021-03-01'
#
# https://github.com/Brunopvh/storecli.git
# https://github.com/Brunopvh/storecli/archive/master.zip
# https://github.com/Brunopvh/storecli/archive/master.tar.gz
#
# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
#

__script__=$(readlink -f "$0")

case "$1" in
	-h|--help)
		echo "Use: ./$(basename $__script__) para instalar o script storecli." 
		echo "     ./$(basename $__script__) -r|--remove para desinstalar o script storecli."
		exit 0
		;;
esac

URL_STORECLI_MASTER='https://github.com/Brunopvh/storecli/archive/old-release.tar.gz'
TEMP_DIR=$(mktemp --directory)
UNPACK_DIR="$TEMP_DIR/unpack"
mkdir -p "$UNPACK_DIR"

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

_download_storecli()
{
	printf "Conectando ... $URL_STORECLI_MASTER "
	if is_executable aria2c; then
		aria2c "$URL_STORECLI_MASTER" -d "$TEMP_DIR" -o storecli.tar.gz 1> /dev/null
	elif is_executable wget; then
		wget -q "$URL_STORECLI_MASTER" -O "$TEMP_DIR"/storecli.tar.gz
	elif is_executable curl; then
		curl -sSL -o "$TEMP_DIR"/storecli.tar.gz "$URL_STORECLI_MASTER"
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
	printf "Copiando $1 ==> $2 "
	if cp -R -u "$1" "$2"; then
		printf "OK\n"
		return 0
	else
		printf "ERRO\n"
		return 1
	fi
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
	_copy_files "lib" "$INSTALATION_DIR" 
	_copy_files "scripts" "$INSTALATION_DIR"  
	_copy_files "setup.sh" "$INSTALATION_DIR" 
	_copy_files "storecli.sh" "$INSTALATION_DIR"

	printf "Configurando permissões para execução\n"; chmod -R a+x $INSTALATION_DIR
	printf "Criando link para execução\n"; ln -sf $INSTALATION_DIR/storecli.sh $DESTINATION_LINK

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
		-r|--remove) 
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