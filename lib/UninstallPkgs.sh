#!/usr/bin/env bash
#
#
#

#=============================================================#
# Removção desinstalação dos pacotes
#=============================================================#
_uninstall_etcher()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) 
						_APT remove 'balena-etcher-electron'
						__rmdir__ '/etc/apt/sources.list.d/balena-etcher.list'
						;;
		*) __rmdir__ "${destinationFilesEtcher[@]}";;
	esac
}

_uninstall_vscode()
{
	__rmdir__ "${destinationFilesVscode[@]}"
}

_uninstall_teamviewer()
{	
	case "$os_id" in
		debian|ubuntu|linuxmint) _APT remove teamviewer;;
		fedora) _DNF remove teamviewer;;
		*) __rmdir__ "${destinationFilesTeamviewer[@]}";;
	esac

}

_uninstall_edge()
{
	if [[ -f /etc/debian_version ]]; then
		_APT remove microsoft-edge-dev
	elif [[ -f /etc/fedora-release ]]; then
		_DNF remove microsoft-edge-dev
	else
		_sred "Seu sistema não tem suporte para executar esta ação."
		sleep 0.5
		return 1
	fi
}

_uninstall_packages()
{
	[[ -z $1 ]] && usage && return 1
	while [[ $1 ]]; do
		case "$1" in
			etcher) _uninstall_etcher;;
			veracrypt) __sudo__ 'veracrypt-uninstall.sh';;

			'android-studio') __rmdir__ "${destinationFilesAndroidStudio[@]}";;
			idea) __rmdir__ "${destinationFilesIdeaic[@]}";;
			pycharm) __rmdir__ "${destinationFilesPycharm[@]}";;
			'sublime-text') __rmdir__ "${destinationFilesSublime[@]}";;
			vscode) _uninstall_vscode;;

			'libreoffice-appimage') __rmdir__ "${destinationFilesLibreofficeAppimage[@]}";;
			edge) _uninstall_edge;;
			torbrowser) "$scriptTorBrowser" --remove;;	

			telegram) __rmdir__ "${destinationFilesTelegram[@]}";;
			tixati) __rmdir__ "${destinationFilesTixati[@]}";;
			teamviewer) _uninstall_teamviewer;;
			youtube-dl) __rmdir__ "$directoryUSERbin/youtube-dl";;
	
			peazip) __rmdir__ "${destinationFilesPeazip[@]}";;
			refind) __rmdir__ "${destinationFilesRefind[@]}";;
			stacer) __rmdir__ "${destinationFilesStacer[@]}";;

			epsxe-win) __rmdir__ "${destinationFilesEpsxeWin32[@]}";;
			remove) ;;
			*) _red "Não foi possível remover: $1"; return 1; break;;
		esac
		shift
	done
	
	return "$?"
}