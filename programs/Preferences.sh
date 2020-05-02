#!/usr/bin/env bash
#
#

github='https://github.com'

#-----------------------------------------------------#

function _hacking_parrot()
{
# https://github.com/hanstnt1382/hacking_Parrot
# https://www.gnome-look.org/p/1328048/
# https://www.gnome-look.org/p/1328048/startdownload?file_id=1575222720&file_name=hacking_Parrot.tar.gz&file_type=application/x-gzip&file_size=752852
local url_hacking_parrot='https://dllb2.pling.com/api/files/download/id/1575222720/s/884ec5309b0fefb4a8fac0c7b83ac279f2991595266e3bb92413a3ba164ed25f515ac617ebe667575c18ecd09c9876c5cff3fa5d40747c031e3d9204b0df5d10/t/1575245823/c/884ec5309b0fefb4a8fac0c7b83ac279f2991595266e3bb92413a3ba164ed25f515ac617ebe667575c18ecd09c9876c5cff3fa5d40747c031e3d9204b0df5d10/lt/download/hacking_Parrot.tar.gz'
local path_file="$Dir_Downloads/$(basename $url_hacking_parrot)"

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	_unpack "$path_file" || return 1

	if [[ -d ~/.themes/hacking_Parrot ]]; then 
		rm -rf ~/.themes/hacking_Parrot
	fi

	cd "$Dir_Unpack" 
	mv $(ls -d hacking*) ~/.themes
	if [[ "$?" == '0' ]]; then
		_INFO 'pkg_sucess' 'code'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'code'
		return 1
	fi
}

#-----------------------------------------------------#

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
	msg "Instalando temas para ${Yellow}ohmybash${Reset} em: $HOME/.bash/themes"
	cp -ru "$Dir_Unpack/oh-my-bash-master/themes/" "$HOME/.bash/" || return 1
	msg "OK"

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

function _papirus()
{
	#------------------- Instruções para instalação ---------------------#
	# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme
	# https://github.com/PapirusDevelopmentTeam/papirus-icon-theme/archive/master.zip
	# "https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh"
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
	mv Papirus-Dark "$Dir_User_Icons/"

	green "Instalando Papirus"
	mv Papirus "$Dir_User_Icons/"
	
	green "Instalando Papirus-Light"
	mv Papirus-Light "$Dir_User_Icons/"

	green "Instalando ePapirus"
	mv ePapirus "$Dir_User_Icons/"
	
	for dir in "${array_papirus_dirs[@]}"; do
		if [[ -d "$dir" ]]; then
			_INFO 'pkg_sucess' "$dir"
		else
			_INFO 'pkg_instalation_failed' "$dir"
		fi
	done
}


#=====================================================#
# Tema Sierra
#=====================================================#

function _sierra()
{
	# https://github.com/vinceliuice/Sierra-gtk-theme
	github_sierra="$github/vinceliuice/Sierra-gtk-theme"
	_gitclone "$github_sierra" || return 1

	msg "Aguarde"
	cd "$dir_temp" 
	cd Sierra-gtk-theme 
	chmod +x install.sh
	./install.sh
}
