#!/usr/bin/env bash
#

_println()
{
	# Imprimir mensagens sem quebrar linhas.
	echo -ne " + $@"
}

_print()
{
	echo -e " + $@"
}

_clear_temp_dirs()
{
	# Limpar diretórios temporários.
	cd "$DirTemp" && __rmdir__ $(ls)
	cd "$DirUnpack" && __rmdir__ $(ls)
	cd "$DirGitclone" && __rmdir__ $(ls)
}

