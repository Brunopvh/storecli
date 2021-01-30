#!/usr/bin/env bash
#
__version__='2021-01-30'
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
# CONFIGURAR O GRUB EFI
#----------------------------------------------------------------#
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
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
# INSTALAÇÃO DE FONTES NO SISTEMA.
# sudo pacman -S ttf-dejavu ttf-liberation noto-fonts
# 
# INSTALAÇÃO DO XFCE
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
#
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
	if [[ -x $(which "$1" 2> /dev/null) ]]; then
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
	read -t 20 -n 1 yesno
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

if [[ $(uname -s) != 'Linux' ]]; then
	_red "Seu sistema não e Linux"
	exit 1
fi

loadkeys br-abnt2 
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
DiskInfoTarget=() # Array com informações do disco selecionado para instalação.
CliArguments="$@"

# Analizar a linha de comando se receber um argumento ou mais.
[[ ! -z $1 ]] && {
while [[ $1 ]]; do
	case "$1" in
		-b|--boot) shift; DiskInfoTarget[partition_boot]="$1";;      # /boot - Opcional
		-e|--efi) shift; DiskInfoTarget[partition_efi]="$1";;        # /efi - Somente para EFI/GPT (obrigatório).
		-H|--home) shift; DiskInfoTarget[partition_home]="$1";;      # /home - Opcional
		-r|--root) shift; DiskInfoTarget[partition_root]="$1";;      # /
		-t|--target) shift; DiskInfoTarget[instalation_disk]="$1";;  # disco alvo - /dev/sda, /dev/sdb, /dev/sdc
		-h|--help) usage; exit; break;;
		-v|--version) echo -e "$__version__"; exit 0; break;;
		*)  _red "Opção/Agumento inválida: $1"; exit 1; break;;
	esac
	shift
done
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

function show_logo(){
	print_line
	_yellow "${CGreen}Url         -> ${CReset}$URL_ARCHLINUX_INSTALLER"
	_yellow "${CGreen}Repositório -> ${CReset}$REPOS_STORECLI"
	_yellow "${CGreen}Versão      -> ${CReset}$__version__"
	_yellow "${CGreen}Autor       -> ${CReset}$__author__"
}

function check_boot_type()
{
	# Verificar se o tipos de boot e Bios/Efi e definir a variável TYPE_BOOT.
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
}

function parse_disk_partitions()
{
	# Obter informações sobre o tipo de tabela de particionamento do disco selecionado para 
	# instalação e o tamanaho em GB do disco.
	if [[ ! -e "${DiskInfoTarget[instalation_disk]}" ]]; then
		_red "(parse_disk_partitions): informe um disco para instalação"
		return 1
	fi

	# Verificar a partição informada para ser a 'raiz' / do sistema.
	if [[ ! -e "${DiskInfoTarget[partition_root]}" ]]; then
		_red "(parse_disk_partitions): informe uma partição raiz para instalação do diretório '/'"
		return 1
	fi

	# Filtrar informações do disco selecionado (/dev/sda, /dev/sdb/, /dev/sdc, /dev/sdx...)
	fdisk -l "${DiskInfoTarget[instalation_disk]}" > "$temp_file"
	DiskInfoTarget[disk_table]=$(egrep -m 1 '(Tipo|Type|type)' "$temp_file" | cut -d ':' -f 2 | sed 's/ //g')
	DiskInfoTarget[disk_len]=$(egrep -m 1 '(Disco|Disk)' "$temp_file" | awk '{print $3,$4}' | sed 's/\,//g')
	DiskInfoTarget[disk_len]="${DiskInfoTarget[disk_len]%%\,}"
	_msg "Informações do disco de instalação."
	_yellow "Disco ... ${DiskInfoTarget[instalation_disk]}"
	_yellow "Tamanho ... ${DiskInfoTarget[disk_len]}"
	_yellow "Partição root ... ${DiskInfoTarget[partition_root]}"

	[[ -e "${DiskInfoTarget[partition_home]}" ]] && {
		_yellow "Ponto de montagem /home ... ${DiskInfoTarget[partition_home]}"
	}
	[[ -e "${DiskInfoTarget[partition_boot]}" ]] && {
		_yellow "Ponto de montagem /boot ... ${DiskInfoTarget[partition_boot]}"
	}
	[[ -e "${DiskInfoTarget[partition_efi]}" ]] && {
		_yellow "Ponto de montagem /boot/efi ... ${DiskInfoTarget[partition_efi]}"
	}
}

parse_table_disk()
{
	# Se a tabela de partição do disco for GPT e o usuário não informar uma partição
	# para montar /boot/efi será exibida uma mensagem de erro.
	if [[ "${DiskInfoTarget[disk_table]}" == 'gpt' ]] && [[ ! -e "${DiskInfoTarget[partition_efi]}" ]]; then
		_red "O disco selecionado tem tabela de partição do tipo (gpt) informe uma partição para usar (EFI)"
		return 1
	fi

	# Partição e EFI foi informada na linha de comando, mas o particionamento é do tipo MBR.
	if [[ "${DiskInfoTarget[disk_table]}" != 'gpt' ]] && [[ ! -z "${DiskInfoTarget[partition_efi]}" ]]; then
		_red "O disco selecionado NÃO tem tabela de partição do tipo (GPT) você não pode usar (EFI)"
		return 1
	fi
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
		return 0
	else
		_red "(_PACMAN) FALHA: pacman -S --noconfirm --needed $@"
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
		return 0 # Partição está montada.
	else
		_red "Dispositivo não montado ... $1"
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
		return 0
	else
		_red "Falha"
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
		return 0
	else
		_red "Falha"
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
	[[ ! -e "${DiskInfoTarget[partition_efi]}" ]] && return 0

	# Perguntar se o usuário deseja fotmatar a partição efi.
	_format_to_fat32 "${DiskInfoTarget[partition_efi]}"
	
	if [[ ! -d /mnt/boot/efi ]]; then
		_yellow "Criando o diretório ... /mnt/boot/efi"
		mkdir -p "/mnt/boot/efi"
	fi
	
	_mount_partition "${DiskInfoTarget[partition_efi]}" "/mnt/boot/efi" || return 1 
	return 0
}

_configure_partition_boot()
{
	# Se o usuário informar uma partição para /boot será montada na partição especificada.
	[[ ! -e "${DiskInfoTarget[partition_boot]}" ]] && return 0

	# Formatar e montar a partição /boot.
	_format_to_ext4 "${DiskInfoTarget[partition_boot]}" 'ARCHBOOT'
	if [[ -d /mnt/boot ]]; then
		_yellow "Criando o diretório ... /mnt/boot"
		mkdir -p /mnt/boot
	fi
	_mount_partition "${DiskInfoTarget[partition_boot]}" '/mnt/boot' || return 1
	return 0
}

_configure_partition_home()
{	
	# Se o usuário informar uma partição para /home ela sera montada com o comado abaixo.
	[[ ! -e "${DiskInfoTarget[partition_home]}" ]] && return 0	

	# Formatar e montar a partição /home.
	_format_to_ext4 "${DiskInfoTarget[partition_home]}" 'ARCHHOME'
	if [[ -d /mnt/home ]]; then
		_yellow "Criando o diretório ... /mnt/boot"
		mkdir -p /mnt/home
	fi
	_mount_partition "${DiskInfoTarget[partition_home]}" '/mnt/home' || return 1
	return 0
}

_configure_locale()
{
	_yellow "Executando ... export LANG=pt_BR.UTF-8"; export LANG=pt_BR.UTF-8
	_yellow "Executando ... timedatectl set-ntp true"; timedatectl set-ntp true; timedatectl status
	_yellow "Executando ... loadkeys br-abnt2"; loadkeys br-abnt2
	_yellow "Configurando ... pt_BR.UTF-8"
	sed -i 's/^#pt_BR.UTF-8/pt_BR.UTF-8' /etc/locale.gen 
	sed -i 's/^# pt_BR.UTF-8/pt_BR.UTF-8' /etc/locale.gen

	# /usr/share/zoneinfo/America/Porto_Velho - Configurar horário de Porto Velho/RO
	_yellow "Executando: ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime"
	ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime
	_yellow "Configurando ... /etc/locale.conf"; echo 'LANG="pt_BR.UTF-8"' > '/etc/locale.conf'
	_yellow "Configurando ... /etc/vconsole.conf"; echo 'KEYMAP=br-abnt2' > '/etc/vconsole.conf'
	_yellow "Executando ... locale-gen"; locale-gen
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
	_format_to_ext4 "${DiskInfoTarget[partition_root]}" 'ARCHLINUX' || return 1
	_mount_partition "${DiskInfoTarget[partition_root]}" '/mnt' || return 1
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
	curl -L -S $URL_ARCHLINUX_INSTALLER -o "/mnt/${__appname__}.sh"
	_yellow "Executando: arch-chroot /mnt /bin/bash"
	_green "Execute os comandos a seguir para proxima fase"
	_green "curl -L -S $URL_ARCHLINUX_INSTALLER -o archutils.sh"
	_green "chmod +x archutils.sh; ./archutils.sh"
	ls /mnt/*.sh
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

	_yellow "Executando pacman -Syy"
	pacman -Syy

	for pkg in "${pkgs_cli_utils[@]}"; do
		_PACMAN "$pkg"
	done

	_green "Para finalizar defina sua senha de ${Red}root${Reset} com o comando passwd"
	_green "Também e recomendado habilitar o multilib em /etc/pacman.conf"
	_green "Em seguida execute este programa novamente e escolha a opição 3 no menu"
}

_install_grub()
{
	# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck
	# grub-mkconfig -o /boot/grub/grub.cfg

	if [[ "$TYPE_BOOT" == 'efi' ]]; then
		_PACMAN grub os-prober efibootmgr || return 1
	else
		_PACMAN grub os-prober || return 1
	fi
 
	_green "Instalando grub em ... ${DiskInfoTarget[instalation_disk]}"
	if [[ "$TYPE_BOOT" == 'efi' ]]; then
		grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck || return 1
	else
		grub-install "${DiskInfoTarget[instalation_disk]}" --target=i386-pc --bootloader-id=ArchLinux --recheck || return 1
	fi

	_yellow "Executando grub-mkconfig -o /boot/grub/grub.cfg"
	grub-mkconfig -o /boot/grub/grub.cfg || return 1
	return 0
}

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
		_PACMAN "$X"
	done

	for c in "${pkgs_gnomeshell[@]}"; do
		_PACMAN "$c"
	done

	_configure_systemctl
	print_line
	_yellow "Execute as ações a seguir manualmente"
	_yellow "Criar seu usuário useradd -m seu_nome; passwd seu_nome"
	_yellow "usermod -aG wheel"
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

	if [[ "$online_version" == "$__version__" ]]; then
		_green "Você tem a ultima versão deste script"
		return 1
	else
		_green "Nova versão [$online_version] baixada em ... $path_download_online_script"
		return 0
	fi

	echo "$NowTime" > "config_file"
}

main()
{
	get_script_online_version
	sleep 1

	if [[ ! -z $1 ]]; then
		parse_disk_partitions || return 1
		parse_table_disk || return 
	fi

	_ping || return 1

	_yellow "MENU PRINCIPAL"
	_yellow "0 - Sair"
	_yellow "1 - Instalar base ARCH"
	_yellow "2 - Instalar POS BASE - (opição usada após o arch-chroot)"
	_yellow "3 - Instalar Grub"
	_yellow "4 - Instalar gnome-shell"
	read -t 40 -n 1 -p "Digite um número e pressione enter: " op
	echo ' '

	check_boot_type

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
			_yellow "(_configure_base_system) -> (main): Saindo..."
			exit 0
			;;
		2) _configure_pos_base "$@";;
		3) _install_grub;;
		4) _install_gnome;;
		*) return 1;;
	esac

}

main "$@"


