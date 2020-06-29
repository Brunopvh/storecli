#!/usr/bin/env bash
#
#
# Use: 
# source Gpg.sh
# _verify_signature <sig> <file>
#
#


_verify_signature()
{
	# $1 = sig
	# $2 = file
	# gpg -a --export <nr_da_chave> > arq.asc

	if ! is_executable 'gpg'; then
		_red "Instale o pacote 'gpg'"
		return 1
	fi

	if [[ ! -f "$2" ]]; then
		_red "Use _verify_signature <sig> <file>"
		return 1
	fi

	local sig="$1"
	local file="$2"

	echo -ne "[>] Verificando arquivo [$(basename $file)] "

	if gpg --verify "$sig" "$file" 2> /dev/null; then
		echo 'OK'
	else
		rm -rf "$file"
		rm -rf "$sig"
		echo ' '
		_red "Falha o arquivo [$file] não é confiável portanto foi removido"
		return 1
	fi	
}