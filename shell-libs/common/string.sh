#!/usr/bin/env bash
#
# DEPENDÊNCIAS:
#   + sed
#   + awk
#
# https://www.zentica-global.com/pt/zentica-blog/ver/como-cortar-string-em-bash---linux-hint-60739de9bdd55
# https://giovannireisnunes.wordpress.com/2017/06/02/manipulacao-de-strings-em-bash
# https://www.shellscriptx.com/2016/12/utilizando-expansao-de-variaveis.html
#
#
#
#


function upper()
{
    # arg 1 = string/texto
    # type arg 1 = string
    #

	local _string="$1"
	echo -e "${_string^^}"
}


function lower()
{
    # arg 1 = string/texto
    # type arg 1 = string
    #
	local _string="$1"
	echo -e "${_string,,}"
}

function replace(){
    # arg 1 = texto original a ser substituido
    # arg 2 = corrência que deseja substituir no texto
    # arg 3 = valor final da ocorrência.
    # type args = string
    #
    # SUBSTITUI $2 por $3 no texto original $1.
    local _string="$1"
    echo "$_string" | sed "s/$2/$3/g"
}









