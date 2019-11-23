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
	# github_ohmy_bash="$github/ohmybash/oh-my-bash.git"
	echo -e "$(_c 33)==> $(_c)Instalar oh-my-bash $(_c 35)[s/n]$(_c) ? : "
	read input
	[[ "${input,,}" == 's' ]] || { echo -e "$(_c 31)==> $(_c)Abortando..."; return 0; }

	#sh -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
	wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O '/tmp/ohmybash.sh'
	chmod +x '/tmp/ohmybash.sh'; '/tmp/ohmybash.sh'
}