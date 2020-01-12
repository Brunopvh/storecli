#!/usr/bin/env bash
#
#
# Compara hash de um arquivo com uma hash recebida como argumento
# Uso:
# source ShaSum.sh
# _check_sum <arquivo> <soma> 
#
# Se a soma informada for igual a soma do arquivo irá 
# receber uma mensagem de "OK" e em seguida retornara
# status de saída "0", se não o programa retornara status de saída "1".
#

function _c()
{
	[[ -z $2 ]] && { echo -e "\033[1;$1m"; return 0; }
	echo -e "\033[$2;$1m"
}

# File+Sum
function _run_sum()
{
# $1 = file
# $2 = sum
local path_arq="$1"
local sum="$2"	

	echo -e "$(_c 32)=> $(_c)Gerando soma do arquivo [$path_arq]"	
	get_new_sum=$(sha256sum "$path_arq" | awk '{print $1}')

	echo "[$sum] -> Soma informada"
	echo "[$get_new_sum] -> Arquivo no disco"

	echo -ne "=> Comparando os valores: "

	if [[ "$sum" == "$get_new_sum" ]]; then
		echo "$(_c 32 2)[OK]$(_c)"; return 0
		
	else
		echo "$(_c 31 5)[Falha]$(_c)"; return 1

	fi
}

# Check args.
function _check_sum()
{
	[[ -z "$1" ]] && { echo "=> [Erro] use: <arquivo> <soma>"; return 1; }
	[[ -z "$2" ]] && { echo "=> [Erro] use: <arquivo> <soma>"; return 1; }
	[[ ! -f "$1" ]] && { echo "=> [Falha] arquivo inválido: $1"; return 1; }

	_run_sum "$@"
		
	[[ $? == '0' ]] || { echo "$(_c 31 5)Função: [_check_sum] retornou erro $(_c)"; return 1; }	
}

