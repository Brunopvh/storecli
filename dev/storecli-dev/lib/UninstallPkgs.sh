#!/usr/bin/env bash
#
#
#

__delete_files__()
{
	if [[ -z $1 ]]; then
		return 1
	fi

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# A função __sudo__ irá remover o arquivo/diretório.
	for X in "$@"; do
		if [[ ! -L "$X" ]] && [[ ! -f "$X" ]] && [[ ! -d "$X" ]]; then
			_red "Não encontrado: $X"
		else
			printf "[>] ${CRed}R${CReset}emovendo: $X "
			if rm -rf "$X" 2> /dev/null || sudo rm -rf "$X"; then
				_syellow "OK"
			else
				_sred "FALHA"
			fi
		fi
	done
}

#=============================================================#
# Removção desinstalação dos pacotes
#=============================================================#
_uninstall_etcher()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _APT remove etcher;;
		*) __delete_files__ "${destinationFilesEtcher[@]}";;
	esac
}

_uninstall_vscode()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _APT remove code;;
		*) __delete_files__ "${destinationFilesVscode[@]}";;
	esac
}

_uninstall_teamviewer()
{	
	case "$os_id" in
		debian|ubuntu|linuxmint) _APT remove teamviewer;;
		fedora) _DNF remove teamviewer;;
		*) __delete_files__ "${destinationFilesTeamviewer[@]}";;
	esac

}

_uninstall_packages()
{
	[[ -z $1 ]] && return 1
	while [[ $1 ]]; do
		_space_text "Removendo" "$1"

		case "$1" in
			etcher) _uninstall_etcher;;
			veracrypt) __sudo__ 'veracrypt-uninstall.sh';;

			'android-studio') __delete_files__ "${destinationFilesAndroidStudio[@]}";;
			pycharm) __delete_files__ "${destinationFilesPycharm[@]}";;
			'sublime-text') __delete_files__ "${destinationFilesSublime[@]}";;
			vscode) _uninstall_vscode;;

			'libreoffice-appimage') __delete_files__ "${destinationFilesLibreofficeAppimage[@]}";;

			torbrowser) "$scritpTorBrowser" --remove;;	

			telegram) __delete_files__ "${destinationFilesTelegram[@]}";;
			tixati) __delete_files__ "${destinationFilesTixati[@]}";;
			teamviewer) _uninstall_teamviewer;;
			youtube-dl) __delete_files__ "$directoryUSERbin/youtube-dl";;
	
			peazip) __delete_files__ "${destinationFilesPeazip[@]}";;
			refind) __delete_files__ "${destinationFilesRefind[@]}";;
			stacer) __delete_files__ "${destinationFilesStacer[@]}";;

			*) _red "Não foi possível remover: $1";;
		esac
		shift
	done


return "$?"
}