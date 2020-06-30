#!/usr/bin/env bash
#
#
__version__='2020_06_29_rev2'
__author__='Bruno Chaves'
#
#=============================================================#
# REFERÊNCIAS
#=============================================================#
# https://www.dicas-l.com.br/arquivo/fatiando_opcoes_com_o_getopts.php
# https://man7.org/linux/man-pages/man1/getopts.1p.html
#

#=============================================================#
# Verificar requesitos minimos do sistema.
#=============================================================#
# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]]; then
	printf "\033[0;31m Execute este programa apenas em sistemas Linux.\033[m\n"
	exit 1
fi

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	printf "\033[0;31m Usuário não pode ser o [root] execute novamente sem o [sudo]\033[m\n"
	exit 1
fi

# Necessário ter o pacote "sudo" intalado.
if [[ ! -x $(which sudo 2> /dev/null) ]]; then
	printf "\033[0;31m Instale o pacote [sudo] e adicione [$USER] no arquivo [sudoers] para prosseguir\033[m\n"
	exit 1
fi

# Verificar se a arquitetura do Sistema e 64 bits
if ! uname -m | grep '64' 1> /dev/null; then
	printf "\033[0;31m Seu sistema não e 64 bits. Saindo\033[m\n"
	exit 1
fi

#=============================================================#
# Configuração de diretórios para libs, scripts e programas
#=============================================================#
export dirSTORECLIPath=$(dirname $(readlink -f "$0"))

source "$dirSTORECLIPath/bin/run.sh"
main "$@"
exit "$?"