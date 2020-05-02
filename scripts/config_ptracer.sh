#!/bin/sh
#
#
#-------------------------------------------------------#
# FONTES
#-------------------------------------------------------#
# https://www.vivaolinux.com.br/dica/Como-extrair-e-instalar-pacotes-deb-sem-o-DPKG
# https://packages.debian.org/jessie/amd64/libssl1.0.0/download
# https://packages.debian.org/pt-br/jessie/amd64/libpng12-0/download 
#
#-------------------------------------------------------#
# libcrypto.so.1.0.0
# libpng12.so.0
#

clear

Red=$(printf "\033[1;31m")
Green=$(printf "\033[1;32m")
Yellow=$(printf "\033[1;33m")
White=$(printf "\033[1;37m")
Reset=$(printf "\033[m\n")

space_line='==================================================='

msg()
{
	echo "=> ${@}"	
}

#=======================================================#
red()
{
	echo "=> $Red${@}$Reset"
}

#=======================================================#
green()
{
	echo "=> $Green${@}$Reset"
}

#=======================================================#
white()
{
	echo "=> $White${@}$Reset"
}

#=======================================================#
# Necessário ser o root
#=======================================================#
user_id=$(id -u)
if ! [ "$user_id" = 0 ]; then
	red "[!] Você precisa ser o root"
	exit 1
fi

#=======================================================#
# Diretórios
#=======================================================#
dir_temp="/tmp/$USER/pt_config"
dir_dow="$dir_temp/downloads"
dir_unpack="$dir_temp/unpack"

mkdir -p "$dir_temp"
mkdir -p "$dir_dow"
mkdir -p "$dir_unpack"

#=======================================================#
# Urls
#=======================================================#
url_libpng12='http://ftp.us.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_amd64.deb'
url_libssl='http://security.debian.org/debian-security/pool/updates/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u12_amd64.deb'

#=======================================================#
# Arquivos
#=======================================================#
file_libpng12="$dir_dow/$(basename $url_libpng12)"
file_libssl="$dir_dow/$(basename $url_libssl)"


#=======================================================#
# hash sha256sum
#=======================================================#
hash_libpng12='fa86f58f9595392dc078abe3b446327089c47b5ed8632c19128a156a1ea68b96'
hash_libssl='c91f6f016d0b02392cbd2ca4b04ff7404fbe54a7f4ca514dc1c499e3f5da23a2'

#=======================================================#

WHICH()
{
	# Verificar executáveis via linha de comando.
	pkg=$(which "$1" 2> /dev/null)
	if [ -x "$pkg" ]; then
		return 0
	else
		return 1
	fi
}

#=======================================================#

CLI()
{
	local line='-----------------------------------------------'
	while [ $1 ]; do
		if ! WHICH "$1"; then
			echo "${Red}[!] $line $1${Reset}"
			return 1
			break
		fi
		shift
	done
	return 0
}

#=======================================================#
_Curl()
{
	# $1 = url
	# $2 = path_file
	local url="$1"
	local path_file="$2"

	if [ -f "$path_file" ]; then
		rm "$path_file"
	fi


	echo "Baixando: [$url]"
	echo "Destino: [$path_file]"

	if curl -# -SL "$url" -o "$path_file"; then
		return 0
	else	
		red "[!] Falha no download de $(basename $path_file)"
		return 1
	fi
}

#=======================================================#
# Descompactar arquivos .deb
#=======================================================#
unpack_deb()
{
	# $1 = arquivo a ser descompactado - tem que estar no diretório "$dir_dow"
	if [ -z $1 ]; then
		red "Informe um arquivo '.deb' para descompressão"
	fi

	cd "$dir_dow"

	msg "Descomprimido: [$1]"
	msg "Destino: [$(pwd)]"
	ar -x "$1"
}

#=======================================================#
# Descompactar arquivos .tar.gz
#=======================================================#
unpack_tar()
{
	# $1 = arquivo .tar.gz a ser descomprimido no diretório "$dir_unpack".
	# tar -zxpvf data.tar.gz -C
	# tar -Jxf "$path_arq" -C "$DIR_TEMP"

	cd "$dir_unpack" && rm -rf *

	echo "$space_line"
	msg "Descomprimido: [$1]"
	msg "Destino: [$dir_unpack]"

	if tar -Jxf "$1" -C "$dir_unpack"; then
		return 0
	else
		red "[!] Falha na descompressão de [$1]"
		return 1
	fi
}


#=======================================================#
# Configurar os arquivos individualmente usando as 
# funções unpack_deb e unpack_tar
#=======================================================#
config_libs()
{
	# Descomprimir e configurar libpng12 .deb
	unpack_deb "$file_libpng12" || return 1

	# Descomprimir arquivo de dados .tar.xz gerado
	unpack_tar "$dir_dow/data.tar.xz" || return 1

	# Copiar as libs descompactadas para /opt/bin/pt
	cd "$dir_unpack/lib/x86_64-linux-gnu"
	echo "$space_line"
	msg "Configurando libpng12.so.0"
	cp -uv libpng12.so.0 '/opt/pt/bin/' || return 1
	chmod +765 '/opt/pt/bin/libpng12.so.0'
	
	msg "Configurando libpng12.so.0.50.0"
	cp -uv libpng12.so.0.50.0 '/opt/pt/bin/' || return 1
	chmod +765 '/opt/pt/bin/libpng12.so.0.50.0'

	# Remover arquivos temporarios de libpng12
	msg "Limpando 'lixo' de libpng12"
	cd "$dir_dow"
	rm data.tar.xz
	rm control.tar.gz
	rm debian-binary
	cd "$dir_unpack" && rm -rf *

	# Descomprimir e configurar libssl .deb
	unpack_deb "$file_libssl" || return 1

	# Descomprimir arquivo de dados .tar.xz gerado apartir de libssl.deb
	unpack_tar "$dir_dow/data.tar.xz" || return 1

	# Copiar as libs descompactadas para /opt/bin/pt
	cd "$dir_unpack/usr/lib/x86_64-linux-gnu"
	echo "$space_line"
	msg "Configurando libcrypto.so.1.0.0"
	cp -uv libcrypto.so.1.0.0 '/opt/pt/bin/'
	chmod +765 '/opt/pt/bin/libcrypto.so.1.0.0'

	# Remover arquivos temporarios de libssl
	msg "Limpando 'lixo' de libssl"
	cd "$dir_dow"
	rm data.tar.xz
	rm control.tar.gz
	rm debian-binary

	return 0
}

#=======================================================#
main()
{
	echo "$Yellow"
	# Verificar se o curl está instalado no sistema
	CLI 'curl' || return 1

	# Fazer o download dos arquivos
	_Curl "$url_libpng12" "$file_libpng12" || return 1
	_Curl "$url_libssl" "$file_libssl" || return 1

	# Configurar as libs
	config_libs || return 1
	
	echo "$Reset"
}
#=======================================================#

main






