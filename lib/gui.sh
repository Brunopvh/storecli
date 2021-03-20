#!/usr/bin/env bash
#
#
#--------------------------------------------------------#
# Este programa é um GUI gráfico com o zenity para o script
# storecli
#

# URLS
github='https://github.com'  
raw='https://raw.github.com'

_zenity_dialog_list()
{
	# $1 = Lista com opções a serem exibidas na caixa de dialogo
	# Os parametros já são fixos e estão com formatação padrão o que
	# será alterado ao longo do programa é a lista de exibição ou seja
	# o primeiro argumento dessa função ("$1") que será passado como 
	# ultimo parâmetro para o zenity ("$@").
	if [[ -z $1 ]]; then
		red "Parametros incorretos detectados na função [_zenity_dialog_list]"
		return 1
	fi

	zenity --list --title='Selecione_uma_opcao' --text='Menu' \
			--width='400' --height='450' --radiolist --column 'Marcar' \
			--column 'Categorias' $@ 2> /dev/null	
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
	'FALSE brmodelo'
	'FALSE codeblocks'
	'FALSE intellij'
	'FALSE netbeans'
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
	'FALSE edge'
	'FALSE firefox'
	'FALSE google-chrome'
	'FALSE opera-stable'
	'FALSE torbrowser'
)

# Lista de opções para categoria internet.
list_menu_internet=(
	'TRUE Voltar'
	'FALSE clipgrab'
	'FALSE electron-player'
	'FALSE freetube'
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
    'FALSE cpu-x'
    'FALSE genymotion'
	'FALSE google-earth'
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
# Funções das categorias.
#=============================================================#
menu_acessory(){
	print_line
	echo -e "Menu Acessórios"
	
	while true; do
		option=$(_zenity_dialog_list "${list_menu_acessory[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			red "Abortando"
			return 1
		fi

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			etcher) main install -y etcher;;
			'gnome-disk') main install -y gnome-disk;;
			veracrypt) main install -y veracrypt;;
			woeusb) main install -y woeusb;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			android-studio) main install -y android-studio;;
			brmodelo) main install -y brmodelo;;
			codeblocks) main install -y codeblocks;;
			intellij) main install -y intellij;;
			netbeans) main -y install netbeans;;
			pycharm) main install -y pycharm;;
			sublime-text) main install -y sublime-text;;
			vim) main install -y vim;;
			vscode) main install -y vscode;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			atril) main install -y atril;;
			fontes-ms) main install -y fontes-ms;;
			libreoffice) main install -y libreoffice;;
			'libreoffice-appimage') main install -y libreoffice-appimage;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			chromium) main install -y chromium;;
			edge) main install -y edge;;
			firefox) main install -y firefox;;
			google-chrome) main install -y google-chrome;;
			'opera-stable') main install -y opera-stable;;
			torbrowser) main install -y torbrowser;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			clipgrab) main install -y clipgrab;;
			electron-player) main install -y electron-player;;
			freetube) main install -y freetube;;
			megasync) main install -y megasync;;
			proxychains) main install -y proxychains;;
			qbittorrent) main install -y qbittorrent;;
			skype) main install -y skype;;
			teamviewer) main install -y teamviewer;;
			telegram) main install -y telegram;;
			tixati) main install -y tixati;;
			uget) main install -y uget;;
			youtube-dl) main install -y youtube-dl;;
			youtube-dl-gui) main install -y youtube-dl-gui;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			celluloid) main install -y celluloid;;
			codecs) main install -y codecs;;
			spotify) main install -y spotify;;
			gnome-mpv) main install -y gnome-mpv;;
			parole) main install -y parole;;
			smplayer) main install -y smplayer;;
			vlc) main install -y vlc;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			bluetooth) main install -y bluetooth;;
			compactadores) main install -y compactadores;;
			cpu-x) main install -y cpu-x;;
			genymotion) main install -y genymotion;;
			firmware-atheros) main install -y firmware-atheros;;
			firmware-linux-nonfree) main install -y firmware-linux-nonfree;;
			firmware-ralink) main install -y firmware-ralink;;
			firmware-realtek) main install -y firmware-realtek;;
			google-earth) main install -y google-earth;;
			gparted) main install -y gparted;;
			peazip) main install -y peazip;;
			refind) main install -y refind;;
			stacer) main install -y stacer;;
			virtualbox) main install -y virtualbox;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			papirus) main install -y papirus;;
			ohmybash) main install -y ohmybash;;
			ohmyzsh) main install -y ohmyzsh;;
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
			red "Abortando"
			return 1
		fi

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			dash-to-dock) main install -y dash-to-dock;;
			drive-menu) main install -y drive-menu;;
			gnome-backgrounds) storecli install -y gnome-backgrounds;;
			gnome-tweaks) main install -y gnome-tweaks;;
			topicons-plus) main install -y topicons-plus;;
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
			red "Abortando"
			return 1
		fi 

		case "$option" in
			Voltar) yellow "Voltando..."; break;;
			Atualizar_este_script) "$SCRIPT_STORECLI_INSTALLER";;
			Remover_pacotes_quebrados) _BROKE;;
			Instalar_dependencias) _install_requeriments;;
		esac
		echo -e "Menu Ferramentas"
	done
}

main_menu(){
	
	if ! is_executable storecli; then
		yellow "Instalando o script storecli"
		sudo bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	fi

	print_line
	yellow "Menu Principal"
	
	while true; do
		category=$(_zenity_dialog_list "${list_main_menu[*]}")

		# O usuário CANCELOU.
		if [[ "$?" != '0' ]]; then
			red "Abortando"
			return 1
		fi 

		case "$category" in
			Sair) yellow "Saindo..."; break;;
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
		yellow "Menu Principal"
	done
}

