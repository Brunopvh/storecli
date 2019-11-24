#!/usr/bin/env bash
#
#
#

#=====================================================#
# Debian Firmwares
#=====================================================#
function _firmware()
{
	[[ "$os_id" == 'debian' ]] || { _prog_not_found; return 1; }

	case "$1" in
		firmware-ralink) sudo apt install firmware-ralink -y;;
		firmware-atheros) sudo apt install firmware-atheros -y;;
		firmware-realtek) sudo apt install firmware-realtek -y;;
		firmware-linux-nonfree) sudo apt install firmware-linux-nonfree -y;;
	esac
}

#=====================================================#
# Debian Bluetooth
#=====================================================#
function _bluetooth()
{
	[[ "$os_id" == 'debian' ]] || { _prog_not_found; return 1; }

	sudo apt install -y bluez bluez-firmware bluez-hcidump
	_info_msgs 'INFO'
	echo "==> 1 - $(_c 32 0)G$(_c)NOME"
	echo "==> 2 - $(_c 32 0)K$(_c)DE"
	echo "==> 3 - $(_c 32 0)L$(_c)XDE/$(_c 32 0)X$(_c)FCE/$(_c 32 0)L$(_c)XQT/$(_c 32 0)M$(_c)ATE"
	
	while true; do

		echo "==> Selecione a sua interface gráfica: $(_c 32 0)(1 / 2 / 3): $(_c)" 
		read -n 1 input; echo ' '
		case "${input,,}" in
			1) sudo apt install gnome-bluetooth;;
			2) sudo apt install bluedevil;;
			3) sudo apt install blueman;;
			*) 
			echo "$(_c 31)==> Opição inválida, você pode $(_c 32)repetir$(_c) ou $(_c 32)cancelar$(_c) (r/c): " 
			read -n 1 input; echo ' '
			if [[ "${input,,}" == 'r' ]]; then
				continue
			elif [[ "${input,,}" == 'c' ]]; then
				return 0; break
			else
				continue
			fi		
			;;
		esac	
		break	
	done
}

#=====================================================#
# Gparted
#=====================================================#
function _gparted()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y gparted

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y gparted

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y gparted

	else
		_prog_not_found; return 1

	fi

}

#=====================================================#
# PeaZip
#=====================================================#
function _peazip()
{
peazip_server='https://osdn.net/dl/peazip'
peazip_pag='https://osdn.net/projects/peazip/downloads'

peazip_html=$(wget -q "$peazip_pag" -O- | grep -m 1 "portable.*tar.gz" | awk '{print $6}')
peazip_pacote=$(echo "$peazip_html" | sed 's/.*peazip_portable/peazip_portable/g;s/\/\".*//g')
peazip_url_download="$peazip_server/$peazip_pacote"
local path_arq="$dir_user_cache/$peazip_pacote"

_dow "$peazip_url_download" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	
	[[ -x $(command -v peazip 2> /dev/null) ]] && { _msg_pack_instaled 'peazip'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"

[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv -v $(ls -d peazip*) "$dir_temp/peazip-amd64" 1> /dev/null
chmod -R +x "$dir_temp/peazip-amd64"

sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.desktop "${array_peazip_dirs[0]}" # .desktop
sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.png "${array_peazip_dirs[1]}" # PNG.
sudo mv "$dir_temp"/peazip-amd64/peazip "${array_peazip_dirs[2]}" # binario.
sudo mv "$dir_temp"/peazip-amd64 "${array_peazip_dirs[3]}" # dir.

if [[ -x $(which peazip 2> /dev/null) ]]; then
	_info_msgs; echo "==> peazip instalado com sucesso."
	return 0

else
	echo "$(cor 31)==> $(cor)Falha"
	return 1

fi
}

#-----------------------------------------------------#

#=====================================================#
# Vitualbox
#=====================================================#

function _virtualbox_downloads()
{
local vbox_pag_linux='https://www.virtualbox.org/wiki/Linux_Downloads'
local vbox_html_linux=$(wget -q -O- "$vbox_pag_linux" | egrep '(amd64.deb|x86_64.rpm|amd64.run)')

local vbox_url_buster=$(echo "$vbox_html_linux" | egrep -m 1 'buster' | sed 's/.*href=\"//g;s/\".*//g') # Deb10
local vbox_url_bionic=$(echo "$vbox_html_linux" | egrep -m 1 'bionic' | sed 's/.*href=\"//g;s/\".*//g') # Ubu18.04
local vbox_url_f29=$(echo "$vbox_html_linux" | egrep -m 1 'fedora29' | sed 's/.*href=\"//g;s/\".*//g') # F29
local vbox_url_run=$(echo "$vbox_html_linux" | egrep -m 1 'amd64.run' | sed 's/.*href=\"//g;s/\".*//g') # .run

local path_arq_buster="$dir_user_cache/$(basename $vbox_url_buster)"
local path_arq_bionic="$dir_user_cache/$(basename $vbox_url_bionic)"
local path_arq_f29="$dir_user_cache/$(basename $vbox_url_f29)"
local path_arq_run="$dir_user_cache/$(basename $vbox_url_run)"

	_dow "$vbox_url_buster" "$path_arq_buster" --curl
	_dow "$vbox_url_bionic" "$path_arq_bionic" --curl
	_dow "$vbox_url_f29" "$path_arq_f29" --curl
	_dow "$vbox_url_run" "$path_arq_run" --curl
}

#-----------------------------------------------------#

function _virtualbox_extpack()
{
local vbox_pag="https://www.virtualbox.org/wiki/Downloads"
local vbox_html=$(wget -q -O- "$vbox_pag" | grep -m 1 "Oracle.*Ext.*vbox.*") # Html filtrado.
local url_extpack=$(echo "$vbox_html" | sed 's/.*href=\"//g;s/\".*//g') # Url filtrado.
local path_arq="$dir_user_cache/$(basename $url_extpack)" # Destion/Arquivo.

	_dow "$url_extpack" "$path_arq" --curl || { 
		echo "$(_c 31)==> Falha  ao tentar baixar ExtensionPackc$(_c)"; return 1; 
	}	

# --downloadonly
[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }

# Instalação
echo "$(_c 32)==> $(_c)Instalando Extension Pack"
sudo VBoxManage extpack install --replace "$arq_extpack"

echo -ne "$(cor 32)==> $(cor)Deseja adicionar $USER ao grupo vboxusers ? $(cor 33)[s/n]$(cor) : " 
read acao 

	[[ "${acao,,}" == 's' ]] && { 
		sudo gpasswd -a $USER vboxusers  
		# sudo usermod -a -G vboxusers $USER
		read -p 'OK: pressione enter : ' enter
	}
}

#-----------------------------------------------------#

function _virtualbox_fedora()
{
local lista_vbox_fedora=(
'libgomp' 'glibc-headers' 'glibc-devel' 'kernel-headers' 'dkms' 'qt5-qtx11extras' 
'libxkbcommon' 'kernel-devel' 'binutils' 'gcc' 'make' 'patch'
)

sudo sh -c 'wget http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo -O /etc/yum.repos.d/virtualbox.repo'
sudo dnf update
sudo dnf install -y "${lista_vbox_fedora[@]}"
sudo dnf install -y $(rpm -qa kernel | sort -V |tail -n 1)
sudo yum install -y kernel-devel-$(uname -r) 
sudo dnf install -y VirtualBox-6.0

# Módulos
sudo sh -c '/usr/lib/virtualbox/vboxdrv.sh setup'
sudo sh -c '/sbin/vboxconfig'
_virtualbox_extpack
}

#-----------------------------------------------------#

function _virtualbox_bionic()
{
local vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib"
local vbox_file="/etc/apt/sources.list.d/virtualbox.list"

	# Limpar o cache antes de adicionar as chaves (recomendado).
	read -p "$(_c 32)==> $(_c)Deseja limpar o cache do $(_c 35)apt$(_c) [s/n] ?: " input
	if [[ "${input,,}" == 's' ]]; then
		sudo apt-get clean
		sudo rm -rf /var/lib/apt/lists/* 1> /dev/null 2> /dev/null
		sudo apt update
	fi
	
find /etc/apt -name *.list | xargs grep "^deb .*download\.virtualbox\.org.*debian bionic contrib$" 2> /dev/null
if [[ "$?" == '0' ]]; then # Pular
	echo "$(_c 32 0)==> $(_c)Repositório já disponível $(_c 32 0)'pulando'$(_c)"

else
	echo "$(_c 32)==> $(_c)Adicionando chaves e repositório"
	sudo sh -c 'wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -'
	sudo sh -c 'wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -'
	echo "$vbox_repo" | sudo tee "$vbox_file" # Repositório.
fi
	sudo apt update
	
	# Dependências
	echo "$(cor 32)==> $(cor)Instalando dependências"
	sudo sh -c 'apt install -y module-assistant build-essential dkms; apt install -y linux-headers-$(uname -r)'
	
	# Virtualbox 6.0
	echo "$(_c 32)==> $(_c)Instalando virtualbox"
	sudo apt install -y virtualbox-6.0
	_virtualbox_extpack
}

#-----------------------------------------------------#

function _virtualbox_buster()
{
local vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib"
local vbox_file="/etc/apt/sources.list.d/virtualbox.list"

	# Limpar o cache antes de adicionar as chaves (recomendado).
	read -p "$(_c 32)==> $(_c)Deseja limpar o cache do $(_c 35)apt$(_c) [s/n] ?: " input
	if [[ "${input,,}" == 's' ]]; then
		sudo apt-get clean
		sudo rm -rf /var/lib/apt/lists/* 1> /dev/null 2> /dev/null
		sudo apt update
	fi
	
find /etc/apt -name *.list | xargs grep "^deb .*download\.virtualbox\.org.*debian buster contrib$" 2> /dev/null
if [[ "$?" == '0' ]]; then # Pular
	echo "$(_c 32 0)==> $(_c)Repositório já disponível $(_c 32 0)'pulando'$(_c)"

else
	echo "$(_c 32)==> $(_c)Adicionando chaves e repositório"
	sudo sh -c 'wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -'
	sudo sh -c 'wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -'
	echo "$vbox_repo" | sudo tee "$vbox_file" # Repositório.
fi
	sudo apt update
	
	# Dependências
	echo "$(cor 32)==> $(cor)Instalando dependências"
	sudo sh -c 'apt install -y module-assistant build-essential dkms; apt install -y linux-headers-$(uname -r)'
	
	# Virtualbox 6.0
	echo "$(_c 32)==> $(_c)Instalando virtualbox"
	sudo apt install -y virtualbox-6.0
	_virtualbox_extpack
}


#-----------------------------------------------------#

function _virtualbox()
{
	# --downloadonly -> Baixar e sair.
	[[ "$download_only" == 'on' ]] && { _virtualbox_downloads; _virtualbox_extpack; return "$?"; }

	case "$sysname" in
		debian10) _virtualbox_buster;;
		thirty|thirty_one) _virtualbox_fedora;;
		leap) _virtualbox_leap;;
		*) _prog_ind;;	
	esac
}
