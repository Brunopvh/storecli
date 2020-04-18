#!/usr/bin/env bash
#
#
#
#
#
VERSION='2020-04-05 rev9'
#

#clear

#=============================================================#
# Diretórios
#=============================================================#
export readonly Dir_Store_Gui=$(dirname $(readlink -f "$0"))       # path deste arquivo no disco.
export Dir_Store_Lib="$Dir_Store_Gui/lib"
export dir_temp="/tmp/$USER/temp_dir"; mkdir -p "$dir_temp"
export Dir_Bin="$HOME/.local/bin"; mkdir -p "$Dir_Bin"

#=============================================================#
# Libs
#=============================================================#
export Lib_Colors="$Dir_Store_Lib/Colors.sh"

#=============================================================#
# Scripts
#=============================================================#
#Script_Storecli="$Dir_Bin/storecli-amd64/storecli.sh"
Script_Storecli="$Dir_Store_Gui/storecli.sh"
Script_Install_Storecli="$dir_temp/setup_storecli.sh"
Script_Setup_Gui="$Dir_Store_Gui/setup.sh"

#=============================================================#
# Importar
#=============================================================#
source "$Lib_Colors"

#=============================================================#
# Urls
#=============================================================#
github='https://github.com'  
raw='https://raw.github.com'
url_setup_gui="$raw/Brunopvh/apps-buster/master/scripts/setup_gui.sh"

space_line='--------------------------------------'


#=============================================================#
# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	red "Usuário não pode ser o [root] execute novamente sem o [sudo]"
	exit 1
fi

# Válidar se o Kernel e Linux.
if [[ $(uname -s) != 'Linux' ]]; then
	red "Seu sistema não é Linux"
	exit 1
fi

# Necessário ter a ferramenta "curl" intalada.
if [[ ! -x $(which curl 2> /dev/null) ]]; then
	red "Instale a ferramenta [curl] para prosseguir"
	exit 1
fi

#=============================================================#
# Verificar conexão com a internet.
yellow "Aguardando conexão"
if ping -c 2 8.8.8.8 1> /dev/null; then
	yellow "Conectado"
else
	red "Falha - AVISO: você está OFF-LINE"
	read -p "Pressione enter: " enter
fi

#=============================================================#
# Instalar o script storecli se ele não estiver disponível.
if [[ ! -x "$Script_Storecli" ]]; then
	msg "Instalando script [storecli]"
	sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/install.sh)" || {
		red "Falha ao tentar instalar [storecli]"
		exit 1
	}
fi

#=============================================================#

# Verificar se e necessário configurar o script storecli.
Config_File="$HOME/.config/storecli.conf"
if [[ ! -f "$Config_File" ]]; then echo ' ' >> "$Config_File"; fi

# Se não encontrar a linha 'requeriments false' no arquivo "Config_File"
# então executar storecli --configure.
grep -q 'requeriments false' "$Config_File" || {
	storecli --configure
}

# É necessário incluir o diretório de binários do usuário na 
# variável PATH se ainda não estiver incluso.
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
	export PATH="$HOME/.local/bin:$PATH"
fi

#=============================================================#

_zenity_dialog_list()
{
	# $1 = Lista com opções a serem exibidas na caixa de dialogo
	# Os parametros já são fixos e está com formatação padrão o que
	# será alterado ao longo do programa é a lista de exibição ou seja
	# o primerio argumento dessa função ("$1") que será passado como 
	# ultimo parâmetro para o zenity ("$@").
	if [[ -z $1 ]]; then
		red "Parametros incorretos detectado na função [_zenity_dialog_list]"
		return 1
	fi

	zenity --list --title='Selecione_uma_opcao' --text='Menu' \
			--width='400' --height='450' --radiolist --column 'Marcar' \
			--column 'Categorias' $@ 	
}



# Listas com as opções para serem selecionadas nas caixas de dialogo com o zenity.


# Lista de opções a ser exibida no menu principal
list_main_menu=(
	"TRUE Sair"
	"FALSE Acessorios"
	"FALSE Desenvolvimento"
	"FALSE Escritorio"
	"FALSE Internet"
	"FALSE Midia"
	"FALSE Sistema"
	"FALSE Preferencias"
)
# "FALSE Wine"

# Lista de opções para categoria acessórios.
list_menu_acessory=(
	'TRUE Voltar'
	'FALSE gnome-disk'
    'FALSE veracrypt'
    'FALSE woeusb'
)

# Lista de opções para categoria desenvolvimento.
list_menu_development=(
	'TRUE Voltar'
	'FALSE android-studio'
	'FALSE codeblocks'
    'FALSE pycharm'
    'FALSE sublime-text'
    'FALSE vim'
    'FALSE vscode'
)

# Lista de opções para categoria escritório.
list_menu_office=(
	'TRUE Voltar'
	'FALSE atril'
    'FALSE fontes-ms'
    'FALSE libreoffice'
    'FALSE libreoffice-appimage'
)

# Lista de opções para categoria internet.
list_menu_internet=(
	'TRUE Voltar'
	'FALSE chromium'
	'FALSE google-chrome'
	'FALSE megasync'
	'FALSE opera-stable'
	'FALSE proxychains'
	'FALSE qbittorrent'
	'FALSE teamviewer'
	'FALSE telegram'
	'FALSE tixati'
	'FALSE torbrowser'
	'FALSE uget'
	'FALSE youtube-dl'
	'FALSE youtube-dl-gui'
)

# Lista de opções para categoria midia.
list_menu_midia=(
	'TRUE Voltar'
	'FALSE celluloid'
	'FALSE codecs'
    'FALSE gnome-mpv'
    'FALSE parole'
    'FALSE smplayer'
    'FALSE vlc'
)

# Lista de opções para categoria sistema.
list_menu_system=(
	'TRUE Voltar'
	'FALSE bluetooth'
    'FALSE compactadores'
    'FALSE firmware-atheros'
    'FALSE firmware-linux-nonfree'
    'FALSE firmware-ralink'
    'FALSE firmware-realtek'
    'FALSE peazip'
    'FALSE virtualbox'
)

# Lista de opções para categoria preferências.
list_menu_preferences=(
	'TRUE Voltar'
	'FALSE papirus'
    'FALSE ohmybash'
    'FALSE ohmyzsh'
    'FALSE sierra'
)

#=============================================================#
# Função para instalação dos pacotes vis 'storecli'.
storecli_args()
{
	"$Script_Storecli" install -y "$@"
}

#=============================================================#
# Funções das categorias.

menu_acessory(){
	echo -e "$space_line"
	echo -e "Menu Acessórios"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_acessory[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$option" in
			Voltar) msg "Voltando..."; break;;
			'gnome-disk') storecli_args gnome-disk;;
			veracrypt) storecli_args veracrypt;;
			woeusb) storecli_args woeusb;;
		esac
		echo -e "Menu Acessórios"
	done
}

menu_dev(){
	echo -e "$space_line"
	echo -e "Menu Desenvolvimento"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_development[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$option" in
			Voltar) msg "Voltando..."; break;;
			'android-studio') storecli_args android-studio;;
			codeblocks) storecli_args codeblocks;;
			pycharm) storecli_args pycharm;;
			sublime-text) storecli_args sublime-text;;
			vim) storecli_args vim;;
			vscode) storecli_args vscode;;
		esac
		echo -e "Menu Desenvolvimento"
	done
}

menu_office(){
	echo -e "$space_line"
	echo -e "Menu Escritório"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_office[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$option" in
			Voltar) msg "Voltando..."; break;;
			atril) storecli_args atril;;
			fontes-ms) storecli_args fontes-ms;;
			libreoffice) storecli_args libreoffice;;
			'libreoffice-appimage') storecli_args libreoffice-appimage;;
		esac
		echo -e "Menu Escritório"
	done
}


menu_internet(){
	echo -e "$space_line"
	echo -e "Menu Internet"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_internet[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$option" in
			Voltar) msg "Voltando..."; break;;
			chromium) storecli_args chromium;;
			google-chrome) storecli_args google-chrome;;
			megasync) storecli_args megasync;;
			'opera-stable') storecli_args opera-stable;;
			proxychains) storecli_args proxychains;;
			qbittorrent) storecli_args qbittorrent;;
			teamviewer) storecli_args teamviewer;;
			telegram) storecli_args telegram;;
			tixati) storecli_args tixati;;
			torbrowser) storecli_args torbrowser;;
			uget) storecli_args uget;;
			youtube-dl) storecli_args youtube-dl;;
			youtube-dl-gui) storecli_args youtube-dl-gui;;
		esac
		echo -e "Menu Internet"
	done
}


menu_midia(){
	echo -e "$space_line"
	echo -e "Menu Midia"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_midia[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$option" in
			Voltar) msg "Voltando..."; break;;
			celluloid) storecli_args celluloid;;
			codecs) storecli_args codecs;;
			gnome-mpv) storecli_args gnome-mpv;;
			parole) storecli_args parole;;
			smplayer) storecli_args smplayer;;
			vlc) storecli_args vlc;;
		esac
		echo -e "Menu Midia"
	done
}


menu_system(){
	echo -e "$space_line"
	echo -e "Menu Sistema"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_system[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$option" in
			Voltar) msg "Voltando..."; break;;
			bluetooth) storecli_args bluetooth;;
			compactadores) storecli_args compactadores;;
			firmware-atheros) storecli_args firmware-atheros;;
			firmware-linux-nonfree) storecli_args firmware-linux-nonfree;;
			firmware-ralink) storecli_args firmware-ralink;;
			firmware-realtek) storecli_args firmware-realtek;;
			peazip) storecli_args peazip;;
			virtualbox) storecli_args virtualbox;;
		esac
		echo -e "Menu Sistema"
	done
}


menu_preferences(){
	echo -e "$space_line"
	echo -e "Menu Preferências"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_preferences[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$option" in
			Voltar) msg "Voltando..."; break;;
			papirus) storecli_args papirus;;
			ohmybash) storecli_args ohmybash;;
			ohmyzsh) storecli_args ohmyzsh;;
			sierra) storecli_args sierra;;
		esac
		echo -e "Menu Preferências"
	done
}



main(){
	echo -e "$space_line"
	echo -e "Menu Principal"
	
	while true; do
		category=$(_zenity_dialog_list "${list_main_menu[*]}")

		# Provavelmente o usuário CANCELOU.
		[[ "$?" == '0' ]] || {
			red "Abortando"
			return 1
		} 

		case "$category" in
			Sair) msg "Saindo..."; break;;
			Acessorios) menu_acessory;;
			Desenvolvimento) menu_dev;;
			Escritorio) menu_office;;
			Internet) menu_internet;;
			Midia) menu_midia;;
			Sistema) menu_system;;
			Preferencias) menu_preferences;;
		esac
		echo -e "Menu Principal"
	done
}

usage()
{
cat << EOF
   Use: $(basename "$0") --help|--upgrade|--version
   --help          Mostra ajuda.
   --upgrade       Instala a ultima versão deste programa, disponível
                   no github

   --version       Mostra versão.
EOF
}

if [[ ! -z $1 ]]; then
	case "$1" in
		--help) usage; exit;;
		--version) echo -e "$(basename $0) V${VERSION}"; exit;;
		--upgrade) 
				sudo "$Script_Setup_Gui"
				sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/install.sh)"
				exit
				;;

		*) red "Comando não encontrado [$1]"; exit;;
	esac
else
	main
fi

exit "$?"
