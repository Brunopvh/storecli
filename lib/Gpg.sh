#!/usr/bin/env bash
#
#
# Use: 
# source Gpg.sh
# _verify_sig <sig> <file>
#
#

function _verify_sig()
{
# $1 = sig
# $2 = file
# gpg -a --export <nr_da_chave> > arq.asc

local esp='---------------'
local esp2="${esp}${esp}"

[[ ! -x $(command -v gpg 2> /dev/null) ]] && { echo "=> Instale o pacote gpg"; return 1; }

local msg='Use: _verify_sig <sig> <file>'

if [[ -f "$1" ]]; then sig="$1"; else echo "$msg"; return 1; fi
if [[ -f "$2" ]]; then file="$2"; else echo "$msg"; return 1; fi

	echo "$esp[ Verificando ]$esp"
	echo "=> Sig: [$sig]"
	echo "=> Arquivo: [$file]"
	echo " "

	gpg --verify "$sig" "$file" || return 1
	
	return "$?"
}