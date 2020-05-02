#!/usr/bin/env bash
#
#
# V='2020-02-23'
#

esp='-------------------'
space_line='======================================'

function _msg(){
	echo -e "=> $@"
}

function _white(){
	echo -e "\033[1;37m=> $@\033[m"
}

_yellow(){
	echo -e "\033[1;93m[+] $@\033[m"
}

function usage()
{
cat <<EOF 
  Use: $(basename $(readlink -f $0)) --distro-repos
    --debian-repos             Habilitar repositórios em debian buster
    --fedora-repos             Habilitar repositórios no fedora
    --arch-repos               Habilitar repositórios no archlinux
    --tumblewee-repos          Adicionar repostórios extras para OpenSuse Tumbleweed
EOF
}

#============================================================#
# Repositórios fedora
#============================================================#
function _install_repos_fedora()
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
	_msg "Adicionando os seguintes repositórios: "
	sleep 1
	_msg "rpmfusion-free-release-$(rpm -E %fedora)"
	_msg "rpmfusion-nonfree-release-$(rpm -E %fedora)"
	_msg "fedora-workstation-repositories"

	sudo dnf install -y fedora-workstation-repositories || return 1
	sudo dnf install -y "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm" || return 1
	sudo dnf install -y "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm" || return 1
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
function _addrepo_buster(){
	local code_name=$(grep -m 1 'VERSION_CODENAME=' /etc/os-release | sed 's/.*=//g')
	local debian_repo='deb http://deb.debian.org/debian buster main contrib non-free'

	[[ "$code_name" == 'buster' ]] || {
		_msg "[!] Seu sistema não é 'Debian Buster'. Saindo"
		return 1
	}

	# 
	_msg "Adicionar o seguinte repositório [$debian_repo] em: /etc/apt/sources.list?: "
	read -p "Prosseguir? [s/n]: " _sn

	[[ "$_sn" == 's' ]] || {
		_msg "Abortando..."
		return 1
	}

	if ! grep '^deb.*debian.*main' /etc/apt/sources.list | grep -q "^deb.*main contrib non-free$"; then
		_white "Adicionando"
		sudo sh -c "echo 'deb http://deb.debian.org/debian buster main contrib non-free' >> /etc/apt/sources.list"
	fi

	grep -q 'deb http://deb.debian.org/debian buster main' /etc/apt/sources.list && {
		_white "Removendo repositório [main] duplicado"
		sudo sed -i "/^deb http:\/\/deb.debian.org\/debian buster main\$/d" /etc/apt/sources.list
	}

	grep -q 'deb http://deb.debian.org/debian buster contrib non-free' /etc/apt/sources.list && {
		_white "Removendo repositório [contrib non-free] duplicado"
		sudo sed -i "/^deb http:\/\/deb.debian.org\/debian buster contrib non-free\$/d" /etc/apt/sources.list
	}

	sudo apt update

}

#============================================================#
# Repositórios ArchLinux
#============================================================#
function _addrepo_arch(){

	# Linha onde está a string multibli.
	local num_line=$(grep -n '^\#\[multilib\]' /etc/pacman.conf | sed 's/:.*//g')
	local num_line_repo="$(($num_line+1))"

	echo -e "$space_line"
	read -p "Deseja habilitar o repositório [multilib] [s/n]?: " sn
	[[ "${sn,,}" == 's' ]] || {
		_msg "Abortando"
		return 1
	}

	# Descomentar as linhas abaixo com o sed.
	sudo sed -i "s|^\#\[multilib\]\$|[multilib]|" /etc/pacman.conf
	sudo sed -i "s|^\#Include = \/etc\/pacman.d\/mirrorlist\$|Include = \/etc\/pacman.d\/mirrorlist|" /etc/pacman.conf

	_msg "Sincronizando repositórios"
	# listar todos os pacotes no repositório multilib.
	# pacman -Sl
	sudo pacman -Sy
}

#============================================================#

if [[ ! -z $1 ]]; then

	while [[ $1 ]]; do
		case "$1" in
			--fedora-repos) _install_repos_fedora;;
			--debian-repos) _addrepo_buster;;
			--arch-repos) _addrepo_arch;;
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






