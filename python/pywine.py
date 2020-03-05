#!/usr/bin/env python3
#
#--------------------------------------------------------#
# REQUERIMENTS
# python 3.7 ou superior
# wget (módulo do python3 - pip3 install wget)
#
#
VERSION = '2020-03-05'
#

import os, sys
import getpass
import platform 
import re
import subprocess
import wget
import urllib.request   # urllib.request.urlopen(url)
from time import sleep
from pathlib import Path

# Necessário python 3.7 ou superior.
if platform.python_version()[0:3] < '3.7':
	print(f'\033[93m[!] Necessário ter python 3.7 ou superior instalado, saindo...\033[m\n')
	sys.exit('1')

Red = '\033[1;31m'
Green = '\033[1;32m'
Yellow = '\033[1;33m'
White = '\033[1;37m'
Reset = '\033[m'

space_line = '====================================================='

#----------------------------------------------------------#
class C:
	"""
	Altera a cor do terminal (Color).
	"""

	def red():
		print(Red, end='')

	def green():
		print(Green, end='')

	def yellow():
		print(Yellow, end='')

	def white():
		print(White, end='')

	def reset():
		print(Reset, end='')
		
#----------------------------------------------------------#
class msg:
	"""
	Exibe mensagem com determinada cor.
	"""

	def red(text):
		print('=> ', end='')
		C.red()
		print(f'{text}')
		C.reset()
	
	def green(text):
		print('=> ', end='')
		print(f'{Green}{text}{Reset}')

	def yellow(text):
		print('=> ', end='')
		print(f'{Yellow}{text}{Reset}')
		

	def white(text):
		print('=> ', end='')
		print(f'{White}{text}{Reset}')

#----------------------------------------------------------#

# Verificar se o sistema e Linux.
if platform.system() != 'Linux':
	msg.red('[-] Seu sistema não é Linux.')
	sys.exit('1')

# Limpar a tela do console.
os.system('clear')

# Usuário não pode ser "root"
if getpass.getuser() == 'root': 
	msg.red('Usuário não pode ser o [root]')
	sys.exit('1')

# Detectar versão do sistema.
file_release = '/etc/os-release' # Arquivo que contém informações do sistema.
lines_release = open(file_release, 'rt').readlines()

#----------------------------------------------------------#
class SysInfo:
	"""
	Retornar informações do sistma como nome (debian/ubuntu/fedora...)

	info = SysInfo()

	print(f'Id -> {info.get_id()}')
	print(f'Version Id -> {info.get_version_id()}')
	print(f'Id Like -> {info.get_id_like()}')
	print(f'Version -> {info.get_version()}')
	print(f'Codename -> {info.get_codename()}')
	"""

	# ID
	def get_id(self):
		for i in lines_release:
			if i[0:3] == 'ID=':
				os_id = i.replace('\n', '').replace('"', '').replace('ID=', '')
				break

		self.os_id = os_id
		return self.os_id
		
	# Id Like
	def get_id_like(self):
		os_id_like = 'NoNe'
		for i in lines_release:
			if i[0:8] == 'ID_LIKE=':
				i = i.replace('\n', '').replace('"', '').replace('ID_LIKE=', '')
				os_id_like = i.replace(' ', '_')
				break

		self.os_id_like = os_id_like
		return self.os_id_like

	# Version Id
	def get_version_id(self):
		os_version_id = 'NoNe'
		for i in lines_release:
			if i[0:11] == 'VERSION_ID=':
				os_version_id = i.replace('\n', '').replace('"', '').replace('VERSION_ID=', '')
				break

		self.os_version_id = os_version_id
		return self.os_version_id

	# Version
	def get_version(self):
		os_version = 'NoNe'
		for i in lines_release:
			if i[0:8] == 'VERSION=':
				i = i.replace('\n', '').replace('"', '').replace('VERSION=', '')
				os_version = i.replace('(', '').replace(')', '').replace(' ', '_')
				break

		self.os_version = os_version
		return os_version

	# Codename
	def get_codename(self):
		os_codename = 'NoNe'
		for i in lines_release:
			if i[0:17] == 'VERSION_CODENAME=':
				os_codename = i.replace('\n', '').replace('"', '').replace('VERSION_CODENAME=', '')
				break

		self.os_codename = os_codename
		return self.os_codename

#----------------------------------------------------------#

info = SysInfo()
os_id = info.get_id()
os_version = info.get_version()
os_codename = info.get_codename()
os_version_id = info.get_version_id()

#----------------------------------------------------------#
# Ajuda
def usage():
	print(f"""
   Use: {os.path.basename(sys.argv[0])} --help|--version|--list|install

     --help                   Mostar ajuda.
     --version                Mostra versão.
     --list                   Mostra pacotes disponiveis para instalação.
     install <pacote>         Instala um pacote.
""")

	exit()

if len(sys.argv) >= int('2'):
	if sys.argv[1] == '--help':
		usage()
	elif sys.argv[1] == '--version':
		print(f'V{VERSION}')
		exit()

#----------------------------------------------------------#
# URLs
url_suse_repo = 'https://download.opensuse.org/repositories/Emulators'
url_emulator_debian = (f'{url_suse_repo}/:/Wine:/Debian')
url_libfaudio_buster_default = (f'{url_emulator_debian}/Debian_10/amd64/libfaudio0_20.01-0~buster_amd64.deb')

url_key_buster = (f'{url_suse_repo}:/Wine:/Debian/Debian_10/Release.key')
url_key_winestable = 'https://dl.winehq.org/wine-builds/winehq.key'

url_winrar = 'http://www.rarlab.com/rar/winrar-x64-571br.exe'
url_burnaware = 'http://download.betanews.com/download/1212419334-2/burnaware_free_12.4.exe'
url_vlc = 'https://get.videolan.org/vlc/3.0.8/win32/vlc-3.0.8-win32.exe'
url_peazip = 'https://osdn.net/frs/redir.php?m=c3sl&f=peazip%2F71536%2Fpeazip-6.9.2.WIN64.exe'
url_ffactory = 'http://www.pcfreetime.com/public/FFSetup4.8.0.0.exe'
url_epsxe = 'http://www.epsxe.com/files/ePSXe205.zip' 

#----------------------------------------------------------#
# Repositórios
repos_emulators_buster = 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./'
repos_wine_buster = 'deb https://dl.winehq.org/wine-builds/debian/ buster main'
repos_winetricks = 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'

#----------------------------------------------------------#
# Requerimentos wine para debian e dirivados.
tup_requeriments_debian = (
	'libc6', 
	'libasound2:i386', 
	'wine-stable-i386:i386', 
	'wine-stable-i386:i386', 
	'wine-stable-amd64', 
	'wine-stable'
)

tup_requeriments_winetricks = (
	'zenity',
	'cabextract', 
	'unrar', 
	'unzip', 
	'wget', 
	'aria2', 
	'curl',
	'tor'
)

tup_requeriments_winetricks_debian = (
	'binutils', 
	'fuseiso', 
	'p7zip-full', 
	'policykit-1', 
	'xz-utils'
)

tup_requeriments_winetricks_suse = (
	'binutils', 
	'fuseiso', 
	'p7zip', 
	'polkit',  
	'xdg-utils',
	'xz'
)

# Lista de programas disponiveis para instalção.
tup_programs = (
	'wine'
	'winetricks'
	'winrar'
	)

#----------------------------------------------------------#
# Diretórios.
dir_root = os.path.dirname(os.path.realpath(__file__)) # Endereço deste script no disco.
dir_run = os.getcwd()                                  # Diretório onde o terminal está aberto.

dir_home = Path.home()                       # Home do usuario
dir_bin = (f'{dir_home}/.local/bin')         # Local de binarios na home
dir_downloads = (f'{dir_home}/.cache/downloads')  # Cache temporário para downloads
dir_wine = (f'{dir_home}/.wine')             # Pasta dos aplicativos wine na home.
dir_drive_c = (f'{dir_wine}/drive_c')        #

tup_dirs = (dir_bin, dir_downloads)          # Tupla com diretórios.
for d in tup_dirs:
	if os.path.isdir(d) == False:
		os.makedirs(d)                       # Criar diretórios.

#----------------------------------------------------------#
# Arquivos
Winetricks_Script = (f'{dir_bin}/winetricks')

path_file_winrar = (f'{dir_downloads}/{os.path.basename(url_winrar)}')

#----------------------------------------------------------#
class Setup_Wine:
	"""
	Instalar o wine no sistema incluindo dependências
	"""

	def libfaudio_buster():
		"""
		Instalar a depedência libfaudio no debian buster
		"""

		# Instalar utilitários de linha de comando antes de prosseguir.
		msg.white('Necessário instalar os pacotes: dirmngr apt-transport-https gnupg gpgv2 gpgv')
		os.system("sudo sh -c 'apt update; apt install -y dirmngr apt-transport-https gnupg gpgv2 gpgv'")

		# Importar keys
		print(space_line)
		msg.white('Adicionando keys aguarde')
		os.system(f"sudo sh -c 'wget -qO- {url_key_buster} | apt-key add -'") # key para libfaudio
		os.system(f"sudo sh -c 'wget -qO- {url_key_winestable} | apt-key add -'") # Key para wine-stable

		#  Adicionar repositórios no sistema
		msg.white('Adicionando repositórios aguarde')
		os.system(f"echo {repos_wine_buster} | sudo tee /etc/apt/sources.list.d/wine.list")
		os.system(f"echo {repos_emulators_buster} | sudo tee /etc/apt/sources.list.d/emulators.list")

		# Adicionar suporte a arch 32 bits.
		print(space_line)
		msg.white('Adicionando suporte a arch i386')
		os.system(f"sudo dpkg --add-architecture i386")
		os.system('sudo apt update')
		
		# Instalar libfaudio
		msg.green('Instalando libfaudio')
		os.system('sudo apt install libfaudio0:i386')

		
	def winehq_debian():
		"""
		Instalar requerimentos e em seguida o winehq-stable
		"""

		# Instalar um por vez nesta ordem para não ter problemas com pacotes quebrados.
		for c in tup_requeriments_debian:
			print(space_line)
			msg.green(f'Instalando: {c}')
			os.system(f'sudo apt install --install-recommends {c}')

		print(space_line)
		msg.white('Instalando winehq-stable')
		os.system('sudo apt install -y winehq-stable')


		# Suporte a icones .exe do windows.
		print(space_line)
		msg.white('Instalando recomendações')
		os.system(f'sudo apt install --no-install-recommends gnome-colors-common gnome-wine-icon-theme gtk2-engines-murrine -y')
		os.system(f'sudo apt install --no-install-recommends gnome-exe-thumbnailer -y')


	def winetricks_debian():
		"""
		Instalar o script winetricks na HOME.
		"""

		#--------------| Instalar requerimentos |--------------#
		for c in tup_requeriments_winetricks:
			print(space_line)
			msg.white(f'Instalando: {c}')
			os.system(f'sudo apt install {c}')

		for c in tup_requeriments_debian:
			print(space_line)
			msg.white(f'Instalando: {c}')
			os.system(f'sudo apt install {c}')

		if os.path.isfile(Winetricks_Script) == True:
			return int('0')


		# Instalar winetricks
		msg.white(f'Instalando winetricks')
		os.system(f'curl -SL {repos_winetricks} -o {Winetricks_Script}')

		if os.path.isfile(Winetricks_Script) == True:
			msg.white('[+] Sucesso')
			os.system(f'chmod a+x {Winetricks_Script}')
		else:
			msg.red('[!] Falha')
		
#----------------------------------------------------------#

def which_pkg(app):
	"""
	Usar o utilitário de linha de comando which para verificar a existência de um executável qualquer.
	"""
	
	if (subprocess.getstatusoutput(f'which {app} 2> /dev/null')[0]) == int('0'):
		return int('0') # Sucesso, o pacote executável existe.
	else:
		return int('1') # Falha, não existe.

#----------------------------------------------------------#

def install_wine():
	"""
	Esta função verifica qual é o sistema atual (ubunt/fedora/mint) e em seguida instala o wine
	de acordo com o sistema.
	"""

	if (os_id == 'debian') and (os_codename == 'buster'):
		Setup_Wine.libfaudio_buster()
		Setup_Wine.winehq_debian()
		Setup_Wine.winetricks_debian()

	elif os_id == 'fedora':
		os.system('sudo dnf install wine')

	else:
		msg.red('Programa indisponível para seu sistema.')
		sys.exit('1')

#----------------------------------------------------------#
# Verificar se o wine já está instalado, caso não esteja o usuario será indagado a respeito de instalação.
if which_pkg('wine') != int('0'):
	print(space_line)
	sn = str(input('Necessário instalar o winehq-stable deseja proseguir [s/n]?: ').lower())
	if sn != 's':
		exit()

	install_wine()

#----------------------------------------------------------#
# Verificar se o winetricks já está instalado, caso não esteja o usuario será indagado a respeito de instalação.
if which_pkg('winetricks') != int('0'):
	print(space_line)
	sn = str(input('Necessário instalar o script winetricks deseja proseguir [s/n]?: ').lower())
	if sn != 's':
		exit()

	install_wine()


#----------------------------------------------------------#
# Programas windows
#----------------------------------------------------------#
def down(url, path_file):

	if os.path.isfile(path_file) == True:
		msg.white(f'Arquivo em cache [{path_file}]')
		return int('0')


	print(space_line)
	msg.white(f'Baixando [{url}]')
	msg.white(f'Destino [{path_file}]')

	try:
		wget.download(url, path_file)
		print(' OK')

	except(KeyboardInterrupt):
		msg.red('Interrompido com Ctrl c'); sleep(0.5)
		if os.path.isfile(path_file): 
			os.remove(path_file)
        
		exit()

	except:
		msg.red('Falha no download'); sleep(0.5)
		if os.path.isfile(path_file): 
			os.remove(path_file)

	exit()

class WindPrograms:
	
	def winrar():
		# Baixar o arquivo de instalação.
		down(url_winrar, path_file_winrar)

#----------------------------------------------------------#

def install_programs(args):

	for c in args:

		if c == 'wine ':
			install_wine()

		elif c == 'winetricks':
			install_wine()

		elif c == 'winrar':
			WindPrograms.winrar()
			os.system(f'wine {path_file_winrar}')

		else:
			msg.red(f'Programa indisponível: {c}')

if sys.argv[1] == 'install':
	list_args = sys.argv[2:]
	install_programs(list_args)








