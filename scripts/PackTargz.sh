#!/usr/bin/env bash
#
# Este script instala pacotes já compilados, em qualquer distribuição linux
# Pois não usa gerenciador de pacotes nem repositorios, apenas 
# compilados do tipo tar.xz, tar.gz, tar,bz2 entre outros.
#
VERSAO='2019-11-16'
#
#

clear

# Cores
vermelho="\e[1;31m"
verde="\e[1;32m"
amarelo="\e[1;33m"
fecha="\e[m"

Verde="\e[1;32;5m"
Amarelo="\e[1;33;5m"
Vermelho="\e[1;31;5m"

function cor() { echo -e "\e[1;${1}m"; }
function msgs() { echo -e "${1}${2} ${fecha}"; }

# Programa não pode ser executado como root 
# a autênticação com sudo será feita quando precisar.
[[ $(id -u) == '0' ]] && { 
	echo "$(cor 31)==> $(cor)O usuário não pode ser o $(cor 31)[root]$(cor) saindo..." 
	exit 1 
}

#==========================================================#
#=================== Diretórios defaults ==================#
#==========================================================#
# User
dir_downloads="$HOME"/.cache/downloads
dir_bin="$HOME"/.local/bin
dir_icons="${HOME}/.icons"
dir_icons_share=~/'.local/share/icons'
dir_themes=~/.themes
dir_desktop="$HOME"/.local/share/applications
dir_temp="$HOME"/.local/tmp #

dir_default="$dir_downloads"
log_w="$dir_default/wget-log"
_tmp=$(mktemp)

mkdir -p "$dir_default"
cd "$dir_default"

# Root
dir_desktop_root="/usr/shar/applications"

lista_dirs=("$dir_downloads" "$dir_temp" "$dir_bin" "$dir_desktop" "$dir_icons" "$dir_themes")

# Criar diretórios em "$lista_dirs".
for dir in "${lista_dirs[@]}"; do mkdir -p "$dir"; done 

#==========================================================#
#========================= URLs defaults ==================#
#==========================================================#
url_papirus='https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh'
url_peazip="http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz"
url_pycharm='https://download.jetbrains.com/python/pycharm-community-2019.1.2.tar.gz'
url_pyenv='https://raw.githubusercontent.com/pyenv/pyenv-installer/master/bin/pyenv-installer'
url_sublime_text_default='https://download.sublimetext.com/sublime_text_3_build_3211_x64.tar.bz2'
html_sublime='https://www.sublimetext.com/3'
url_telegram="https://updates.tdesktop.com/tlinux/tsetup.1.8.2.tar.xz" # ATUALIZE-ME <<
url_tixati='https://download2.tixati.com/download/tixati-2.63-1.x86_64.manualinstall.tar.gz'
url_veracrypt_default='https://launchpad.net/veracrypt/trunk/1.23/+download/veracrypt-1.23-setup.tar.bz2'
url_vscode='https://go.microsoft.com/fwlink/?LinkID=620884'
url_vscode_default='https://az764295.vo.msecnd.net/stable/86405ea23e3937316009fc27c9361deee66ffbf5/code-stable-1573064450.tar.gz'
github='https://github.com'

# Lista de caracteres a deletar de paginas html para retornar links de download.
lista_deletar=(' ' '\"' '=' '<a' '>' 'class' 'download' 'Link' 'href')

#==========================================================#
#=================== Lista de programas ===================#
#==========================================================#
lista_acessorios=("veracrypt")
lista_desenvolvimento=("pycharm" "pyenv" "sublime-text" "vscode")
lista_internet=("torbrowser" 'telegram' "tixati")
lista_sistema=("peazip")
lista_preferencias=('papirus' 'sierra')

lista_apps=("$lista_desenvolvimento" "$lista_internet")

# Dependências
lista_dependencias=('wget' 'gpg' 'unzip' 'gzip' 'sudo' 'xterm' 'curl')

#================================================================#
# Lista de arquivos e diretórios dos programas quando instalados #
#================================================================#

# La-capitaine
lista_la_capitaine=("$dir_icons"/la-capitaine)

# Papirus
lista_papirus=("$dir_icons/Papirus-Dark" "$dir_icons/Papirus" 
"$dir_icons/Papirus-Light" "$dir_icons/ePapirus"
)

# Peazip
lista_peazip=(
"$dir_icons/peazip.png" # Png
"$dir_desktop/peazip.desktop" # .desktop
"$dir_bin/peazip-amd64" # Diretório de instalação.
"$dir_bin/peazip" # Link simbolico.
)

# Pycharm - lista de arquivos e diretórios depois de instalado.
lista_pycharm=( 
"$dir_icons/pycharm.png" # Icone png.
"$dir_desktop/pycharm.desktop" # Lançador .desktop.
"$dir_bin/pycharm-community" # Diretório de instalação.
)

# Pyenv
lista_pyenv=("$HOME/.pyenv")

# Sierra
lista_sierra=("$dir_themes"/Sierra-*)

# Sublime - lista de arquivos e diretórios depois de instalado.
lista_sublime=(
"/usr/share/icons/hicolor/256x256/apps/sublime-text.png" # Icone png.
"/usr/share/applications/sublime_text.desktop" # Lançador .desktop.
"/opt/sublime_text" # Diretório de instalação.
)

# Telegram
lista_telegram=(
"$dir_icons_share/telegram.png" # Icone .png
"$dir_bin/Telegram/" # Diretório.
"$dir_desktop/telegramdesktop.desktop" # .desktop
"$dir_bin/telegram" # Link.
)


# Tixati - 
lista_tixati=(
"$dir_icons/tixati.png" # Icone.
"$dir_desktop/tixati.desktop" # .desktop
"$dir_bin/tixati" # Binário.
)

# Tor Browser
lista_torbrowser=(
"$dir_desktop/start-tor-browser.desktop"
"$dir_bin/torbrowser-amd64"
"$dir_bin/torbrowser"
)

# Veracrypt
lista_veracrypt=(
"/usr/bin/veracrypt-uninstall.sh"
"/usr/share/applications/veracrypt.desktop"
"/usr/share/pixmaps/veracrypt.xpm"
"/usr/share/veracrypt"
"/usr/bin/veracrypt"
)

# Vscode
lista_vscode=(
"$dir_icons/code.png" # Icone png.
"$dir_desktop/code.desktop" # Arquivo .desktop
"$dir_bin/vscode-amd64" # Diretório de instalção.
"$dir_bin/vscode" # Atalho para execução.
)

#========== Inserir ~/.local/bin em PATH se necessário ====#
[[ $(egrep "^export PATH.*$HOME/.local/bin.*" "$HOME"/.bashrc) ]] || { 
    echo "export PATH=$HOME/.local/bin:$PATH" >> "$HOME"/.bashrc 
}


#==========================================================#
#========================= Funções ========================#
#==========================================================#
function usage()
{
clear
cat << EOF 
Use: $0 help|info|install <programa>|list|list <categoria>|remove <programa>|version

categorias:    Acessorios|Desenvolvimento|Internet

Exemplos:
        $0 install tixati telegram torbrowser veracrypt vscode sublime-text
        $0 remove sublime-text vscode peazip
        $0 list-internet

info:                   => Mostar informações e sai.
help:                   => Mostra esse menu e sai.
list:                   => Mostra aplicativos disponiveis para instalação.
list desenvolvimento    => Mostra aplicativos disponiveis para instalação na categoria desenvolvimento.
list internet           => Mostra aplicativos disponiveis para instalação na categoria internet.
remove                  => Remove pacotes.
EOF

}

#=========================================================#
function info()
{
clear
cat << EOF
Programas necessários: "${lista_dependencias[@]}"
EOF
}

function mensag()
{

# $1 = mensagem a exibir.
# $2 = Nome de um programa ou uma mensagem adicional a ser exibida.
local pacotes=$(basename $0)

local lista_mensag=("Programa já instalado, para remove-lo use: $pacotes $(cor 32)r$(cor)emove $2")

case "$1" in
	1) echo "$(cor 31)==> $(cor)${lista_mensag[0]}";;
	2) echo "$(cor 32)==> $(cor)Necessário fazer o download do pacote de instalação";;
	3) echo "$(cor 32)==> $(cor)Arquivo de instalação já em cache";;
	4) echo "$(cor 32)==> $(cor)Descompactando";;
	5) echo "$(cor 32)==> $(cor)Instalando";;
	6) echo "$(cor 32)==> $(cor)Instalação concluida";;
	7) echo "$(cor 31)==> $(cor)Instalação falhou";;
	8) echo "$(cor 31)==> $(cor)Download falhou";;

esac
}

#===============================================================#
# Funçaõ para listar todos os programas ou todos de uma categoria.
function lista()
{

if [[ ! -z "$2" ]]; then # Mostrar apenas uma ou mais categorioas.
    shift

    while [[ "$1" ]]; do
        case "$1" in
            acessorios) for i in "${lista_acessorios[@]}"; do echo -e "$i"; done;;
            desenvolvimento) for i in "${lista_desenvolvimento[@]}"; do echo -e "$i"; done;;
            internet) for i in "${lista_internet[@]}"; do echo -e "$i"; done;;
			sistema) for i in "${lista_sistema[@]}"; do echo -e "$i"; done;;
            preferencias) for i in "${lista_preferencias[@]}"; do echo -e "$i"; done;;
            *) usage; exit 1;;

        esac
        shift
    done 
     
fi

if [[ "$1" == 'list' ]] && [[ -z "$2" ]]; then  # Mostrar todas as categorias

    for c in "${lista_acessorios[@]}"; do echo -e "$c"; done   
    echo ' '
    for c in "${lista_desenvolvimento[@]}"; do echo -e "$c"; done
    echo ' '
    for c in "${lista_internet[@]}"; do echo -e "$c"; done
	echo ' '
	for i in "${lista_sistema[@]}"; do echo -e "$i"; done
	echo ' '
	for i in "${lista_preferencias[@]}"; do echo -e "$i"; done

fi
}

#=========================================================#
function check_apps()
{
# Pacotes necessários para o funcionamento correto deste script.

while [[ $1 ]]; do

	if [[ -x $(which "$1") ]]; then
		echo "$(cor 32)==> $(cor)[+] $1"
	else
		echo "$(cor 31)==> $(cor)[-] Pacote não encontrado: $1"
		read -p "==> Pressione enter : " enter	
		exit 1
	fi
	shift
	sleep 0.1
done
#clear
}

#=========================================================#
function install()
{

    echo -ne "${verde}==> ${fecha}Verificando conexão com a internet: "
    if [[ $(ping -c 1 8.8.8.8) ]]; then
	    echo -e "${verde}C${fecha}onectado"
    else
        echo ' '
	    msgs "${vermelho}" "==> Aviso${fecha}: Você está off-line" 
	    read -p "Pressione enter" enter 
    fi

    [[ -z "$1" ]] && { usage; exit 1; } # Argumetos/Parametros foram passados corretamente ?

    while [[ $1 ]]; do
        case "$1" in
        	la-capitaine) _la_capitaine;;
        	papirus) papirus;;
			peazip) peazip;;
            pycharm) pycharm;;
			sierra) _sierra;;
            sublime-text) sublime_text;;
			telegram) _telegram;;
            tixati) tixati;;
			torbrowser) torbrowser;;
            veracrypt) veracrypt;;
			vscode) vscode;;
			*) echo "$(cor 31)==> [-]$(cor) Pacote não encontrado: $1"; exit 1;;
            
        esac
        shift
		if [[ ! -z $1 ]]; then continue; fi
    done
}

#==========================================================#
#================= Remoção dos programas ==================#
#==========================================================#
# Está função remove os programas e invocada pela função "remve"
# Recebe como parametro os arquivos e pastas que devem ser deletados.
function remove_apps()
{
    while [[ "$1" ]]; do
        if [[ -f "$1" ]] || [[ -d "$1" ]] || [[ -x "$1" ]] || [[ -L "$1" ]]; then
            msgs "$verde" "==> ${fecha}Removendo: $1"
            # Precisa ser root para remove ??
            if [[ $(echo $1 | grep "$HOME") ]]; then rm -rf "$1"; else sudo rm -rf $1; fi
        else
            msgs "$vermelho" "==> ${fecha}Não encontrado: $1"
        fi
        shift
    done
}

#=========================================================#
function remove()
{
# $1 = Nome do pacote a ser removido

	# Passar todos os arquivos e diretórios a deletar para a função "remove_apps"
    while [[ $1 ]]; do
        case "$1" in
        	papirus) remove_apps "${lista_papirus[@]}";;
			peazip) remove_apps "${lista_peazip[@]}";;
            pycharm) remove_apps "${lista_pycharm[@]}";;
			pyenv) remove_apps "${lista_pyenv[@]}";;
			sierra) remove_apps "${lista_sierra[@]}";;
            sublime-text) remove_apps "${lista_sublime[@]}";; 
			telegram) remove_apps "${lista_telegram[@]}";;
            tixati) remove_apps "${lista_tixati[@]}";;
			torbrowser) remove_apps "${lista_torbrowser[@]}";;
            veracrypt) sudo "/usr/bin/veracrypt-uninstall.sh";;
			vscode) remove_apps "${lista_vscode[@]}";;
			*) msgs "$vermelho" "==> [-]${fecha} Pacote não encontrado: $1";;
        esac
        shift
		if [[ -z $1 ]]; then break; fi
    done
}

#==========================================================#
#================= Dowload dos programas ==================#
#==========================================================#

#=============================================#
# Informações/Progresso de download
#=============================================#
_progress(){
n=1
while [[ ! $(grep '99%' "$log_w") && ! $(grep 'Done' "$_tmp") ]]; do
	_porcentagem=$(awk '{print $7}' "$log_w" | tail -n 2 | sed -n 1p)
	_velocidade=$(awk '{print $8}' "$log_w" | tail -n 2 | sed -n 1p)
	case "$n" in
	1) echo -en "$(cor 31) [ | ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	2) echo -en "$(cor 31) [ / ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	3) echo -en "$(cor 31) [ - ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	4) echo -en "$(cor 31) [ \ ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	esac

	if [[ "$n" == "4" ]]; then
	    sleep 0.1
	    n=1
	else
	    sleep 0.1
	    let n=n+1
	fi
done
echo -en "$(cor 31) [ | ]$(cor 35) $_porcentagem $(cor 34)$_velocidade $(cor)"
echo -e "Done" > "$_tmp"
}



#==================================#
# wget
#==================================#
function _Wget()
{
# $1 = url
# $2 = path_arq
local url="$1"
local path_arq="$2"

[[ $(pidof wget) ]] && kill -9 $(pidof wget)
[[ -f "$log_w" ]] && rm "$log_w"

echo -e "==> Baixando: [$url]"
if [[ -z $2 ]]; then 
	#wget -c "$url" 
	while [[ ! $(grep 'Done' "$_tmp") ]] && wget -c -b "$url" | sed '/Continuando\|escrita/d'; do
		_progress;
	done

elif [[ -d $(dirname "$2") ]]; then
	echo -e "==> Destino: [$path_arq]"
	#wget -c "$url" -O "$path_arq"
	while [[ ! $(grep 'Done' "$_tmp") ]] && wget -c -b "$url" -O "$path_arq" | sed '/Continuando\|escrita/d'; do
		_progress;
	done

fi
}


#==================================#
# Curl
#==================================#
function _Curl()
{
# $1 = url
# $2 = path_arq
local url="$1"
local path_arq="$2"

echo -e "==> Baixando: [$url]"
if [[ -z $2 ]]; then 
	curl -# -C - -O "$url" 

elif [[ -d $(dirname "$2") ]]; then
	echo -e "==> Destino: [$path_arq]"
	curl -# -C - -o "$path_arq" -O "$url"

fi
}


#==================================#
# _dow url path_arq
#==================================#
function _dow()
{
	[[ -f "$2" ]] && { 
		echo "==> O arquivo já existe em [$2]"
		echo "==> 'Pulando' o download" 
		return 0 
	}

if [[ "$3" == '--wget' ]]; then
	echo "[wget]"
	_Wget "$@"

elif [[ "$3" == '--curl' ]]; then
	echo "[curl]"
	_Curl "$@"

else
	echo "==> Use: _dow <url> <file> --wget|--curl"
	return 1

fi

# Exit
if [[ $? == '0' ]]; then
	return 0

else
	echo "==> Função [_dow] retornou erro"
	return 1
fi
}


#==========================================================#
#================= Clonar programas =======================#
#==========================================================#
function _git_clone()
{
# $1 = Diretório onde deve ser clonado.
# $2 = Repositório para clonar.

[[ ! -d "$1" ]] && { echo "$(cor 31)==> $(cor)Erro: informe um diretório de destino."; exit 1; }
[[ ! -w "$1" ]] && { echo "$(cor 31)==> $(cor)Erro: Você não tem permissão de escrita em $1"; exit 1; }
[[ -z $2 ]] && { echo "$(cor 31)==> $(cor)Erro: informe um repositório para ser clonado."; exit 1; }


cd "$1"
if git clone "$2"; then
	echo "$(cor 32)==> $(cor)Sucesso: git clone $2"
else
	echo "$(cor 31)==> $(cor)Falha: git clone $2"
	exit 1
fi
sleep 0.1
}


#==========================================================#
#================= Descompressão dos programas ============#
#==========================================================#
function _unpack()
{
# $1 = arquivo a descomprimir.
# $2 = destino da descompressão.
local arq="$1"
local dir_arq="$2"

rm -rf "${dir_arq}"/* 1> /dev/null 2>&1 
mkdir -p "$dir_arq"

	echo -e "$(cor 32)==> $(cor)Descompactando ["$arq"]"

if [[ $(echo "$arq" | grep 'tar.gz') ]]; then
	tar -zxvf "$arq" -C "$dir_arq" 1> /dev/null	

elif [[ $(echo "$arq" | grep 'tar.bz2') ]]; then
	tar -jxvf "$arq" -C "$dir_arq" 1> /dev/null

elif [[ $(echo "$arq" | grep 'tar.xz') ]]; then
	tar -Jxf "$arq" -C "$dir_arq" 1> /dev/null

else
	echo "$(cor 31)==> $(cor)Arquivo inválido: $arq"

fi

}


#==========================================================#
#================= Instalação dos programas ===============#
#==========================================================#


#==================================================#
#====================== La capitane ===============#
function _la_capitaine()
{
github_la_capitaine="$github/keeferrourke/la-capitaine-icon-theme.git"

[[ -d "$dir_downloads"/la-capitaine-icon-theme ]] && { 
	cd "$dir_downloads" && rm -rf la-capitaine-icon-theme; 
}

_git_clone "$dir_downloads" "$github_la_capitaine"
cd "$dir_downloads"/la-capitaine-icon-theme && { chmod +x configure; ./configure; }
}

#==========================================================#
#========================= Papirus [icones] ===============#
function papirus()
{

if [[ -d ~/.icons/Papirus-Dark ]]; then mensag 1 'papirus'; exit 0; fi
echo "$(cor 32)==> $(cor)Papirus [icones]"

pacote_papirus="$dir_downloads"/papirus.run

# Precisa baixar o pacote ?
if [[ -f "$pacote_papirus" ]]; then 
	mensag 3 
else 
	mensag 2 
	echo "$(cor 32)==> $(cor)Baixando: $url_papirus"
	_dow "$url_papirus" "$pacote_papirus" --curl

fi

mensag 5 # Instalando
chmod +x "$pacote_papirus"
"$pacote_papirus"

}

#==================================================#
#=========================== Peazip ===============#
function peazip()
{
[[ -x $(which peazip) ]] && { mensag 1 'peazip'; return 0; }

echo "$(cor 32)==> $(cor)Peazip"

pacote_nome='peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
pacote_peazip="${dir_downloads}/$pacote_nome"

# Precisa baixar o pacote ?
if [[ -f "$pacote_peazip" ]]; then 
	mensag 3 
else 
	mensag 2 
	_dow "$url_peazip" "$pacote_peazip" --wget

fi

_unpack "$pacote_peazip" "$dir_temp"

mensag 5 # Instalando
mv "$dir_temp"/peazip*/ "${lista_peazip[2]}"; chmod -R +x "${lista_peazip[2]}"

# Arquivo .desktop
echo '[Desktop Entry]' > "${lista_peazip[1]}"
{
	echo "Version=1.0"
	echo "Encoding=UTF-8"
	echo "Name=PeaZip"
	echo "GenericName=Archiving Tool"
	echo "Exec=${lista_peazip[2]}/peazip"
	echo "Icon=${lista_peazip[0]}"
	echo "Type=Application"
	echo "Terminal=false"
	echo "X-KDE-HasTempFileOption=true"
	echo "Categories=GTK;KDE;Utility;System;Archiving;"
	echo "Name[en_US]=PeaZip"
} >> "${lista_peazip[1]}"

cp -u "${lista_peazip[2]}"/FreeDesktop_integration/peazip.png "${lista_peazip[0]}"
ln -sf "${lista_peazip[2]}"/peazip "$dir_bin"/peazip
[[ -d ~/Desktop/ ]] && cp -u "${lista_peazip[1]}" ~/Desktop/ # copiar atalho -> ~/Desktop
[[ -d ~/'Área de trabalho'/ ]] && cp -u "${lista_peazip[1]}" ~/'Área de trabalho'/ # -> ~/'Área de trabalho'

[[ -f ~/Desktop/peazip.desktop ]] && chmod +x ~/Desktop/peazip.desktop
[[ -f ~/'Área de trabalho'/peazip.desktop ]] && chmod +x ~/'Área de trabalho'/peazip.desktop

if [[ -x $(which peazip) ]]; then 
	mensag 6
	cd "${lista_peazip[2]}" && ./peazip

else 
	mensag 7; exit 1 
fi

}

#==================================================#
#========================== Pycharm ===============#
function pycharm()
{
[[ -x $(which pycharm) ]] && { mensag 1 'pycharm'; return 0; }

echo "$(cor 32)==> $(cor)Pycharm"

local pacote_pycharm="${dir_downloads}"/pycharm-community.tar.gz

if [[ -f "$pacote_pycharm" ]]; then 
	mensag 3
else
	mensag 2
    _dow "$url_pycharm" "$pacote_pycharm" --wget
fi

_unpack "$pacote_pycharm" "$dir_temp"

echo "$(cor 32)==> $(cor)Instalando"
mv "$dir_temp"/pycharm-community*/ "$dir_bin"/pycharm-community
chmod -R +x "$dir_bin"/pycharm-community
cp -u "$dir_bin"/pycharm-community/bin/pycharm.png "$HOME"/.icons/pycharm.png
ln -sf "${dir_bin}/pycharm-community/bin/pycharm.sh" "${dir_bin}/pycharm" 

# Arquivo.desktop
    touch "$dir_desktop/pycharm.desktop"
    echo "[Desktop Entry]" > "$dir_desktop"/pycharm.desktop
    {
        echo "Name=Pycharm Community"
        echo "Version=1.0"
        echo "Icon=$dir_icons/pycharm.png"
        echo "Exec=$dir_bin/pycharm"
        echo "Terminal=false"
        echo "Categories=Development;IDE;"
        echo "Type=Application"
        

    } >> "$dir_desktop"/pycharm.desktop

if [[ $? == 0 ]]; then
	cp -u "${lista_pycharm[1]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${lista_pycharm[1]}" ~/'Área de trabalho'/ 2> /dev/null
    echo "$(cor 32)==> $(cor)Instalação concluida"
else
    echo "$(cor 32)==> $(cor)Instalação falhou"; exit 1
fi

}

#=========================================================#
#============================ Pyenv ======================#
function pyenv()
{
[[ -x $(which pyenv) ]] && { mensag 1 'pyenv'; return 0; }
echo "$(cor 32)==> $(cor)pyenv"

mensag 5 # Instalando
curl -S -L "$url_pyenv" | bash -s -- "$@"

#-------------------- Incluir diretório ~/.pyenv em PATH -----------------------#
[[ $(grep "^export PATH.*/.pyenv" ~/.bashrc) ]] || { echo "export PATH=$HOME/.pyenv/bin:$PATH" >> ~/.bashrc; }

if [[ $? == 0 ]]; then mensag 6; else mensag 7; exit 1; fi
}


#=========================================================#
#============================ Tema Sierra ================#
function _sierra()
{
github_sierra="$github/vinceliuice/Sierra-gtk-theme"

cd "$dir_downloads"
[[ -d "$dir_downloads"/Sierra-gtk-theme ]] && { rm -rf "$dir_downloads"/Sierra-gtk-theme; }

_git_clone "$dir_downloads" "$github_sierra"

echo "$(cor 32)==> $(cor)Instalando"
chmod +x "$dir_downloads"/Sierra-gtk-theme/install.sh
cd "$dir_downloads"/Sierra-gtk-theme/ && ./install.sh 
}


#=========================================================#
#============================ Sublime-text ===============#
function sublime_text()
{
[[ -d '/opt/sublime_text' ]] && { mensag 1 'sublime-text'; return 0; }
echo "$(cor 32)==> $(cor)sublime-text"

new_url_sublime=$(curl -s "$html_sublime_text" -o- | grep -m 1 'http.*sublime.*x64.tar.bz2' | sed 's/\">64.*//g;s/.*=\"//g')
if echo "$new_url_sublime" | grep -q '^https.*sublimetext.*x64.tar.bz2'; then 
	url_sublime_text="$new_url_sublime"
else
	url_sublime_text="$url_sublime_text_default" 
fi

arq_sublime=$(echo "$url_sublime_text" | sed 's|.*\/||g')
local pacote_sublime="${dir_downloads}/$arq_sublime"

if [[ -f "$pacote_sublime" ]]; then 
	mensag 3 
else 
	mensag 2; _dow "$url_sublime_text" "$pacote_sublime" --wget 
fi

if [[ $? != 0 ]]; then mensag 8; exit 1; fi

_unpack "$pacote_sublime" "$dir_temp"

mensag 5
sudo cp -u "$dir_temp"/sublime_text_3/sublime_text.desktop '/usr/share/applications/sublime_text.desktop' 
sudo cp -u "$dir_temp"/sublime_text_3/Icon/256x256/sublime-text.png '/usr/share/icons/hicolor/256x256/apps/sublime-text.png'
sudo gtk-update-icon-cache
sudo mv "$dir_temp"/sublime_text_3 '/opt/sublime_text'

if [[ $? == 0 ]]; then 
	cp -u "${lista_sublime[1]}" ~/Desktop/ 2> /dev/null
	cp -u "${lista_sublime[1]}" ~/'Área de trabalho'/ 2> /dev/null
	mensag 6 
	
else 
	mensag 7; exit 1; 

fi
}

#=========================================================#
# Telegram
#=========================================================#
function _telegram() 
{
# https://telegram.org/dl/desktop/linux
# https://desktop.telegram.org/
# gconftool-2 >> Depedência.

pacote_telegram="$dir_downloads/telegram-amd64.tar.xz"

[[ -x $(which telegram) ]] && { mensag 1 'telegram'; return 0; }

	# Precisa baixar o pacote ?
	if [[ -f "$pacote_telegram" ]]; then 
		mensag 3
    else 
		mensag 2; _dow "$url_telegram" "$pacote_telegram" --wget
	fi

	_unpack "$dir_downloads/telegram-amd64.tar.xz" "$dir_temp"

	echo "$(cor 32)==> $(cor)Instalando"
	mv "$dir_temp/Telegram" "$dir_bin/"
	ln -sf "$dir_bin/Telegram/Telegram" "$dir_bin/telegram"
	echo -e "$(cor 33)==> $(cor)Aguarde..."
	telegram

} 

#=========================================================#
#============================ Tixati =====================#
tixati() 
{

[[ -x $(which tixati) ]] && { mensag 1 "tixati"; return 0; }

echo "$(cor 32)==> $(cor)Tixati"
echo "$(cor 32)==> $(cor)Obtendo url de download aguarde..."
tixati_html='https://www.tixati.com/download/linux.html' # Pagina de download do programa.
url_tixati=$(wget -qE "$tixati_html" -O- | egrep -m 1 "https.*64.*tar.gz" | sed "s/gz\".*/gz/g;s/.*=\"//g") # url de download.
pacote_nome=$(echo "$url_tixati" | sed 's/.*\///g') # Nome do arquivo.
pacote_tixati="${dir_downloads}/${pacote_nome}" # Nome e diretório completo.

	# Precisa baixar o pacote ?
	if [[ -f "$pacote_tixati" ]]; then 
		mensag 3
	else 
		mensag 2; _dow "$url_tixati" "$pacote_tixati" --wget
	fi
 
_unpack "$pacote_tixati" "$dir_temp"

mensag 5 # Instalando
mv "$dir_temp"/tixati-*/ "$dir_temp"/tixati
chmod -R a+x "$dir_temp"/tixati
cp -u "$dir_temp"/tixati/tixati.png "${lista_tixati[0]}" # copiar .PNG em: ~/.icons 
cp -u "$dir_temp"/tixati/tixati "${lista_tixati[2]}" # mover binário para ~/.local/bin/tixati.

# arquivo .desktop
echo '[Desktop Entry]' > "${lista_tixati[1]}"
{
	echo "Version=1.0"
	echo "Encoding=UTF-8"
	echo "Name=Tixati"
	echo "GenericName=BitTorrent Client"
	echo "Comment=Share files over bittorrent"
	echo "Exec=${lista_tixati[2]}"
	echo "Icon=${lista_tixati[0]}"
	echo "Terminal=false"
	echo "Type=Application"
	echo "Categories=Internet;Network;FileTransfer;P2P;GTK;"
} >> "${lista_tixati[1]}"

cp -u "${lista_tixati[1]}" ~/Desktop/ 2> /dev/null # copiar atalho -> ~/Desktop
cp -u "${lista_tixati[1]}" ~/'Área de trabalho'/ 2> /dev/null # copiar atalho -> ~/'Área de trabalho'

[[ -f ~/Desktop/tixati.desktop ]] && chmod +x ~/Desktop/tixati.desktop
[[ -f ~/'Área de trabalho'/tixati.desktop ]] && chmod +x ~/'Área de trabalho'/tixati.desktop
[[ -x "${lista_tixati[1]}" ]] && chmod +x "${lista_tixati[1]}"

	if [[ -x "${lista_tixati[2]}" ]]; then 
		mensag 6 
		"${lista_tixati[2]}"

	else 
		mensag 7; exit 1 
	fi

}


#=========================================================#
#======================= Tor Browser =====================#
torbrowser() 
{
[[ -x $(which torbrowser) ]] && { mensag 1 'torbrowser'; return 0; }

echo "$(cor 32)==> $(cor)Tor Browser"

# https://dist.torproject.org/torbrowser/8.5.5/tor-browser-linux64-8.5.5_en-US.tar.xz

torbrowser_dominio='https://dist.torproject.org/torbrowser'
torbrowser_html='https://www.torproject.org/download/' # Pagina de download do programa.

torbrowser_nome=$(wget -q "$torbrowser_html" -O- | grep -m 1 'torbrowser.*linux.*64.*tar' | sed "s/.*\///g;s/\".*//g")

torbrowser_versao="${torbrowser_nome#tor-browser-linux64-}" # Cortar do começo 'tor-browser-linux64-'
torbrowser_versao="${torbrowser_versao%_en-US.tar.xz}" # Cortar do fim '_en-US.tar.xz'
url_torbrowser="${torbrowser_dominio}/${torbrowser_versao}/${torbrowser_nome}"

pacote_torbrowser="${dir_downloads}/${torbrowser_nome}"

	# Precisa baixar o pacote ?
	if [[ -f "$pacote_torbrowser" ]]; then 
		mensag 3 
	else 
		mensag 2 
		echo "$(cor 32)==> $(cor)Baixando: ${url_torbrowser}"
		_dow "$url_torbrowser" "$pacote_torbrowser" --wget 

	fi

_unpack "$pacote_torbrowser" "$dir_temp"

mensag 5 # Instalando
mv "$dir_temp"/tor-browser*/ "${lista_torbrowser[1]}" # Mover para o diretório de instalação.
chmod -R +x "${lista_torbrowser[1]}" # Permissão de execução.
cd "${lista_torbrowser[1]}" && ./start-tor-browser.desktop --register-app # Gerar arquivo .desktop

# Gerar script para chamada via linha de comando.
touch "$dir_bin"/torbrowser
echo '#!/usr/bin/env bash' > "$dir_bin"/torbrowser
echo -e "\ncd ${lista_torbrowser[1]} && ./start-tor-browser.desktop" >> "$dir_bin"/torbrowser

chmod +x "$dir_bin"/torbrowser

#sed -i "s|^Exec=.*|Exec=cd ${lista_torbrowser[1]} \&\& \.\/start-tor-browser.desktop|g" "${lista_torbrowser[0]}" 

if [[ $? == 0 ]]; then 
    mensag 6 
	cp -u "$dir_desktop"/start-tor-browser.desktop ~/Desktop/ 2> /dev/null
	cp -u "$dir_desktop"/start-tor-browser.desktop ~/'Área de trabalho'/ 2> /dev/null
    "$dir_bin"/torbrowser # Abrir torbrowser.
else 
    mensag 7 
    exit 1 
fi

}

#=========================================================#
#========================= Veracrypt =====================#
veracrypt() 
{
[[ -x $(which veracrypt) ]] && { mensag 1 'veracrypt'; return 0; }

echo "$(cor 32)==> $(cor)veracrypt"

local veracrypt_html='https://www.veracrypt.fr/en/Downloads.html' # Pagina de download do programa.
url_veracrypt=$(wget -qE "$veracrypt_html" -O- | egrep -m 1 "http.*tar.bz2" | sed 's/z2\".*/z2/g;s/.*\"//g' | sed 's/&#43\;/+/g')

local pacote_nome=$(echo $url_veracrypt | sed 's/.*\///g') # Nome do arquivo.
local pacote_veracrypt="${dir_downloads}"/"$pacote_nome" # Nome e diretório e arquivo completo.

	# Precisa baixar o pacote ?
	if [[ -f "$pacote_veracrypt" ]]; then 
		mensag 3 
	else 
        # wget -c url -O <path>
		mensag 2; # wget -c "$url_veracrypt" -O "$pacote_veracrypt"
        _dow "$url_veracrypt" "$pacote_veracrypt" --wget
		[[ $? != 0 ]] && { mensag 8; rm -rf "$pacote_veracrypt"; exit 1; }
	fi


_unpack "$pacote_veracrypt" "$dir_temp"

mensag 5 # Instalando
chmod -R +x "$dir_temp"
mv "$dir_temp"/veracrypt-*-setup-gui-x64 "$dir_temp"/veracrypt-setup-x64
sudo "$dir_temp"/veracrypt-setup-x64
sudo rm -rf "$dir_temp"

	if [[ $? == 0 ]]; then mensag 6; else mensag 7; exit 1; fi
}


#=========================================================#
#========================= Vscode =====================#
vscode() 
{
[[ -x $(which vscode) ]] && { mensag 1 'vscode'; return 0; }

echo "$(cor 32)==> $(cor)vscode"

pacote_nome="vscode.tar.gz" # Nome do arquivo.
pacote_vscode="${dir_downloads}/$pacote_nome" # Nome e diretório completo.

# Precisa baixar o pacote ?
if [[ -f "$pacote_vscode" ]]; then 
	mensag 3
else
	mensag 2
	_dow "$url_vscode" "$pacote_vscode"  
fi


if [[ $? != 0 ]]; then mensag 8; exit 1; fi

_unpack "$pacote_vscode" "$dir_temp"

mensag 5 # Instalando
mv "$dir_temp"/VSCode-*/ "${lista_vscode[2]}"
chmod -R +x "${lista_vscode[2]}"
cp -u "${lista_vscode[2]}"/resources/app/resources/linux/code.png "${lista_vscode[0]}"

# Criar atalho para execução na linha de comando.
touch "$dir_bin"/vscode
echo "#!/usr/bin/env bash" > "$dir_bin"/vscode
echo -e "\ncd "${lista_vscode[2]}"/bin/ && ./code" >> "$dir_bin"/vscode
chmod +x "$dir_bin"/vscode

# Criar entrada no menu do sistema.
echo "[Desktop Entry]" > "${lista_vscode[1]}" 
	{
		echo "Name=Code"
		echo "Version=1.0"
		echo "Icon=code"
		echo "Exec=$dir_bin/vscode-amd64/bin/code"
		echo "Terminal=false"
		echo "Categories=Development;IDE;" 
		echo "Type=Application"
	} >> "${lista_vscode[1]}" 

if [[ $? == 0 ]]; then 
	mensag 6
	cp -u "${lista_vscode[1]}" ~/'Área de trabalho'/ 2> /dev/null 
	cp -u "${lista_vscode[1]}" ~/Desktop/ 2> /dev/null 
	cd "${lista_vscode[2]}"/bin/ && ./code 
else 
	mensag 7; exit 1 
fi
}

#==========================================================#
#=================== Execução =============================#
#==========================================================#
check_apps "${lista_dependencias[@]}"

#==========================================================#
#=================== Argumentos ===========================#
#==========================================================#

if [[ ! -z $1 ]]; then

	while [[ "$1" ]]; do
    	case "$1" in
    	    info) info; exit 0;;
    	    install) shift; install "$@"; exit "$?";;
    	    list) lista "$@"; exit 0;;
    	    help) usage; exit 0;;
    	    remove) shift; remove "$@"; exit 0;;
    	    *) usage; exit 1;;
    	esac
    	shift
		if [[ -z $1 ]]; then break; exit; fi
	done

elif [[ -z $1 ]]; then 
	usage; exit 1
fi






