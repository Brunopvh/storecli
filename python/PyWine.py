#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# vim: noai:ts=4:sw=4:expandtab
#
# AUTOR: Bruno Chaves
#
# GitHub: https://github.com/Brunopvh
#
# Este módulo/programa instala o WINE stable nos sistemas: 
# Debian buster, Ubuntu Bionic, OpenSuse Leap 15.1, Fedora 30.
#
# As funções/opções deste programa também pode ser usado como módulo de outro programa:
# >>> import PyWine
# >>>> PyWine.menu_pywine()
# 
#----------------------------------------------------#
# Uso:
# Para iniciar em modo menu interativo e escolher qual opção usar, use ./Pywine.py
# desta maneira o programa iniciará com um menu de opções.
#
# Se você ja sabe as funções e quer executar uma ação de maneira mais rápida, pode usar 
# parametros/argumentos para realizar uma ação específica veja alguns exemplos:
# ./Pywine.py --help
# ./Pywine.py list
# ./Pywine.py install wine
# ./Pywine.py install winrar
#----------------------------------------------------#
#
VERSAO = '2019-12-01'
#
github_pywine = 'https://github.com/Brunopvh/apps-buster'
#

import os, sys, getpass, platform
from pathlib import Path
from zipfile import ZipFile
from time import sleep

# path no disco
dir_root = os.path.dirname(os.path.realpath(__file__))
dir_run = os.getcwd() 
os.chdir(dir_root)

import sys_info

# Cores 
vermelho = '\033[1;31m'
verde = '\033[1;32m'
amarelo = '\033[1;33m'
fecha = '\033[m'

Vermelho = '\033[1;31;5m'
Verde = '\033[1;32;5m'
Amarelo = '\033[1;33;5m'

def limpar():
	os.system('clear')


limpar()

if getpass.getuser() == 'root': 
    print(f'{vermelho}==> {fecha}[-] Falha: Usuário não pode ser o {vermelho}[root]{fecha}')
    exit()



#=========================== Módulos bash e wget ===========================#
try:
    import bash, wget

except:

    print(f'{vermelho}==> {fecha}Falha, tente executar os seguites comandos: ')
    print('==> $ sudo apt install python3-pip python3-setuptools python-setuptools')
    print('==> $ pip3 install bash wget --user')
    exit()



esp = '---------------------------------------'
esp1 = '--------------['
esp2 = ']--------------'

#============================== URLs globais ==============================#
url_winrar = 'http://www.rarlab.com/rar/winrar-x64-571br.exe'
url_burnaware = 'http://download.betanews.com/download/1212419334-2/burnaware_free_12.4.exe'
url_vlc = 'https://get.videolan.org/vlc/3.0.8/win32/vlc-3.0.8-win32.exe'
url_peazip = 'https://osdn.net/frs/redir.php?m=c3sl&f=peazip%2F71536%2Fpeazip-6.9.2.WIN64.exe'
url_ffactory = 'http://www.pcfreetime.com/public/FFSetup4.8.0.0.exe'
url_epsxe = 'http://www.epsxe.com/files/ePSXe205.zip' 


def logo():
	print(f""" 
{amarelo}****************************************************{fecha}
{amarelo}|{vermelho}    Wine (Instalação e Configuração)
{amarelo}|{vermelho}    Autor: Bruno Da Silva Chaves {amarelo}
{amarelo}|{vermelho}    Versão: {VERSAO}             {amarelo}
{amarelo}|{vermelho}    Github: {github_pywine}       {amarelo}
{amarelo}****************************************************{fecha}""")



# Espaço/Linha
def espaco(num):
	n = int((40 - num))
	print('-' * n, end='')
	print(' ', end='')


#============================================================#
# detectar sistema
#============================================================#
os_type = str(platform.system())

nome_sistema = sys_info._sys_name(' ') # nome/id
versao_sistema = sys_info._sys_version(' ') # número/versão
codinome_sistema = sys_info._sys_codiname(' ') # codinome

#============================================================#
# diretórios 
#============================================================#
dir_home = Path.home()
dir_bin = (f'{dir_home}/.local/bin')
dir_apps = (f'{dir_home}/.cache/downloads')
dir_wine = (f'{dir_home}/.wine')
dir_drive_c = (f'{dir_wine}/drive_c')
local_trab = dir_root


# Criar diretórios.
lista_dirs = [dir_home, dir_bin, dir_apps, dir_wine, dir_drive_c]
for i in lista_dirs:
	if os.path.isdir(i) == False: os.makedirs(i)


# Diretório de programas portables (Windows).
if os.path.isdir(f'{dir_drive_c}/portable') == False: os.makedirs(f'{dir_drive_c}/portable')

# Incluir $HOME/.local/bin em PATH se necessário
adc_path = 'echo "export PATH=$HOME/.local/bin:$PATH" >> "$HOME"/.bashrc' # Adicionar em .bashrc
bash.bash(f'if ! grep "^export PATH.*$HOME.*" "$HOME"/.bashrc; then {adc_path}; fi')


# Mostrar opção inválida.
def opcao_invalida():
    print(f'{vermelho}Opção Inválida{fecha}'); sleep(1)

# Mensagem de falha no download.
def download_falhou(nome=str('')):

	if nome == str(''):
		print(f'{vermelho}==> F{fecha}alha no download')

	else:
		print(f'{vermelho}==> F{fecha}alha ao tentar baixar: {nome}')


#=============================== Listas ======================#

# Lista de opções para ser exibida no menu ou quando invocada por argumento/parametro.
lista_wine_opcoes = ['Sair', 'informacoes', 'wine', 'winetricks', 'q4wine', 
'playonlinux', 'Configurar (DLLs - Fontes e outros utilitários Wine)', 
'epsxe', 'Python37', 'winrar', 'peazip', 'vlc', 'burnaware', 'formatfactory', 'office2007pro']

# Lista de configurações do wine.
lista_conf_wine = ['Voltar', 'Executar ===> winecfg', 
'Executar ===> winetricks allfonts atmlib gdiplus msxml3 msxml6 corefonts tahoma',
'Executar ===> winetricks vcrun2008 vcrun2010 vcrun2012 vcrun2013  vcrun2005sp1',
'Executar ===> winetricks dotnet35 dotnet35sp1 dotnet40 dotnet472 allcodecs dmusic']

# Lista de aplicativos do windows 
lista_apps = [lista_wine_opcoes, lista_conf_wine]


#-------------------- Menu de informações -----------------#
def info():
	os.system('clear')
	print(f"""Informações
Instalar wine-stable: 
        Adiciona chaves de assinatura do wine, e repositório do wine e 
        em seguida instala dependências e o wine.

script winetricks: 
        Winetricks é uma maneira fácil de solucionar problemas no Wine.
        Possui um menu de jogos / aplicativos compatíveis, para os quais é possível 
        executar todas as soluções alternativas automaticamente. Também permite a 
        instalação de DLLs ausentes e ajustes de várias configurações do Wine.
                            
        A versão mais recente pode ser baixada aqui:
        https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
                            
        Versões marcadas podem ser acessadas aqui: 
        https://github.com/Winetricks/winetricks/releases

q4wine:
    Q4Wine is a Qt-based GUI for WINE. It can help manage Wine
    prefixes and installed applications.
""")
	enter = input('Pressione enter : ')


#-------------------- Ajuda/help ----------------------#
def usage():
	os.system('clear')
	print(f"""Use: 
     {sys.argv[0]} help|version|install|info|configure
     
     Ex: {sys.argv[0]} install wine vlc peazip

     {sys.argv[0]}:          Abre o menu interativo.		
     --help:                 Mostra este menu e sai.
     --list:                 Lista os aplicativos e configurações dispóniveis.
     version:              Mostra versão e sai.
     info:                 Mostra informações.
     install <pacote>      Instala <pacote>.
     configure:            Abre o menu de configuração
	""")

	exit()


#=================================================#
# _Wget
#=================================================#
def _Wget(url, arq):

    if os.path.isfile(arq) == True:
        print(f'{vermelho}==> {fecha}O arquivo {arq} já existe.')
        acao = str( input(f'{verde}==> {fecha}deseja remove-lo e prosseguir com o download [s/n] ? : ')).lower()

        if acao == str('s'): 
            os.remove(arq)
        else:
            exit()

    try:
        print(f'{verde}==> {fecha}Baixando: {arq}')
        wget.download(url, arq); print(' ')

    except(KeyboardInterrupt):
        print(f'\n{verde}==> {fecha}Interrompido com Ctrl c'); sleep(0.5)
        if os.path.isfile(arq): os.remove(arq)
        exit()

    except:
        print(f'\n{vermelho}==> {fecha}Falha no download'); sleep(0.5)
        if os.path.isfile(arq): os.remove(arq)
        exit()


#=============================== wine FreeBSD ======================#
def wine_freebsd():
	print(f'{verde}==> {fecha}Instalando wine e wine-gecko-2.47')
	os.system('sudo pkg install wine')
	os.system('sudo pkg install wine-gecko-2.47')
	bash.bash('[[ ! -x $(which wine) ]] && sudo ln -sf $(which wine64) /usr/local/bin/wine')


#=============================== wine Fedora 30 ====================#
def wine_fedora():	
	os.system('sudo dnf install wine')


#========================= OpenSuse leap 15.1 ======================#
def wine_suse():
	link_winesuse = 'https://software.opensuse.org/ymp/openSUSE:Leap:15.1/standard/wine.ymp?base=openSUSE%3ALeap%3A15.1&query=wine'
	arq_winesuse = (f'{dir_apps}/wine.ymp')

	if os.path.isfile(arq_winesuse) == True: os.remove(arq_winesuse)
	wget.download(link_winesuse, arq_winesuse); print(' OK')
	bash.bash(f'/sbin/yast2 OneClickInstallUI {arq_winesuse}')
	

#========================== Debian/Ubuntu/Mint ======================#
def wine_debian():
	
	arq_wine = '/etc/apt/sources.list.d/wine.list'

	os.system("sudo sh -c 'apt update; apt install -y dirmngr git apt-transport-https gnupg gpgv2 gpgv'")

	if codinome_sistema == 'bionic': # Repos bionic
		repos_wine = 'deb https://dl.winehq.org/wine-builds/ubuntu/ bionic main'

	elif codinome_sistema == 'buster': # Repos buster
		repos_wine = 'deb https://dl.winehq.org/wine-builds/debian/ buster main'

	#======================= Chaves e repositório ==================#
	print(f'{amarelo}==> {fecha}Adicionando chaves e repositório aguarde...')
	os.system(f"echo {repos_wine} | sudo tee {arq_wine}")
	os.system(f"sudo sh -c 'wget -q https://dl.winehq.org/wine-builds/winehq.key -O- | apt-key add -'")

	print(f'{amarelo}==> {fecha}Adicionando: suporte arch i386')
	os.system(f"sudo sh -c 'dpkg --add-architecture i386; apt update'")

	#========================== Instalação de dependências ==========#
	print(f"{amarelo}Instalando dependências...{fecha}")

	# Instalar um por vez nesta ordem para não ter problemas com pacotes quebrados.
	lista_depen = ['libc6', 'libasound2:i386', 'wine-stable-i386:i386', 'wine-stable-i386:i386', 'wine-stable-amd64', 
'wine-stable']

	for i in lista_depen:
		print(f'{amarelo}==> {fecha}Instalando: {i}')
		os.system(f'sudo apt install --yes --install-recommends {i}')

	# winehq-stable
	os.system('sudo apt install -y winehq-stable')

	# Suporte a icones .exe do windows.
	os.system(f'sudo apt install --no-install-recommends gnome-colors-common gnome-wine-icon-theme gtk2-engines-murrine -y')
	os.system(f'sudo apt install --no-install-recommends gnome-exe-thumbnailer -y')


#=============================== Instalação winehq =================#
def wine():

	# FreeBSD 
	if nome_sistema == 'freebsd12':
		wine_freebsd()

	# Fedora 30 
	elif (codinome_sistema == 'thirty') or (codinome_sistema == 'thirtyone'):
		wine_fedora()

	# OpenSuse leap 15.1 
	elif codinome_sistema == 'leap':
		wine_suse()

	# Debian/Ubuntu/Mint 
	elif codinome_sistema == 'buster' or codinome_sistema == 'bionic':
		wine_debian()



#========================== Instalar winetricks ==========#
def winetricks():

	tupla_app_winetricks = ('zenity cabextract unrar unzip wget aria2 wget curl')

	tupla_debian = ('binutils fuseiso p7zip-full policykit-1 tor xdg-utils xz-utils')

	tupla_suse = ('binutils fuseiso p7zip polkit tor xdg-utils xz')

	repos_winetricks = 'https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks'

	# FreeBSD
	if codinome_sistema == 'freebsd12':
		print(f'{verde}==> {fecha}Instalando: {tupla_app_winetricks}')
		os.system(f'sudo apt install -y {tupla_app_winetricks}')

		print(f'{verde}==> {fecha}Instalando winetricks')
		os.system('sudo pkg install winetricks')

	# Debian/Ubuntu/Mint
	elif codinome_sistema == 'buster' or codinome_sistema == 'bionic':
	
		print(f'{verde}==> {fecha}Instalando: {tupla_app_winetricks}')
		os.system(f'sudo apt install -y {tupla_app_winetricks}')

		print(f'{amarelo}==> {fecha}Instalando: {tupla_debian}')
		os.system(f'sudo apt install -y {tupla_debian}')

	# OpenSuse Leap 15.1
	elif codinome_sistema == 'leap':
		print(f'{verde}==> {fecha}Instalando: {tupla_app_winetricks}')
		os.system(f'sudo zypper in {tupla_app_winetricks}')

		print(f'{amarelo}==> {fecha}Instalando: {tupla_suse}')
		os.system(f'sudo zypper in {tupla_suse}')

	# Fedora 30
	elif codinome_sistema == 'thirty':
		print(f'{verde}==> {fecha}Instalando: {tupla_app_winetricks}')
		os.system(f'sudo dnf install -y {tupla_app_winetricks}')

		print(f'{amarelo}==> {fecha}Instalando: {tupla_suse}')
		os.system(f'sudo dnf install -y {tupla_suse}')

        
	if os_type == 'linux': # Somente no linux
		print(f'{verde}==> {fecha}Instalando: winetricks')
        
		if os.path.isfile(dir_bin) == False: 
			os.makedirs(dir_bin)
    
		arq_winetricks = (f'{dir_bin}/winetricks')
		_Wget(repos_winetricks, arq_winetricks)
	
		os.system('sudo cp -u "$HOME"/.local/bin/winetricks /usr/local/bin/winetricks')
		os.system('chmod +x "$HOME"/.local/bin/winetricks; sudo chmod a+x /usr/local/bin/winetricks')
	


# Q4wine
def q4wine():

	# Q4wine
	if codinome_sistema == 'freebsd12': # FreeBSD
		print(f'{verde}==> {fecha}q4wine indisponível')
		sleep(3)

	elif codinome_sistema == str('leap'): # OpenSuse
		os.system('sudo zypper in q4wine')
	
	elif 'bionic' or 'buster' in codinome_sisteam: # Debian/Ubuntu
		os.system('sudo apt install -y --no-install-recommends q4wine')

	elif codinome_sistema == 'thirty': # Fedora 30.
		os.system('sudo dnf install q4wine')


#====================== playonlinux =================================#
def playonlinux():
	
	if codinome_sistema == 'freebsd12':
		print(f'{verde}==> {fecha}Playonbsd')
		os.system('sudo pkg install playonbsd')
		
	elif codinome_sistema == 'buster' or codinome_sistema == 'bionic':
		print(f'{verde}==> {fecha}Playonlinux')
		os.system('sudo apt install -y playonlinux')
		
	elif codinome_sistema == 'thirty':
		print(f'{verde}==> {fecha}Playonlinux')
		os.system('sudo dnf install playonlinux')

#===============================================================#
#================= Instalação de aplicativos do windows ========#
#===============================================================#

#----------------------- ePSXe ------------------#
def epsxe():

	if os.path.isdir(dir_drive_c) == False:
		print(f'==> diretório NÃO encontrado:  {dir_drive_c}')
		sys.exit(1)

	if os.path.isdir(f'{dir_drive_c}/portable/epsxe-win32') == False: 
		os.makedirs(f'{dir_drive_c}/portable/epsxe-win32')

	
	arq_zip = (f'{dir_apps}/epsxe-win32.zip') # Baixar com este nome.

	_Wget(url=url_epsxe, arq=arq_zip) # Baixar o arquivo
	
	with ZipFile(arq_zip, 'r') as zip:

		# Mostrar todos os arquivos dentro do .zip
		#zip.printdir() 

		# Descomprimir
		print(f'{amarelo}==> {fecha}Descompactando...')
		zip.extractall(f'{dir_drive_c}/portable/epsxe-win32') 

	
	# Valores a serem inseridos no arquivo .desktop
	# 0 -> Name, 1 -> Exec, 2 -> Type, 3 -> Path, 4 -> Comment
	name = 'Name=ePSXe Win32'
	exe = (f'Exec=env WINEPREFIX="{dir_wine}" wine {dir_drive_c}/portable/epsxe-win32/ePSXe.exe')
	typ = 'Type=Application'
	path = (f'Path={dir_drive_c}/portable/epsxe-win32/')
	comment = 'Comment=Emulador de PS1'
	terminal = 'Terminal=true'

	arq_desk_epsxe = (f'{dir_home}/.local/share/applications/epsxe-win32.desktop')
	arq = open(arq_desk_epsxe, 'w')

	arq.write(f'[Desktop Entry]\n')
	arq.write(f'{name}\n')
	arq.write(f'{exe}\n')
	arq.write(f'{typ}\n')
	arq.write(f'{path}\n')
	arq.write(f'{comment}\n')
	arq.write(f'{terminal}\n')

	arq.close()

	# Abrir o programa
	print(f'{amarelo}Abrindo...{fecha}')
	bash.bash(f'env WINEPREFIX="{dir_wine}" wine {dir_drive_c}/portable/epsxe-win32/ePSXe.exe')



#----------------------- Python3.7.3 win32 -------------------#
def python37():

	link_python = 'https://www.python.org/ftp/python/3.7.3/python-3.7.3-embed-win32.zip'

	arq_python =  (f'{dir_apps}/python37-win32.zip') # arquivo a descomprimir
	dir_python = (f'{dir_wine}/drive_c/portable/python37') # Diretório onde está o portable do python37
	exec_python = (f'wine {dir_python}/python.exe') # Chamada do programa via wine.
	arq_desktop_python = (f'{dir_home}/.local/share/applications/python3.desktop')

	# Criar diretório onde o programa será extraido.
	if os.path.isdir(f'{dir_python}') == False: os.makedirs(f'{dir_python}') 

	# Baixar o programa se necessário.
	if os.path.isfile(f'{arq_python}') == False: os.system(f"wget {link_python} -O {arq_python}")

	os.system(f"unzip -u {arq_python} -d {dir_python}")


	# Valores a serem inseridos no arquivo .desktop
	# 0 -> Name, 1 -> Exec, 2 -> Type, 3 -> Path, 4 -> Comment
	name = 'Name=Python 3.7 win32'
	exe = (f'Exec=wine {dir_python}/python.exe')
	typ = 'Type=Application'
	path = (f'Path={dir_python}')
	comment = 'Comment=Python 3.7.3 win 32 bits'
	terminal = 'Terminal=true'

	lista_python = [name, exe, typ, path, comment, terminal]

	# Criação do arquivo .desktop para menu do sistema
	os.system(f'echo "[Desktop Entry]" > {arq_desktop_python}')
	arq = open(arq_desktop_python, 'a')
	for i in lista_python:
			arq.write(f'{i}\n')

	arq.close()

	# Criar arquivo para chamada CLI pythonwin
	arq_cli = (f'{dir_home}/.local/bin/pythonwin') # Chamada via terminal.
	cli = open(arq_cli, 'w')

	cli.write(f'#!/usr/bin/env bash\n\n')
	cli.write(f'path_python={dir_python}\n')
	cli.write(f'cd $path_python && wine "$path_python"/python.exe\n')

	os.system(f'chmod +x {dir_home}/.local/bin/pythonwin')

	print(f'==> Python3.7 win32 instalado em: {dir_python}')
	print(f'==> Use o comando "pythonwin" ou execute apartir do menu: "Outros -> Python 3.7 win"')
	enter = input(f'Pressione enter')


# Winrar x64
def winrar():

	arq_winrar = (f'{dir_apps}/winrar-x64.exe')
	if os.path.isfile(arq_winrar) == True:
		print(f'{amarelo}Encontrado: {fecha}{arq_winrar}')

	else:
		print(f'{amarelo}Baixando: {fecha}{arq_winrar}')
		try:
			wget.download(url_winrar, arq_winrar)
			print(' OK')

		except:
			print(' ')
			download_falhou(nome=arq_winrar)
			exit(1)

	# Instalação
	print(f'{amarelo}Executando: {fecha}wine {arq_winrar}')
	os.chdir(dir_apps)
	bash.bash(f'wine {arq_winrar}')
	os.chdir(local_trab)

# Peazip win64
def peazip():
	arq_peazip = (f'{dir_apps}/peazip-x64.exe')
	if os.path.isfile(arq_peazip) == True:
		print(f'{amarelo}Encontrado: {fecha}{arq_peazip}')

	else:
		print(f'{amarelo}Baixando: {fecha}{arq_peazip}')
		try:
			wget.download(url_peazip, arq_peazip)
			print(' OK')

		except:
			print(' ')
			download_falhou(nome=arq_peazip)
			exit(1)

	# Instalação
	print(f'{amarelo}Executando: {fecha}wine {arq_peazip}')
	os.chdir(dir_apps)
	bash.bash(f'wine {arq_peazip}')
	os.chdir(local_trab)


# Vlc
def vlc():
	arq_vlc = (f'{dir_apps}/vlc-win32.exe')

	if os.path.isfile(arq_vlc) == True:
		print(f'{verde}==> {fecha}Arquivo de instalação já em cache: {arq_vlc}')

	elif os.path.isfile(arq_vlc) == False: 
		print(f'{verde}==> {fecha}Baixando: {arq_vlc}')

		try:
			wget.download(url_vlc, arq_vlc); print(f' OK')

		except:
				os.remove(arq_vlc)
				print(' '); download_falhou(nome=arq_vlc); sys.exit(1)

	print(f'{verde}==> {fecha}Executando: wine {arq_vlc}')
	bash.bash(f'wine {arq_vlc}')


# Burnaware
def burnaware():
	arq_burnaware = (f'{dir_apps}/burnaware-free.exe')
	
	if os.path.isfile(arq_burnaware) == True: 
		print(f'{verde}==> {fecha}Arquivo de instalação já em cache: {arq_burnaware}')

	elif os.path.isfile(arq_burnaware) == False: 
	
		try:
			_Wget(url=url_burnaware, arq=arq_burnaware) # Baixar o arquivo

		except:
				if os.path.isfile(arq_burnaware) == True: os.remove(arq_burnaware)
				print(' '); download_falhou(nome=arq_burnaware) 
				exit(1)

	print(f'{verde}Executando: {fecha}wine {arq_burnaware}')
	bash.bash(f'wine {arq_burnaware}')


# Format factory
def formatfactory():

	arq_formatfactory = (f'{dir_apps}/ffactory')

	if os.path.isfile(arq_formatfactory) == False:
		print(f'{amarelo}Baixando: {fecha}{arq_formatfactory}')

		try:
			wget.download(url_ffactory, arq_formatfactory); print(' OK')

		except:
			os.remove(arq_formatfactory)
			print(' '); download_falhou(nome=arq_formatfactory); exit(1)

	print(f'{amarelo}==> {fecha}Executando: wine {arq_formatfactory}')
	bash.bash(f'wine {arq_formatfactory}')


def office2007pro():
	# sudo mount -o loop OFFICE12.iso /mnt
	print(f'{verde}==> {fecha}Necessário CD ou imagem .iso para instalação, volume OFFICE12.')
	ins = str(input ('==> Prosseguir [s/n] : ')).lower()
	if ins == 's':
		print(f'==> O comando a seguir pode ser util: sudo mount -o loop OFFICE12.iso /mnt')
		print(f'{verde}==> {fecha}Executando: winetricks office2007pro WINEARCH=win32')
		os.system('winetricks office2007pro WINEARCH=win32')

#======================= Menu de configuração do Wine [5]==============#
def conf_wine():

	while True:

		print(f'{amarelo}{esp1} Menu de configuração do wine {esp2}{fecha}')

		num = int('0')
		for op in lista_conf_wine:
			if op == 'Voltar':
				print(f'{verde}==> {num} - {vermelho}{op}')

			else:
				print(f'{verde}==> {num}{fecha} - {op}')

			num += 1

		try:	
			acao_conf = int(input (f'{Verde}==> {fecha}Digite um número e pressione enter : '))

		except:
			print(f'{vermelho}Digite apenas números :( :( {fecha}')
			enter = input('Pressione enter : ')
			continue

		
		if acao_conf == int('0'):
			print('Voltando...')
			break

		elif acao_conf == int('1'):
			os.system('winecfg')

		elif acao_conf == int('2'):
			os.system('winetricks allfonts atmlib gdiplus msxml3 msxml6 corefonts tahoma')

		elif acao_conf == int('3'):
			os.system('winetricks vcrun2008 vcrun2010 vcrun2012 vcrun2013  vcrun2005sp1')

		elif acao_conf == int('4'):
			os.system('winetricks dotnet35 dotnet35sp1 dotnet40 dotnet472 allcodecs dmusic')


#====================== Função install ============================#
# Está função realiza a chamada de instalação de um pacote qualquer

def install(pacotes):

	for c in pacotes: # Lista de Programas passados como argumentos.
		print(f'{verde}==> {fecha}Instalando: {c}')
		
		if c == 'wine':
			wine()

		elif c == 'winetricks':
			winetricks()

		elif c == 'q4wine':
			q4wine()
			
		elif c == 'playonlinux':
			playonlinux()

		elif c == 'epsxe':
			epsxe()

		elif c == 'python37':
			python37()
				
		elif c == 'winrar':
			winrar()

		elif c == 'peazip':
			peazip()
	
		elif c == 'vlc':
			vlc()
		
		elif c == 'burnaware':
			burnaware()

		elif c == 'formatfactory':
			formatfactory()

		elif c == 'office2007pro':
			office2007pro()

		else:
			print(f'{vermelho}==> {fecha}Programa não encontrado: {c}')


def show_info():
	print(f'==> {verde}L{fecha}ocal de downloads: ', end=''); espaco(len('==> Local de downloads: '))
	print(dir_apps)

	print(f'==> {verde}S{fecha}istema: ', end=''); espaco(len('==> Sistema: ')) 
	print(f'{os_type} {nome_sistema} {codinome_sistema}')

	print(f'{esp1} {verde}M{fecha}enu PyWine {esp2}')
    

#=================================================================#
#======================= Menu opções/princiapal ==================#
def menu_pywine():

	while True:

		logo()
		show_info()

		num = int('0')
		for op in lista_wine_opcoes:
			if op == 'Sair':
				print(f'==> {num} - {vermelho}{op}')

			else:
				print(f'==> {num}{fecha} - {op}')

			num += 1

		try:	
			acao = int(input (f'{verde}==> {fecha}Digite um número e pressione enter : '))

		except:
			print(f'{vermelho}Digite apenas números :( :( {fecha}')
			enter = input('Pressione enter : ')
			continue

		if acao == int('0'): # Sair
			break
			sys.exit(0)

		elif acao == int('1'): # Info
			info()

		elif acao == int('2'): # Wine stable
			wine()

		elif acao == int('3'): # Winetricks 
			print('winetricks')
			winetricks()

		elif acao == int('4'): # Q4wine
			os.system('clear')
			print('q4wine')
			q4wine()

		elif acao == int('5'): # Playonlinux.
			os.system('clear')
			playonlinux()

		elif acao == int('6'): #-------------- Configuração do wine
			os.system('clear')
			conf_wine()

		elif acao == int('7'): # ePSXe.
			os.system('clear')
			#menu_apps_win()
			print('ePSXe')
			epsxe()

		elif acao == int('8'): # Python3.7 win32
			os.system('clear')
			print('Python3.7 win32')
			python37()

		elif acao == int('9'): # Winrar
			os.system('clear')
			print('Winrar')
			winrar()

		elif acao == int('10'): # Peazip
			os.system('clear')
			print('Peazip')
			peazip()

		elif acao == int('11'): # Vlc win32
			limpar()
			print('Vlc win32')
			vlc()

		elif acao == int('12'): # Burnaware
			limpar()
			print('Burnaware')
			burnaware()

		elif acao == int('13'): # Ffactory
			limpar()
			print('Format Factory')
			formatfactory()

		elif acao == int('14'): # Office 2007 pro
			print('Office 2007 pro')
			office2007pro()

		else:
			opcao_invalida()



#========================== Argumentos ===============#
def argumentos():
	if sys.argv[1] == str('--help'):
		usage(); sys.exit()

	elif sys.argv[1] == str('version'): # Mostrar versão e sair
		limpar(); print(f'Versão: {VERSAO}'); sys.exit(0)

	elif sys.argv[1] == str('--list'): # Mostrar aplicativos e configurações.

		limpar()
		for i in lista_apps:
			for c in i:
				if c == 'Voltar' or c == 'Sair':
					print(' ')
				else:
					print(c)


	elif sys.argv[1] == str('info'): # Info
		info()

	elif sys.argv[1] == str('configure'): # Menu configuração
		conf_wine()

	elif sys.argv[1] == str('install'): # Install
		install(pacotes=sys.argv[2:])

	else:
		usage()



if len(sys.argv) == int('1'): 
	menu_pywine() 

elif len(sys.argv) >= int('2'): # Descomentar para aceitar os argumentos 
	argumentos()
