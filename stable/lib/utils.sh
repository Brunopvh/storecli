#!/usr/bin/env bash


_ping()
{
	printf "Aguardando conexão ... "

	if ping -c 1 8.8.8.8 1> /dev/null 2>&1; then
		printf "Conectado\n"
		return 0
	else
		printf "\033[0;31mFALHA\033[m\n"
		printf "\033[0;31mAVISO: você está OFF-LINE\033[m\n"
		sleep 1
		return 1
	fi
}

_get_storecli_online_version()
{
	local URL_STORECLI_MASTER='https://raw.github.com/Brunopvh/storecli/master/storecli.sh'
	local TEMP_DIR_UPDATE="$(mktemp --directory)-storecli-update"
	local FILE_UPDATE='storecli.update'

	__download__ "$URL_STORECLI_MASTER" "$TEMP_DIR_UPDATE/$FILE_UPDATE" 1> /dev/null || return 1

	local OnlineVersion=$(grep -m 1 '^__version__=' "$TEMP_DIR_UPDATE/$FILE_UPDATE" | sed "s/.*=//g;s/'//g")
	echo -e "$OnlineVersion"
	rm -rf "$TEMP_DIR_UPDATE/$FILE_UPDATE" 1> /dev/null 2>&1
}

_update_storecli()
{
	[[ "$IgnoreCli" == 'True' ]] && return 0
	# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	# sh -c "$(wget -q -O- https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	
	local COLUMNS=$(tput cols)
	local FileConfigUpdate="$DIR_CONFIG_USER/update.conf"                   	
	local nowDate=$(date +%Y_%m_%d) # Data atual /ano/mês/dia. 
	touch "$FileConfigUpdate"
	
	# Data de execução da última busca por atualizações.
	local oldDateUpdate=$(grep -m 1 "date_update" "$FileConfigUpdate" | cut -d ' ' -f 2 2> /dev/null) 
	
	if [[ "$nowDate" == "$oldDateUpdate" ]]; then
		# Atualização já foi executada no dia atual.
		return 0
	else
		# Atualização ainda não foi executada no dia atual, gravar a data atual
		# no arquivo de configuração de atualizações e prosseguir.
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
	fi
	
	print_line
	[[ ! -z "$oldDateUpdate" ]] && printf "Data da última busca por atualizações ... $oldDateUpdate\n"
	
	_ping || return 1
	printf "Verificando atualização no github aguarde\n"	
	OnlineVersion=$(_get_storecli_online_version)
	printf "%-17s%-10s\n" "Versão local" "$__version__" 
	printf "%-17s%-10s\n" "Versão online" "$OnlineVersion"
	
	if [[ "$OnlineVersion" == "$__version__" ]]; then
		printf "Você está usando a ultima versão deste programa\n"
		echo -e "date_update $nowDate" > "$FileConfigUpdate"
		return 0
	fi
	
	printf "%-25s%-10s\n" "Atualizando para versão" "$OnlineVersion"
	
	cd "$dir_of_executable"
	if ! sh setup.sh; then
	    _sred "FALHA na execução do script setup.sh"
	    return 1
	fi
	
	echo -e "date_update $nowDate" > "$FileConfigUpdate"
	print_line
	return 0
}

_list_applications()
{
	# Função para listar os programas disponíveis para instalação no sistema
	# também lista programas de uma categoria especifica, bastando informar essa
	# categoria como argumento.
	# EXEMPLO:
	#   storecli -l Acessorios  -> Lista somente a categoria acessorios

	if [[ -z $1 ]]; then
		printf "%s\n" "  Acessorios: " # Acessorios
		for APP in "${programs_acessory[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Desenvolvimento: " # Desenvolvimento
		for APP in "${programs_development[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Escritorio: " # Escritório
		for APP in "${programs_office[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Navegadores: " # Navegadores
		for APP in "${programs_browser[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Internet: " # Internt
		for APP in "${programs_internet[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Midia: " # Midia
		for APP in "${programs_midia[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Sistema: " # Sistema
		for APP in "${programs_system[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Preferencias: " # Preferências
		for APP in "${programs_preferences[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Gnome Shell: " # Gnome Shell
		for APP in "${programs_gnomeshell[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Wine: " # Gnome Shell
		for APP in "${programs_wine[@]}"; do
			printf "%s\n" "      $APP"
		done
		printf "\n"

		return 0
	fi

	for arg in "${@}"; do
		case "$arg" in
			Acessorios)
					printf "%s\n" "  Acessorios: "
					for APP in "${programs_acessory[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Desenvolvimento)
					printf "%s\n" "  Desenvolvimento: "
					for APP in "${programs_development[@]}"; do
						printf "%s\n" "     $APP"
					done
					printf "\n"
					;;
			Escritorio)
					printf "%s\n" "  Escritorio: "
					for APP in "${programs_office[@]}"; do
						printf "%5s%s\n" " " "$APP"
					done
					printf "\n"
					;;
			Navegadores)
					printf "%s\n" "  Navegadores: "
					for APP in "${programs_browser[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Internet)
					printf "%s\n" "  Internet: "
					for APP in "${programs_internet[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Midia)
					printf "%s\n" "  Midia: "
					for APP in "${programs_midia[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Sistema)
					printf "%s\n" "  Sistema: "
					for APP in "${programs_system[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Preferencias)
					printf "%s\n" "  Preferencias: "
					for APP in "${programs_preferences[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			GnomeShell)
					printf "%s\n" "  Gnome Shell: "
					for APP in "${programs_gnomeshell[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Wine)
					printf "%s\n" "  Wine: "
					for APP in "${programs_wine[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			*)
				printf "\n"
				_red "(_list_applications) categoria inválida: $arg"
				printf "\n"
					;;
		esac
		shift
	done	
}


_pkg_manager_storecli()
{
	# Instalação dos programas, esta função recebe como parâmetro os pacotes a serem instalados
	# aluguns desses pacotes são instalados diretamente pelo gerenciador de pacotes da sua distro
	# Enquanto outros são instalados, seguindo um processo de download, descompressão e configuração.
	if [[ -z $1 ]]; then
		_list_applications
		return 1
	fi

	echo -e ".... $(date +%H:%M:%S) $__app_name__ V$__version__ ...."
	_clear_temp_dirs

	# Se o sistema for LinuxMint tricia, deverá ser tratado como Ubuntu bionic.
	case "$os_codename" in
		tina|tricia) export os_codename='bionic';;
	esac

	while [[ $1 ]]; do
		[[ -z $1 ]] && return 0 
		case "$1" in 
			Acessorios) _Acessory_All;;
			etcher) _etcher;;
			gnome-disk) _gnome_disk;;
			microsoft-teams) _microsoft_teams;;
			plank) _plank;;
			storecli-gui) _install_storecli;;
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

			Desenvolvimento) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			codeblocks) _codeblocks;;
			java) _java;;
			idea) _idea_ic;;
			pycharm) _pycharm;;
			sublime-text) _sublime_text;;
			vim) _vim;;
			vscode) _vscode;;

			Escritorio) _Office_All;;
			atril) _atril;;
			'fontes-ms') _fontes_microsoft;;
			libreoffice) _libreoffice;;
			libreoffice-appimage) _libreoffice_appimage;;

			Navegadores) _Browser_All;;
			chromium) _chromium;;
			edge) _edge;;
			firefox) _firefox;;
			'google-chrome') _google_chrome;;
			'opera-stable') _opera_stable;;
			torbrowser) _torbrowser;;

			Internet) _Internet_All;;      # Instalar todos da catgória Internet.
			clipgrab) _clipgrab_appimage;;
			megasync) _megasync;;
			proxychains) _proxychains;;
			qbittorrent) _qbittorrent;;
			skype) _skype;;
			teamviewer) _teamviewer;;
			telegram) _telegram;;
			tixati) _tixati;;
			uget) _uget;;
			youtube-dl) _youtube_dl;;
			youtube-dl-gui) _youtube_dlgui;;
		
			Midia) _Midia_All;;
			blender) _blender;;
			celluloid) _celluloid;;
			cinema) _cinema;;
			codecs) _codecs;;
			'gnome-mpv') _gnome_mpv;;
			smplayer) _smplayer;;
			spotify) _spotify;;
			parole) _parole;;
			totem) _totem;;
			vlc) _vlc;;

			Sistema) _System_All;;
			bluetooth) _bluetooth;;
			bspwm) _bspwm;;
			cpu-x) _cpux;;
			compactadores) _compactadores;;
			genymotion) _genymotion;;
			google-earth) _google_earth;;
			gparted) _gparted;;
			peazip) _peazip;;
			refind) _refind;;
			stacer) _stacer;;
			timeshift) _timeshift;;
			virtualbox) _virtualbox;;
			virtualbox-additions) _virtualbox_additions;;
			virtualbox-extensionpack) _virtualbox_extension_pack;; 

			ohmybash) _ohmybash;;			
			ohmyzsh) _ohmyzsh;;
			papirus) _papirus;;
			sierra) _sierra;;
		
			'dash-to-dock') _dashtodock;;
			'drive-menu') _drive_menu;;
			'gnome-backgrounds') _gnome_backgrounds;;
			'gnome-tweaks') _gnome_tweaks;;
			'topicons-plus') _topicons_plus;;
			
			Wine) _Wine_All;;
			wine) _install_wine;;
			winetricks) _install_script_winetricks;;
			epsxe-win) _epsxe_windows;;
			python37-windows-portable) _python37_windows32_portable;;
			python37-windows) _python37_windows32;;
			youtube-dl-gui-windows) _youtube_dlgui_windows;;
			install) ;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			-I|--ignore-cli) ;;
			*) _red "(_pkg_manager_storecli) programa não encontrado: $1"; return 1; break;;
		esac
		shift
	done
	return "$?"
}
