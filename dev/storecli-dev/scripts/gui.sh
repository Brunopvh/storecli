#!/usr/bin/env bash
#
#
#--------------------------------------------------------#
# Este programa é um GUI gráfico com o zenity para o script
# storecli
#
#
VERSION_GUI='2020-10-11'
#

export script_gui=$(readlink -f "$0")
export readonly dir_gui=$(dirname "$script_gui") # path deste arquivo no disco.
export dir_libs=$(cd "$dir_gui" && cd ../lib/ && pwd)

source "$dir_libs"/colors.sh

is_executable()
{
	# Função para verificar se um executável existe no PATH do sistema.
	if [[ -x $(which "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}

if is_executable tput; then
	columns=$(tput cols)
else
	columns='45'
fi

#=============================================================#
# Imprimir textos com formatação e cores.
#=============================================================#

print_line(){
	# Função para imprimir um caractere que preencha todo espaço horizontal do terminal.
	local L='-' # Caractere que será impresso ocupando todas as colunas do terminal.
	num='1'
	while [[ "$num" != "$columns" ]]; do
		L="${L}-"
		num="$(($num+1))"
	done
	[[ "$silent" == 'True' ]] && return 0
	printf '%s\n' "$L"
}

_msg()
{
	print_line
	echo -e " $@"
	print_line
}

_println()
{
	# Imprimir mensagens com printf sem quebrar linhas.
	printf "[>] $@"
}

_print()
{
	# Imprimir texto com formatação e quebra de linha.
	printf '%s\n' "[>] $@"
}

_red()
{
	echo -e "[${CRed}!${CReset}] $@"
}

_green()
{
	echo -e "[${CGreen}+${CReset}] $@"
}

_yellow()
{
	echo -e "[${CYellow}+${CReset}] $@"
}

_blue()
{
	echo -e "[${CBlue}+${CReset}] $@"
}

# Urls
github='https://github.com'  
raw='https://raw.github.com'

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

# Verificar conexão com a internet.
_ping()
{
	_println "Aguardando conexão ... "

	if ping -c 2 8.8.8.8 1> /dev/null; then
		echo "Conectado"
		return 0
	else
		_red "Falha"
		_red "AVISO: você está OFF-LINE"
		read -p "Pressione enter: " enter
		return 1
	fi
}

# Instalar o script storecli se ele não estiver disponível.
if [[ ! -x '/usr/local/bin/storecli' ]]; then
	_yellow "Instalando script storecli"
	if ! sudo sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"; then
		_red "Falha ao tentar instalar o script storecli"
		exit 1
	fi
fi

if is_executable "$HOME/.local/bin/storecli"; then
	script_storecli="$HOME/.local/bin/storecli"
elif is_executable '/usr/local/bin/storecli'; then
	script_storecli='/usr/local/bin/storecli'
else
	return 1
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
storecli_install_package()
{
	# Argumentos usados para instalação.
	_print "Executando ... $script_storecli install -y $@"
	"$script_storecli" install -y "$@"
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
			etcher) storecli_install_package etcher;;
			'gnome-disk') storecli_install_package gnome-disk;;
			veracrypt) storecli_install_package veracrypt;;
			woeusb) storecli_install_package woeusb;;
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
			'android-studio') storecli_install_package android-studio;;
			codeblocks) storecli_install_package codeblocks;;
			pycharm) storecli_install_package pycharm;;
			sublime-text) storecli_install_package sublime-text;;
			vim) storecli_install_package vim;;
			vscode) storecli_install_package vscode;;
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
			atril) storecli_install_package atril;;
			fontes-ms) storecli_install_package fontes-ms;;
			libreoffice) storecli_install_package libreoffice;;
			'libreoffice-appimage') storecli_install_package libreoffice-appimage;;
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
			chromium) storecli_install_package chromium;;
			firefox) storecli_install_package firefox;;
			google-chrome) storecli_install_package google-chrome;;
			'opera-stable') storecli_install_package opera-stable;;
			torbrowser) storecli_install_package torbrowser;;
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
			megasync) storecli_install_package megasync;;
			proxychains) storecli_install_package proxychains;;
			qbittorrent) storecli_install_package qbittorrent;;
			skype) storecli_install_package skype;;
			teamviewer) storecli_install_package teamviewer;;
			telegram) storecli_install_package telegram;;
			tixati) storecli_install_package tixati;;
			uget) storecli_install_package uget;;
			youtube-dl) storecli_install_package youtube-dl;;
			youtube-dl-gui) storecli_install_package youtube-dl-gui;;
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
			celluloid) storecli_install_package celluloid;;
			codecs) storecli_install_package codecs;;
			spotify) storecli_install_package spotify;;
			gnome-mpv) storecli_install_package gnome-mpv;;
			parole) storecli_install_package parole;;
			smplayer) storecli_install_package smplayer;;
			vlc) storecli_install_package vlc;;
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
			bluetooth) storecli_install_package bluetooth;;
			compactadores) storecli_install_package compactadores;;
			firmware-atheros) storecli_install_package firmware-atheros;;
			firmware-linux-nonfree) storecli_install_package firmware-linux-nonfree;;
			firmware-ralink) storecli_install_package firmware-ralink;;
			firmware-realtek) storecli_install_package firmware-realtek;;
			gparted) storecli_install_package gparted;;
			peazip) storecli_install_package peazip;;
			refind) storecli_install_package refind;;
			stacer) storecli_install_package stacer;;
			virtualbox) storecli_install_package virtualbox;;
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
			papirus) storecli_install_package papirus;;
			ohmybash) storecli_install_package ohmybash;;
			ohmyzsh) storecli_install_package ohmyzsh;;
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
			Atualizar_este_script) "$script_storecli" -u;;
			Remover_pacotes_quebrados) "$script_storecli" --broke;;
			Instalar_dependencias) "$script_storecli" --configure;;
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
