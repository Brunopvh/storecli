#!/usr/bin/env bash
#
VERSION='2020-04-11'
# archutils.sh /dev/sda2 /dev/sda7
#
# pacstrap /mnt base #base-devel
# genfstab -U -p /mnt >> /mnt/etc/fstab
# 
#
#
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

Red='\033[1;31m'
Green='\033[1;32m'
Yellow='\033[1;93m'
White='\033[1;37m'
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
esac

#=============================================================#
partition_efi="$1"
partiton_root="$2"


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
array_pkgs_base=(
	'dosfstools'
	'mtools'
	'network-manager-applet'
	'networkmanager'
	'wpa_supplicant'
	'wireless_tools'
	'dhclient'
	'sudo'
	'dialog'
	'ntfs-3g'
	'curl'
	'git'
	'vim'
)

array_laptop_utils=(
	'acpi' 'acpid'
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
_PACMAN()
{
	# Usar o gerenciador de pacotes do arch para instalar pacotes
	# e retornar '0' ou '1'.
	if sudo pacman "$@"; then
		return 0
	else
		return 1
	fi
}
#=============================================================#
_YESNO()
{
	text="$1"
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
_isroot()
{
	if [[ $(id -u) == '0' ]]; then
		return 0
	else
		return 1
	fi
}

_ismount()
{
	# Se o dispositivo estiver montado retorna '0', se não retorna '1'.
	# USE _ismount "$1"
	device="$1"

	# Um dispositivo do tipo /dev/sdXy tem 9 caracteres
	# Validar o tamanho de caracteres.
	if [[ "${#device}" < '9' ]]; then 
		_red "Informe um dispositivo do tipo /dev/sdXy"
		return 1
	fi

	# Procurar o ponto de montagem
	proc_device=$(grep "$device" '/proc/mounts' | awk '{print $1}')

	if [[ "$proc_device" == "$device" ]]; then
		return 0
	else
		return 1
	fi
}

#=============================================================#
_UMOUNT_DEV()
{
	# Desmontar um dispositivo.
	# $1 = device a ser desmontado
	# USE _UMOUNT_DEV "$1"

	_msg "Desmontando [$1]"
	if ! _isroot; then
		_red "Você precisa ser 'root'"
		return 1
	fi

	# Desmontar
	if umount "$1"; then
		_msg "[$1] desmontado com sucesso"
		return 0
	else
		_red "Falha ao tentar desmontar [$1]"
		return 1
	fi
}

#=============================================================#
_MOUNT_DEVICE()
{
	# USE _MOUNT_DEVICE device mount_point
	_msg "Montando [$1] em [$2]"
	if ! _isroot; then
		_red "Você precisa ser 'root'"
		return 1
	fi

	# Montar
	if mount "$1" "$2"; then
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
	
	_msg "Formatando [$1] como FAT32"
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

	_msg "Formatando $1 como ext4"
	mkfs.ext4 -L "$label" "$device"
}

#=============================================================#
_configure_base()
{
	local url='https://github.com/Brunopvh/apps-buster/archive/master.tar.gz'

	if ! _isroot; then
		_red "Você precisa ser 'root' para realizar está operação"
		return 1
	fi

	# Formatar dispositivo EFI
	if _YESNO "Deseja formatar $partition_efi com FAT32"; then
		_YESNO "Tem certeza que deseja formatar $partition_efi" && {
			_FORMAT_FAT "$partition_efi"
		}
	fi

	# Formatar partição onde o sistema será instalado.
	if _YESNO "Deseja formatar $partiton_root como EXT4"; then 
		_FORMAT_EXT4 "$partiton_root" 'ARCHLINUX'
	fi

	_msg "Criando /mnt/boot"; mkdir -p "/mnt/boot"
	_msg "Criando /mnt/boot/efi"; mkdir -p "/mnt/boot/efi"

	_msg "Montando $partiton_root em [/mnt]"
	_MOUNT_DEVICE "$partiton_root" '/mnt' 

	_msg "Montando partição EFI [$partition_efi] em /mnt/boot/efi"
	_MOUNT_DEVICE "$partition_efi" "/mnt/boot/efi" 

	# Pacstrap
	_msg "Executando [pacstrap /mnt base base-devel]"
	pacstrap /mnt base 'base-devel' linux 'linux-firmware'

	# Configuar FSTAB.
	_yellow "Configurando fstab [genfstab -U -p /mnt >> /mnt/etc/fstab]"
	genfstab -p /mnt >> /mnt/etc/fstab

	_msg "Executando [arch-chroot /mnt /bin/bash]"
	_green "Execute os comandos a seguir para proxima fase"
	_msg "curl -LS $url -o apps-buster.tar.gz"
	_msg "tar -zxvf apps-buster.tar.gz"
	_msg "chmod -R +x apps-buster; ./apps-buster/scripts/archutils.sh"
	
	arch-chroot /mnt /bin/bash

}

_configure_POSBASE()
{
	# /usr/share/zoneinfo/America/Porto_Velho
	if ! _isroot; then
		_red "Você precisa ser 'root' para realizar está operação"
		return 1
	fi

	_msg "Executando [ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime]"
	ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime

	# Idioma pt_BR.UTF-8
	_green "Executando  sed -i 's/# pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen"
	cp '/etc/locale.gen' '/etc/locale.gen.backup'
	sed -i 's/# pt_BR.UTF-8 UTF-8/pt_BR.UTF-8 UTF-8/g' '/etc/locale.gen'

	echo 'LANG="pt_BR.UTF-8"' > '/etc/locale.conf'
	echo 'KEYMAP=br-abnt2' > '/etc/vconsole.conf'

	_yellow "Executando [locale-gen]"
	locale-gen

	# Hostname
	echo "$Yellow"
	read -p "-> Digite um HOSTENAME para sua máquiana: " hname
	_green "Usando este hostname $hname"
	echo "$hname" > '/etc/hostname'

	_green "Configurando /etc/hosts"
	echo '127.0.0.1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo '::1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo -e "127.0.0.1	${hname}.localdomain	$hname" >> '/etc/hosts'

	_green "Executando pacman -S wireless_tools wpa_supplicant wpa_actiond dialog"
	pacman -S wireless_tools wpa_supplicant wpa_actiond dialog

	_msg "Executando pacman -Syy"
	pacman -Syy

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

	_msg "Executando pacman -S grub os-prober efibootmgr"
	pacman -S grub 'os-prober' efibootmgr 

	_msg "Executando grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=ArchLinux --recheck"
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck

	_msg "Executando grub-mkconfig -o /boot/grub/grub.cfg"
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

	echo "systemctl status NetworkManager"
	echo "systemctl start NetworkManager"
	echo "systemctl enable NetwokrManager"
	echo "systemctl enable gdm"
}

_install_gnome()
{
	for c in "${array_pkgs_base[@]}"; do
		echo -e "$scpace_line"
		_green "Instalando: $c"
		pacman -S "$c"
	done

	_msg "Instalando: ${array_laptop_utils[@]}"
	pacman -S "${array_laptop_utils[@]}"

	for c in "${array_gnomeshell[@]}"; do
		echo -e "$scpace_line"
		_green "Instalando: $c"
		pacman -S "$c"
	done


	systemctl enable NetwokrManager
	systemctl enable gdm

	_yellow "Execute as ações a seguir manualmente"
	_yellow "Criar seu usuário useradd -m seu_nome; passwd seu_nome"
	_yellow "usermod -aG wheel"
	_yellow "Edite o arquivo visudo"
	
	_yellow "umount -R /mnt"
}

#=============================================================#
main()
{

	_msg "Selecine uma opição"
	_msg "1 - Instalar base ARCH"
	_msg "2 - Instalar POS BASE - (opição usada após o arch-chroot)"
	_msg "3 - Instalar Grub"
	_msg "4 - Instalar gnome-shell"
	read op

	case "$op" in
		1) _configure_base "$@";;
		2) _configure_POSBASE "$@";;
		3) _install_grub;;
		4) _install_gnome;;
	esac

}

main "$@"

#=============================================================#
