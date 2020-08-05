#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os, sys, subprocess
import tempfile
import re
import argparse
#import tarfile
import urllib.request

__version__ = '2020-08-04'

Red = '\033[0;31m'
Yellow = '\033[0;33m'
Reset = '\033[m'

columns = os.get_terminal_size(0)[0]
line = ('-' * columns)

# Endereço deste script no disco.
dir_root = os.path.dirname(os.path.realpath(__file__)) 

# Nome do script/app
app_name = os.path.basename(__file__)


def red(text=None):
	if text == None:
		print(Red, end ='')
	else:
		print(f'{Red}{text}{Reset}')

def yellow(text=None):
	if text == None:
		print(Yellow, end='')
	else:
		print(f'{Yellow}{text}{Reset}')

def is_executable(exec):
	if int(subprocess.getstatusoutput(f'command -v {exec} 2> /dev/null')[0]) == int('0'):
		return 'True'
	else:
		return 'False'


def yes_no(text=''):
	print(f'{Yellow}{text} [s/{Red}n{Reset}{Yellow}]? :', end=' ')
	YESNO = str(input()).strip()
	if (YESNO.lower() == 's') or (YESNO.lower() == 'sim'): 
		return 'True'
	elif (YESNO.lower() == 'n') or (YESNO.lower() == 'nao'):
		return 'False'
	else:
		red('Opição inválida.')
		return 'False'



# root
if os.geteuid() != int('0'):
	red('Usuário tem que ser o root saindo')
	sys.exit('1')

url_storecli='https://github.com/Brunopvh/storecli/archive/master.tar.gz'
url_archutils='https://raw.github.com/Brunopvh/storecli/master/scripts/archutils.py'
TempDir = tempfile.mkdtemp()

# Pacotes e utilitários.
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
	'git'
	'vim'
	'ttf-dejavu' 
	'ttf-liberation' 
	'noto-fonts'
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

class ArchUtiuls:
	'''
	https://docs.python.org/3/library/os.path.html

	'''
	def __init__(self):
		pass

	def pkg_is_list(self, pkgs):
		'''
		Verificar se os pacotes foram passados para classe em forma de lista
		'''
		if isinstance(pkgs, list): 
			return 'True'
		else:
			print('\033[0;31mFalha o(s) pacotes para instalação precisam ser passados em forma de uma lista.\033[m') 
			print(__class__)
			return 'False'

	def pacman(pkgs):
		# _PACMAN -S --needed "$@"
		# pacman -S --noconfirm --needed
		if self.pkg_is_list(pkgs) == 'False':
			return

		for PKG in pkgs:
			print(line)
			yellow(f'Instalando: {PKG}')
			print(line)
			os.system(f'pacman -S --noconfirm --needed {PKG}')

	def get_table_info(self):
		# Verificar a tabela de partições do disco. GPT/MBR.
		if int(len(DiskTargetInfo['target_disk'])) != int('8'):
			red('Disco alvo inválido. Informe apenas o dispositivo sem partições. EX: /dev/sda')
			return

		info = subprocess.getstatusoutput('fdisk -l {}'.format(DiskTargetInfo['target_disk']))[1].split('\n')
		for I in info:
			I = str(I).lower()
			if ('tipo' in I) and ('disco' in I):
				partition_table = I[I.find(':')+1 :].strip()
				break
			elif ('type' in I) and ('disk' in I):
				partition_table = I[I.find(':')+1 : ].strip()
				break
			else:
				partition_table = None

		return partition_table

	def parser_table_disk(self):
		diskTable = self.get_table_info()
		if diskTable == 'gpt':
			if not 'target_efi' in DiskTargetInfo:
				red('O disco selecionando e do tipo EFI. você precisa informar uma partição para /boot/efi')
				return 'Error'

		if diskTable == 'mbr':
			if 'target_efi' in DiskTargetInfo:
				red('O disco selecionando e do tipo MBR. NÂO é possível usar /boot/efi')
				return 'Error'

		return 'True'

	def format_device(self, device, file_system, label):
		if len(device) < int('9'):
			red(f'Dispositivo inválido: {device}')
			return

		YN = yes_no(f'Deseja formatar o dispositivo {device} como sistema de arquivos {file_system}')
		if YN == 'False':
			return

		if file_system == 'FAT32':
			print('Executando: mkfs.vfat -F32 {} -n {}'.format(device, label))
			os.system('mkfs.vfat -F32 {} -n {}'.format(device, label))
		elif file_system == 'EXT4':
			print(('Executando: mkfs.ext4 -L {} {}'.format(label, file_system)))
			os.system('mkfs.ext4 -L {} {}'.format(label, file_system))


	def configure_partition_efi(self):
		# Configurar EFI em discos gpt
		if self.get_table_info() != 'gpt':
			return

		self.format_device(DiskTargetInfo['target_efi', 'FAT32', 'EFI-BOOT'])
		yellow('Criando: /mnt/boot/efi')
		if os.path.isdir('/mnt/boot/efi') == False: os.makedirs('/mnt/boot/efi')
		os.system('mount {} /mnt/boot/efi'.format(DiskTargetInfo['target_efi']))

	def install_base(self):
		if self.parser_table_disk == 'Error':
			return

		if os.path.isdir('/mnt') == False: os.makedirs('/mnt')
		if os.path.isdir('/mnt/boot') == False: os.makedirs('/mnt/boot')
		if os.path.isdir('/mnt/home') == False: os.makedirs('/mnt/home')

		# Formatar e montar as partições de instalação.
		self.format_device(DiskTargetInfo['target_root'], 'EXT4', 'ARCHLINUX')
		yellow('Montando: {} em /mnt'.format(DiskTargetInfo['target_root']))
		os.system('mount {} /mnt'.format(DiskTargetInfo['target_root']))

		if 'target_boot' in DiskTargetInfo:
			self.format_device(DiskTargetInfo['target_boot'], 'EXT4', 'BOOT')
			yellow('Montando: {} em /mnt'.format(DiskTargetInfo['target_boot']))
			os.system('mount {} /mnt/boot'.format(DiskTargetInfo['target_boot']))

		if 'target_home' in DiskTargetInfo:
			self.format_device(DiskTargetInfo['target_home'], 'EXT4', 'HOME')
			yellow('Montando: {} em /mnt'.format(DiskTargetInfo['target_home']))
			os.system('mount {} /mnt/home'.format(DiskTargetInfo['target_home']))

		print(line)
		yellow('Iniciando a instalação')
		print(line)
		yellow("Configurando horário do sistema")
		os.system('timedatectl set-ntp true')
		yellow('Executando: pacstrap /mnt base base-devel linux linux-firmware')
		os.system('pacstrap /mnt base base-devel linux linux-firmware')

		print(line)
		yellow("Executando: arch-chroot /mnt /bin/bash")
		yellow("Execute os comandos a seguir para próxima fase")
		yellow(f"curl -L -S {url_archutils} -o archutils.py")
		yellow("chmod +x archutils.sh; ./archutils.py")
		os.system('arch-chroot /mnt /bin/bash')

	def install_pos_base(self):
		# /usr/share/zoneinfo/America/Porto_Velho
		# Configurar horário de Porto Velho/RO
		yellow("Executando: ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime")
		os.system('ln -sf /usr/share/zoneinfo/America/Porto_Velho /etc/localtime')

		# Idioma pt_BR.UTF-8
		
		# yellow("Configurando: /etc/locale.gen")
		# sed -i 's/#pt_BR.UTF-8/pt_BR.UTF-8/g' /etc/locale.gen

		yellow("Configurando: /etc/locale.conf")
		f = open('/etc/locale.conf', 'w')
		f.write('LANG="pt_BR.UTF-8"\n')
		f.seek(0)
		f.close()

		yellow("Configurando: KEYMAP=br-abnt2 em /etc/vconsole.conf")
		f = open('/etc/vconsole.conf', 'w')
		f.write('KEYMAP=br-abnt2\n')
		f.seek(0)
		f.close()
		
		yellow("Executando locale-gen")
		os.system('locale-gen')

		# Hostname
		hostname = str(input("Digite um HOSTENAME para sua máquina: ")).strip()
		yellow(f"Usando este hostname: {hostname}")
		f = open('/etc/hostname', 'w')
		f.write(f'{hostname}\n')
		f.seek(0)
		f.close()
	
		yellow("Configurando /etc/hosts")
		os.system("echo '127.0.0.1	localhost.localdomain	localhost' >> '/etc/hosts'")
		os.system("echo '::1	localhost.localdomain	localhost' >> '/etc/hosts'")
		os.system(f'echo "127.0.0.1	${hostname}.localdomain	{hostname}" >> "/etc/hosts"')

		yellow("Executando pacman -Syy")
		os.system('pacman -Syy')

		yellow(f"Para finalizar defina sua senha de {Red}root{Reset} com o comando passwd")
		yellow("É recomendado habilitar o multilib em /etc/pacman.conf")
		yellow("Em seguida execute este programa novamente e escolha a opição 3 no menu")

	def install_grub(self):
		self.pacman(['grub', 'os-prober'])

		if self.get_table_info() == 'mbr':
			yellow('Instalando grub em: {}'.format(DiskTargetInfo['target_disk']))
			os.system('grub-install {} --target=i386-pc --bootloader-id=ArchLinux --recheck'.format(DiskTargetInfo['target_disk']))
		elif self.get_table_info() == 'gpt':
			self.pacman(['efibootmgr'])
			print('Executando: grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck')
			os.system('grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=archlinux --recheck')

		yellow("Executando grub-mkconfig -o /boot/grub/grub.cfg")
		os.system('grub-mkconfig -o /boot/grub/grub.cfg')
		yellow("Execute este programa novamente e selecione a opição 4 no menu")

	def configure_systemctl():
		# systemctl status NetworkManager
		# systemctl start NetworkManager
		# systemctl enable NetworkManager
		# systemctl enable gdm

		yellow("systemctl start NetworkManager"); os.system('systemctl start NetworkManager')
		yellow("systemctl enable NetworkManager"); os.system('systemctl enable NetworkManager')
		yellow("systemctl enable gdm"); os.system('systemctl enable gdm')

	def install_gnome():
		self.pacman(pkgs_cli_utils)
		self.pacman(pkgs_gnomeshell)
		self.configure_systemctl()

		print(line)
		yellow("Execute as ações a seguir manualmente")
		yellow("Criar seu usuário useradd -m seu_nome; passwd seu_nome")
		yellow("usermod -aG wheel")
		yellow("Edite o arquivo visudo")
		yellow("umount -R /mnt")



DiskTargetInfo = {'info': 'Informações sobre o disco de instalação'}

parser = argparse.ArgumentParser(
			description='Instalador básico para o Arch Linux com Gnome em PtBr.'
			)

parser.add_argument(
	'-v', '--version', 
	action='version', 
	version=(f"%(prog)s {__version__}")
	)

# /boot
parser.add_argument(
	'-b', '--boot', 
	action='store', 
	dest='partition_boot',
	type=str,
	help='Informe uma partição para /boot - OPCIONAL'
	)

# /boot/efi
parser.add_argument(
	'-e', '--efi', 
	action='store', 
	dest='partition_efi',
	type=str,
	help='Informe um partição para /boot/efi'
	)

# /HOME
parser.add_argument(
	'-H', '--home', 
	action='store', 
	dest='partition_home',
	type=str,
	help='Informe uma partição para /home - OPCIONAL'
	)

# Alvo de instalação.
parser.add_argument(
	'-t', '--target', 
	action='store', 
	dest='disk_instalation',
	type=str,
	required=True,
	help='Informe um disco para instalação do sistema. /dev/sdX'
	)

# Alvo de instalação.
parser.add_argument(
	'-r', '--root', 
	action='store', 
	dest='partition_root',
	type=str,
	required=True,
	help='Informe uma partição para / raiz do sistema - OBRIGATÓRIO.'
	)

args = parser.parse_args()

DiskTargetInfo.update({'target_root': args.partition_root})
DiskTargetInfo.update({'target_disk': args.disk_instalation})

if args.partition_boot:
	DiskTargetInfo.update({'target_boot': args.partition_boot})

if args.partition_efi:
	DiskTargetInfo.update({'target_efi': args.partition_efi})

if args.partition_home:
	DiskTargetInfo.update({'target_home': args.partition_home})

print(line)
print('Resumo')
print(line)
yellow('Disco alvo => {}'.format(DiskTargetInfo['target_disk']))
yellow('Partição raiz => {}'.format(DiskTargetInfo['target_root']))
if 'target_boot' in DiskTargetInfo: 
	yellow('Partição /boot => {}'.format(DiskTargetInfo['target_boot']))

if 'target_efi' in DiskTargetInfo: 
	yellow('Partição /boot/efi => {}'.format(DiskTargetInfo['target_efi']))

if 'target_home' in DiskTargetInfo: 
	yellow('Partição /home => {}'.format(DiskTargetInfo['target_home']))

YN = yes_no('Deseja prosseguir')
if YN != 'True':
	sys.exit()

os.system('clear')
yellow('Menu Principal')
yellow('0 - Sair')
yellow('1 - Instalar base ARCHLINUX')
yellow('2 - Instalar pos BASE - Opição usada após o arch-chroot')
yellow('3 - Instalar o grub')
yellow('4 - Instalar gnome-shell')
n = str(input('Digite um número e precione enter: '))

if n == '0':
	sys.exit()
elif n == '1':
	ArchUtiuls().install_base()
elif n == '2':
	ArchUtiuls().install_pos_base()
elif n == '3':
	ArchUtiuls().install_grub()
elif n == '4':
	ArchUtiuls().install_gnome()
