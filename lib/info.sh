#!/usr/bin/env bash
#
#
#

github_storecli='https://github.com/Brunopvh/storecli.git'

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

   Use: $(basename $0) --configure|--upgrade|--help|--downloadonly|--version
                                 install <pacote>|remove <pacote>

   $(basename $0): V$VERSION

Comandos:
   --configure            Instala programas necessários (dependências).
   --help                 Mostra esse menu e sai.
   --list                 Lista aplicativos disponíveis para instalação.
   --logo                 Exibe logo e sai.
   --quebrado             Remove pacotes quebrados.
   --upgrade              Instala a ultima versão deste script em: ~/.local/bin            
   --version              Mostra versão e sai. 
   
   install <pacote>       Instala um ou mais pacote(s) 
                            Ex: $(basename $0) vlc google-chrome icones-papirus
                                  
   remove <pacote>        Remove um ou mais pacotes se possível.
                            Ex: $(basename $0) remove torbrowser vscode
   
Opções:
   -d|--downloadonly      Somente baixa o(s) pacote(s) se disponível.
                          se não for possivel o pacote será instalado.
                          Ex: $(basename $0) -d <pacote>
                          
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
echo "$(_c 31)  Github: $github_storecli"
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

echo "Escritorio: "
for a in "${array_escritorio[@]}"; do echo "     $a"; done
echo ' '

echo "Internet: "
for a in "${array_internet[@]}"; do echo "     $a"; done
echo ' '

echo "Midia: "
for a in "${array_midia[@]}"; do echo "     $a"; done
echo ' '

echo "Sistema: "
for a in "${array_sistema[@]}"; do echo "     $a"; done
echo ' '

echo "Preferências: "
for a in "${array_preferencias[@]}"; do echo "     $a"; done

}










