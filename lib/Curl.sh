#!/usr/bin/env bash
#
#



_CURL()
{
	# User Agent -A
	cd "$Dir_Downloads"
	if curl "$@"; then
		return 0
	else
		return 1
	fi
}


_dow()
{
	# $1 = url
	# $2 = arquivo de destino - (OPICIONAL)
	#
	# Usr Agent Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/44.0.2403.157 Safari/537.36
	# Mozilla/5.0 (X11; Linux x86_64)
	local url="$1"
	local path_file="$2"
	local UserAgent='Mozilla/5.0 (X11; Linux x86_64)'

	if [[ -z "$Dir_Downloads" ]]; then
		red "O deretório de Downloads e nulo"
		return 1
	fi	

	# O arquivo solicitado já existe
	if [[ -f "$path_file" ]]; then
		blue "Arquivo encontrado em: $path_file"
		return 0
	fi

	blue "Baixando: $url"
	if [[ -z "$path_file" ]]; then
		_CURL -C - -SL -O "$url"
	else
		blue "Destino: $path_file"
		_CURL -C - -SL "$url" -o "$path_file"
	fi



	if [[ "$?" == '0' ]]; then
		return 0
	elif [[ "$?" == '130' ]]; then
		red "Cancelado com Ctrl c"
	else
		red "Função [_dow] retornou erro"
	fi


	rm "$path_file"
	return 1	
}
