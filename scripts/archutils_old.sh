#!/usr/bin/env bash
#
VERSION='2020-05-30'
#
#--------------------------| INFORMAÇÃOES |----------------------#
# Este programa serve para automatizar a instalação do archlinux
# em maquinas UEFI com idioma PTBR UTF 8.
#
# USO: 
#      archutils.sh /dev/sdXY /dev/sdXZ
#
#      /dev/sdXY = partição UEFI
#      /dev/sdXZ = partição do sistema "/"
#      
#----------------------------------------------------------------#
# pacstrap /mnt base #base-devel
# genfstab -U -p /mnt >> /mnt/etc/fstab
# 
#
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
# grub-mkconfig -o /boot/grub/grub.cfg
#
# systemctl status NetworkManager
# systemctl start NetworkManager
# systemctl enable NetwokrManager
# systemctl enable gdm
#
# pacman -Sy
# pacman -S xorg-server
#
# TECLADO
# localectl list-keymaps
# localectl set-keymap --no-convert br-abnt2 
#
# sudo setxkbmap -model abnt2 -layout br -variant abnt2
# sudo nano /etc/X11/xorg.conf.d/10-evdev.conf
#
# Fontes para o Sistema
# sudo pacman -S ttf-dejavu ttf-liberation noto-fonts
#
#------------------------------------------------------------------#
# REFERENCIAS
#------------------------------------------------------------------#
# https://wiki.archlinux.org/index.php/Linux_console_(Portugu%C3%AAs)/Keyboard_configuration_(Portugu%C3%AAs)
# https://www.vivaolinux.com.br/dica/Teclado-ABNT2-definitivo-no-Archlinux
#

scpace_line='=========================================================='

Red='\033[0;31m'
Green='\033[0;32m'
Yellow='\033[0;33m'
White='\033[0;37m'
Reset='\033[m'

#=============================================================#
_c()
{
	if [[ -z $2 ]]; then
		echo -e "\033[1;$1m"
	elif [[ $2 ]]; then
		echo -e "\033[$2;$1m"
	fi
}

#=============================================================#

_msg()
{
	echo -e "[>] $@"
}

_red()
{
	echo -e "${Red}[!] $@${Reset}"
}

_green()
{
	echo -e "${Green}[*] $@${Reset}"
}

_yellow()
{
	echo -e "${Yellow}[+] $@${Reset}"
}

#=============================================================#
usage()
{
cat << EOF
      USE: $(basename $0) <partição efi> <partição root>
      Exemplo:
           $(basename $0) /dev/sda1 /dev/sda3

      Sendo: 
          sda1 -> Partição efi.
          sda3 -> local onde o sistema será instalado.
EOF
}

case "$1" in
	-h|--help) usage; exit;;
	-v|--version) echo -e "$(basename $0) V${VERSION}"; exit;;
esac

echo -e "$(basename $0) V${VERSION}"

#=============================================================#
partition_efi="$1"
partiton_root="$2"

url_storecli='https://github.com/Brunopvh/storecli/archive/master.tar.gz'

# Verificar conexão com a internet.
echo -ne "[>] Aguardando conexão "
if ping -c 2 8.8.8.8 1> /dev/null; then
	echo "[Conectado]"
else
	echo ' '
	_red "Falha - AVISO: você está OFF-LINE"
	_red "Use: wifi-menu para se conectar a uma rede WIFI"
	read -p "Pressione enter: " enter
fi

#=============================================================#
# Arrays
#=============================================================#
# Pacotes básicos que estão nos repositórios do arch.
#
array_pkgs_base=(
	'dosfstools'
	'mtools'
	'network-manager-applet'
	'networkmanager'
	'wpa_supplicant'
	'wireless_tools'
	'wpa_actiond'	
	'dhclient'
	'sudo'
	'dialog'
	'ntfs-3g'
	'curl'
	'git'
	'vim'
)

array_laptop_utils=(
	'acpi' 
	'acpid'
)

# Pacotes para instalação do gnome-shell no arch.
array_gnomeshell=(
	'xorg-server'
	'xf86-video-video-intel'
	'libgl'
	'mesa'
	'gdm'
	'gnome'
	'gnome-terminal'
	'nautilus'
	'gnome-control-center'
	'adwaita-icon-theme'
)

#=============================================================#
_isroot()
{
	if [[ $(id -u) == '0' ]]; then
		return 0
	else
		return 1
	fi
}

#=============================================================#

_PACMAN()
{
	# Usar o gerenciador de pacotes do arch para instalar pacotes
	# e retornar '0' ou '1'.

	if ! _isroot; then
		_red "Você precisa ser o 'root'"
		return 1
	fi


	if pacman -S --neededs "$@"; then
		return 0
	else
		return 1
	fi
}
#=============================================================#
_YESNO()
{
	# Função para indagações do tipo sim ou não que retorna '0'
	# se o usuário responder 's' ou '1' se o usuário responder 'n'.
	# O texto a ser exibido deve ser passado no parametro '1' ($1)

	local text="$1"
	_green "${text} [${Yellow}s${Reset}/${Red}n${Reset}]?: "
	read -t 10 -n 1 sn
	echo ' '
	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		return 1
	fi
}

#=============================================================#

_ismount()
{
	# Se o dispositivo estiver montado retorna '0', se não retorna '1'.
	# USE _ismount "$1"
	local partition="$1"

	# Uma partição montada do tipo /dev/sdXy tem 9 caracteres validar o tamanho de caracteres.
	if [[ "${#partition}" < '9' ]]; then 
		_red "Informe uma partição do tipo /dev/sdXy"
		return 1
	fi

	# Procurar o ponto de montagem
	proc_device=$(grep "$partition" '/proc/mounts' | awk '{print $1}')

	if [[ "$proc_device" == "$partition" ]]; then
		return 0
	else
		return 1
	fi
}

#=============================================================#
_UMOUNT_DEV()
{
	# Desmontar uma partição montada.
	# $1 = partição a ser desmontada
	# USE _UMOUNT_DEV "$1"
	local partition="$1"

	_yellow "Desmontando: $partition"
	if ! _isroot; then
		_red "Você precisa ser 'root'"
		return 1
	fi

	if ! _ismount "$partiton"; then
		_red "Partição não montada: $patition"
		return 1
	fi

	# Desmontar
	if umount "$partiton"; then
		_yellow "Desmontado com sucesso: $patition"
		return 0
	else
		_red "Falha ao tentar desmontar: $partiton"
		return 1
	fi
}

#=============================================================#
_MOUNT_DEVICE()
{
	# USE _MOUNT_DEVICE partiton mount_point
	local partition="$1"
	local mount_point="$2"

	_yellow "Montando [$partition] em [$mount_point]"
	if ! _isroot; then
		_red "Você precisa ser 'root'"
		return 1
	fi

	# Montar
	if mount "$partiton" "$mount_point"; then
		return 0
	else
		return 1
	fi
}

#=============================================================#
_FORMAT_FAT()
{
	# mkfs.vfat -F32 /dev/sdx1
	# mkfs -t vfat /dev/sdb1
	# eject /dev/sdb1
	# USE _FORMAT_FAT device

	# Desmontar caso esteja montado
	if _ismount "$1"; then 
		_UMOUNT_DEV "$1" || return 1
	fi
	
	_yellow "Formatando [$1] como FAT32"
	if ! _isroot; then
		_red "Você precisa ser 'root'"
		return 1
	fi
	mkfs.vfat -F32 "$1"
}

_FORMAT_EXT4()
{
	# Formatar uma partição com ext4
	# USE _FORMAT_EXT4 devicie label
	local device="$1"
	local label="$2"

	_yellow "Formatando $1 como ext4"
	mkfs.ext4 -L "$label" "$device"
}

#=============================================================#
_configure_base()
{
	# PART 1
	# Formatar partições, montar partições e gerar fstab.

	if ! _isroot; then
		_red "Você precisa ser 'root' para realizar está operação"
		return 1
	fi

	
	if _YESNO "Deseja formatar $partition_efi como FAT32"; then
		_YESNO "Tem certeza que deseja formatar $partition_efi" && {
			_FORMAT_FAT "$partition_efi"
		}
	fi

	
	if _YESNO "Deseja formatar $partiton_root como EXT4"; then 
		_FORMAT_EXT4 "$partiton_root" 'ARCHLINUX'
	fi

	_yellow "Criando /mnt/boot"; mkdir -p "/mnt/boot"
	_yellow "Criando /mnt/boot/efi"; mkdir -p "/mnt/boot/efi"

	_yellow "Montando $partiton_root em /mnt"
	_MOUNT_DEVICE "$partiton_root" '/mnt' 

	_yellow "Montando partição EFI [$partition_efi] em /mnt/boot/efi"
	_MOUNT_DEVICE "$partition_efi" "/mnt/boot/efi" 

	# Pacstrap
	_yellow "Executando: pacstrap /mnt base base-devel"
	pacstrap /mnt base 'base-devel' linux 'linux-firmware'

	# Configuar FSTAB.
	_yellow "Configurando fstab [genfstab -U -p /mnt >> /mnt/etc/fstab]"
	genfstab -p /mnt >> /mnt/etc/fstab

	_yellow "Executando: arch-chroot /mnt /bin/bash"
	echo -e "$space_line"
	_green "Execute os comandos a seguir para proxima fase"
	_green "curl -LS $url_storecli -o storecli.tar.gz"
	_green "tar -zxvf storecli.tar.gz"
	_green "chmod -R +x storecli; ./storecli/scripts/archutils.sh"
	
	arch-chroot /mnt /bin/bash

}

_configure_POSBASE()
{
	# PART 2
	# /usr/share/zoneinfo/America/Porto_Velho
	if ! _isroot; then
		_red "Você precisa ser 'root' para realizar está operação"
		return 1
	fi

	_yellow "Executando: ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime"
	ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime

	# Idioma pt_BR.UTF-8
	_yellow "Criando backup de /etc/locale.gen em /etc/locale.gen.backup"
	cp '/etc/locale.gen' '/etc/locale.gen.backup' # Criar backup

	_yellow "Executando  sed -i 's/# pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen"
	sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' '/etc/locale.gen'

	_yellow "Configurando: pt_BR.UTF-8 em /etc/locale.conf"
	echo 'LANG="pt_BR.UTF-8"' > '/etc/locale.conf'

	_yellow "Configurando: KEYMAP=br-abnt2 em /etc/vconsole.conf"
	echo 'KEYMAP=br-abnt2' > '/etc/vconsole.conf'

	_yellow "Executando [locale-gen]"
	locale-gen

	# Hostname
	_yellow "Digite um HOSTENAME para sua máquina: "
	read host_name
	_yellow "Usando este hostname $host_name"
	echo "$host_name" > '/etc/hostname'

	_yellow "Configurando /etc/hosts"
	echo '127.0.0.1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo '::1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo -e "127.0.0.1	${hname}.localdomain	$hname" >> '/etc/hosts'

	_yellow "Executando pacman -Syy"
	pacman -Syy

	for X in "${array_pkgs_base[@]}"; do
		echo -e "$space_line"
		_green "Instalando: $X"
		if ! _PACMAN "$X"; then
			_red "Falha: $X"
			sleep 1
		fi
	done

	echo -e "$space_line"
	_green "Para finalizar defina sua senha de ${Red}root${Reset} com o comando passwd"
	_green "Também e recomendado habilitar o multilib em /etc/pacman.conf"
	_green "Em seguida execute este programa novamente e escolha a opição 3 no menu"
}

#=============================================================#
_install_grub()
{
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
# grub-mkconfig -o /boot/grub/grub.cfg

	if ! _isroot; then
		_red "Você precisa ser 'root' para realizar está operação"
		return 1
	fi

	_yellow "Executando pacman -S grub os-prober efibootmgr"
	if ! _PACMAN grub 'os-prober' efibootmgr; then
		_red "Falha: grub os-prober efibootmgr"
		return 1
	fi 

	_yellow "Executando grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck"
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck

	_yellow "Executando grub-mkconfig -o /boot/grub/grub.cfg"
	grub-mkconfig -o /boot/grub/grub.cfg

	_yellow "Execute este programa novamente e selecione a opição 4 no menu"
}

#=============================================================#

_configure_systemctl()
{
	# systemctl status NetworkManager
	# systemctl start NetworkManager
	# systemctl enable NetwokrManager
	# systemctl enable gdm

	#_yellow "Executando: systemctl status NetworkManager"
	_yellow "systemctl start NetworkManager"; systemctl start NetworkManager
	_yellow "systemctl enable NetwokrManager"; systemctl enable NetwokrManager
	_yellow "systemctl enable gdm"; systemctl enable gdm
}

_install_gnome()
{
	for c in "${array_pkgs_base[@]}"; do
		echo -e "$scpace_line"
		_yellow "Instalando: $c"
		if ! _PACMAN "$c"; then
			_red "Falha: $c"
			sleep 1
		fi
	done

	#_yellow "Instalando: ${array_laptop_utils[@]}"
	#pacman -S "${array_laptop_utils[@]}"

	for c in "${array_gnomeshell[@]}"; do
		echo -e "$scpace_line"
		_yellow "Instalando: $c"
		if ! _PACMAN "$c"; then
			_red "Falha: $c"
			sleep 1
		fi
	done


	_configure_systemctls

	echo -e "$space_line"
	_yellow "Execute as ações a seguir manualmente"
	_yellow "Criar seu usuário useradd -m seu_nome; passwd seu_nome"
	_yellow "usermod -aG wheel"
	_yellow "Edite o arquivo visudo"
	_yellow "umount -R /mnt"
	echo ' '
}

#=============================================================#
main()
{

	_yellow "MENU PRINCIPAL"
	_green "1 - Instalar base ARCH"
	_green "2 - Instalar POS BASE - (opição usada após o arch-chroot)"
	_green "3 - Instalar Grub"
	_green "4 - Instalar gnome-shell"
	read -p "Digite um número e pressione enter: " op

	case "$op" in
		1) _configure_base "$@";;
		2) _configure_POSBASE "$@";;
		3) _install_grub;;
		4) _install_gnome;;
		*) exit 0;;
	esac

}

main "$@"

#=============================================================#
