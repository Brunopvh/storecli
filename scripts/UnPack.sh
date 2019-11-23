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
function cor() { echo -e "\e[1;${1}m"; }

#==========================================================#
#================= Descompressão dos programas ============#
#==========================================================#
function _unpack()
{
# $1 = arquivo a descomprimir.

local path_arq="$1"

# Limpar o destino antes da descompressão.
cd "$DIR_TEMP" && rm -rf * 2> /dev/null  

	echo -e "$(cor 32)==> $(cor)Descompactando: [$path_arq]"
	echo -e "$(cor 32)==> $(cor)Destino: [$DIR_TEMP]"

if [[ $(echo "$path_arq" | grep 'tar.gz') ]]; then
	tar -zxvf "$path_arq" -C "$DIR_TEMP" 1> /dev/null	

elif [[ $(echo "$path_arq" | grep 'tar.bz2') ]]; then
	tar -jxvf "$path_arq" -C "$DIR_TEMP" 1> /dev/null

elif [[ $(echo "$path_arq" | grep 'tar.xz') ]]; then
	tar -Jxf "$path_arq" -C "$DIR_TEMP" 1> /dev/null

else
	echo "$(cor 31)==> $(cor)[Erro] arquivo não suportado: $path_arq"
	return 1
fi
}

[[ ! -f "$1" ]] && { echo -e "$(cor 31)==> $(cor)Arquivo não encontrado: $1"; exit 1; }
[[ ! -d "$DIR_TEMP" ]] && { echo -e "$(cor 31)==> $(cor)Erro: $DIR_TEMP"; exit 1; }

_unpack "$@" # Descomprimir.



