#!/usr/bin/env bash
#
#
# Use: 
# source Gpg.sh
# _verify_sig <sig> <file>
#
#


_verify_sig()
{
	# $1 = sig
	# $2 = file
	# gpg -a --export <nr_da_chave> > arq.asc

	if ! _WHICH 'gpg'; then
		red "Instale o pacote 'gpg'"
		return 1
	fi

	if [[ ! -f "$2" ]]; then
		red "Use _verify_sig <sig> <file>"
		return 1
	fi

	local sig="$1"
	local file="$2"

	echo -e "$space_line"
	echo -ne "[>] Verificando arquivo [$(basename $file)] "

	if gpg --verify "$sig" "$file"; then
		echo 'OK'
	else
		rm -rf "$file"
		rm -rf "$sig"
		red "Falha o arquivo [$file] não é confiável portanto foi removido"
		return 1
	fi	
}