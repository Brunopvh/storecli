#!/usr/bin/env bash
#
#
# Compara hash de um arquivo com uma hash recebida como argumento
# Uso:
# _check_sum <path/arquivo> <soma> --> Se a soma for igual irá retornar OK se não ira retornar 1.
#

function _c()
{
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

# Sum
function _run_sum()
{
# $1 = file
# $2 = sum
local path_arq="$1"
local sum="$2"	

echo -e "$(cl 32)==> $(cl)Gerando soma do arquivo [$path_arq]"	
get_new_sum=$(sha256sum "$path_arq" | awk '{print $1}')

echo "[$sum]<->[$get_new_sum]"
echo -ne "$(cl 32)==> $(cl)Comparando os valores: "

if [[ "$sum" == "$get_new_sum" ]]; then
	echo "$(_c 32 7)[OK]$(_c)"; return 0
	
else
	echo "$(_c 31 5)[Falha]$(_c)"; return 1

fi
	
}

# Check args.
function _check_sum()
{
[[ -z "$1" ]] && { echo "==> [Erro] use: <arquivo> <soma>"; return 1; }
[[ -z "$2" ]] && { echo "==> [Erro] use: <arquivo> <soma>"; return 1; }
[[ ! -f "$1" ]] && { echo "==> [Falha] arquivo inválido: $1"; return 1; }

_run_sum "$@"
	
[[ $? == '0' ]] || { echo "Função: $(_c 31 5)_check_sum $(_c) retornou $(_c 31)[erro]"$(_c); return 1; }
	
}

