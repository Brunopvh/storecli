#!/usr/bin/env bash
#
#
#
#
#


Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;93m'
White='\033[1;37m'
Reset='\033[m'

#=============================================================#
_c()
{
	if [[ -z $2 ]]; then
		echo -e "\033[1;$1m"
	elif [[ $2 ]]; then
		echo -e "\033[$2;$1m"
	fi
}

#=============================================================#
msg()
{
	echo -e "${White}[>] $@${Reset}"
}

red()
{
	echo -e "${Red}[!] $@${Reset}"
}

green()
{
	echo -e "${Green}[+] $@${Reset}"
}

yellow()
{
	echo -e "${Yellow}[*] $@${Reset}"
}

#=============================================================#

SPACE_TEXT()
{
	# Espaçamento entre textos ou mensagens, o distânciamento
	# padrão e 45, esse valor será subraido do tamanho da string "${#string}"
	# Exemplo echo "texto1 $(SPACE_TEXT 'texto1') texto2"
	
	local line='-'
	num="$((40-${#@}))" # Subtrair (45) - (tamanho da string recebida com $@) 

	for n in $(seq "$num"); do
		line="${line}-"
	done
	echo -ne "$line"
}
