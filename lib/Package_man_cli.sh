#!/usr/bin/env bash
#
#


function package_man_cli()
{
	# Se a opção de somente download estiver ativada, então devemos setar um argumento
	# padrão para os gerenciadores de pacotes realizarem somente o download dos pacotes.
	# por exemplo:
	#        'sudo dnf install -y' (para baixar é instalar).
	#        'sudo apt install -y' (para baixar é instalar).
	#
	#        'sudo dnf install -y --downloadonly' (para somente baixar).
	#        'sudo apt install -y --download-only' (para somente baixar)
	#        'sudo zypper in --downloadonly' (para somente baixar).
	#
	#-------------------------------------------------------------#
	# Somente download
	#-------------------------------------------------------------#
	[[ "$download_only" == 'on' ]] && {

		if [[ -f '/etc/debian_version' ]]; then
			sudo apt install -y --download-only "$@"

		elif [[ "$os_id" == 'fedora' ]]; then
			sudo dnf install -y --downloadonly "$@"

		elif _WHICH 'zypper'; then
			sudo zypper in -y "$@"

		elif _WHICH 'pacman'; then
			sudo pacman -S "$@"

		elif _WHICH 'pkg'; then
			sudo pkg install "$@"
		
		else
			_prog_not_found
			return 1

		fi

	return 0 # Somente download encerrar depois de baixar os pacotes.
	}

	#-------------------------------------------------------------#
	# Baixar e instalar assumindo sim/yes.
	#-------------------------------------------------------------#
	[[ "$install_yes" == 'on' ]] && {
		if [[ -f '/etc/debian_version' ]]; then
			sudo apt install -y "$@"

		elif [[ "$os_id" == 'fedora' ]]; then
			sudo dnf install -y "$@"

		elif _WHICH 'zypper'; then
			sudo zypper in -y "$@"

		elif _WHICH 'pacman'; then
			sudo pacman -S "$@"

		elif _WHICH 'pkg'; then # FreeBSD
			sudo pkg install "$@"

		else
			_prog_not_found
			return 1
		
		fi

	return 0
	}


	if [[ -f '/etc/debian_version' ]]; then
		sudo apt install "$@"

	elif [[ "$os_id" == 'fedora' ]]; then
		sudo dnf install "$@"

	elif _WHICH 'zypper'; then
		sudo zypper in "$@"

	elif _WHICH 'pacman'; then
		sudo pacman -S "$@"

	elif _WHICH 'pkg'; then # FreeBSD
			sudo pkg install "$@"

	else
		_prog_not_found
		return 1
		
	fi
}

