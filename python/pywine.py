#!/usr/bin/env python3
#
#--------------------------------------------------------#
# REQUERIMENTS
# python 3.7 ou superior
# wget (módulo do python3 - pip3 install wget)
#
#
VERSION = '2020-02-23'
#

import os, sys
import getpass
import platform 
import re
import subprocess
import wget

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

def which_pkg(app):
	"""
	Usar o utilitário de linha de comando which para verificar a existência de um executável qualquer.
	"""

	if (subprocess.getstatusoutput(f'which {app} 2> /dev/null')[0]) == int('0'):
		return int('0') # Sucesso, o pacote executável existe.
	else:
		return int('1') # Falha, não existe.

#----------------------------------------------------------#
# Detectar versão do sistema e codenome se possível.
file_release = open('/etc/os-release', 'rt').readlines()

for i in file_release:
	i = i.replace('\n', '')
	i = str(i)
	if i[0:3] == 'ID=':
		i = i.replace('ID=', '')
		os_id = i
		break

os_codename = 'none'
for c in file_release:
	c = c.replace('\n', '')
	c = str(c)
	if c[0:17] == 'VERSION_CODENAME=':
		os_codename = c.replace('"', '').replace('VERSION_CODENAME=', '')
		break

#----------------------------------------------------------#

def install_wine_debian():
	"""
	Instalação do wine no debian e ubuntu.
	"""

	# Habilitar suporte a arquitetura 32 bits no kernel.
	msg.green('Habilitando suporte a arquitetura 32 bits.')
	os.system("sudo dpkg --add-architecture i386")

	msg.green('Instalando o wine')
	os.system('sudo apt install --install-recommends wine wine32 wine64')
	os.system('sudo apt install -y winetricks')

	# Suporte a icones .exe do windows.
	#os.system(f'sudo apt install --no-install-recommends gnome-colors-common gnome-wine-icon-theme gtk2-engines-murrine')
	#os.system(f'sudo apt install --no-install-recommends gnome-exe-thumbnailer')

#----------------------------------------------------------#

def install_wine_fedora():
	os.system('sudo dnf install wine winetricks')

#----------------------------------------------------------#

def install_wine():
	"""
	Instalar o wine de acordo com cada distribuição/sistema Linux.
	"""

	msg.green('Necessário instalar o wine para prosseguir')
	sn = str(input('=> Deseja instalar agora? [s/n]: ')).lower()

	if sn != 's': # Usuário escolheu não instalar.
		msg.red('Abortando.')
		sys.exit('1')

	if os_id == 'debian':
		install_wine_debian()
	elif (os_id == 'ubuntu') or (os_id == 'linuxmint'):
		install_wine_debian() 
	elif os_id == 'fedora':
		install_wine_fedora()
	else:
		msg.red(f'[!] Sistema incompativél {os_id}, instale o "wine e winetricks" manualmente.')
		sys.exit('1')

#----------------------------------------------------------#
def install_winetricks():
	"""
	Instalar o script winetricks na HOME.
	"""

	tup_winetricks = ('zenity cabextract unrar unzip wget aria2 curl')
	tup_debian = ('binutils fuseiso p7zip-full policykit-1 tor xdg-utils xz-utils')
	tup_suse = ('binutils fuseiso p7zip polkit tor xdg-utils xz')
	repos_winetricks = 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'

	msg.green(f'Instalando {tup_winetricks}')
	
	if which_pkg('zypper') == int('0'): # Suse
		os.system(f'sudo zypper in {tup_winetricks}')

		msg.green(f'Instalando {tup_suse}')
		os.system(f'sudo zypper in {tup_suse}')
	elif which_pkg('dnf') == int('0'): # Fedora
		os.system(f'sudo dnf install {tup_winetricks}')

		msg.green(f'Instalando {tup_suse}') 
		os.system(f'sudo dnf install {tup_suse}')
	elif which_pkg('apt') == int('0'): # Debian
		os.system(f'sudo apt install {tup_winetricks}') 

		msg.green(f'Instalando {tup_suse}')
		os.system(f'sudo apt install {tup_debian}')

	msg.white('Instalando winetricks')
	os.system(f'curl -sSL {repos_winetricks} -o {dir_bin}/winetricks')
	os.system(f'chmod a+x {dir_bin}/winetricks')
	#os.system(f'sudo cp -u {dir_bin}/winetricks /usr/local/bin')

	if which_pkg('winetricks') == int('0'):
		msg.white('winetricks instalado com sucesso')
	else:
		msg.red('Falha na instalação de winetricks')

#----------------------------------------------------------#
# Diretórios
# /home/bruno/.wine/drive_c/Program Files/WinRAR
#----------------------------------------------------------#
dir_root = os.path.dirname(os.path.realpath(__file__)) # Diretório onde este script está.
dir_run = os.getcwd()                                  # Diretório onde o terminal está aberto.
dir_home = Path.home()                                 # Home do usuário.
dir_downloads = (f'{dir_home}/.cache/pywine')          # Local onde este script irá baixar os arquivos.
dir_bin = (f'{dir_home}/.local/bin')                   # Local para binarios e executáveis na home.
drive_c = (f'{dir_home}/.wine/drive_c')                # Local simbolico do disco "C:" do windows.
dir_win64 = (f'{drive_c}/"Program Files"')             # Local de programas 64 bits
dir_win32 = (f'{drive_c}/"Program Files (x86)"')             # Local de programas 32 bits

tup_dirs = (dir_root, dir_run, dir_downloads, dir_bin)
# Criar os diretórios acima se for necessário.
for c in tup_dirs:
	if os.path.isdir(c) == False:
		msg.white(f'Criando diretório [{c}]')
		os.makedirs(c)

#----------------------------------------------------------#
# Url dos programas
#----------------------------------------------------------#
url_burnaware = 'http://download.betanews.com/download/1212419334-2/burnaware_free_12.4.exe'
url_formatfactory = 'http://www.pcfreetime.com/public/FFSetup4.8.0.0.exe'
url_peazip = 'https://osdn.net/frs/redir.php?m=c3sl&f=peazip%2F71536%2Fpeazip-6.9.2.WIN64.exe'
url_vlc = 'https://get.videolan.org/vlc/3.0.8/win32/vlc-3.0.8-win32.exe'
url_winrar = 'http://www.rarlab.com/rar/winrar-x64-571br.exe'
url_winetricks = 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'

#----------------------------------------------------------#
# Arquivos
# os arquivos serão salvos com os nomes abaixo.
#----------------------------------------------------------#
path_burnaware = (f'{dir_downloads}/{os.path.basename(url_burnaware)}')
path_formatfactory = (f'{dir_downloads}/{os.path.basename(url_formatfactory)}')
path_peazip = (f'{dir_downloads}/peazip-6.9.2.WIN64.exe')
path_vlc = (f'{dir_downloads}/{os.path.basename(url_vlc)}')
path_winrar = (f'{dir_downloads}/{os.path.basename(url_winrar)}')

Script_winetricks = (f'{dir_bin}/winetricks')

#----------------------------------------------------------#
def WGET(URL, FILE):
	"""
	Fazer o download os arquivos.
	"""

	if os.path.isfile(FILE):
		msg.white(f'Arquivo já em cache [{FILE}]')
		_sn = str(input('=> Deseja baixar novamente [s/n]?: ')).lower()
		if _sn == 's':
			os.remove(FILE)
		else:
			return int('0')

	msg.white(f'Baixando [{URL}]')
	msg.white(f'Destino [{FILE}]')

	try:
		wget.download(URL, FILE)
	except KeyboardInterrupt:
		msg.white('Interrompido com [Ctrl + c].') 
		print(' ')
		if os.path.isfile(FILE) == True: os.remove(FILE) # Remover o arquivo.
		sys.exit('1')
	except:
		msg.white('Falha no download.')
		if os.path.isfile(FILE) == True: os.remove(FILE) # Remover o arquivo.
		sys.exit('1')

#----------------------------------------------------------#
def _download(pkg):
	"""
	Informar para esta função o pacote que deseja baixar.
	"""

	if pkg == 'burnaware':
		WGET(url_burnaware, path_burnaware)

	elif pkg == 'formatfactory':
		WGET(url_formatfactory, path_formatfactory)

	elif pkg == 'peazip':
		WGET(url_peazip, path_peazip)

	elif pkg == 'vlc':
		WGET(url_vlc, path_vlc)

	elif pkg == 'winrar':
		WGET(url_winrar, path_winrar)

	else:
		msg.red(f'Programa indisponivel: [{pkg}]')

#----------------------------------------------------------#
# Pacotes disponiveis para instalação.
tup_pkgs = (
'7zip', 
'burnaware', 
'formatfactory', 
'office2007',
'peazip', 
'q4wine', 
'vlc', 
'wine',
'winrar' 
)

#----------------------------------------------------------#
# Instalar o wine se ainda não estiver instalado.
if which_pkg('wine') != int('0'):
	install_wine() # Instalar.
	
# Instalar o script winetricks na HOME.
if subprocess.getstatusoutput(f'[ -x {Script_winetricks} ]')[0] != int('0'):
	install_winetricks()

#----------------------------------------------------------#
def configure_wine():
	msg.white('Aguarde...')
	os.system('winecfg')


def install_pkgs(ARGS):
	for c in ARGS:

		if c == '7zip':
			os.system(f'{Script_winetricks} 7zip')

		elif c == 'burnaware':
			_download('burnaware')
			os.system(f'wine {path_burnaware}')

		elif c == 'peazip':
			_download('peazip')
			os.system(f'wine {path_peazip}')

		elif c == 'vlc':
			_download('vlc')
			os.system(f'wine {path_vlc}')

		elif c == 'wine':
			install_wine()

		elif c == 'winetricks':
			install_winetricks()

		elif c == 'winrar':
			_download('winrar')
			os.system(f'wine {path_winrar}')

		else:
			msg.red(f'Programa indisponivel: {c}')

#----------------------------------------------------------#

if len(sys.argv) >= int('2'):
	if sys.argv[1] == '--configure':
		configure_wine()

	elif sys.argv[1] == '--list':
		for c in tup_pkgs:
			print(f'       {c}')

	elif sys.argv[1] == 'install':
		ARGS = sys.argv[2:]
		install_pkgs(ARGS)





