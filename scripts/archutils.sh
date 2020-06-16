#!/usr/bin/env bash
#
VERSION='2020-06-16'
# 
# Uso:
# $0 -t /dev/sdX -e /dev/sdaE -h /dev/sdaH -r /dev/sdaR -b /sdaB
#
# sdX = partição alvo da instalação Ex: /dev/sda, /dev/sdb ... (NÃO USE PARTIÇÃO SOMENTE O DISPOSITIVO)
# sdaE = partição onde será configurado EFI. Ex: /dev/sda2 (OPCIONAL caso use bios MBR)
# sdaH = partição da home. Ex: /dev/sda4 (OPCIONAL)
# sdaB = partição de boot. Ex: /dev/sda5 (OPCIONAL)
# sdaR = partição raiz. Ex: /dev/sda6 (OBRIGATÓRIO)
#
# caso queira instalar o sistema em apenas uma partição use: $0 -t <disk> -r <partição>
# ou em sistemas EFI use: $0 -e <partição> -r <partição>
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
#------------------------------------------------------------------#
# TECLADO
#------------------------------------------------------------------#
# localectl list-keymaps
# localectl set-keymap --no-convert br-abnt2 
#
# sudo setxkbmap -model abnt2 -layout br -variant abnt2
# sudo nano /etc/X11/xorg.conf.d/10-evdev.conf
#
# Fontes para o Sistema
# sudo pacman -S ttf-dejavu ttf-liberation noto-fonts
# 
#
#------------------------------------------------------------------#
# REFERÊNCIAS
#------------------------------------------------------------------#
# https://wiki.archlinux.org/index.php/Linux_console_(Portugu%C3%AAs)/Keyboard_configuration_(Portugu%C3%AAs)
# https://www.vivaolinux.com.br/dica/Teclado-ABNT2-definitivo-no-Archlinux
# https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options
# https://www.dicas-l.com.br/arquivo/fatiando_opcoes_com_o_getopts.php
#

clear

CRed='\033[0;31m'
CGreen='\033[0;32m'
CYellow='\033[0;33m'
CBlue='\033[0;34m'
CWhite='\033[0;37m'
CReset='\033[m'

space_line='--------------------------------------------------------'

_space_text()
{
	local __space__='-'
	local num="$((45-$1))" # Subtrair (45) - (tamanho da string recebida com $@) 
	
	for n in $(seq "$num"); do
		__space__="${__space__}-"
	done
	echo -ne "${__space__}>"
}

_msg()
{
	num="${#1}" # Tamanho da string 1 que será passado para função '_space_text'.

	echo -ne "${CYellow}[>] ${1} " 
	_space_text "$num"  # Echoar o espaçamento.
	echo -e "${CGreen} $2${CReset}"
}

_red()
{
	echo -e "${CRed}[!] $@${CReset}"
}

_green()
{
	echo -e "${CGreen} * $@${CReset}"
}

_yellow()
{
	echo -e "${CYellow}[+] $@${CReset}"
}

_blue()
{
	echo -e "${CBlue} * $@${CReset}"
}

_white()
{
	echo -e "${CWhite} > $@${CReset}"
}

#=======================================================#
usage()
{
cat << EOF
     Use:
      $(basename "$0") -t <device> -r <partition>

      -b          BOOT, partição para /boot (OPCIONAL).
      -e          EFI, partição para /boot/efi (Usar apenas em sistemas efi).
      -H          HOME, partição para /home (OPICIONAL).
      -r          ROOT, partição raiz do sistema / (OBRIGATÓRIO).
      -t          TARGET, disco alvo para instalação (/dev/sdX - OBRIGATÓRIO).

      -h          Mostra ajuda

          Supondo que você queira instalar o sistema em /dev/sda com a partição efi
          em /dev/sda2 e com raiz em /dev/sda3 use o comando:

          $(basename "$0") -t /dev/sda -e /dev/sda2 -r /dev/sda3

EOF
}


function _YESNO()
{
	echo -ne "[>] ${@} [${CGreen}s${CReset}/${CRed}n${CReset}]: ${CReset}"
	read -t 30 -n 1 yesno
	echo ' '

	case "${yesno,,}" in
		s|S|y|Y) return 0;;
		n|N) return 1;;
		*) _red "Opção inválida: $yesno"; return 1;;
	esac 
}


# Necessário ser root.
if [[ $(id -u) != '0' ]]; then
	_red "Você tem que ser 'root'"
	exit 1
fi

TempDir='/tmp/archutils'; mkdir -p "$TempDir"
LogInfo="$TempDir/Info.log"
LogErro="$TempDir/Erro.log"
FileTemp="$TempDir/Tempfile.txt"
url_storecli='https://github.com/Brunopvh/storecli/archive/master.tar.gz'
url_archutils='https://raw.github.com/Brunopvh/storecli/master/scripts/archutils.sh'

declare -A DiskInfoTarget
DiskInfoTarget=() # Array com informações do disco selecionado para instalação.
CliArguments=()

OPTIND=1
num=0

while getopts :b:e:H:r:t:h Arg; do
	case "$Arg" in
		b) DiskInfoTarget[partition_boot]="$OPTARG";;    # /boot - Opcional
		e) DiskInfoTarget[partition_efi]="$OPTARG";;     # /efi - Opcional se for do tipo MBR.
		H) DiskInfoTarget[partition_home]="$OPTARG";;    # /home - Opcional
		r) DiskInfoTarget[partition_root]="$OPTARG";;    # /
		t) DiskInfoTarget[instalation_disk]="$OPTARG";;  # disco - /dev/sda, /dev/sdb, /dev/sdc
		h) usage; exit;;
		\?)  _red "Opição inválida: $OPTARG"; exit 1;;
		\:)  _red "Falta(m) argumento(s) para uma ou mais opções."; exit 1;;
	esac
	CliArguments[$num]="$OPTARG"
	num+=1
done
 
#=======================================================#

function parse_disk_partitions()
{
	if [[ ! -e "${DiskInfoTarget[instalation_disk]}" ]]; then
		_red "Erro: informe um disco para instalação"; exit 1
	fi

	if [[ ! -e "${DiskInfoTarget[partition_root]}" ]]; then
		_red "Erro: informe uma partição raiz para instalação"; exit 1
	fi


	fdisk -l "${DiskInfoTarget[instalation_disk]}" > "$FileTemp"
	DiskInfoTarget[disk_table]=$(egrep -m 1 '(Tipo|Type|type)' "$FileTemp" | cut -d ':' -f 2 | sed 's/ //g')
	DiskInfoTarget[disk_len]=$(egrep -m 1 '(Disco|Disk)' "$FileTemp" | awk '{print $3,$4}')
	DiskInfoTarget[disk_len]="${DiskInfoTarget[disk_len]%%\,}"
}


parse_table_disk()
{
	# Se a tabela de partição do disco for GPT e o usuário não informar uma partição
	# para efi será exibida uma mensagem de erro.
	if [[ "${DiskInfoTarget[disk_table]}" == 'gpt' ]] && [[ ! -e "${DiskInfoTarget[partition_efi]}" ]]; then
		_red "O disco selecionado tem tabela de partição do tipo (gpt) informe uma partição para usar (EFI)"
		exit 1
	fi

	if [[ "${DiskInfoTarget[disk_table]}" != 'gpt' ]] && [[ ! -z "${DiskInfoTarget[partition_efi]}" ]]; then
		_red "O disco selecionado NÃO tem tabela de partição do tipo (GPT) você não pode usar (EFI)"
		exit 1
	fi
}

#=======================================================#

_ping()
{
	# Verificar conexão com a internet.
	echo -ne "[>] Aguardando conexão $(_space_text 18) "
	if ping -c 2 8.8.8.8 1> /dev/null; then
		echo "[Conectado]"
	else
		echo ' '
		_red "Falha - AVISO: você está OFF-LINE"
		_red "Use: wifi-menu para se conectar a uma rede WIFI"
		read -p "Pressione enter: " enter
	fi
}

_PACMAN()
{
	# _PACMAN -S --needed "$@"
	if pacman -S --noconfirm --needed "$@"; then
		return 0
	else
		_red "Erro: pacman $@"
		return 1
	fi
}

#=======================================================#
# Lista de pacotes utils para cli e interface gráfica.
#=======================================================#
pkgs_cli_utils=(
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
	'ttf-dejavu' 
	'ttf-liberation' 
	'noto-fonts'
)

pkgs_laptop_utils=(
	'acpi' 
	'acpid'
)

# Pacotes para instalação do gnome-shell no arch.
pkgs_gnomeshell=(
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


_ismount()
{
	# Se o dispositivo estiver montado retorna '0', se não retorna '1'.
	# Use _ismount "$1"
	local partition="$1"

	
	if ! ls "$1" 1> /dev/null 2&>1; then 
		_red "Informe uma partição do tipo /dev/sdXy"
		return 1
	fi

	# Procurar o ponto de montagem no arquivo /proc/mounts
	proc_partition_device=$(grep "$partition" '/proc/mounts' | awk '{print $1}')

	if [[ "$proc_partition_device" == "$partition" ]]; then
		return 0
	else
		return 1
	fi
}

#=============================================================#
_UMOUNT_PARTITION()
{
	# Desmontar uma partição montada.
	# $1 = partição a ser desmontada
	# USE _UMOUNT_PARTITION "$1"
	local partition="$1"

	_msg "Desmontando: " "$partition"
	
	if ! _ismount "$partiton"; then
		return 0
	fi

	# Desmontar
	if umount "$partiton"; then
		_yellow "$patition desmontada com sucesso"
		return 0
	else
		_red "Falha ao tentar desmontar: $partiton"
		return 1
	fi
}

#=============================================================#
_MOUNT_PARTITION()
{
	# USE _MOUNT_PARTITION partiton mount_point
	local partition="$1"
	local mount_point="$2"

	_msg "Montando $partition em " "$mount_point"
	
	# Montar
	if mount "$partiton" "$mount_point"; then
		return 0
	else
		_red "Erro: mount $partition $mount_point"
		sleep 0.5
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
	
	if ! _YESNO "Deseja formatar $1 como sistema de arquivos fat32"; then
		return 0
	fi

	# Desmontar a partição a ser formatada caso esteja montada.
	if _ismount "$1"; then 
		_UMOUNT_PARTITION "$1" || return 1
	fi
	mkfs.vfat -F32 "$1"
}


_FORMAT_EXT4()
{
	# Formatar uma partição com ext4
	# USE _FORMAT_EXT4 devicie label
	local device="$1"
	local label="$2"

	if ! _YESNO "Deseja formatar $device como ext4"; then
		return 0
	fi

	# Desmontar caso esteja montado
	if _ismount "$device"; then 
		_UMOUNT_PARTITION "$device" || return 1
	fi


	if [[ "$label" ]]; then
		mkfs.ext4 -L "$label" "$device"
	else
		mkfs.ext4 "$device"
	fi
}


_configure_partition_efi()
{
	# Configurar EFI em discos gpt
	[[ ! -e "${DiskInfoTarget[partition_efi]}" ]] && return 0

	_FORMAT_FAT "${DiskInfoTarget[partition_efi]}"
	
	_yellow "Criando /mnt/boot/efi"
	mkdir -p "/mnt/boot/efi"
	_MOUNT_PARTITION "${DiskInfoTarget[partition_efi]}" "/mnt/boot/efi" || return 1 
	return 0
}

_configure_partition_boot()
{
	# Se o usuário informar uma partição para /boot será montada na partição especificada.
	[[ ! -e "${DiskInfoTarget[partition_boot]}" ]] && return 0

	# Formatar e montar a partição /boot.
	_FORMAT_EXT4 "${DiskInfoTarget[partition_boot]}" 'ARCHBOOT'
	_MOUNT_PARTITION "${DiskInfoTarget[partition_boot]}" '/mnt/boot' || return 1
	return 0
}

_configure_partition_home()
{	
	# Se o usuário informar uma partição para /home ela sera montada com o comado abaixo.
	[[ ! -e "${DiskInfoTarget[partition_home]}" ]] && return 0	

	# Formatar e montar a partição /home.
	_FORMAT_EXT4 "${DiskInfoTarget[partition_home]}" 'ARCHHOME'
	_MOUNT_PARTITION "${DiskInfoTarget[partition_home]}" '/mnt/home' || return 1
	return 0
}

_configure_base_system()
{
	_yellow "Criando diretórios" 
	mkdir -p /mnt
	mkdir -p /mnt/boot
	mkdir -p /mnt/home

	# Formatar a partição raiz '/'. 
	_FORMAT_EXT4 "${DiskInfoTarget[partition_root]}" 'ARCHLINUX'
	_MOUNT_PARTITION "${DiskInfoTarget[partition_root]}" '/mnt' || return 1
	
	_configure_partition_home || return 1
	_configure_partition_boot || return 1
	_configure_partition_efi || return 1

	# Loadkeys
	_yellow "Configurando teclado como abnt2"
	loadkeys br-abnt2

	_yellow "Configurando idioma pt_BR.UTF-8"
	sed -i 's/^#pt_BR.UTF-8/pt_BR.UTF-8' /etc/locale.gen 2> "$LogErro"
	sed -i 's/^# pt_BR.UTF-8/pt_BR.UTF-8' /etc/locale.gen 2> "$LogErro"

	_yellow "Configurando horário do sistema"
	timedatectl set-ntp true

	# Pacstrap
	_yellow "Executando: pacstrap /mnt base base-devel linux linux-firmware"
	if ! pacstrap /mnt base 'base-devel' linux 'linux-firmware'; then
		_red "Erro: pacstrap"
		return 1
	fi

	# Configuar FSTAB.
	_yellow "Executando: genfstab -U -p /mnt >> /mnt/etc/fstab"
	genfstab -p /mnt >> /mnt/etc/fstab

	_yellow "Executando: arch-chroot /mnt /bin/bash"
	_green "Execute os comandos a seguir para proxima fase"
	_green "curl -LS $url_archutils -o archutils.sh"
	_green "chmod +x archutils.sh; ./archutils.sh"
	
	arch-chroot /mnt /bin/bash
	return 0
}

_configure_pos_base()
{
	# /usr/share/zoneinfo/America/Porto_Velho
	# Configurar horário de Porto Velho/RO
	_yellow "Executando: ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime"
	ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime

	# Idioma pt_BR.UTF-8
	# _yellow "Criando backup de /etc/locale.gen em /etc/locale.gen.backup"
	# cp '/etc/locale.gen' '/etc/locale.gen.backup' # Criar backup

	_yellow "Configurando: /etc/locale.gen"
	sed -i 's/#pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen

	_yellow "Configurando: /etc/locale.conf"
	echo 'LANG="pt_BR.UTF-8"' > '/etc/locale.conf'

	_yellow "Configurando: KEYMAP=br-abnt2 em /etc/vconsole.conf"
	echo 'KEYMAP=br-abnt2' > '/etc/vconsole.conf'

	_yellow "Executando [locale-gen]"
	locale-gen

	# Hostname
	_yellow "Digite um HOSTENAME para sua máquina: "; read host_name
	_yellow "Usando este hostname $host_name"
	echo "$host_name" > '/etc/hostname'

	_yellow "Configurando /etc/hosts"
	echo '127.0.0.1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo '::1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo -e "127.0.0.1	${host_name}.localdomain	$host_name" >> '/etc/hosts'

	_yellow "Executando pacman -Syy"
	pacman -Syy

	for pkg in "${pkgs_cli_utils[@]}"; do
		echo -e "$space_line"
		_yellow "Instalando: $pkg"
		_PACMAN "$pkg"
	done

	_green "Para finalizar defina sua senha de ${Red}root${Reset} com o comando passwd"
	_green "Também e recomendado habilitar o multilib em /etc/pacman.conf"
	_green "Em seguida execute este programa novamente e escolha a opição 3 no menu"
}


_install_grub_mbr()
{
	# grub-install ${DiskInfoTarget[instalation_disk]} --target=i386-pc --bootloader-id=ArchLinux --recheck
	# grub-mkconfig -o /boot/grub/grub.cfg

	_yellow "Instalando: grub os-prober"
	_PACMAN grub 'os-prober' || return 1
 
	_yellow "Instalando grub em: ${DiskInfoTarget[instalation_disk]}"
	grub-install "${DiskInfoTarget[instalation_disk]}" --target=i386-pc --bootloader-id=ArchLinux --recheck || return 1

	_yellow "Executando grub-mkconfig -o /boot/grub/grub.cfg"
	grub-mkconfig -o /boot/grub/grub.cfg || return 1

	_yellow "Execute este programa novamente e selecione a opição 4 no menu"
	return 0
}


_install_grub_efi()
{
	# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
	# grub-mkconfig -o /boot/grub/grub.cfg

	_yellow "Instalando: grub os-prober efibootmgr"
	_PACMAN grub 'os-prober' efibootmgr || return 1
 
	_yellow "Instalando grub em: ${DiskInfoTarget[instalation_disk]}"
	grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck || return 1

	_yellow "Executando grub-mkconfig -o /boot/grub/grub.cfg"
	grub-mkconfig -o /boot/grub/grub.cfg || return 1

	_yellow "Execute este programa novamente e selecione a opição 4 no menu"
	return 0
}


_install_grub()
{
	if [[ "${DiskInfoTarget[disk_table]}" == 'gpt' ]]; then
		_install_grub_efi
	else
		_install_grub_mbr
	fi
}

#=============================================================#

_configure_systemctl()
{
	# systemctl status NetworkManager
	# systemctl start NetworkManager
	# systemctl enable NetworkManager
	# systemctl enable gdm

	#_yellow "Executando: systemctl status NetworkManager"
	_yellow "systemctl start NetworkManager"; systemctl start NetworkManager
	_yellow "systemctl enable NetworkManager"; systemctl enable NetworkManager
	_yellow "systemctl enable gdm"; systemctl enable gdm
}

_install_gnome()
{
	for X in "${pks_cli_utils[@]}"; do
		_yellow "Instalando: $X"
		_PACMAN "$X"
	done


	for c in "${pkgs_gnomeshell[@]}"; do
		echo -e "$scpace_line"
		_yellow "Instalando: $c"
		_PACMAN "$c"
	done

	_configure_systemctl

	echo -e "$space_line"
	_yellow "Execute as ações a seguir manualmente"
	_yellow "Criar seu usuário useradd -m seu_nome; passwd seu_nome"
	_yellow "usermod -aG wheel"
	_yellow "Edite o arquivo visudo"
	_yellow "umount -R /mnt"
	echo ' '
}



main()
{
	parse_disk_partitions || return 1
	parse_table_disk || return 1

	# Exibir informações do disco
	_msg "Disco para instalação " "${DiskInfoTarget[instalation_disk]}"
	_msg "Tamanho " "${DiskInfoTarget[disk_len]}"
	_msg "Ponto de montagem / " "${DiskInfoTarget[partition_root]}"
	[[ -e "${DiskInfoTarget[partition_home]}" ]] && _msg "Ponto de montagem /home " "${DiskInfoTarget[partition_home]}"
	[[ -e "${DiskInfoTarget[partition_boot]}" ]] && _msg "Ponto de montagem /boot " "${DiskInfoTarget[partition_boot]}"
	[[ -e "${DiskInfoTarget[partition_efi]}" ]] && _msg "Ponto de montagem /boot/efi " "${DiskInfoTarget[partition_efi]}"


	if ! _YESNO "Deseja prosseguir"; then
		_red "Saindo"
		exit 0
	fi

	_ping || return 1

	_yellow "MENU PRINCIPAL"
	_yellow "0 - Sair"
	_yellow "1 - Instalar base ARCH"
	_yellow "2 - Instalar POS BASE - (opição usada após o arch-chroot)"
	_yellow "3 - Instalar Grub"
	_yellow "4 - Instalar gnome-shell"
	read -t 15 -n 1 -p "Digite um número e pressione enter: " op
	echo ' '

	case "$op" in
		0) exit;;
		1) _configure_base_system "$@";;
		2) _configure_pos_base "$@";;
		3) _install_grub;;
		4) _install_gnome;;
		*) exit 0;;
	esac

}

main "$@"



