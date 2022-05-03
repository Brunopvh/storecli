#!/usr/bin/env bash
#
#
#=============================================================#
# + print_text - Imprimir textos com formatação e cores.
#=============================================================#
#
# DEPENDÊNCIAS:
#   colors.sh
#   tput
#
#
#

# Calcular os pixel da janela de terminal.
export COLUMNS=$(tput cols)

function setColumns(){
	# setar o tamanho das colunas do terminal.
	export COLUMNS=$(tput cols)	
}



printLine() # -> None
{
    # + arg 1 = caracter a ser impresso no terminal (=, +, *, ~, -, #, ...).
    # + type arg 1 = string.
    #
    # Imprime um caracter que ocupa todas as colunas do terminal, o padrão é "-".
    #
    if [[ -z $1 ]]; then
	    printf "%$(tput cols)s\n" | tr ' ' '-'
	else
	    printf "%$(tput cols)s\n" | tr ' ' "$1"
	fi
}


function msgErro(){
    # args = number + string 
    # Imprime uma mensagem de erro personalizada na cor padrão do terminal.
	echo -e "ERRO ... $@"
}

function msgErroParam(){
	# Função para exibir erro genérico quando outra função retorna erro, por parâmetros incorretos
	# na linha de comando.
	#
	msgErro "$1 - parâmetros incorretos detectados."
}


printErro()
{
    # Exibe uma mensagem personalizada de erro em vermelho.
	if [[ -z $1 ]]; then
		echo -e "${CRed}ERRO${CReset}"
	else
		echo -e "${CRed}ERRO:${CReset} $@"
	fi
}

printInfo()
{
	echo -e "${CGreen}INFO ... ${CReset}$@"
}


print()
{
    echo -e " + $@"
}


msg()
{
	printLine
	echo -e " $@"
	printLine
}

red()
{
	echo -e "${CRed} ! ${CReset}$@"
}

green()
{
	echo -e "${CGreen} + ${CReset}$@"
}

yellow()
{
	echo -e "${CYellow} + ${CReset}$@"
}

blue()
{
	echo -e "${CBlue} + ${CReset}$@"
}

white()
{
	echo -e "${CWhite} + ${CReset}$@"
}

sred()
{
	echo -e "${CSRed}$@${CReset}"
}

sgreen()
{
	echo -e "${CSGreen}$@${CReset}"
}

syellow()
{
	echo -e "${CSYellow}$@${CReset}"
}

sblue()
{
	echo -e "${CSBlue}$@${CReset}"
}



