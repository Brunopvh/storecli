#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Requerimentos: wget (python3)
# 
# Use: --help
# git clone https://github.com/Brunopvh/storecli.git
#
VERSION = '2019-12-07'
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
	
#-----------------------------------------------#

R='\033[1;31m'
G='\033[1;32m'; g = '\033[32m'
Y='\033[1;33m'
RS='\033[m'

#-----------------------------------------------#
# Id/Codename/Version/Release
#-----------------------------------------------#

os_type = str(platform.system())

if platform.system() == 'Linux':
	file_release = '/etc/os-release'

elif platform.system() == 'FreeBSD':
	file_release = '/usr/local/etc/os-release'

else:
	print('Sistema incompatível saindo...')
	exit()

if os.path.isfile(file_release) == True:
	lines_release = open(file_release, 'rt').readlines()

else:
	print('Arquivo os-release não encontrado saindo...')
	exit()

class SysInfo:
	"""Retornar informações do sistma"""

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

#-----------------------------------------------#

info = SysInfo()

os_id = info.get_id()
os_version = info.get_version()
os_version_id = info.get_version_id()
os_id_like = info.get_id_like()
os_codename = info.get_codename()
sysname = (f'{os_id}{os_version}') 

"""
print(f'Id -> {os_id}')
print(f'Version Id -> {os_version_id}')
print(f'Version -> {os_version}')
print(f'Id Like {os_id_like}')
print(f'Codename -> {os_codename}')

exit()
"""


#-----------------------------------------------#
# Se for Debian ou derivado checar (BASE)
#-----------------------------------------------#

#-----------------------------------------------#

#===============================================#
# Listas
#===============================================#
lista_apps = [
'7zip', 
'burnaware', 
'formatfactory', 
'office2007',
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

	exit()

#-----------------------------------------------#

def list_apps():
	for app in lista_apps: print(f'{app}')

#-----------------------------------------------#
if len(sys.argv) < 2: usage(); exit() 

if sys.argv[1] == '--help':
	usage(); exit()

elif sys.argv[1] == '--version':
	print(f'{os.path.basename(sys.argv[0])} V{VERSION}'); exit()

elif sys.argv[1] == '--list':
	list_apps(); exit()


#-----------------------------------------------#

def _msgs(msg, c=''):
	""" 
	c = Cor 
	_msg('Minha mensagem', R) -> Mensagem em vermelho/RED
	_msg('Minha mensagem', G) -> Mensagem em verde
	"""
	print(c, end='')
	print(f'-> {msg}', end='')
	print(RS)

#-----------------------------------------------#


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
	Será retornada uma lista.
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
	
	_msgs(f'Adicionando suporte arch i386', G)
	os.system("sudo sh -c 'dpkg --add-architecture i386; apt update'")

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

	else:
		_msgs(f'Não foi possível instalar o wine, tente manualmente.', R)
		exit()

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

	num = int('0')
	while True:
		_sn = input('Deseja prosseguir [s/n] ? : ').lower().strip()

		if _sn == 's':
			break
		elif _sn == 'n':
			print('Abortando...')
			return '0'; break

		else:
			_msgs(f'Opção inválida, digite (s) ou (n) [{num}].', R)

			num += 1
			if num == int('3'):
				_msgs('Máximo de tentativas atingido, saindo...', R)
				exit(); break
			
			continue
	
	# Volume está montado ?
	shell_cmd = subprocess.getstatusoutput('grep "OFFICE12" /proc/mounts')
	sys_exit = int(shell_cmd[0])
	sys_out = str(shell_cmd[1]).split() # Segundo item, ponto de montagem

	if sys_exit != int('0'): # Não montado
		print('Volume OFFICE12 não está montado'); return int('1')

	elif sys_exit == int('0'): # Montado
		print(f'Volume OFFICE12 montado em: {sys_out[1]}')

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

	# Wine está instalado ?
	if subprocess.getstatusoutput('which wine 2> /dev/null')[0] != int('0'):
		_msgs('Necessário instalar [wine]', R)
		info = input('Pressione enter para instalar agora.')
		_install_wine()

	# Wine está instalado ?
	if subprocess.getstatusoutput('which winetricks 2> /dev/null')[0] != int('0'):
		_msgs('Necessário instalar [winetricks]', R)
		info = input('Pressione enter para instalar agora.')
		_install_winetricks()

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

_msgs(f'{os_id} {os_version}', g)

if sys.argv[1] == 'install': # Instalação.
	_install() 
	
elif sys.argv[1] == 'download': # Download.
	args = sys.argv[2:]
	for num in range(0, len(args)):
		_download(args[num])

	_msgs('Feito somente download', G)
