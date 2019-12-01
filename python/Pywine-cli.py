#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Requerimentos: wget (python3)
# 
# Use: --help
# git clone https://github.com/Brunopvh/storecli.git
#
VERSION = '2019-12-01'
#
#

import os, sys, getpass, platform, re
import subprocess
import wget
from pathlib import Path

dir_root = os.path.dirname(os.path.realpath(__file__))
dir_run = os.getcwd() 
dir_home = Path.home()
dir_dow = (f'{dir_home}/.cache/downloads')

#os.system('clear')

os_type = str(platform.system())

if os.path.isfile('/etc/os-release'): 
	file_release = '/etc/os-release'
	cont_file = open(file_release, 'rt').readlines()
	
#-----------------------------------------------#

R='\033[1;31m'
G='\033[1;32m'; g = '\033[32m'
Y='\033[1;33m'
RS='\033[m'

#-----------------------------------------------#
# os_id

def _os_id():
	if  os_type == 'Linux':
		for c in cont_file:
			if c[0:3] == 'ID=':
				os_id = c.replace('\n', '').replace('ID=', '').replace('"', '')
				break
	os_id = os_id			
	return os_id

#-----------------------------------------------#
# os_version

def _os_version():
	if os_type == 'Linux':
		for c in cont_file:
			if c[0:11] == 'VERSION_ID=':
				os_version = c.replace('"', '').replace('\n', '').replace('VERSION_ID=', '')

	return os_version

#-----------------------------------------------#

def _os_release():
	os_release = ' '
	if os_type == 'Linux':
		for c in cont_file:
			if c[0:8] == 'VERSION=':
				os_release = c.replace('"', '').replace('\n', '').replace('VERSION=', '')

	del_lis = ['.', '_', '(', ')']
	del_num = re.findall(r'\d', os_release)
	for n in del_num:
		if n in os_release: os_release = os_release.replace(n, '')
		
	for c in del_lis:
		os_release = os_release.replace(c, '').strip()


	return os_release

#-----------------------------------------------#

def _os_codename():
	os_codename = ' '
	if os_type == 'Linux':
		for c in cont_file:
			if c[0:17] == 'VERSION_CODENAME=':
				os_codename = c.replace('"', '').replace('\n', '').replace('VERSION_CODENAME=', '')
				break
			else:
				os_codename = ' '

	return os_codename


#-----------------------------------------------#

try:
	os_id = _os_id() # ID
	os_version = _os_version() # Version
	os_release = _os_release() # Release
	os_codename = _os_codename() # Codename
	sysname = (f'{os_id}{os_version}') # Sys

except:
	print('=' * 40); print(f'{R}[Falha ao tentar detectar o sistema]{RS}'); print('=' * 40)
	sys.exit()

#-----------------------------------------------#
# Se for Debian ou derivado checar (BASE)
#-----------------------------------------------#

if (os_id == 'debian') or (os_id == 'linuxmint') or (os_id == 'ubuntu'):
	debian_base = subprocess.getstatusoutput('cat /etc/debian_version') # 'buster/sid'

#-----------------------------------------------#

#===============================================#
# Listas
#===============================================#
lista_apps = [
'7zip', 
'burnaware', 
'formatfactory', 
'office2007'
'peazip', 
'q4wine', 
'vlc', 
'wine', 
'winetricks', 
'winrar' 
]

#-----------------------------------------------#

def usage():
	print(f"""Use:
   {sys.argv[0]} --help|--version

   --help                Mostra ajuda e sai.
   --version             Mostra versão e sai.
   --list                Lista aplicativos disponíveis para instalação.

   install <pacote>      Instala um ou mais programas.     
                            Ex: {sys.argv[0]} install wine winetricks vlc
   
   download <pacote>     Baixa um ou mais programas.
                            EX {sys.argv[0]} download peazip vlc winrar
		""")

	sys.exit()

#-----------------------------------------------#

def list_apps():
	for app in lista_apps: print(f'{app}')

#-----------------------------------------------#
if len(sys.argv) < 2: usage(); exit() 

if sys.argv[1] == '--help':
	usage()
elif sys.argv[1] == '--version':
	print(f'{os.path.basename(sys.argv[0])} V{VERSION}'); exit()
elif sys.argv[1] == '--list':
	list_apps()


#-----------------------------------------------#

def _msgs(msg, c=''):
	print(c, end=''); print(f'-> {msg}', end=''); print(RS)

#-----------------------------------------------#

_msgs(f'{os_id} {os_version}', g)

#-----------------------------------------------#

def _Grep(texto, arq):
	"""
	Informar um texto seguido de um arquivo a ser filtrado.
	será retornado uma lista com o conteúdo encontrado no arquivo
	se existir.
	"""

	if os.path.isfile(arq) == False: 
		_msgs(f'Arquivo não econtrado: {arq}', R)
		return '1'

	leitor = open(arq, 'rt').readlines()

	filtro = []; num = int('0')
	for linha in leitor:
		if texto in linha:
			linha = str(linha.replace('\n', ''))
			filtro.insert(num, linha)
			num += 1

	open(arq).seek(0)
	return filtro

#-----------------------------------------------#

def sys_status(comando):
	"""
	Executar o comando e retornar o status de saída
	seguido da saída no terminal texto/erros/mensagens/etc.
	Será retornado uma lista.
	"""
	status, output = subprocess.getstatusoutput(comando)

	return [status, output] # status + stdout.

#-----------------------------------------------#
# Criar diretórios
#-----------------------------------------------#
os.system('mkdir -p ~/.local/bin')
os.system('mkdir -p ~/.cache/downloads')
dir_home = Path.home()
dir_user_cache = (f'{dir_home}/.cache/downloads')

#===============================================#
# Urls dos programas
#===============================================#
url_burnaware = 'http://download.betanews.com/download/1212419334-2/burnaware_free_12.4.exe'
url_formatfactory = 'http://www.pcfreetime.com/public/FFSetup4.8.0.0.exe'
url_peazip = 'https://osdn.net/frs/redir.php?m=c3sl&f=peazip%2F71536%2Fpeazip-6.9.2.WIN64.exe'
url_vlc = 'https://get.videolan.org/vlc/3.0.8/win32/vlc-3.0.8-win32.exe'
url_winrar = 'http://www.rarlab.com/rar/winrar-x64-571br.exe' 

#===============================================#
# Nomes/destino dos programas.
#===============================================#
path_burnaware = (f'{dir_user_cache}/burnaware_free_12.4.exe')
path_formatfactory = (f'{dir_user_cache}/FFSetup4.8.0.0.exe')
path_peazip = (f'{dir_user_cache}/peazip-6.9.2.WIN64.exe')
path_vlc = (f'{dir_user_cache}/vlc-3.0.8-win32.exe')
path_winrar = (f'{dir_user_cache}/winrar-x64.exe')

#===============================================#
# Download
#===============================================#
def _Wget(url, path_file):
	if os.path.isdir(dir_user_cache) == False: os.makedirs(dir_user_cache)

	if os.path.isfile(path_file) == True:
		_msgs(f'Arquivo encontrado em: {path_file}', G)
		return

	try:
		print(f'{G}Baixando: {RS}{path_file}')
		print(f'{G}Url: {RS}{url}')
		wget.download(url, path_file); print(' [OK]')

	except KeyboardInterrupt:
		print(f'{R}Interrompido com Ctrl c{RS}')
		os.remove(path_file)
		return

	except:
		print(f'{R}Falha no download{RS}')
		os.remove(path_file)
		return

#-----------------------------------------------#

def _download(pkg):
	if pkg == 'burnaware':
		_Wget(url_burnaware, path_burnaware)

	elif pkg == 'formatfactory':
		_Wget(url_formatfactory, path_formatfactory)

	elif pkg == 'peazip':
		_Wget(url_peazip, path_peazip)

	elif pkg == 'vlc':
		_Wget(url_vlc, path_vlc)

	elif pkg == 'winrar':
		_Wget(url_winrar, path_winrar)

#-----------------------------------------------#
# Wine requeriments Debian/Ubuntu
#-----------------------------------------------#

def _install_wine_requeriments_debian():

	lista_wine_utils = [
'libc6', 
'libasound2:i386', 
'wine-stable-i386:i386',  
'wine-stable-amd64', 
'wine-stable'
]
	
	for i in lista_wine_utils:
		_msgs(f'Instalando: {i}', G)
		os.system(f'sudo apt install -y --install-recommends {i}')

	_msgs('Instalando winehq-stable', G)
	os.system('sudo apt install -y winehq-stable') # Wine Hq stable.

	# Suporte a icones .exe do windows.
	os.system(f'sudo apt install --no-install-recommends gnome-colors-common gnome-wine-icon-theme gtk2-engines-murrine')
	os.system(f'sudo apt install --no-install-recommends gnome-exe-thumbnailer')
		

#-----------------------------------------------#
# Wine Ubuntu
#-----------------------------------------------#

def _install_wine_debian(): # Debian/Ubuntu/LinuxMint
	wine_file = '/etc/apt/sources.list.d/wine.list'

	if (os_codename == 'tina') or (os_codename == 'bionic'):
		wine_repo = 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

	elif os_codename == 'buster':
		wine_repo = 'deb https://dl.winehq.org/wine-builds/debian/ buster main'
	
	_msgs('-> Instalando utilitários', G)
	os.system("sudo sh -c 'apt update; apt install -y dirmngr git apt-transport-https gnupg gpgv2 gpgv'")
	
	
	_msgs(f'Adicionando repositório em: {wine_file}', G)
	os.system(f"echo {wine_repo} | sudo tee {wine_file}")
	os.system(f"sudo sh -c 'wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | apt-key add -'")
		

	_install_wine_requeriments_debian()

		
#-----------------------------------------------#
# Install Winetricks
#-----------------------------------------------#

def _install_winetricks():

	shell_cmd = sys_status('command -v wine') # Existe wine.
	if int(shell_cmd[0]) != int('0'):
		_msgs('Instale o wine', R)
		return '1'

	tupla_winetricks = ('zenity cabextract unrar unzip wget aria2 wget curl')
	tupla_debian = ('binutils fuseiso p7zip-full policykit-1 tor xdg-utils xz-utils')
	tupla_suse = ('binutils fuseiso p7zip polkit tor xdg-utils xz')
	repos_winetricks = 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'

	shell_cmd = sys_status('command -v winetricks') # Existe winetricks.
		
	if int(shell_cmd[0]) == int('0'):
		_msgs(f'Winetricks instalado em: {shell_cmd[1]}', G) 
		return
	
	_msgs(f'Instalando {tupla_winetricks}', G)

	if int(sys_status('command -v zypper')[0]) == int('0'): # Suse
		os.system(f'sudo zypper in {tupla_winetricks} {tupla_suse}')

	elif int(sys_status('command -v dnf')[0]) == int('0'): # Fedora
		os.system(f'sudo dnf install {tupla_winetricks} {tupla_suse}')

	elif int(sys_status('command -v apt')[0]) == int('0'): # Debian
		os.system(f'sudo apt install {tupla_winetricks} {tupla_debian}')


	_msgs('Instalando winetricks', G)
	os.system(f'wget {repos_winetricks} -O ~/.local/bin/winetricks')
	os.system('chmod a+x ~/.local/bin/winetricks')
	os.system('sudo cp -u ~/.local/bin/winetricks /usr/local/bin')

	if int(sys_status('command -v winetricks')[0]) == int('0'):
		_msgs('Winetricks instalado com sucesso.', G)
	else:
		_msgs('Falha na instalação de winetricks', R)

#-----------------------------------------------#

def _install_wine():

	if (os_id == 'debian') or (os_id == 'linuxmint') or (os_id == 'ubuntu'):
		_install_wine_debian() # Debian/Ubuntu/Mint

#-----------------------------------------------#

#===============================================#
#===============================================#
# Programas Windows.
#===============================================#
#===============================================#

def burnaware():
	_download('burnaware')
	os.system(f'wine {path_burnaware}')

#-----------------------------------------------#

def format_factory():
	_download('formatfactory')
	os.system(f'wine {path_formatfactory}')

#-----------------------------------------------#

def office2007():

	sys_out = subprocess.getstatusoutput('command -v winetricks 2> /dev/null')
	if int(sys_out[0]) != int('0'):
		_msgs('Instale o winetricks primeiro', R)
		_msgs(f'Use: {sys.argv[0]} install winetricks', R)
		return '1'

	_msgs('Necessário o CD de instalação volume OFFICE12', G)
	_sn = input('Deseja prosseguir [s/n] ? : ').lower().strip()

	if _sn == 's':
		os.system('winetricks office2007pro WINEARCH=win32')

#-----------------------------------------------#

def peazip():
	_download('peazip')
	os.system(f'wine {path_peazip}')

#-----------------------------------------------#

def vlc():
	_download('vlc')
	os.system(f'wine {path_vlc}')

#-----------------------------------------------#

def winrar():
	_download('winrar')
	os.system(f'wine {path_winrar}')

#-----------------------------------------------#

def _install():
	args = sys.argv[2:]
	for num in range(0, len(args)):
		if args[num] == 'wine': # Wine
			_install_wine()

		elif args[num] == 'winetricks': # Winetricks
			_install_winetricks()
#------------------------------------------------#
		elif args[num] == '7zip':
			os.system('winetricks 7zip')

		elif args[num] == 'burnaware':
			burnaware()

		elif args[num] == 'formatfactory':
			format_factory()

		elif args[num] == 'office2007':
			office2007()

		elif args[num] == 'peazip':
			peazip()

		elif args[num] == 'vlc':
			vlc()

		elif args[num] == 'winrar':
			winrar()

		else:
			_msgs(f'Programa não encontrado: {args[num]}', R)

#-----------------------------------------------#

if sys.argv[1] == 'install': # Instalação.
	_install() 
	
elif sys.argv[1] == 'download': # Download.
	args = sys.argv[2:]
	for num in range(0, len(args)):
		_download(args[num])

	_msgs('Feito somente download', G)
