#!/bin/sh
#
#----------------------------------------------------#
# INFO
#  este programa instala o wine-stable no debian buster
#----------------------------------------------------#
#
# https://wiki.winehq.org/Debian
# https://forum.winehq.org/viewtopic.php?t=32192

CRed="\033[0;31m"
CGreen="\033[0;32m"
CYellow="\033[0;33m"
CBlue="\033[0;34m"
CPrurple="\033[0;35m"
CCyan="\033[0;36m"
CGray="\033[0;37m"
CWhite="\033[0;37m"
CReset="\033[0m"

os_id=$(grep -m 1 ^'ID=' /etc/os-release | sed 's/.*=//g')
os_codename=$(grep -m 1 ^'VERSION_CODENAME=' /etc/os-release | sed 's/.*=//g')

space_line='--------------------------------------------------'

_msg()
{
	printf '%s\n' "$space_line"
	printf "${@}\n"
	printf '%s\n' "$space_line"
}

_add_arch32()
{
	printf "%s\n" "Executando: sudo dpkg --add-architecture i386"
	sudo dpkg --add-architecture i386
}


_add_repo()
{
	printf '%s' "Adicionando key "
	if ! wget -qnc -O- https://dl.winehq.org/wine-builds/winehq.key | sudo apt-key add -; then
		printf "${CRed}FALHA${CReset}\n"
		return 1
	fi

	printf '%s' "Adicionando repositório: "
	case "$os_codename" in
		buster) echo 'deb https://dl.winehq.org/wine-builds/debian/ buster main' | sudo tee /etc/apt/sources.list.d/wine.list;;
		*) printf "${CRed}FALHA${CReset} seu sistema não é suportado\n"; return 1;;
	esac


}

_libfaudio()
{
	local UrlKeyBuster='https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key'
	local opensuseRepo='deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./'

	printf 'Adicionando key '
	case "$os_codename" in
		buster)
			wget -q -O- "$UrlKeyBuster" | sudo apt-key add - || return 1
			echo "$opensuseRepo" | sudo tee /etc/apt/sources.list.d/libfaudio.list
			;;
	esac

	sudo apt update
	sudo apt install libfaudio0:i386 || return 1
}

_broke()
{
	sudo apt --fix-broken install
	sudo dpkg --configure -a
	sudo apt update
}

_install_wine()
{
	#sudo apt update
	#sudo apt  install --install-recommends libfaudio0:i386 || return 1
	sudo apt install -y --install-recommends wine-stable-i386 || return 1
	sudo apt install -y --install-recommends wine-stable-amd64 || return 1
	sudo apt install -y --install-recommends wine-stable || return 1
	sudo apt install -y --install-recommends winehq-stable || return 1
}

main()
{
	_msg "$os_id $os_codename"
	_add_repo
	_add_arch32
	_libfaudio || return 1
	_install_wine
}


main "$@"