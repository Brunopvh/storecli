#!/usr/bin/env bash
#
# Script para atualizar o storecli para ultima versão disponível.
#

readonly temp_dir=$(mktemp -d)
readonly temp_file=$(mktemp -u)
readonly BRANCH='v3.1'
readonly ONLINE_REPO="https://github.com/Brunopvh/storecli/archive/refs/heads/${BRANCH}.zip"


clientDownloader='None'
if [[ -x $(command -v curl) ]]; then
	clientDownloader='curl'
elif [[ -x $(command -v wget) ]]; then
	clientDownloader='wget'
else
	echo -e "Instale curl ou wget para prosseguir."
	exit 1
fi


function checkInternet(){
	# https://www.vivaolinux.com.br/dica/Wget-Verificando-existencia-de-arquivo-remoto
	# https://www.vivaolinux.com.br/dica/Verificar-se-site-esta-online-via-linha-de-comando
	#

	#if isExecutable ping; then
	#	ping -c 1 8.8.8.8 #1> /dev/null 2>&1 || return $?

	[[ "$clientDownloader" == 'None' ]] && return 1

	if [[ "$clientDownloader" == 'curl' ]]; then
		curl -Is 'www.google.com' 1> /dev/null 2>&1 && return 0
	elif [[ "$clientDownloader" == 'wget' ]]; then
		wget -q 'www.google.com' -O /dev/null && return 0
	fi	

	_status=$?
	echo -e "Você não está conectado a INTERNET"
	return $_status
}


function download()
{
    # $1 = URL
	# $2 = Output File - (Opcional)
	#
	# Baixa arquivos da internet.
	# Requer um gerenciador de downloads wget, curl, aria2
	# 
	# https://curl.se/
	# https://www.gnu.org/software/wget/
	# https://aria2.github.io/manual/pt/html/README.html
	# 
	


	[[ -f "$2" ]] && {
		echo -e "Arquivo encontrado ... $2"
		return 0
	}

	local url="$1"
	local path_file="$2"

	if [[ "$clientDownloader" == 'None' ]]; then
		echo -e "(download) Instale curl|wget para prosseguir."
		sleep 0.1
		return 1
	fi


	checkInternet || return $?

	# echo -e "Baixando ... $url"

	clientDownloader='curl'

	if [[ ! -z $path_file ]]; then
		case "$clientDownloader" in 
			aria2c) 
					aria2c -c "$url" -d "$(dirname $path_file)" -o "$(basename $path_file)" 
					;;
			curl)
				curl -C - -S -L -o "$path_file" "$url"
					;;
			wget)
				wget -c "$url" -O "$path_file"
					;;
		esac
	else
		case "$clientDownloader" in 
			aria2c) 
					aria2c -c "$url"
					;;
			curl)
					curl -C - -S -L -O "$url"
					;;
			wget)
				wget -c "$url"
					;;
		esac
	fi

	[[ $? == 0 ]] && return 0
	echo -e '(download)'
	return 1
}


function fileInfo(){
	# Retorna informções de um arquivo com base no comando file.
	[[ ! -f $1 ]] && {
		echo -e "fileInfo"
		return 1
	}

	file "$1" | cut -d ' ' -f 2
}



function unpack()
{
	# Descomprimir vários tipos de arquivos.
	#
	# $1 = arquivo a ser descomprimido - (obrigatório)
	# $2 = diretório de saída - (opcional)
	
	local _unpackDir=$(pwd)

	if [[ ! -f "$1" ]]; then
		echo -e 'ERRO ... unpack_archive'
		return 1
	fi


	if [[ -d $2 ]]; then _unpackDir="$2"; fi


	[[ ! -w "$_unpackDir" ]] && { 
		echo -e "ERRO ... Você não tem permissão de escrita [-w] em ... $_unpackDir"
		return 1	
	}

	# Obter o tipo de arquivo
	path_file="$1"
	extension_file=$(fileInfo $1)

	
	# Calcular o tamanho do arquivo
	# local len_file=$(du -hs $path_file | awk '{print $1}')
	# echo -ne "Descompactando ... $(basename $1) "

	# Descomprimir de acordo com cada extensão de arquivo.	
	if [[ "$extension_file" == 'gzip' ]]; then
		tar -zxvf "$path_file" -C "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'bzip2' ]]; then
		tar -jxvf "$path_file" -C "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'XZ' ]]; then
		tar -Jxf "$path_file" -C "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'Zip' ]]; then
		unzip -o "$path_file" -d "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'Debian' ]]; then
		
		if [[ -f /etc/debian_version ]]; then    # Descompressão em sistemas DEBIAN
			ar -x "$path_file" 1> /dev/null 2>&1 
		else                                     # Descompressão em outros sistemas.
			ar -x "$path_file" --output="$_unpackDir" 1> /dev/null 2>&1
		fi
	fi

	# echo -e "$(date +%H:%M:%S)"

	return $?
}




function _update(){
	download $ONLINE_REPO $temp_file 1> /dev/null 2> /dev/null || return $?
	unpack $temp_file $temp_dir || return $?
	cd $temp_dir

	mv $(ls -d *storecli*) storecli
	cd storecli
	chmod +x setup.sh
	./setup.sh
	
}


function main()
{
	_update
	return $?
}



main $@
