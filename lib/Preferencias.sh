#!/usr/bin/env bash
#
#

#-----------------------------------------------------#

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



