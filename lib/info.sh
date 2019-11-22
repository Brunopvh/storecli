#!/usr/bin/env bash
#
#
#

source "$Lib_array"

function _c() { 
if [[ -z $2 ]]; then
	echo -e "\033[1;$1m"
	
elif [[ $2 ]]; then
	echo -e "\033[$2;$1m"

fi
}

#============================================================#
# Usage
#============================================================#
function usage() {

clear

cat <<EOF

   Use: $(basename "$appsutils") --configure|--upgrade|--help|--downloadonly|--version
                                 install <pacote>|remove <pacote>

   $(basename "$appsutils"): V$VERSION

Comandos:
   --configure            Instala programas necessários (dependências).
   --help                 Mostra esse menu e sai.
   --upgrade              Instala a ultima versão deste script em: ~/.local/bin
   --quebrado             Remove pacotes quebrados.                 
   --version              Mostra versão e sai.
   --list                 Lista aplicativos disponíveis para instalação.
   --logo                 Exibe logo e sai.
   
   install <pacote>       Instala um ou mais pacote(s) 
                            Ex: ./$(basename "$appsutils") vlc google-chrome icones-papirus
                                  
   remove <pacote>        Remove um ou mais pacotes.
   
Opições:
   -d|--downloadonly      Somente baixa o(s) pacote(s) se disponível.
                          se não for possivel o pacote será instalado.
                          Ex: $(basename $appsutils) -d <pacote>
                          
EOF
}

#============================================================#
#--------------------------- < Logo > -----------------------#
#============================================================#

function _logo()
{
echo "$(_c 34 1)**********************************************************$(_c)"
echo "$(_c 31)  Autor: Bruno Da Silva Chaves"
echo "$(_c 31)  Versão: $VERSION"
echo "$(_c 31)  Github: None"
echo "$(_c 34)  StoreCli $(_c 32 0)sua loja de aplicativos via linha de comando."
echo "$(_c 34 1)**********************************************************$(_c)"
echo -n "$(_c)"
}


#============================================================#
# List applications
#============================================================#
function _list_applications()
{
echo "Acessórios: "
for a in "${array_acessorios[@]}"; do echo "     $a"; done
echo ' '	
	
echo "Desenvolvimento: "
for a in "${array_dev[@]}"; do echo "     $a"; done
echo ' '

echo "Internet: "
for a in "${array_internet[@]}"; do echo "     $a"; done
echo ' '

echo "Midia: "
for a in "${array_midia[@]}"; do echo "     $a"; done
echo ' '

echo "Sistema: "
for a in "${array_sistema[@]}"; do echo "     $a"; done
	
}










