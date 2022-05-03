#!/usr/bin/env bash
#
#

[[ -z $SHELL_LIBS ]] && {

	if [[ -f ~/.shell-libs.rc ]]; then
		source ~/.shell-libs.rc
	elif [[ -d ~/.local/lib/shell-libs ]]; then
		export SHELL_LIBS=~/.local/lib/shell-libs
	elif [[ -d /usr/local/lib/shell-libs ]]; then
		export SHELL_LIBS=/usr/local/lib/shell-libs
	else
		echo -e "ERRO ... SHELL_LIBS não encontrado."
		exit 1
	fi
}


source "${SHELL_LIBS}"/__init__.sh

