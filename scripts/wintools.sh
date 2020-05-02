#!/usr/bin/env bash
#
#

clear

#-----------------------------------------------#
Red="\033[1;31m"
Green="\033[1;32m"
Yellow="\033[1;33m"
Blue="\033[1;34m"
White="\033[1;37m"
Reset="\033[m"

space_line='------------------------------------------'

_msg()
{
	echo -e "[>] $@"
}

_red()
{
	echo -e "$(printf $Red)[!] $@$(printf $Reset)"
}

_green()
{
	echo -e "$(printf $Green)[*] $@$(printf $Reset)"
}

_yellow()
{
	echo -e "$(printf $Yellow)[+] $@$(printf $Reset)"
}

# Não pode ser root.
if [[ $(id -u) == '0' ]]; then
	_red "O usuário não pode ser o 'root'"
	exit 1
fi

# Necessário curl para fazer download dos arquivos.
#

#-----------------------------------------------#
# Diretórios
#-----------------------------------------------#
export readonly dir_root=$(dirname $(readlink -f "$0")) 


#-----------------------------------------------#
# Tipo de sistema
#-----------------------------------------------#
os_kernel=$(uname -s) # Kernel

if [[ "$os_kernel" == 'Linux' ]]; then
	os_id=$(grep '^ID=' "/etc/os-release" | sed 's/.*=//g;s/\"//g')
fi

_msg "Sistema ............................ $os_id"



