#!/usr/bin/env bash
#
# Utilitário para descomprimir arquivos .tar.gz, .tar.xz entre outors.
#
# Uso: unpack.sh <aquivo> <destino>
# se destino for nulo, sera usado DIR_TEMP default.
#
#
#

if [[ ! -d "$2" ]]; then 
	DIR_TEMP='/tmp/UNPACK'

elif [[ -d "$2" ]]; then
	DIR_TEMP="$2"

fi

mkdir -p "$DIR_TEMP"

# Cor
function _c() { echo -e "\e[1;${1}m"; }


#==========================================================#
#================= Descompressão dos arquivos =============#
#==========================================================#

function _unpack()
{
# $1 = arquivo a descomprimir.

	local path_arq="$1"

	# Detectar a extensão do arquivo.
	if [[ "${path_arq: -6}" == 'tar.gz' ]]; then # tar.gz - 6 ultimos caracteres.
		type_arq='tar.gz'

	elif [[ "${path_arq: -7}" == 'tar.bz2' ]]; then # tar.bz2
		type_arq='tar.bz2'

	elif [[ "${path_arq: -6}" == 'tar.xz' ]]; then # tar.xz
		type_arq='tar.xz'

	else
		echo "$(_c 31)Arquivo não suportado: [$path_arq] $(_c)"
		return 1

	fi

	# Limpar o destino antes da descompressão.
	cd "$DIR_TEMP" && rm -rf * 2> /dev/null  

		echo -e "$(_c 32)==> $(_c)Descompactando: [$path_arq]"
		echo -e "$(_c 32)==> $(_c)Destino: [$DIR_TEMP]"

	# Descomprimir.
	case "$type_arq" in
		'tar.gz') tar -zxvf "$path_arq" -C "$DIR_TEMP" 1> /dev/null;;
		'tar.bz2') tar -jxvf "$path_arq" -C "$DIR_TEMP" 1> /dev/null;;
		'tar.xz') tar -Jxf "$path_arq" -C "$DIR_TEMP" 1> /dev/null;;
		*) return 1;;
	esac
}

#==========================================================#

[[ ! -f "$1" ]] && { echo -e "$(_c 31)Arquivo não encontrado: $1 $(_c)"; exit 1; }

# Run.
_unpack "$@" 



