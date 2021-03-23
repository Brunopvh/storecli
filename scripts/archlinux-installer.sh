#!/usr/bin/env bash
#
__version__='2021-02-02'
__appname__='archlinux-installer'
__author__='Bruno Chaves'
__script__=$(readlink -f "$0")
dir_of_executable=$(dirname "$__script__")

#----------------------------------------------------------------#
# INSTALAÇÃO BÁSICA DO ARCHLINUX
#----------------------------------------------------------------#
# https://wiki.archlinux.org/index.php/Installation_guide_(Portugu%C3%AAs)#Definir_o_idioma_do_ambiente_live
#
# -Configurações básicas da imagem live CD.
#   1 - loadkeys br-abnt2 -> para ver todos os mapas te teclado use (ls /usr/share/kbd/keymaps/**/*.map.gz)
#   2 - Descomente a linha pt_BR.UTF-8 UTF-8 em /etc/locale.gen e execute locale-gen
#   3 - export LANG=pt_BR.UTF-8
#   4 - Verificar se o tipo de inicialização e EFI -> ls /sys/firmware/efi/efivars
#   5 - Atualizar o relógio do sistema para garantir que está correto -> timedatectl set-ntp true; timedatectl status
#   6 - Formatar a partição de instalação -> mkfs.ext4 /dev/particao
#   7 - Montar a partição de instalação -> mount /dev/particao /mnt
#
#----------------------------------------------------------------#
#
# pacstrap /mnt base base-devel
# genfstab -U -p /mnt >> /mnt/etc/fstab
#
#----------------------------------------------------------------#
# CONFIGURAR O GRUB 
#----------------------------------------------------------------#
# - EFI
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
# 
# - BIOS
# grub-install DEVICE --target=i386-pc --bootloader-id=ArchLinux --recheck
# 
# grub-mkconfig -o /boot/grub/grub.cfg
#
#----------------------------------------------------------------#
# WIFI
#----------------------------------------------------------------#
# systemctl status NetworkManager
# systemctl start NetworkManager
# systemctl enable NetwokrManager
# systemctl enable gdm
#
#----------------------------------------------------------------#
# XORG
#----------------------------------------------------------------#
# pacman -Sy
# pacman -S xorg-server
#
#----------------------------------------------------------------#
# CONFIGURAÇÃO DO TECLADO
#----------------------------------------------------------------#
# localectl list-keymaps
# localectl set-keymap --no-convert br-abnt2 
#
# sudo setxkbmap -model abnt2 -layout br -variant abnt2
# sudo nano /etc/X11/xorg.conf.d/10-evdev.conf
#
#----------------------------------------------------------------#
# INSTALAÇÃO DE FONTES NO SISTEMA.
#----------------------------------------------------------------#
# sudo pacman -S ttf-dejavu ttf-liberation noto-fonts
# 
#----------------------------------------------------------------#
# INSTALAÇÃO DO XFCE
#----------------------------------------------------------------#
# pacman -S xfce4 xfce4-goodies lightdm lightdm-gtk-greeter networkmanager network-manager-applet
# systemctl enable lightdm
# systemctl enable NetworkManager
#
#------------------------------------------------------------------#
# REFERÊNCIAS
#------------------------------------------------------------------#
# https://wiki.archlinux.org/index.php/Linux_console_(Portugu%C3%AAs)/Keyboard_configuration_(Portugu%C3%AAs)
# https://www.vivaolinux.com.br/dica/Teclado-ABNT2-definitivo-no-Archlinux
# https://stackoverflow.com/questions/402377/using-getopts-to-process-long-and-short-command-line-options
# https://www.dicas-l.com.br/arquivo/fatiando_opcoes_com_o_getopts.php
#
#----------------------------------------------------------------#
# Obtendo a ultima versão deste script
#----------------------------------------------------------------#
# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/scripts/archlinux-installer.sh)"
#

CRed='\033[0;31m'
CGreen='\033[0;32m'
CYellow='\033[0;33m'
CBlue='\033[0;34m'
CWhite='\033[0;37m'
CReset='\033[m'

is_executable()
{
	# Função para verificar se um executável existe no PATH do sistema.
	if [[ -x $(command -v "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}

#=============================================================#
# Imprimir textos com formatação e cores.
#=============================================================#
COLUMNS=$(tput cols)

_red()
{
	echo -e "${CRed} $@${CReset}"
}

_green()
{
	echo -e "${CGreen} $@${CReset}"
}

_yellow()
{
	echo -e "${CYellow} $@${CReset}"
}

_blue()
{
	echo -e "${CBlue} $@${CReset}"
}

_println()
{
	# Imprimir texto sem quebrar linha
	printf "$@"
}


print_line()
{
	# Função para imprimir um caractere que preencha todo espaço horizontal do terminal.
	printf "%-${COLUMNS}s" | tr ' ' '-'
}

_msg()
{
	print_line
	echo -e " $@"
	print_line
}

usage()
{
cat << EOF
     Use:
      $(basename "$0") -t <device> -r <partition>

      -b|--boot            BOOT, partição para /boot (OPCIONAL).
      -e|--efi             EFI, partição para /boot/efi (Usar apenas em sistemas efi).
      -H|--home            HOME, partição para /home (OPICIONAL).
      -r|--root            ROOT, partição raiz do sistema / (OBRIGATÓRIO).
      -t|--target          TARGET, disco alvo para instalação (/dev/sdX - OBRIGATÓRIO).

      -h|--help            Mostra ajuda.

          Supondo que você queira instalar o sistema em /dev/sda com a partição efi
          em /dev/sda2 e com raiz em /dev/sda3 use o comando:

          $(basename "$0") --target /dev/sda --efi /dev/sda2 --root /dev/sda3

EOF
}

function _YESNO()
{
	# Mostra uma mensagem para o usuário responder sim ou não e retorna 1
	# caso a resposta seja não ou 0 caso a resposta seja sim.
	echo -ne "${@} [${CGreen}s${CReset}/${CRed}N${CReset}]: "
	read -t 30 -n 1 yesno
	echo ' '
	case "${yesno,,}" in
		s|S|y|Y) return 0;;
		n|N) return 1;;
		*) _red "Resposta inválida."; return 1;;
	esac 
}

# Necessário ser root.
if [[ $(id -u) != '0' ]]; then
	_red "Você tem que ser 'root'"
	exit 1
fi

[[ $(uname -s) != 'Linux' ]] && {
	_red "Seu sistema não e Linux"
	exit 1
}

temp_dir=$(mktemp --directory)
temp_file="$temp_dir/Tempfile.txt"
LogInfo="$temp_dir/Info.log"
LogErro="$temp_dir/Erro.log"
REPOS_STORECLI='https://github.com/Brunopvh/storecli'
URL_STORECLI_MASTER="$REPOS_STORECLI/archive/master.tar.gz"
URL_ARCHLINUX_INSTALLER='https://raw.github.com/Brunopvh/storecli/master/scripts/archlinux-installer.sh'

# Efi/Bios
TYPE_BOOT='' # $(ls /sys/firmware/efi/efivars)

declare -A DiskInfoTarget
CliArguments="$@"

# Analizar a linha de comando se receber um argumento ou mais.
[[ ! -z $1 ]] && {
while [[ $1 ]]; do
	case "$1" in
		-b|--boot) shift; partition_boot="$1";;      # /boot - Opcional
		-e|--efi) shift; partition_efi="$1";;        # /efi - Somente para EFI/GPT (obrigatório).
		-H|--home) shift; partition_home="$1";;      # /home - Opcional
		-r|--root) shift; partition_root="$1";;      # /
		-t|--target) shift; device_target_to_installation="$1";;  # disco alvo - /dev/sda, /dev/sdb, /dev/sdc
		-h|--help) usage; exit; break;;
		-v|--version) echo -e "$__version__"; exit 0; break;;
		*)  _red "Opção/Agumento inválida: $1"; exit 1; break;;
	esac
	shift
done
}
device_target_to_installationLEN=''
device_target_to_installationTABLE=''

#=======================================================#
# Lista de pacotes utils para cli e interface gráfica.
#=======================================================#
PROGRAMS_CLI_UTILS=(
	'dosfstools'
	'mtools'
	'sudo'
	'dialog'
	'ntfs-3g'
	'curl'
	'python'
	'git'
	'vim'
	'ttf-dejavu' 
	'ttf-liberation' 
	'noto-fonts'
)

PROGRAMS_INTERNET_UTILS=(
	networkmanager 
	wpa_supplicant
	wireless_tools
	wpa_actiond	
	dhclient
	)

PROGRAMS_XORG_UTILS=(
	xorg-server
	xf86-video-intel
	)

# Pacotes para instalação do gnome-shell no arch.
PROGRAMS_GNOME_SHELL=(
	'libgl'
	'mesa'
	'gdm'
	'gnome'
	'gnome-terminal'
	'nautilus'
	'gnome-control-center'
	'adwaita-icon-theme'
)

PROGRAMS_XFCE=(
	xfce4 
	xfce4-goodies 
	lightdm 
	lightdm-gtk-greeter
)

pkgs_laptop_utils=(
	'acpi' 
	'acpid'
)


function show_logo(){
	print_line
	_yellow "${CGreen}Url         -> ${CReset}$URL_ARCHLINUX_INSTALLER"
	_yellow "${CGreen}Repositório -> ${CReset}$REPOS_STORECLI"
	_yellow "${CGreen}Versão      -> ${CReset}$__version__"
	_yellow "${CGreen}Autor       -> ${CReset}$__author__"
}

function check_boot_type()
{
	# Verificar se o tipo de boot e Bios/Efi e definir a variável TYPE_BOOT.
	# ls /sys/firmware/efi/efivars
	modprobe -q efivarfs
    if [[ -d "/sys/firmware/efi/" ]]; then
		if [[ -z $(mount | grep /sys/firmware/efi/efivars) ]]; then
			_yellow "Executando ... mount -t efivarfs efivarfs /sys/firmware/efi/efivars"
			mount -t efivarfs efivarfs /sys/firmware/efi/efivars
		fi
		TYPE_BOOT='efi'
		_yellow "(check_boot_type):  Modo EFI detectado"
    else
		TYPE_BOOT='bios'
		_yellow "(check_boot_type):  Modo BIOS detectado"
    fi
   	sleep 0.25
}

function parse_disk_partitions()
{
	# Obter informações sobre o dispositivo de instalação tamanho/tipo/...
	if [[ -z "${device_target_to_installation}" ]]; then
		_red "(parse_disk_partitions): informe um disco para instalação"
		return 1
	fi

	# Verificar a partição informada para ser a 'raiz' / do sistema.
	if [[ -z "${partition_root}" ]]; then
		_red "(parse_disk_partitions): informe uma partição raiz para instalação do diretório '/'"
		return 1
	fi

	# Filtrar informações do disco selecionado (/dev/sda, /dev/sdb/, /dev/sdc, /dev/sdx...)
	fdisk -l "${device_target_to_installation}" > "$temp_file"

	# Tamanho do armazenamento do dispositivo GB/MB.
	device_target_to_installationLEN=$(egrep -m 1 ^'(Disk|Disco)' "$temp_file" | cut -d ' ' -f 3-4 | sed 's/,//g')

	# Tabela de partição gpt/mbr.
	device_target_to_installationTABLE=$(egrep -m 1 '(Tipo|Type|type)' "$temp_file" | cut -d ':' -f 2 | sed 's/ //g')
	
	_msg "Informações do disco de instalação."
	_yellow "Disco ... ${device_target_to_installation}"
	_yellow "Tamanho ... ${device_target_to_instalationLEN}"
	_yellow "Partição root ... ${partition_root}"

	[[ -e "${partition_home}" ]] && {
		_yellow "Ponto de montagem /home ... ${partition_home}"
	}
	[[ -e "${partition_boot}" ]] && {
		_yellow "Ponto de montagem /boot ... ${partition_boot}"
	}
	[[ -e "${partition_efi}" ]] && {
		_yellow "Ponto de montagem /boot/efi ... ${partition_efi}"
	}
	sleep 1
}

parse_table_disk()
{
	# Se a tabela de partição do disco for GPT e o usuário não informar uma partição
	# para montar /boot/efi será exibida uma mensagem de erro.
	if [[ "${device_target_to_installationTABLE}" == 'gpt' ]] && [[ ! -e "${partition_efi}" ]]; then
		_red "O disco selecionado tem tabela de partição do tipo (gpt) informe uma partição para usar (EFI)"
		return 1
	fi

	# Partição e EFI foi informada na linha de comando, mas o particionamento é do tipo MBR.
	if [[ "${device_target_to_installationTABLE}" != 'gpt' ]] && [[ ! -z "${partition_efi}" ]]; then
		_red "O disco selecionado NÃO tem tabela de partição do tipo (GPT) você não pode usar (EFI)"
		return 1
	fi
	sleep 1
}

_ping()
{
	# Verificar conexão com a internet.
	_println "Aguardando conexão ... "
	if ping -c 2 8.8.8.8 1> /dev/null; then
		printf "Conectado\n"
	else
		_red 'FALHA'
		_red "AVISO: você está OFF-LINE - use o wifi-menu para se conectar a uma rede WIFI"
		read -p "Pressione enter: " enter
	fi
}

_PACMAN()
{
	_msg "${CGreen}Executando ... pacman -S --noconfirm --needed $@${CReset}"
	if pacman -S --noconfirm --needed "$@"; then
		sleep 1
		return 0
	else
		_red "(_PACMAN) FALHA: pacman -S --noconfirm --needed $@"
		sleep 3
		return 1
	fi
}

__mount__()
{
	mount "$@" || return 1
	return 0
}

_ismount()
{
	# Se o dispositivo informado em "$1" estiver montado retorna '0', se não retorna '1'.
	# Use _ismount "$1"
	local partition_device=$(grep -m 1 "$1" /proc/mounts | awk '{print $1}')

	if [[ "$partition_device" == "$1" ]]; then
		_yellow "Dispositivo $1 está montado."
		sleep 1
		return 0 # Partição está montada.
	else
		_red "Dispositivo não montado ... $1"
		sleep 2
		return 1 # Partição não montada.
	fi
}

_umount_partition()
{
	# Desmontar uma partição montada.
	# $1 = partição a ser desmontada
	# USE _umount_partition "$1"
	_ismount "$1" || return 1 # Partição não está montada.

	echo -ne "${CYellow}Desmontando ... ${1}${CReset} "
	mount "$1" 
	if [[ $? == 0 ]]; then
		_yellow "OK"
		sleep 0.5
		return 0
	else
		_red "Falha"
		sleep 1
		return 1
	fi
}

_mount_partition()
{
	# USE _mount_partition partiton mount-point
	_ismount "$1" && return 0 # Partição já está montada.

	echo "${CYellow}Montando $1 em ... ${2}${CReset} "
	__mount__ "$1" "$2"
	if [[ $? == 0 ]]; then
		_yellow "OK"
		sleep 0.5
		return 0
	else
		_red "Falha"
		sleep 1
		return 1
	fi
}

_format_to_fat32()
{
	# Formatar uma partição como FAT32.
	# Use: _format_to_fat32 patition
	#
	# mkfs.vfat -F32 /dev/sdx1
	# mkfs -t vfat /dev/sdb1
	# eject /dev/sdb1
	# USE _format_to_fat32 device
	
	if ! _YESNO "Deseja formatar $1 como sistema de arquivos fat32"; then
		return 0
	fi

	# Desmontar a partição a ser formatada caso esteja montada. 
	_umount_partition "$1"
	_yellow "Executando ... mkfs.vfat -F32 $1"
	mkfs.vfat -F32 "$1"
}

_format_to_ext4()
{
	# Formatar uma partição com ext4. 
	# Use _format_to_ext4 devicie label
	local device="$1"
	local label="$2"

	if ! _YESNO "Deseja formatar $device como ext4"; then
		return 0
	fi

	# Desmontar caso esteja montado
	 _umount_partition "$device"

	if [[ "$label" ]]; then
		_yellow "Executando ... mkfs.ext4 -L $label $device"
		mkfs.ext4 -L "$label" "$device"
	else
		_yellow "Executando ... mkfs.ext4 $device"
		mkfs.ext4 "$device"
	fi
	return 0
}

_configure_partition_efi()
{
	# Configurar EFI em discos gpt
	[[ ! -e "${partition_efi}" ]] && return 0

	# Perguntar se o usuário deseja fotmatar a partição efi.
	_format_to_fat32 "${partition_efi}"
	
	if [[ ! -d /mnt/boot/efi ]]; then
		_yellow "Criando o diretório ... /mnt/boot/efi"
		mkdir -p "/mnt/boot/efi"
	fi
	
	_mount_partition "${partition_efi}" "/mnt/boot/efi" || return 1 
	return 0
}

_configure_partition_boot()
{
	# Se o usuário informar uma partição para /boot será montada na partição especificada.
	[[ ! -e "${partition_boot}" ]] && return 0

	# Formatar e montar a partição /boot.
	_format_to_ext4 "${partition_boot}" 'ARCHBOOT'
	if [[ ! -d /mnt/boot ]]; then
		_yellow "Criando o diretório ... /mnt/boot"
		mkdir -p /mnt/boot
	fi
	_mount_partition "${partition_boot}" '/mnt/boot' || return 1
	return 0
}

_configure_partition_home()
{	
	# Se o usuário informar uma partição para /home ela sera montada com o comado abaixo.
	[[ ! -e "${partition_home}" ]] && return 0	

	# Formatar e montar a partição /home.
	_format_to_ext4 "${partition_home}" 'ARCHHOME'
	if [[ ! -d /mnt/home ]]; then
		_yellow "Criando o diretório ... /mnt/home"
		mkdir -p /mnt/home
	fi
	_mount_partition "${partition_home}" '/mnt/home' || return 1
	return 0
}

_configure_locale()
{
	_yellow "Configurando locale"
	export LANG=pt_BR.UTF-8
	timedatectl set-ntp true 1> /dev/null # timedatectl status 
	loadkeys br-abnt2 1> /dev/null
	sed -i 's/^#pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen 
	sed -i 's/^# pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen

	# /usr/share/zoneinfo/America/Porto_Velho - Configurar horário de Porto Velho/RO
	ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime
	echo 'LANG="pt_BR.UTF-8"' > '/etc/locale.conf'
	echo 'KEYMAP=br-abnt2' > '/etc/vconsole.conf'
	locale-gen 1> /dev/null
	sleep 1
}

_configure_base_system()
{
	# Configuração básica de instalação do sistema. Está função deve é executada antes da instalação do
	# sistema é interface gráfica.
	# genfstab -U /mnt >> /mnt/etc/fstab

	mkdir -p /mnt
	mkdir -p /mnt/boot
	mkdir -p /mnt/home

	# Formatar a partição raiz para o ponto de montagem '/'. 
	_format_to_ext4 "${partition_root}" 'ARCHLINUX' || return 1
	_mount_partition "${partition_root}" '/mnt' || return 1
	_configure_partition_home
	_configure_partition_boot 
	_configure_partition_efi
	_configure_locale

	# Pacstrap
	_yellow "Executando: pacstrap /mnt base base-devel linux linux-firmware python3 vim curl"
	pacstrap /mnt base base-devel linux linux-firmware python3 vim curl || {
		_red "(_configure_base_system) erro: pacstrap"
		return 1
	}

	# Configuar fstab.
	_yellow "Executando: genfstab -U -p /mnt >> /mnt/etc/fstab"
	genfstab -p /mnt >> /mnt/etc/fstab
	curl -L -S $URL_ARCHLINUX_INSTALLER -o "/mnt/root/${__appname__}.sh"
	_yellow "Executando: arch-chroot /mnt /bin/bash"
	_green "Execute os comandos a seguir para proxima fase"
	_green "curl -L -S $URL_ARCHLINUX_INSTALLER -o archutils.sh"
	_green "chmod +x archutils.sh; ./archutils.sh"
	arch-chroot /mnt /bin/bash
}

_configure_pos_base()
{
	_configure_locale

	if [[ -f /etc/hosts ]] && [[ ! -f /etc/hosts.bak ]]; then
		cp /etc/hosts /etc/hosts.bak
	fi
	
	# Hostname
	HOSTENAME="archlinux"
	_yellow "Digite um HOSTENAME para sua máquina: "; read -t 30 HOSTENAME
	_yellow "Usando este hostname $HOSTENAME"
	echo "$HOSTENAME" > '/etc/hostname'
	_yellow "Configurando /etc/hosts"
	echo '127.0.0.1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo '::1	localhost.localdomain	localhost' >> '/etc/hosts'
	echo -e "127.0.0.1	${HOSTENAME}.localdomain	$HOSTENAME" >> '/etc/hosts'

	_yellow "Executando pacman -Syy"; pacman -Syy
	_install_cli_utils
	_install_net_utils
	_configure_systemctl_network
	_green "Para finalizar defina sua senha de ${Red}root${Reset} com o comando passwd"
	_green "Também e recomendado habilitar o multilib em /etc/pacman.conf"
	_green "Em seguida execute este programa novamente e escolha a opição 3 no menu"
}

_install_grub()
{
	# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
	# grub-mkconfig -o /boot/grub/grub.cfg

	print_line
	parse_disk_partitions || {
		_red "(_install_grub): Erro"
	}

	if [[ "$TYPE_BOOT" == 'efi' ]]; then
		_PACMAN grub os-prober efibootmgr || return 1
	else
		_PACMAN grub os-prober || return 1
	fi
 
	_green "Instalando grub em ... ${device_target_to_installation}"
	if [[ "$TYPE_BOOT" == 'efi' ]]; then
		grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck || return 1
	else
		grub-install "${device_target_to_installation}" --target=i386-pc --bootloader-id=ArchLinux --recheck || return 1
	fi

	_yellow "Executando grub-mkconfig -o /boot/grub/grub.cfg"
	grub-mkconfig -o /boot/grub/grub.cfg || return 1
	return 0
}

_install_net_utils()
{
	for pkg in "${PROGRAMS_INTERNET_UTILS[@]}"; do _PACMAN "$pkg"; done
}

_install_xorg_utils()
{
	for pkg in "${PROGRAMS_XORG_UTILS[@]}"; do _PACMAN "$pkg"; done
}

_install_cli_utils()
{
	for pkg in "${PROGRAMS_CLI_UTILS[@]}"; do _PACMAN "$pkg"; done
}

_configure_systemctl_network()
{
	# systemctl status NetworkManager
	_yellow "systemctl start NetworkManager"; systemctl start NetworkManager
	_yellow "systemctl enable NetworkManager"; systemctl enable NetworkManager
}

_install_gnome_desktop()
{
	_install_cli_utils
	_install_net_utils
	_install_xorg_utils
	for pkg in "${PROGRAMS_GNOME_SHELL[@]}"; do _PACMAN "$pkg"; done
	_configure_systemctl_network
	systemctl enable gdm
	print_line
	_yellow "Execute as ações a seguir manualmente"
	_yellow "Criar seu usuário useradd -m seu_nome; passwd seu_nome"
	_yellow "usermod -aG wheel seu_nome"
	_yellow "Edite o arquivo visudo"
	_yellow "umount -R /mnt"
}

_install_xfce_desktop()
{
	pacman -Sy
	_install_cli_utils
	_install_net_utils
	_install_xorg_utils
	for pkg in "${PROGRAMS_XFCE[@]}"; do _PACMAN "$pkg"; done
	_configure_systemctl_network
	systemctl enable lightdm
	print_line
	_yellow "Execute as ações a seguir manualmente"
	_yellow "Criar seu usuário useradd -m seu_nome; passwd seu_nome"
	_yellow "usermod -aG wheel seu_nome"
	_yellow "Edite o arquivo visudo"
	_yellow "umount -R /mnt"
}

function get_script_online_version()
{
	# Baixar a versão deste script no github se a versão online for diferente da versão local.
	config_file=/root/"${__appname__}.cfg"
	touch "$config_file"
	
	NowTime=$(date +%Y_%m_%d)
	OldTime=$(cat "$config_file")
	[[ "$NowTime" == "$OldTime" ]] && return 0

	cd $temp_dir
	path_download_online_script="$dir_of_executable/${__appname__}-new-version.sh"

	print_line
	_yellow "Buscando por atualização aguarde ..."
	curl -SL "$URL_ARCHLINUX_INSTALLER" -o "$path_download_online_script" || {
		_red "Falha"
		return 1
	}
	_green 'OK'
	chmod +x $path_download_online_script
	online_version=$($path_download_online_script -v)
	echo -e "$NowTime" > "$config_file"

	if [[ "$online_version" == "$__version__" ]]; then
		_green "Você tem a ultima versão deste script"
		return 1
	else
		_green "Nova versão [$online_version] baixada em ... $path_download_online_script"
		return 0
	fi
}

main()
{
	_ping || return 1
	#get_script_online_version
	#sleep 1

	if [[ ! -z $1 ]]; then
		parse_disk_partitions || return 1
		parse_table_disk || return 
	fi

	loadkeys br-abnt2 1> /dev/null 2>&1 
	_yellow "MENU PRINCIPAL"
	_yellow "0 - Sair"
	_yellow "1 - Instalar base ARCH"
	_yellow "2 - Instalar POS BASE - (opição usada após o arch-chroot)"
	_yellow "3 - Instalar Grub"
	_yellow "4 - Instalar gnome-shell"
	_yellow "5 - Instalar xfce4"
	read -t 40 -n 1 -p "Digite um número e pressione enter: " op
	echo ' '

	[[ "$op" != 0 ]] && check_boot_type

	case "$op" in
		0) exit;;
		1) 
			parse_disk_partitions
			parse_table_disk
			if ! _YESNO "Deseja prosseguir"; then
				_red "Saindo"
				return 0
			fi
			_configure_base_system "$@"
			exit 0
			;;
		2) _configure_pos_base "$@";;
		3) _install_grub;;
		4) _install_gnome_desktop;;
		5) _install_xfce_desktop;;
		*) return 1;;
	esac

}

main "$@"


