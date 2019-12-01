#!/usr/bin/env bash
#
#

github='https://github.com'

mkdir -p ~/.themes

#-----------------------------------------------------#

function _hacking_parrot()
{
# https://github.com/hanstnt1382/hacking_Parrot
# https://www.gnome-look.org/p/1328048/
# https://www.gnome-look.org/p/1328048/startdownload?file_id=1575222720&file_name=hacking_Parrot.tar.gz&file_type=application/x-gzip&file_size=752852
local url_hacking_parrot='https://dllb2.pling.com/api/files/download/id/1575222720/s/884ec5309b0fefb4a8fac0c7b83ac279f2991595266e3bb92413a3ba164ed25f515ac617ebe667575c18ecd09c9876c5cff3fa5d40747c031e3d9204b0df5d10/t/1575245823/c/884ec5309b0fefb4a8fac0c7b83ac279f2991595266e3bb92413a3ba164ed25f515ac617ebe667575c18ecd09c9876c5cff3fa5d40747c031e3d9204b0df5d10/lt/download/hacking_Parrot.tar.gz'
local path_arq="$dir_user_cache/$(basename $url_hacking_parrot)"

_dow "$url_hacking_parrot" "$path_arq" --wget
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }

	"$Script_UnPack" "$path_arq" "$dir_temp" || { 
		echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; 
	}

if [[ -d ~/.themes/hacking_Parrot ]]; then rm -rf ~/.themes/hacking_Parrot; fi

	cd "$dir_temp" && mv $(ls -d hacking*) ~/.themes
	if [[ $? == '0' ]]; then echo "$(_c 32)==> $(_c)[OK]"; fi
}

#-----------------------------------------------------#

#=====================================================#
# OhMyBash
#=====================================================#
function _ohmybash()
{
	# github_ohmy_bash="https://github.com/ohmybash/oh-my-bash.git"
	echo -e "$(_c 33)==> $(_c)Instalar oh-my-bash $(_c 35)[s/n]$(_c) ? : "
	read input
	[[ "${input,,}" == 's' ]] || { echo -e "$(_c 31)==> $(_c)Abortando..."; return 0; }

	#sh -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
	wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O '/tmp/ohmybash.sh'
	chmod +x '/tmp/ohmybash.sh'; '/tmp/ohmybash.sh'
}

#-----------------------------------------------------#

function _ohmyzsh()
{
	if [[ ! -x $(command -v zsh 2> /dev/null) ]]; then 
		echo -e "$(_c 32 0)==> Necessário instalar shell [zsh]$(_c)"

		if [[ -x $(command -v zypper 2> /dev/null) ]]; then
			sudo zypper in zsh
		elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
			sudo dnf install zsh
		elif [[ -x $(command -v apt 2> /dev/null) ]]; then
			sudo apt install zsh
		else
			return 1
		fi
	fi

	echo "$(_c 32 0)==> Instalando ohmyzsh$(_c)"
	sh -c "$(wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"	
}

#=====================================================#
# Papirus
#=====================================================#

function _papirus()
{
# Está função NÃO está em uso no momento.
#
local url_papirus='https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-icon-theme/master/install.sh'
local path_arq="$dir_user_cache/papirus.run"

	_dow "$url_papirus" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	chmod +x "$path_arq"
	"$path_arq"
}


#=====================================================#
# Tema Sierra
#=====================================================#

function _sierra()
{
github_sierra="$github/vinceliuice/Sierra-gtk-theme"
_gitclone "$github_sierra"

echo "$(_c 32)==> $(_c)Instalando"
cd "$dir_temp" && { cd Sierra-gtk-theme && chmod +x install.sh && ./install.sh; }
}
