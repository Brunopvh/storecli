#!/usr/bin/env bash
#
#

github='https://github.com'


#=====================================================#
# OhMyBash
#=====================================================#
function _ohmybash()
{
	# github_ohmy_bash="https://github.com/ohmybash/oh-my-bash.git"
	# https://github.com/ohmybash/oh-my-bash/wiki/Themes#agnoster
	#
	#
	# Temas:
	# I recommend the following:
	# $ cd home
	# $ mkdir -p .bash/themes/agnoster-bash
	# $ git clone https://github.com/speedenator/agnoster-bash.git .bash/themes/agnoster-bash
	# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh)"
	
	local ohmybash_master='https://github.com/ohmybash/oh-my-bash/archive/master.zip'
	local path_file="$Dir_Downloads/ohmybash.zip"


	# Perguntar se o usuário deseja realmente instalar o pacote caso não exista
	# o argumento '-y' ou --yes.
	if [[ -z "$install_yes" ]]; then
		_YESNO "Instalar o pacote ohmybash" || return 0
	fi

	# Executar script de instalação que está no diretório scripts.
	"$Script_ohmybash" 

	mkdir -p "$HOME/.bash/themes"
	_dow "$ohmybash_master" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	_unpack "$path_file" || return 1
	white "Instalando temas para ${Yellow}ohmybash${Reset} em: $HOME/.bash/themes"
	cp -ru "$Dir_Unpack/oh-my-bash-master/themes/" "$HOME/.bash/" || return 1
	white "OK"

	#echo 'OSH_THEME="rjorgenson"' >> "$HOME/.bashrc"
	if ! grep -q "^OSH_THEME.*rjorgenson" "$HOME/.bashrc"; then
		green "Configurando tema rjorgenson para ohmybash"
		echo 'OSH_THEME="rjorgenson"' >> "$HOME/.bashrc"
	fi
}

#-----------------------------------------------------#

function _ohmyzsh()
{
	# sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
	# https://github.com/ohmyzsh/ohmyzsh
	#

	if ! _WHICH 'zsh'; then
		yellow "Necessário instalar shell [zsh]"	
	fi

	_package_man_distro zsh
	yellow "Instalando ohmyzsh"
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"	
}

#=====================================================#
# Papirus
#=====================================================#
function _papirus_debian()
{
	# sudo apt install libreoffice-style-papirus
	#
	_package_man_distro 'papirus-icon-theme'
}


function _papirus_github()
{
	#------------------- Instruções para instalação ---------------------#
	# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
	# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/master.zip
	# https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh
	# https://github.com/PapirusDevelopmentTeam

	local url_papirus_master="$github/PapirusDevelopmentTeam/papirus-icon-theme/archive/master.zip"
	local path_file="$Dir_Downloads/papirus.zip"

	_dow "$url_papirus_master" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Verificar se o tema já está instalado utilizando a lista 
	# de informações sobre o tema que está no módulo 'Arrays.sh'.
	for dir in "${array_papirus_dirs[@]}"; do
		if [[ -d "$dir" ]]; then
			_INFO 'pkg_are_instaled' 'papirus'
			return 0
			break
		fi
	done

	_unpack "$path_file" || return 1
	cd "$Dir_Unpack"
	mv  $(ls -d papirus-*) "$Dir_Unpack/papirus"
	cd "$Dir_Unpack/papirus"

	green "Instalando Papirus-Dark"
	cp -R Papirus-Dark "$Dir_User_Icons/"

	green "Instalando Papirus"
	cp -R Papirus "$Dir_User_Icons/"
	
	green "Instalando Papirus-Light"
	cp -R Papirus-Light "$Dir_User_Icons/"

	green "Instalando ePapirus"
	cp -R ePapirus "$Dir_User_Icons/"
	
	for dir in "${array_papirus_dirs[@]}"; do
		if [[ -d "$dir" ]]; then
			_INFO 'pkg_sucess' "$dir"
		else
			_INFO 'pkg_instalation_failed' "$dir"
		fi
	done
}

function _papirus()
{
	case "$os_id" in
		debian) _papirus_debian;;
		*) _papirus_github;;
	esac
}

#=====================================================#
# Tema Sierra
#=====================================================#

function _sierra()
{
	# https://github.com/vinceliuice/Sierra-gtk-theme
	# https://github.com/vinceliuice/Sierra-gtk-theme#flathub
	#----------------------------------------------------------------------#
	#
	# Flathub
	# Light Theme flatpak install flathub org.gtk.Gtk3theme.High-Sierra
	# Dark Theme flatpak install flathub org.gtk.Gtk3theme.High-Sierra-Dark
	#----------------------------------------------------------------------#
	#
	# Suse
	# sudo zypper ar obs://X11:common:Factory/sierra-gtk-theme x11
    # sudo zypper ref
    # sudo zypper in sierra-gtk-theme
	#----------------------------------------------------------------------#
	#
	
	local github_sierra="$github/vinceliuice/Sierra-gtk-theme"
	local url_sierra='https://github.com/vinceliuice/Sierra-gtk-theme/archive/master.tar.gz'
	local path_file="$Dir_Downloads/sierra_gtk_theme.tar.gz"
	#_gitclone "$github_sierra" || return 1

	_dow "$url_sierra" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	_unpack "$path_file" || return 1

	case "$os_id" in
		fedora) 
				_package_man_distro 'gtk-murrine-engine' 'gtk2-engines'
				;;

		arch) 
				_package_man_distro 'gtk-engine-murrine' 'gtk-engines'
				;;

		debian|ubuntu|linuxmint) 
				_package_man_distro 'gtk2-engines-murrine' 'gtk2-engines-pixbuf'
				;;
	esac

	cd "$Dir_Unpack"
	mv $(ls -d Sierra*) sierra_theme 
	cd sierra_theme
	chmod +x install.sh
	./install.sh --color dark
}
