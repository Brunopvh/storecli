#!/usr/bin/env bash

readonly url_script_torbrowser_installer='https://raw.github.com/Brunopvh/torbrowser/master/tor.sh'
readonly dir_bin=~/.local/bin
readonly SCRIPT_TORBROWSER_INSTALLER="$dir_bin/tor-installer"

function install_script_tor_installer()
{
	mkdir -p "$dir_bin"
	echo -ne "Baixando o script tor.sh em $SCRIPT_TORBROWSER_INSTALLER ... "
	if [[ -x $(command -v wget) ]]; then
		wget -q "$url_script_torbrowser_installer" -O "$SCRIPT_TORBROWSER_INSTALLER" || return 1
	elif [[ -x $(command -v curl) ]]; then
		curl -fsSL "$url_script_torbrowser_installer" -o "$SCRIPT_TORBROWSER_INSTALLER" || return 1	
	else
		return 1
	fi


	chmod +x "$SCRIPT_TORBROWSER_INSTALLER"
	if [[ -x $(command -v tor-installer) ]]; then
		echo "OK"
		return 0
	else
		echo "Falha"
		return 1
	fi
}

[[ ! -x $(command -v tor-installer) ]] && {
	install_script_tor_installer || exit 1	
	}

"$SCRIPT_TORBROWSER_INSTALLER" "$@"
