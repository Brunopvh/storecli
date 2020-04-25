#!/usr/bin/env bash
#
#
#
#
#


Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
White='\033[0;37m'
Reset='\033[0m'

# Default
CRed='\033[0;31m'
CGreen='\033[0;32m'
CYellow='\033[0;33m'
CBlue='\033[0;34m'
CWhite='\033[0;37m'


# Strong
CSRed='\033[1;31m'
CSGreen='\033[1;32m'
CSYellow='\033[1;33m'
CSBlue='\033[1;34m'
CSWhite='\033[1;37m'


# Dark
CDRed='\033[2;31m'
CDGreen='\033[2;32m'
CDYellow='\033[2;33m'
CDBlue='\033[2;34m'
CDWhite='\033[2;37m'



# Blinking text
CBRed='\033[5;31m'
CBGreen='\033[5;32m'
CBYellow='\033[5;33m'
CBBlue='\033[5;34m'
CBWhite='\033[5;37m'

# Reset
CReset='\033[0m'

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
	echo -e "${CWhite}[>] $@${Reset}"
}

red()
{
	echo -e "${CSRed}[!] $@${Reset}"
}

green()
{
	echo -e "${CGreen}[+] $@${Reset}"
}

yellow()
{
	echo -e "${CYellow}[*] $@${Reset}"
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
