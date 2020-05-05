#!/usr/bin/env bash
#
# Este Módulo/Script tem a finalidade de exibir algumas informações
# ao usuário, como por exemplo a função que mostra ajuda, a lista de
# pacotes disponíveis para instalação entre outros.
#   Qualquer nova informção sobre ajuda ou um novo pacote que for
# implementado neste script e necessário incluir o nome do pacote no 
# arquivo de "Arrays.sh" que automaticamente o novo pacote será exibido
# quando o usuario executar storecli -l|--list
#

usage()
{
cat << EOF
    Use: $Script_root -b|-c|-h|-l|-u|-v
         $Script_root install <pacote>
         $Script_root remove <pacote>

       -b|--broke                    Remove pacotes quebrados - (usar em sistemas Debian apenas).
       -c|--configure                Instala requerimentos desse script.
       -h|--help                     Mostra ajuda.
       -l|--list                     Lista aplicativos disponíveis para instalação.
       -u|--upgrade                  Instala ultima versão desse script disponível no github.
       -v|--version                  Mostra versão.

       --ignore-cli                  Ignora a verificação dos pacotes/dependências deste script.
                                     $Scriptroot --ignore-cli install <pacote>

       remove <remove>               Remove um pacote.
       install <pacote>              Instala um pacote.


             Opções para install [-d|--downloadonly] somente baixa o(s) pacote(s).
             $Script_root install -d torbrowser 
             $Script_root install --downloadonly pycharm 
EOF
}

#=============================================================#

_INFO()
{
# Mensagens padrão para serem exibidas como por exemplo: 
# informar que um programa foi instalado com sucesso
# ou que houve um erro durante a instalação, ou seja, mensagens
# com o mesmo padrão exibidas várias vezes.
#
#
# $1 = tipo de mensagem formatada a ser exibida (OBRIGATÓRIO).
# $2 = texto (OPICIONAL) a ser exibido.
#
# EX:
#   _INFO 'pkg_sucess' 'Nome do Pacote aqui' -->> isso ira
# mostra ao usuário que um pacote foi instalado com sucesso.
#
#
case "$1" in
pkg_are_instaled) 
	white "O pacote ${Green}[$2]${Reset} já está instalado. Para remover-lo use $Script_root ${Green}r${Reset}emove $2"
	;;
	
pkg_sucess) 
	white "[$2] instalado com sucesso"
	;;

pkg_instalation_failed)
	red "Falha ao tentar instalar [$2]"
	;;

pkg_not_found) 
	red "Programa indisponível para seu sistema [$2]"
	;;

file_not_found) red "Arquivo não encontrado [$2]"
	;;

download_only) white "Feito somente download [$2]"
	;;

esac
}

#=============================================================#

_list_applications()
{
# Exibir os pacotes de cada categoria, essas informações estão 
# no arquivo Arrays.sh
# para que um programa seja adicionado ou removido da lista de 
# exibição quando se executa "storecli --list" basta adicioná-lo
# ou remove-lo do array correspondente no arquivo Arrays.sh
#
echo " Acessórios: "
for a in "${array_acessorios[@]}"; do echo "     $a"; done
echo ' '	
	
echo " Desenvolvimento: "
for a in "${array_dev[@]}"; do echo "     $a"; done
echo ' '

echo " Escritorio: "
for a in "${array_escritorio[@]}"; do echo "     $a"; done
echo ' '

echo " Internet:  "
for a in "${array_internet[@]}"; do echo "     $a"; done
echo ' '

echo "  Midia:  "
for a in "${array_midia[@]}"; do echo "     $a"; done
echo ' '

echo " Sistema: "
for a in "${array_sistema[@]}"; do echo "     $a"; done
echo ' '

#echo " Wine: "
#for a in "${array_wine[@]}"; do echo "     $a"; done
#echo ' '

echo " Preferências: "
for a in "${array_preferencias[@]}"; do echo "     $a"; done
echo ' '

# Algumas extensões do gnome não estão disponíveis nos repositórios
# das distros da mesma maneira, por exemplo: No Debian e derivados 
# podemos instalar várias extensões para o Gnome via APT INSTALL
# no entanto no Archlinux e Fedora o número de extensões via
# PACMAN INSTALL e DNF INSTALL e menor, sendo necessário instalção
# das extensões atraves do código fonte no github - (Leia a LIB
# programs/GnomeShell.sh) 
echo " Gnome Shell Extensões pacote(gnome-extensions): "
case "$os_id" in
	debian|ubuntu) for a in "${array_gnome_shell_debian[@]}"; do echo "     $a"; done;; # Disponíveis para Debian
	fedora) for a in "${array_gnome_shell_fedora[@]}"; do echo "     $a"; done;;        # Disponíveis para Fedora
	arch) for a in "${array_gnome_shell_archlinux[@]}"; do echo "     $a"; done;;       # Disponíveis para Arch
	suse) for a in "${array_gnome_shell_suse[@]}"; do echo "     $a"; done;;            # Disponíveis para Suse
esac
echo "     topicons-plus"
echo "     dash-to-dock"
}

#=============================================================#

function _YESNO()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do programa, em que a resposta deve ser do tipo SIM ou NÃO (s/n)
	# esta função é para automatizar esta indagação.
	#
	#   se teclar "s" -----------------> retornar 0  
	#   se teclar "n" ou nada ---------> retornar 1.
	#
	# $1 = Mensagem a ser exibida para o usuário reponder SIM ou NÃO (s/n).
	
	echo -en "[>] $@ [${Yellow}s${Reset}/${Red}n${Reset}]?: "
	read -t 10 -n 1 sn
	echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		white "${Yellow}A${Reset}bortando"
		return 1
	fi
}


