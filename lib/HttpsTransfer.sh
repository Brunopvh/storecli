#!/usr/bin/env bash
#
# Esté módulo serve para fazer download dos arquivos/pacotes 
# a serem instalados pelo script storecli usando a ferramenta curl
# use _dow <url> <arquivo> 
# 
#

#======================================================#
# Curl
#======================================================#
function _Curl()
{
# $1 = url
# $2 = path_arq
	local url="$1"
	local path_arq="$2"

	printf "\033[1;37m=> Baixando: [$url]\n"
	if [[ -z $2 ]]; then 
		curl -# -C - -f -O "$url" 

	elif [[ -d $(dirname "$2") ]]; then
		printf "=> Destino: [$path_arq]\033[m\n" 
		curl -LSf -C - "$url" -o "$path_arq"

	fi
}

#======================================================#
# _dow url path_arq
#======================================================#
function _dow()
{
	# Se o download solicitado já existir a função irá encerrar.
	if [[ -f "$2" ]]; then 
		echo -e "=> O arquivo já existe em: [$2]"
		echo -e "=> 'Pulando' o download" 
		return 0 
	fi

	# Fazer o download com a ferramenta curl atravez da função _Curl.
	_Curl "$@" && return 0

	printf "\033[1;31m"
	echo "=> Função [_dow] retornou erro"
	printf "\033[m\n"	
}
