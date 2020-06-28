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
		_red "Arquivo inválido [$1]"
		return 1
	fi

	_white "Gerando hash do arquivo [$1]"
	local hash_file=$(sha256sum "$1" | cut -d ' ' -f 1)
	
	_yellow "[$hash_file] -> Hash Local"
	_yellow "[$2] -> Hash do arquivo baixado"
	echo -ne "[>] Comparando valores "
	if [[ "$hash_file" == "$2" ]]; then
		echo -e "${C_yellow}OK${CReset}"
	else
		echo ' '
		rm -rf "$1"
		_red "Falha arquivo [$1] não é seguro portanto foi removido"
		return 1
	fi
}

