#!/usr/bin/env bash
#
#
#
#

esp='-------------------'

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

local repos_fusion_free='https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release'
local repos_fusion_non_free='https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release'

echo -e "$esp[ Adicionar os seguintes repositórios ]$esp"
echo -e "=> rpmfusion-free-release-$(rpm -E %fedora)"
echo -e "=> rpmfusion-nonfree-release-$(rpm -E %fedora)"
echo -e "=> fedora-workstation-repositories"
echo -ne "=> Prosseguir [s/n] ?: "
read adc
[[ "${adc,,}" == 's' ]] || { echo "=> Abortando..."; return 0; }

echo -e "=> Aguarde..."
sudo dnf install fedora-workstation-repositories
sudo dnf install "$repos_fusion_free-$(rpm -E %fedora).noarch.rpm"
sudo dnf install "$repos_fusion_non_free-$(rpm -E %fedora).noarch.rpm"
return 0
}

#----------------------------------------------------#

if [[ ! -z $1 ]]; then

	while [[ $1 ]]; do
		case "$1" in
			--fedora-repos) _install_repos_fedora;;

		esac
		shift
	done	

fi







