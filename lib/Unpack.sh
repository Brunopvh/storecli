#!/usr/bin/env bash
#
#

#=============================================================#

_unpack()
{
	# Obrigatório informar um arquivo no argumento $1.
	[[ -z $1 ]] && usage_unpack && exit 1 
	
	# Argumento $1 foi informado, porém não é um arquivo.
	if [[ ! -f "$1" ]]; then 
		_INFO 'file_not_found' "$1"
		return 1
	fi

	# Diretório destino da descompressão.
	if [[ ! -d "$Dir_Unpack" ]]; then
		red "O valor de [Dir_Unpack] é nulo"
		return 1
	fi

	cd /tmp
	cd "$Dir_Unpack" || return 1
	
	# Prosseguir.
	local path_file="$1"

	# Detectar a extensão do arquivo.
	if [[ "${path_file: -6}" == 'tar.gz' ]]; then # tar.gz - 6 ultimos caracteres.
		type_file='tar.gz'
	elif [[ "${path_file: -7}" == 'tar.bz2' ]]; then # tar.bz2 - 7 ultimos carcteres.
		type_file='tar.bz2'
	elif [[ "${path_file: -6}" == 'tar.xz' ]]; then # tar.xz
		type_file='tar.xz'
	elif [[ "${path_file: -4}" == '.zip' ]]; then # .zip
		type_file='zip'
	elif [[ "${path_file: -4}" == '.deb' ]]; then # .deb
		type_file='deb'
	else
		red "(_unpack) Arquivo não suportado [$path_file]"
		return 1
	fi

	white "Descomprimindo: $path_file"
	echo -ne "[>] Destino: $Dir_Unpack "
	cd "/tmp"


	# Descomprimir.	
	case "$type_file" in
		'tar.gz') tar -zxvf "$path_file" -C "$Dir_Unpack" 1> /dev/null;;
		'tar.bz2') tar -jxvf "$path_file" -C "$Dir_Unpack" 1> /dev/null;;
		'tar.xz') tar -Jxf "$path_file" -C "$Dir_Unpack" 1> /dev/null;;
		zip) unzip "$path_file" -d "$Dir_Unpack" 1> /dev/null;;
		deb) ar -x "$path_file" --output="$Dir_Unpack" 1> /dev/null;;
		*) return 1;;
	esac

	if [[ "$?" == '0' ]]; then
		echo -e "${Yellow}OK${Reset}"
		return 0
	else
		red "Funçao [_unpack] retornou erro"
		red "Removendo [$path_file]"
		_clear_temp_dirs
		return 1
	fi
}
