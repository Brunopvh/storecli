#!/usr/bin/env bash
#

usage()
{
cat << EOF
    Use: $Script_root -b|-c|-h|-l|-u|-v
         $Script_root install <pacote>
         $Script_root remove <pacote>

       -b|--broke                    Remove pacotes quebrados.
       -c|--configure                Instala requerimentos desse script.
       -h|--help                     Mostra ajuda.
       -l|--list                     Lista aplicativos disponíveis para instalação.
       -u|--upgrade                  Instala ultima versão desse script disponível no github.
       -v|--version                  Mostra versão.

       --ignore-cli                  Ignora a verificação dos pacotes/dependências deste script.
                                     $Scriptroot --ignore-cli install <pacote>

       remove <remove>               Remove um pacote.
       install <pacote>              Instala um pacote.


             Opições para install [-d|--downloadonly] somente baixa o(s) pacote(s).
             $Script_root install -d torbrowser 
             $Script_root install --downloadonly pycharm 
EOF
}

#=============================================================#
_INFO()
{
# Mensagens padrão para serem exibidas durante a execução do programa.
# $1 = tipo de mensagem formatada a ser exibida (OBRIGATÓRIO).
# $2 = texto (OPICIONAL) a ser exibido.
case "$1" in
pkg_are_instaled) 
	msg "O pacote ${Green}[$2]${Reset} já está instalado. Para remover-lo use $Script_root ${Green}r${Reset}emove $2"
	;;
	
pkg_sucess) 
	msg "[$2] instalado com sucesso"
	;;

pkg_instalation_failed)
	red "Falha ao tentar instalar [$2]"
	;;

pkg_not_found) 
	red "Programa indisponível para seu sistema [$2]"
	;;

file_not_found) red "Arquivo não encontrado [$2]"
	;;

download_only) msg "Feito somente download [$2]"
	;;

esac
}

#=============================================================#

_list_applications()
{
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

echo " Gnome Shell Extensões pacote(gnome-extensions): "
case "$os_id" in
	debian|ubuntu) for a in "${array_gnome_shell_debian[@]}"; do echo "     $a"; done;;
	fedora) for a in "${array_gnome_shell_fedora[@]}"; do echo "     $a"; done;;
	arch) for a in "${array_gnome_shell_archlinux[@]}"; do echo "     $a"; done;;
	suse) for a in "${array_gnome_shell_suse[@]}"; do echo "     $a"; done;;
esac
echo "     topicons-plus"
}


function YESNO()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do program, esta função é para automatizar esta indagação.
	msg "Instalar o pacote $1 [${Yellow}s${Reset}/${Red}n${Reset}]?: "
	read -t 10 -n 1 sn
	#echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		msg "${Yellow}A${Reset}bortando"
		return 1
	fi
}

#=============================================================#

function _YESNO()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do program, esta função é para automatizar esta indagação.
	# $1 = Mensagem a ser exibida.
	
	echo -en "[>] $@ [${Yellow}s${Reset}/${Red}n${Reset}]?: "
	read -t 10 -n 1 sn
	echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		msg "${Yellow}A${Reset}bortando"
		return 1
	fi
}
