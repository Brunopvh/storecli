#!/usr/bin/env python3
#
#--------------------------------------------------------#
# REQUERIMENTS
# python 3.7 ou superior
# wget (módulo do python3 - pip3 install wget)
#
#
VERSION = '2020-03-06'
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

#----------------------------------------------------------#
dir_root = os.path.dirname(os.path.realpath(__file__)) # Endereço deste script no disco.
dir_run = os.getcwd()                                  # Diretório onde o terminal está aberto.
sys.path.insert(0, dir_root) # print(sys.path)

from modules.sys_info import *
from modules.colors import *

info = SysInfo()
os_id = info.get_id()
os_version = info.get_version()
os_codename = info.get_codename()
os_version_id = info.get_version_id()

#----------------------------------------------------------#

# Necessário python 3.7 ou superior.
if platform.python_version()[0:3] < '3.6':
	print(f'\033[93m[!] Necessário ter python 3.6 ou superior instalado, saindo...\033[m\n')
	sys.exit('1')

space_line = '====================================================='

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

print(f'Sistema: {os_id} {os_version_id}')

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
	'wine',
	'winetricks',
	'winrar',
	)

#----------------------------------------------------------#
# URLs
#----------------------------------------------------------#
repos_suse_emulators = ''
url_key_libfaudio_buster = 'https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10/Release.key'
url_key_libfaudio_bionic = 'https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/Release.key'
url_key_winehq = 'https://dl.winehq.org/wine-builds/winehq.key'

url_winrar = 'http://www.rarlab.com/rar/winrar-x64-571br.exe'
url_burnaware = 'http://download.betanews.com/download/1212419334-2/burnaware_free_12.4.exe'
url_vlc = 'https://get.videolan.org/vlc/3.0.8/win32/vlc-3.0.8-win32.exe'
url_peazip = 'https://osdn.net/frs/redir.php?m=c3sl&f=peazip%2F71536%2Fpeazip-6.9.2.WIN64.exe'
url_ffactory = 'http://www.pcfreetime.com/public/FFSetup4.8.0.0.exe'
url_epsxe = 'http://www.epsxe.com/files/ePSXe205.zip' 

#----------------------------------------------------------#
# Repositórios
#----------------------------------------------------------#
repos_emulators_buster = 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/Debian_10 ./'
repos_emulators_bionic = 'deb https://download.opensuse.org/repositories/Emulators:/Wine:/Debian/xUbuntu_18.04/ ./'
repos_wine_buster = 'deb https://dl.winehq.org/wine-builds/debian/ buster main'
repos_wine_bionic = 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'
repos_winetricks = 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'

#----------------------------------------------------------#
# Diretórios.
#----------------------------------------------------------#
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
#----------------------------------------------------------#
Winetricks_Script = (f'{dir_bin}/winetricks')
wine_file_repos = '/etc/apt/sources.list.d/wine.list'
path_file_winrar = (f'{dir_downloads}/{os.path.basename(url_winrar)}')

#----------------------------------------------------------#
def config_cli_utils():
	"""
	Instalar utlitários necessarios
	"""
	if (os_id == 'debian') or (os_id == 'linuxmint') or (os_id == 'ubuntu'):
		# Instalar utilitários de linha de comando antes de prosseguir.
		msg.white('Necessário instalar os pacotes: dirmngr apt-transport-https gnupg gpgv2 gpgv')
		os.system("sudo sh -c 'apt update; apt install -y dirmngr apt-transport-https gnupg gpgv2 gpgv'")

#----------------------------------------------------------#
class Setup_Wine:
	"""
	Instalar o wine no sistema incluindo dependências
	https://forum.winehq.org/viewtopic.php?f=8&t=32192
	https://forum.winehq.org/viewtopic.php?t=32061
	https://forum.winehq.org/viewtopic.php?f=8&t=32192
	"""

	def add_archi386():
		"""
		Adicionar suporte a arch 32 bits.
		"""
		print(space_line)
		msg.white('Adicionando suporte a arch i386')
		os.system(f"sudo dpkg --add-architecture i386")
		
	def buster():
		"""
		Instalar a depedência libfaudio no debian buster
		"""
		print(space_line)
		msg.white(f'Adicionando keys')
		print(url_key_libfaudio_buster, end=' ')
		os.system(f"sudo sh -c 'wget -qO- {url_key_libfaudio_buster} | apt-key add -'")

		print(url_key_winehq, end='')
		os.system(f"sudo sh -c 'wget -qO- {url_key_winehq} | apt-key add -'")

		ms.white(f'Adicionando repositórios {repos_emulators_buster} {repos_wine_buster}')
		os.system(f"echo {repos_emulators_buster} | sudo tee {file_repos}")
		os.system(f"echo {repos_wine_buster} | sudo tee {file_repos}")
		os.system('sudo apt update')

		print(space_line)
		msg.green('Instalando libfaudio')
		os.system('sudo apt install libfaudio0:i386')

	def bionic():
		"""
		Instalar a depedência libfaudio no ubuntu bionic
		"""
		print(space_line)
		msg.white(f'Adicionando keys')
		print(url_key_libfaudio_bionic, end=' ')
		os.system(f"sudo sh -c 'wget -qO- {url_key_libfaudio_bionic} | apt-key add -'")
		# sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys DFA175A75104960E

		print(url_key_winehq, end='')
		os.system(f"sudo sh -c 'wget -qO- {url_key_winehq} | apt-key add -'")

		msg.white(f'Adicionando repositórios {repos_emulators_bionic} {repos_wine_bionic}')
		os.system(f'sudo apt-add-repository {repos_emulators_bionic}')
		os.system(f'sudo apt-add-repository {repos_wine_bionic}')
		os.system('sudo apt update')

		print(space_line)
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

	if (os_codename == 'buster'):
		config_cli_utils()
		Setup_Wine.add_archi386()
		Setup_Wine.buster()
		Setup_Wine.winehq_debian()
		Setup_Wine.winetricks_debian()

	elif ((os_id == 'linuxmint') and (os_version_id[0:2] == '19')) or ((os_id == 'ubuntu') and (os_codename == 'bionic')):
		config_cli_utils()
		Setup_Wine.add_archi386()
		Setup_Wine.bionic()
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

def install_programs():

	for c in sys.argv[2:]:
		c = str(c)

		if c == str('wine '):
			install_wine()

		elif c == str('winetricks'):
			install_wine()

		elif c == str('winrar'):
			WindPrograms.winrar()
			os.system(f'wine {path_file_winrar}')

		else:
			msg.red(f'Programa indisponível: {c}')

#----------------------------------------------------------#

if sys.argv[1] == 'install':
	install_programs()

elif sys.argv[1] == '--list':
	for c in tup_programs:
		print(f'    {c}')








