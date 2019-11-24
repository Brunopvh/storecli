#!/usr/bin/env bash
#
# Use: 
#   sourece GitClone.sh
#   _gitclone "repo"
#

source "$Lib_array"

[[ ! -d "$dir_temp" ]] && { dir_temp="/tmp/git_$USER"; mkdir -p "$dir_temp"; }

# Limpar antes de clonar
cd "$dir_temp" && rm -rf *

#-----------------------------------------------------------#

function _gitclone()
{
	[[ -z $1 ]] && { echo "==> Use: _gitclone 'repo'"; return 1; }
	cd "$dir_temp"

	echo "==> Clonando [$1]"
	echo "==> Destino [$dir_temp]"
	if git clone "$1"; then
		return 0
	else
		return 1
	fi
}