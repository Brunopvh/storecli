#!/usr/bin/env bash
#
# Use: 
#   source GitClone.sh
#   _gitclone "repo"
#


if [[ -z "$dir_temp" ]]; then
	red "O diretório [dir_tmp] é nulo"
	exit 1
fi

#=============================================================#

_gitclone()
{

	cd '/tmp'
	cd "$dir_temp" || return 1
	
	if [[ -z $1 ]]; then
		red "Use _gitclone <repo.git>"
		return 1
	fi

	msg "Clonando [$1]"
	msg "Destino [$(pwd)]"
	if git clone "$1"; then
		return 0
	else
		red "Falha ao tentar clonar [$1]"
		return 1
	fi
}
