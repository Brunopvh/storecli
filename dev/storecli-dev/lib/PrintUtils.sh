#!/usr/bin/env bash
#

if [[ -f "$dirSTORECLIPathLib/Colors.sh" ]]; then
	source "$dirSTORECLIPathLib/Colors.sh"
fi

_red()
{
	echo -e "[${CRed}!${CReset}] $@"
}

_green()
{
	echo -e "[${CGreen}*${CReset}] $@"
}

_yellow()
{
	echo -e "[${CYellow}+${CReset}] $@"
}


_blue()
{
	echo -e "[${CBlue}~${CReset}] $@"
}


_white()
{
	echo -e "[${CWhite}>${CReset}] $@"
}

_msg()
{
	echo '--------------------------------------------------'
	echo -e " $@"
	echo '--------------------------------------------------'
}

_YESNO()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do programa, em que a resposta deve ser do tipo SIM ou NÃO (s/n)
	# esta função é para automatizar esta indagação.
	#
	#   se teclar "s" -----------------> retornar 0  
	#   se teclar "n" ou nada ---------> retornar 1.
	#
	# $1 = Mensagem a ser exibida para o usuário reponder SIM ou NÃO (s/n).
	
	echo -en "[>] $@ [${CYellow}s${CReset}/${CRed}n${CReset}]?: "
	read -t 20 -n 1 sn
	echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		_green "${CYellow}A${CReset}bortando"
		return 1
	fi
}


_space_text()
{
	if [[ "${#@}" != '2' ]]; then
		_red "Falha: informe apenas 2 argumentos para serem exibidos como string"
		return 1
	fi

	local line='-'
	num="$((45-${#2}))"  
	
	for i in $(seq "$num"); do
		line="${line}-"
	done
	
	echo -e "$1 ${line}> $2"
}


_show_info()
{
	case "$1" in
		DownloadOnly) _gree "Feito somente download";;
	esac
}