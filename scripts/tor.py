#!/usr/bin/env python3
#
# Este script foi criado para baixar e instalar o Navegador Tor em
# sistemas Linux e Windows.
#

import sys
import tarfile
import shutil
import wget
import urllib.request
from subprocess import getstatusoutput
from platform import system as sys_kernel
from pathlib import Path
from os import (
	system, 
	makedirs, 
	path, 
	geteuid, 
	getcwd,
	chdir,
	remove,
	listdir,
	)


CRed='\033[0;31m'
CGreen='\033[0;32m'
CYellow='\033[0;33m'
CWhite='\033[0;37m'
CReset='\033[m'


class PrintColor:
	
	@classmethod
	def red(cls, text):
		print(f'{CRed}[!] {text}{CReset}')

	@classmethod
	def yellow(cls, text):
		print(f'{CYellow}[+] {text}{CReset}')

	@classmethod
	def white(cls, text):
		print(f'{CWhite} >  {text}{CReset}')


red = PrintColor.red
yellow = PrintColor.yellow
white = PrintColor.white

# root
if geteuid() == int('0'):
	red('Usuário não pode ser o root.')
	sys.exit('1')


# Endereço deste script no disco.
dir_root = path.dirname(path.realpath(__file__)) 

# Diretório onde o terminal está aberto.
dir_run = getcwd()        

# Inserir o diretório do script no PATH do python - print(sys.path)                          
# sys.path.insert(0, dir_root) 

# Linux ou Windows?
if (sys_kernel() != 'Linux') and (sys_kernel() != 'Windows'):
	red('Execute este programa em sistemas Linux ou Windows')
	sys.exit('1')

# Criação é declaração de arquivos e diretórios.
DirHomeUser = Path.home()
DirTempUser = (f'{DirHomeUser}/space_tor_temp')
DirDownloadTor = (f'{DirTempUser}/download')
DirUnpackTor = (f'{DirTempUser}/unpack_tor')
DirUserBin = (f'{DirHomeUser}/.local/bin')

tor_user_dirs = {
	'DirHomeUser' : DirHomeUser,
	'DirTempUser' : DirTempUser,
	'DirDownloadTor' : DirDownloadTor,
	'DirUnpackTor' : DirUnpackTor,
	'DirUserBin' : DirUserBin,
}


for X in tor_user_dirs:
	dirx = tor_user_dirs[X]
	if path.isdir(dirx) == False:
		white(f'Criando o diretório: {dirx}')
		makedirs(dirx)
	
#-------------------------------------------------------------#
# URL = domain/version/name
#-------------------------------------------------------------#
yellow('Aguarde...')
tor_download_page='https://www.torproject.org/download/'
tor_domain_server='https://dist.torproject.org/torbrowser'
html_default = str(urllib.request.urlopen(tor_download_page).read())
html_default = html_default.split()


class SetDataTor:
	def __init__(self, os_kernel=sys_kernel()):
		self.os_kernel = os_kernel

	def get_html_filter(self):
		# Filtrar as ocorrencias ".dmg", ".tar", ".exe" e guardar em uma lista.
		html_filter = []
		for X in range(0, len(html_default)):
			line = html_default[X].replace('\n', '')
			if ('.dmg' in line) or ('.tar' in line) or ('.exe' in line):
				position_left = int(line.find('"') + 1) 
				position_right = int(line.rfind('"'))
				line = line[position_left : position_right]
				html_filter.append(line)

		return html_filter

	def set_filename_linux(self):
		for i in self.get_html_filter(): 
			if '.tar.xz' in i[-8:]:
				torFilename_Linux = path.basename(i)
				break

		return torFilename_Linux

	def set_torversion(self):
		for i in self.get_html_filter(): 
			if '.tar.xz' in i[-8:]:
				torVersion = i.split('/')[3]
				break

		return torVersion

	def set_linux_url(self):
		torLinux_Url = (f'{tor_domain_server}/{self.set_torversion()}/{self.set_filename_linux()}')
		return torLinux_Url

	def set_filename_windows(self):
		for i in self.get_html_filter(): 
			if '.exe' in i[-5:]:
				torFilename_Windows = path.basename(i)
				break

		return torFilename_Windows

	def set_windows_url(self):
		torLinux_Url = (f'{tor_domain_server}/{self.set_torversion()}/{self.set_filename_windows()}')
		return torLinux_Url


class ConfigTor:
	if sys_kernel() == 'Linux':
		url = SetDataTor().set_linux_url()
		file = SetDataTor().set_filename_linux()
		file = ('{}/{}').format(DirDownloadTor, file) # Path completo no disco.
	elif sys_kernel() == 'Windows':
		url = SetDataTor().set_windows_url()
		file = SetDataTor().set_filename_windows()
		file = (f'{tor_user_dirs[DirDownloadTor]}/{file}') # Path completo no disco.

	def __init__(self):
		pass

	def download_file(self):
		if path.isfile(self.file):
			yellow(f'Arquivo encontrado: {self.file}')
			return

		yellow(f'Baixando: {self.url}')
		yellow(f'Destino: {self.file}')
		try:
			wget.download(self.url, self.file)
			print(' OK')
		except:
			print('\n')
			red ('Falha no download')
			if path.isfile(self.file):
				remove(self.file)

	def unpack_file(self):
		# https://docs.python.org/3.3/library/tarfile.html
		yellow(f'Descomprimindo: {self.file}')
		yellow(f'Destino: {DirUnpackTor}')

		chdir(DirUnpackTor)
		tar = tarfile.open(self.file)
		tar.extractall()
		tar.close()

	def linux(self):
		dir_temp_tor = (f'{DirUnpackTor}/tor-browser_en-US') # Old dir
		dir_bin_tor = (f'{DirUserBin}/torbrowser-amd64')
		list_files = listdir(dir_temp_tor)

		if path.isdir(dir_bin_tor) == False:
			yellow(f'Criando: {dir_bin_tor}')
			makedirs(dir_bin_tor)

		chdir(dir_temp_tor)

		for X in range(0, len(list_files)):
			OldFile = list_files[X]
			NewFile = (f'{dir_bin_tor}/{list_files[X]}')
			if (path.isdir(NewFile)) or (path.isfile(NewFile)):
				print(f'Encontrado: {NewFile}')
			else:
				yellow(f'Movendo: {OldFile} => {NewFile}')
				shutil.move(OldFile, NewFile)

		yellow('Configurando arquivos')
		chdir(dir_temp_tor)
		system('chmod +x {}'.format('start-tor-browser.desktop'))
		system('./{} --register-app'.format('start-tor-browser.desktop'))

	def windows():
		system(f'cmd.exe {self.file}')

	def install_tor(self):
		if sys_kernel() == 'Windows':
			self.download_file()
			self.windows()
		elif sys_kernel() == 'Linux':
			self.download_file()
			self.unpack_file()
			self.linux()			



ConfigTor().install_tor()











