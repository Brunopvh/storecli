#!/usr/bin/env bash
#
#
# Este arquivo guarda a lista dos pacotes disponiveis para instalação.

#=============================================================#
# Listagem de todos os pacotes disponíveis para instalação.
#=============================================================#
programs_acessory=(
	etcher
	gnome-disk
	microsoft-teams
	storecli-gui
	veracrypt
	woeusb
	)

programs_development=(
	android-studio
	codeblocks
	idea
	nodejs
	pycharm
	sublime-text
	vim
	vscode
	python37-windows
	python37-windows-portable
	)

programs_office=(
	atril
	fontes-ms
	libreoffice
	libreoffice-appimage
	)

programs_browser=(
	chromium
	edge
	firefox
	google-chrome
	opera-stable
	torbrowser
	)

programs_internet=(
	clipgrab
	megasync
	proxychains
	qbittorrent
	skype
	teamviewer
	telegram
	tixati
	uget
	youtube-dl
	youtube-dl-gui
	)


programs_midia=(
	celluloid
	cinema
	codecs
	spotify
	gnome-mpv
	parole
	smplayer
	totem
	vlc
	)

programs_system=(
	archlinux-installer
	bluetooth
	compactadores
	cpu-x
	genymotion
	google-earth
	gparted
	peazip
	refind
	stacer
	shm
	timeshift
	virtualbox
	virtualbox-additions
	virtualbox-extensionpack
	)

programs_preferences=(
	ohmybash
	ohmyzsh
	papirus
	sierra
	)

programs_gnomeshell=(
	dash-to-dock
	drive-menu
	gnome-backgrounds
	gnome-tweaks
	topicons-plus
	)


programs_wine=(
	wine
	winetricks
	epsxe-win
	python37-windows
	python37-windows-portable
	youtube-dl-gui-windows
	)



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
				red "(_list_applications) categoria inválida: $arg"
				printf "\n"
					;;
		esac
		shift
	done	
}


