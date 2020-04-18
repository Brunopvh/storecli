#!/usr/bin/env bash
#
#



_WGET()
{
	echo -e "$space_line"
	cd "$Dir_Downloads"
	if wget "$@"; then
		return 0
	else
		return 1
	fi
}


_dow()
{
	# $1 = url
	# $2 = arquivo de destino - (OPICIONAL)
	local url="$1"
	local path_file="$2"

	if [[ -z "$Dir_Downloads" ]]; then
		red "O deretório de Downloads e nulo"
		return 1
	fi	

	# O arquivo solicitado já existe
	if [[ -f "$path_file" ]]; then
		msg "Arquivo encontrado em [$path_file]"
		return 0
	fi

	msg "Baixando [$url]"
	if [[ -z "$path_file" ]]; then
		_WGET -c "$url" && return 0
	else
		msg "Destino [$path_file]"
		_WGET -c "$url" -O "$path_file" && return 0
	fi

	red "Função [_dow] retornou erro"
	return 1
}