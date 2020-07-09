#!/usr/bin/env bash
#
#---------------------------------------------------------------#
# Este script tem a finalidade de adicionar repositórios adicionais
# em alguns sistemas, como por exemplo repositórios não livres para
# Debian e Fedora.
#---------------------------------------------------------------#
#
#
VERSION='2020-05-16'
#


Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
Blue='\033[1;34m'
White='\033[0;37m'
Reset='\033[0m'

space_line='===================================================='

#=============================================================#
_msg()
{
	echo -e "$space_line"
	echo -e "${CWhite}[>] $@${Reset}"
	echo -e "$space_line"
}

_red()
{
	echo -e "${Red}[!] $@${Reset}"
}

_green()
{
	echo -e "${Green}[+] $@${Reset}"
}

_yellow()
{
	echo -e "${Yellow}[*] $@${Reset}"
}

_blue()
{
	echo -e "${Blue}[+] $@${Reset}"
}

_white()
{
	echo -e "${White}[>] $@${Reset}"
}


#=============================================================#

function usage()
{
cat <<EOF 
  Use: $(basename $(readlink -f $0)) --distro-repos
    --debian-repos             Habilitar repositórios no debian buster
    --fedora-repos             Habilitar repositórios no fedora
    --tumblewee-repos          Adicionar repostórios extras para OpenSuse Tumbleweed
EOF
}

#if [[ $(id -u) != '0' ]]; then
#	_red "Você precisar ser o root. Execute: sudo $(readlink -f $0)"
#	exit 1
#fi

#============================================================#
# Repositórios fedora
#============================================================#
function _addrepo_fedora()
{
	# sudo dnf repolist
	# sudo dnf repository-packages fedora list
	# sudo dnf repository-packages fedora list available
	# sudo dnf repository-packages fedora list installed
	# sudo vim /etc/yum.repos.d/grafana.repo
	# sudo dnf config-manager --add-repo /etc/yum.repos.d/grafana.repo
	# sudo dnf --enablerepo=grafana install grafana  
	# sudo dnf --disablerepo=fedora-extras install grafana
	# dnf --best upgrade
	# 

	local repos_fusion_free='https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release'
	local repos_fusion_non_free='https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release'

	echo "$space_line"
	_white "Adicionando os seguintes repositórios: "
	_white "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm"
	_white "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm"
	_white "fedora-workstation-repositories"
	echo "$space_line"

	sudo dnf install -y "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm"
	sudo dnf install -y "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm" 
	sudo dnf install -y fedora-workstation-repositories 
}

#============================================================#
# Repositórios OpenSuse Tumbleweed
#============================================================#
function _addrepo_tumbleweed(){
	# https://software.opensuse.org/download/package?package=opensuse-codecs-installer&project=multimedia%3Aapps
	# https://forums.opensuse.org/showthread.php/523476-Multimedia-Guide-for-openSUSE-Tumbleweed
	# sudo zypper ar -f http://opensuse-guide.org/repo/openSUSE_Tumbleweed/ libdvdcss
	# sudo zypper ar -f http://packman.inode.at/suse/openSUSE_Tumbleweed/ packman
	# sudo zypper ref

	# Adicionar repostórios

	_yellow "Adicionando openSUSE_Tumbleweed/multimedia:apps.repo"
	sudo zypper addrepo https://download.opensuse.org/repositories/multimedia:apps/openSUSE_Tumbleweed/multimedia:apps.repo
	
	_yellow "Adicionando openSUSE_Tumbleweed/ libdvdcss"
	sudo zypper ar -f http://opensuse-guide.org/repo/openSUSE_Tumbleweed/ libdvdcss

	_yellow "Adicionando openSUSE_Tumbleweed/ packman"
	sudo zypper ar -f http://packman.inode.at/suse/openSUSE_Tumbleweed/ packman

	_yellow "Adicionando vlc/SuSE/Tumbleweed/SuSE.repo"
	sudo zypper ar -f http://download.videolan.org/pub/videolan/vlc/SuSE/Tumbleweed/SuSE.repo
	#sudo zypper ar -f http://download.videolan.org/pub/vlc/SuSE/Tumbleweed/

	_yellow "Adicionando openSUSE_Tumbleweed/ packman"
	sudo  zypper ar -cfp 90 http://ftp.gwdg.de/pub/linux/misc/packman/suse/openSUSE_Tumbleweed/ packman

	sudo zypper refresh
}

#============================================================#
# Repositórios debian 10
#============================================================#
function _addrepo_debian(){
	local codename=$(grep -m 1 'VERSION_CODENAME=' /etc/os-release | sed 's/.*=//g')
	local debian_repo="deb http://deb.debian.org/debian $codename main contrib non-free"

	echo -e "${Blue}$space_line${Reset}"
	_yellow "Deseja adicionar o repositório: $debian_repo [${Green}s${Reset}/${Red}n${Blue}]?: "
	echo -e "${Blue}$space_line${Reset}"
	read -n 1 -t 15 sn 
	echo ' '

	if [[ "${sn,,}" != 's' ]]; then
		_white "${Yellow}A${Reset}bortando"
		exit 0	
	fi

	if ! grep '^deb.*debian.*main' /etc/apt/sources.list | grep -q "^deb.*main contrib non-free$"; then
		_white "Adicionando: $debian_repo"
		echo "$debian_repo" >> /etc/apt/sources.list
	fi

	grep -q "^deb http://deb.debian.org/debian $codename main" /etc/apt/sources.list && {
		_white "Removendo repositório [main] duplicado"
		sed -i "/^deb http:\/\/deb.debian.org\/debian $codename main\$/d" /etc/apt/sources.list
	}

	grep -q "^deb http://deb.debian.org/debian $codename contrib non-free" /etc/apt/sources.list && {
		_white "Removendo repositório [contrib non-free] duplicado"
		sudo sed -i "/^deb http:\/\/deb.debian.org\/debian $codename contrib non-free\$/d" /etc/apt/sources.list
	}

	apt update

}

#============================================================#
# Repositórios ArchLinux
#============================================================#


#============================================================#

if [[ ! -z $1 ]]; then

	while [[ $1 ]]; do
		case "$1" in
			--debian-repos) _addrepo_debian;;
			--fedora-repos) _addrepo_fedora;;
			--tumbleweed-repos) _addrepo_tumbleweed;;
			-h|--help) usage;;
			*) usage;;
		esac
		shift
	done
elif [[ -z $1 ]]; then
		usage	

fi

#============================================================#

exit "$?"






