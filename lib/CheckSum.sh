#!/usr/bin/env bash
#

usage_check_sum()
{
cat << EOF
	Use: _check_sum <arquivo> <soma_original>
EOF
}


_check_sum()
{
	# Tamanho ${#@}
	if [[ "${#@}" != '2' ]]; then
		usage_check_sum
		return 1
	fi

	if [[ ! -f "$1" ]]; then
		red "Arquivo inválido [$1]"
		return 1
	fi

	white "Gerando hash do arquivo [$1]"
	local hash_file=$(sha256sum "$1" | cut -d ' ' -f 1)
	
	white "Hash local --------> $hash_file"
	white "Hash do servidor --> $2"
	echo -ne "[>] Comparando valores "
	if [[ "$hash_file" == "$2" ]]; then
		echo "[OK]"
	else
		echo ' '
		#rm -rf "$1"
		red "Falha arquivo [$(basename $1)] não é seguro portanto foi removido"
		return 1
	fi
}

