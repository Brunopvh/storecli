#!/usr/bin/env bash
#


#========================================================#
# Mensagens e cores.
#========================================================#
function _c()
{
	# Alterar cores do terminal.
	[[ -z $2 ]] && { echo -e "\033[1;$1m"; return 0; }
	echo -e "\033[$2;$1m"
}

#========================================================#

function _msg()
{
	[[ -z $1 ]] && {
		echo -e "$(_c 32 2)=> INFO $(_c)"
		return 0
	}

	echo -e "=> $(_c)$@"
}

# Red
function _red(){
	echo -e "=> $(_c 31)$@$(_c)"
}

# Green
function _green(){
	echo -e "=> $(_c 32)$@$(_c)"
}

# Yellow
function _yellow(){
	echo -e "=> $(_c 33)$@$(_c)"
}

# White
function _white(){
	echo -e "=> $(_c 37)$@$(_c)"
}
