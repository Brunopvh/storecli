#!/usr/bin/env bash
#
#
#--------------------------------------------------------#
# Este programa é um GUI gráfico com o zenity para o script
# storecli
#
#
VERSION_GUI='2020-07-08'
#


# Diretórios
export readonly DirGui=$(dirname $(readlink -f "$0")) # path deste arquivo no disco.

# Urls
github='https://github.com'  
raw='https://raw.github.com'

_msg()
{
	echo -e "[>] $@"
}

_red()
{
	echo -e "\033[0;31m[!]\033[m $@"
}

_green()
{
	echo -e "\033[0;32m[*]\033[m $@"
}

_yellow()
{
	echo -e "\033[0;33m[+]\033[m $@"
}

# Usuário não pode ser o root.
if [[ $(id -u) == '0' ]]; then
	_red "Usuário não pode ser o [root] execute novamente sem o [sudo]"
	exit 1
fi

# Válidar se o Kernel e Linux ou FreeBSD.
if [[ $(uname -s) != 'Linux' ]] && [[ $(uname -s) != 'FreeBSD' ]]; then
	_red "Execute este programa em sistemas Linux ou FreeBSD."
	exit 1
fi

# Necessário ter a ferramenta "curl" intalada.
if [[ ! -x $(which curl 2> /dev/null) ]]; then
	_red "Instale a ferramenta [curl] para prosseguir"
	exit 1
fi

if [[ -x $(which tput 2> /dev/null) ]]; then
	columns=$(tput cols)
else
	columns='40'
fi

print_line(){
	local L='='
	num='1'
	while [[ "$num" != "$columns" ]]; do
		L="${L}="
		num="$(($num+1))"
	done
	# echo -ne "$L"
	printf '%s\n' "$L"
}

# Verificar conexão com a internet.
_ping()
{
	echo -ne "[>] Aguardando conexão "

	if ping -c 2 8.8.8.8 1> /dev/null; then
		echo "[Conectado]"
		return 0
	else
		echo ' '
		_red "Falha - AVISO: você está OFF-LINE"
		read -p "Pressione enter: " enter
		return 1
	fi
}

# Instalar o script storecli se ele não estiver disponível.
if [[ ! -x $(which storecli 2> /dev/null) ]]; then
	_yellow "Instalando script storecli"
	if ! sudo sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"; then
		_red "Falha ao tentar instalar storecli"
		exit 1
	fi
fi

_zenity_dialog_list()
{
	# $1 = Lista com opções a serem exibidas na caixa de dialogo
	# Os parametros já são fixos e estão com formatação padrão o que
	# será alterado ao longo do programa é a lista de exibição ou seja
	# o primeiro argumento dessa função ("$1") que será passado como 
	# ultimo parâmetro para o zenity ("$@").
	if [[ -z $1 ]]; then
		_red "Parametros incorretos detectados na função [_zenity_dialog_list]"
		return 1
	fi

	zenity --list --title='Selecione_uma_opcao' --text='Menu' \
			--width='400' --height='450' --radiolist --column 'Marcar' \
			--column 'Categorias' $@ 	
}


#=============================================================#
# Listas com as opções para serem selecionadas nas caixas de 
# dialogo com o zenity.
#=============================================================#

# Lista de opções a ser exibida no menu principal
list_main_menu=(
	"TRUE Sair"
	"FALSE Acessorios"
	"FALSE Desenvolvimento"
	"FALSE Escritorio"
	"FALSE Navegadores"
	"FALSE Internet"
	"FALSE Midia"
	"FALSE Sistema"
	"FALSE Preferencias"
	"FALSE Ferramentas"
)


# Lista de opções para categoria acessórios.
list_menu_acessory=(
	'TRUE Voltar'
	'FALSE etcher'
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
list_menu_navegadores=(
	'TRUE Voltar'
	'FALSE chromium'
	'FALSE firefox'
	'FALSE google-chrome'
	'FALSE opera-stable'
	'FALSE torbrowser'
)

# Lista de opções para categoria internet.
list_menu_internet=(
	'TRUE Voltar'
	'FALSE megasync'
	'FALSE proxychains'
	'FALSE qbittorrent'
	'FALSE skype'
	'FALSE teamviewer'
	'FALSE telegram'
	'FALSE tixati'
	'FALSE uget'
	'FALSE youtube-dl'
	'FALSE youtube-dl-gui'
)

# Lista de opções para categoria midia.
list_menu_midia=(
	'TRUE Voltar'
	'FALSE celluloid'
	'FALSE codecs'
	'FALSE spotify'
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
    'FALSE gparted'
    'FALSE peazip'
    'FALSE refind'
    'FALSE stacer'
    'FALSE virtualbox'
)

# Lista de opções para categoria preferências.
list_menu_preferences=(
	'TRUE Voltar'
	'FALSE papirus'
    'FALSE ohmybash'
    'FALSE ohmyzsh'
)

#=============================================================#
# Gnome Shell Extensões
#=============================================================#

list_menu_gnome_extensions=(
	'TRUE Voltar'
	'dash-to-dock'
    'drive-menu'
    'gnome-backgrounds'
    'gnome-tweaks'
    'topicons-plus'
)

#=============================================================#
# Menu mais opções.
#=============================================================#
list_menu_tools=(
	'TRUE Voltar'
	'FALSE Atualizar_este_script'
	'FALSE Remover_pacotes_quebrados'
	'FALSE Instalar_dependencias'
)

#=============================================================#
# Função para instalação dos pacotes com o script 'storecli'.
#=============================================================#
storecli_args()
{
	# Argumentos usados para instalação.
	storecli install -y "$@"
}

#=============================================================#
# Funções das categorias.
#=============================================================#
menu_acessory(){
	print_line
	echo -e "Menu Acessórios"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_acessory[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			etcher) storecli_args etcher;;
			'gnome-disk') storecli_args gnome-disk;;
			veracrypt) storecli_args veracrypt;;
			woeusb) storecli_args woeusb;;
		esac
		echo -e "Menu Acessórios"
	done
}

menu_dev(){
	print_line
	echo -e "Menu Desenvolvimento"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_development[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
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
	print_line
	echo -e "Menu Escritório"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_office[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			atril) storecli_args atril;;
			fontes-ms) storecli_args fontes-ms;;
			libreoffice) storecli_args libreoffice;;
			'libreoffice-appimage') storecli_args libreoffice-appimage;;
		esac
		echo -e "Menu Escritório"
	done
}


menu_navegadores(){
	print_line
	echo -e "Menu Navegadores"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_navegadores[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			chromium) storecli_args chromium;;
			firefox) storecli_args firefox;;
			google-chrome) storecli_args google-chrome;;
			'opera-stable') storecli_args opera-stable;;
			torbrowser) storecli_args torbrowser;;
		esac
		echo -e "Menu Navegadores"
	done
}

menu_internet(){
	print_line
	echo -e "Menu Internet"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_internet[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			megasync) storecli_args megasync;;
			proxychains) storecli_args proxychains;;
			qbittorrent) storecli_args qbittorrent;;
			skype) storecli_args skype;;
			teamviewer) storecli_args teamviewer;;
			telegram) storecli_args telegram;;
			tixati) storecli_args tixati;;
			uget) storecli_args uget;;
			youtube-dl) storecli_args youtube-dl;;
			youtube-dl-gui) storecli_args youtube-dl-gui;;
		esac
		echo -e "Menu Internet"
	done
}


menu_midia(){
	print_line
	echo -e "Menu Midia"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_midia[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			celluloid) storecli_args celluloid;;
			codecs) storecli_args codecs;;
			spotify) storecli_args spotify;;
			gnome-mpv) storecli_args gnome-mpv;;
			parole) storecli_args parole;;
			smplayer) storecli_args smplayer;;
			vlc) storecli_args vlc;;
		esac
		echo -e "Menu Midia"
	done
}


menu_system(){
	print_line
	echo -e "Menu Sistema"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_system[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			bluetooth) storecli_args bluetooth;;
			compactadores) storecli_args compactadores;;
			firmware-atheros) storecli_args firmware-atheros;;
			firmware-linux-nonfree) storecli_args firmware-linux-nonfree;;
			firmware-ralink) storecli_args firmware-ralink;;
			firmware-realtek) storecli_args firmware-realtek;;
			gparted) storecli_args gparted;;
			peazip) storecli_args peazip;;
			refind) storecli_args refind;;
			stacer) storecli_args stacer;;
			virtualbox) storecli_args virtualbox;;
		esac
		echo -e "Menu Sistema"
	done
}


menu_preferences(){
	print_line
	echo -e "Menu Preferências"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_preferences[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			papirus) storecli_args papirus;;
			ohmybash) storecli_args ohmybash;;
			ohmyzsh) storecli_args ohmyzsh;;
		esac
		echo -e "Menu Preferências"
	done
}

menu_gnomeshell()
{
	print_line
	echo -e "Menu Gnome Shell"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_gnome_extensions[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			dash-to-dock) storecli install -y dash-to-dock;;
			drive-menu) storecli install -y drive-menu;;
			gnome-backgrounds) storecli install -y gnome-backgrounds;;
			gnome-tweaks) storecli install -y gnome-tweaks;;
			topicons-plus) storecli install -y topicons-plus;;
		esac
		echo -e "Menu Preferências"
	done
}

menu_tools()
{
	print_line
	echo -e "Menu Ferramentas"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_tools[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) _yellow "Voltando..."; break;;
			Atualizar_este_script) "$Script_Storecli" --upgrade;;
			Remover_pacotes_quebrados) "$Script_Storecli" --broke;;
			Instalar_dependencias) "$Script_Storecli" --configure;;
		esac
		echo -e "Menu Ferramentas"
	done
}

main(){
	print_line
	_yellow "Menu Principal"
	
	while true; do
		category=$(_zenity_dialog_list "${list_main_menu[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			_red "Abortando"
			return 1
		fi 

		case "$category" in
			Sair) _yellow "Saindo..."; break;;
			Acessorios) menu_acessory;;
			Desenvolvimento) menu_dev;;
			Escritorio) menu_office;;
			Navegadores) menu_navegadores;;
			Internet) menu_internet;;
			Midia) menu_midia;;
			Sistema) menu_system;;
			Preferencias) menu_preferences;;
			Ferramentas) menu_tools;;
			GnomeShell) menu_gnomeshell;;
		esac
		_yellow "Menu Principal"
	done
}

usage()
{
cat << EOF
   Use: $(basename "$0") --help|--upgrade|--version
   --help             Mostra ajuda.
   --self-update      Instala a ultima versão deste programa, disponível
                      no github

   --version         Mostra versão.
EOF
}

if [[ ! -z $1 ]]; then
	case "$1" in
		--help) usage; exit;;
		--version) echo -e "$(basename $0) V${VERSION_GUI}"; exit;;
		--self-update) 
				storecli --self-update
				exit
				;;

		*) _red "Comando não encontrado [$1]"; exit;;
	esac
else
	main
fi

exit "$?"
