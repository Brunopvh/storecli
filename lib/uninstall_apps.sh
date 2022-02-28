#!/usr/bin/env bash
#
#
#

#=============================================================#
# Removção desinstalação dos pacotes
#=============================================================#
_uninstall_etcher()
{
	if [[ "$BASE_DISTRO" == 'debian' ]]; then
		_APT remove 'balena-etcher-electron'
		__rmdir__ '/etc/apt/sources.list.d/balena-etcher.list'
	else
		__rmdir__ "${destinationFilesEtcher[@]}"
	fi
}

_uninstall_msteams()
{
	case "$BASE_DISTRO" in
		fedora) _DNF remove teams;;
		debian) _APT remove teams;;
		*) red "Não foi possível remover microsoft-teams."; return 1;;
	esac
}

_uninstall_nodejs_lts()
{
	if [[ "$OS_ID" == 'debian' ]] || [[ "$OS_ID" == 'ubuntu' ]]; then
		_APT remove nodejs
	else
		__rmdir__ "${destinationFilesNodejs[@]}"
	fi
}

_uninstall_vscode()
{
	if [[ -f /etc/debian_version ]]; then
		_APT remove code
	else
		__rmdir__ "${destinationFilesVscode[@]}"
	fi
}

_uninstall_teamviewer()
{	
	case "$OS_ID" in
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
		sred "Seu sistema não tem suporte para executar esta ação."
		sleep 0.5
		return 1
	fi
}

_uninstall_torbrowser()
{
	local url_script_torbrowser_installer='https://raw.github.com/Brunopvh/torbrowser/master/tor.sh'

	is_executable tor-installer || {
		download "$url_script_torbrowser_installer" "$SCRIPT_TORBROWSER_INSTALLER" || return 1
		chmod +x "$SCRIPT_TORBROWSER_INSTALLER"
	}
	
	"$SCRIPT_TORBROWSER_INSTALLER" --remove
}

_uninstall_youtube_dl_gui_windows()
{
	__rmdir__ ~/."local/share/applications/youtube-dl-gui-windows.desktop" 
}

_uninstall_youtube_dl_qt()
{
	echo -e "Desinstalando youtube-dl-qt"
	__rmdir__ "${destinationFilesYoutubeDlQt[@]}"
	python3 -m pip uninstall youtube_dl_qt --yes
}

_uninstall_cpux()
{
	if [[ -f /etc/fedora-release ]]; then
		_DNF remove cpu-x
	else
		__rmdir__ "${destinationFilesCpux[@]}"
	fi
}

_uninstall_stacer()
{
	if [[ -f /etc/debian_version ]]; then
		_APT remove stacer
	elif [[ -f /etc/fedora-release ]]; then
		_DNF remove stacer
	else
		__rmdir__ "${destinationFilesStacer[@]}"
	fi
}

_uninstall_virtualbox()
{
	if [[ "$VERSION_CODENAME" == 'buster' ]]; then
		sudo apt remove virtualbox-5.2
	else
		red "Não foi possível remover: $1"
	fi
}

_uninstall_packages()
{
	[[ -z $1 ]] && usage && return 1
	while [[ $1 ]]; do
		case "$1" in
			coin-qt-gui) __rmdir__ "${destinationFilesCoinQtGui[@]}";;
			electrum) __rmdir__ "${destinationFilesElectrum[@]}";;
			etcher) _uninstall_etcher;;
			veracrypt) __sudo__ 'veracrypt-uninstall.sh';;

			android-studio) __rmdir__ "${destinationFilesAndroidStudio[@]}";;
			brmodelo) __rmdir__ "${destinationFilesBrModelo[@]}";;
			intellij) __rmdir__ "${destinationFilesIntellij[@]}";;
			netbeans) __rmdir__ "${destinationFilesNetbeans[@]}";;
			nodejs) _uninstall_nodejs_lts;;
			pycharm) __rmdir__ "${destinationFilesPycharm[@]}";;
			sublime-text) __rmdir__ "${destinationFilesSublime[@]}";;
			vscode) _uninstall_vscode;;

			'libreoffice-appimage') __rmdir__ "${destinationFilesLibreofficeAppimage[@]}";;
			edge) _uninstall_edge;;
			electron-player) python3 -m appcli --remove electron-player --yes;;
			torbrowser) _uninstall_torbrowser;;	
			telegram) __rmdir__ "${destinationFilesTelegram[@]}";;
			tixati) __rmdir__ "${destinationFilesTixati[@]}";;
			teamviewer) _uninstall_teamviewer;;
			youtube-dl) __rmdir__ "$directoryUSERbin/youtube-dl";;
			youtube-dl-gui-windows) _uninstall_youtube_dl_gui_windows;;
			youtube-dl-qt) _uninstall_youtube_dl_qt;;
	
			archlinux-installer) __rmdir__ "${destinationFilesArchlinuxInstaller[@]}";;
			cpu-x) _uninstall_cpux;;
			peazip) __rmdir__ "${destinationFilesPeazip[@]}";;
			refind) __rmdir__ "${destinationFilesRefind[@]}";;
			stacer) _uninstall_stacer;;
			virtualbox) _uninstall_virtualbox;;

			epsxe-win) __rmdir__ "${destinationFilesEpsxeWin32[@]}";;
			remove) ;;
			-y|-d) ;;
			*) red "Não foi possível remover: $1"; return 1; break;;
		esac
		shift
	done
	
	return "$?"
}
