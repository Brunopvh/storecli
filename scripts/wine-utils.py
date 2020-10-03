#!/usr/bin/env python
# -*- coding: utf-8 -*-

import os, sys
import subprocess
import platform
import urllib.request
import wget

try:
	columns = os.get_terminal_size()[0]
except:
	columns = int(40)

space_line = ('-' * columns)

# Default
CRed = '\033[0;31m'
CGreen = '\033[0;32m'
CYellow = '\033[0;33m'
CBlue = '\033[0;34m'
CWhite = '\033[0;37m'

# Strong
CSRed = '\033[1;31m'
CSGreen = '\033[1;32m'
CSYellow = '\033[1;33m'
CSBlue = '\033[1;34m'
CSWhite = '\033[1;37m'


# Dark
CDRed = '\033[2;31m'
CDGreen = '\033[2;32m'
CDYellow = '\033[2;33m'
CDBlue = '\033[2;34m'
CDWhite = '\033[2;37m'

# Blinking text
CBRed = '\033[5;31m'
CBGreen = '\033[5;32m'
CBYellow = '\033[5;33m'
CBBlue = '\033[5;34m'
CBWhite = '\033[5;37m'

# Reset
CReset = '\033[0m'

class PrintText:
	def __init__(self):
		pass

	def red(self, text=''):
		print(f'{CSRed}[!]{CReset} {text}')

	def green(self, text=''):
		print(f'{CGreen}[+]{CReset} {text}')

	def yellow(self, text=''):
		print(f'{CYellow}[+]{CReset} {text}')

	def blue(self, text=''):
		print(f'{CBlue}[+]{CReset} {text}')

	def white(self, text=''):
		print(f'{CWhite}{text}{CReset}')
		
	def msg(self, text=''):
		self.line()
		print(text.center(columns))
		self.line()
	
	def line(self, char=None):
		if char == None:
			print('-' * columns)
		else:
			print(char * columns)

	# Strong
	def sred(text=''):
		print(f'{CSRed}{text}{CReset}')

	def sgreen(text=''):
		print(f'{CSGreen}{text}{CReset}')

	def syellow(text=''):
		print(f'{CSYellow}{text}{CReset}')

	def sblue(text=''):
		print(f'{CSBlue}{text}{CReset}')

	def swhite(text=''):
		print(f'{CSWhite}{text}{CReset}')

	# Dark
	def dred(text=''):
		print(f'{CDRed}{text}{CReset}')

	def dgreen(text=''):
		print(f'{CDGreen}{text}{CReset}')

	def dyellow(text=''):
		print(f'{CDYellow}{text}{CReset}')

	def dblue(text=''):
		print(f'{CDBlue}{text}{CReset}')

	def dwhite(text=''):
		print(f'{CDWhite}{text}{CReset}')


def is_executable(app):
	cmd = subprocess.getstatusoutput(f'command -v {app} 2> /dev/null')
	if cmd[0] == 0:
		return True
	else:
		return False


class ReleaseInfo:	
		
	def set_release_file(self):
		if os.path.isfile('/etc/os-release') == True:
			self.release_file = '/etc/os-release'
		else:
			print(f'{__class__} arquivo os-release não encontrado...')
			exit()

	def get_lines(self):
		''' Ler o arquivo release_file e retornar o conteúdo das linhas '''
		self.set_release_file()
		f = open(self.release_file, 'rt')
		Lines = [] 
		for L in f.readlines():
			L = L.replace('\n', '').replace('"', '')
			Lines.append(L)

		f.close()
		return Lines

	def get_info(self):
		lines = self.get_lines()
		RELEASE_INFO = {'kernel_type': 'Linux'}

		for LINE in lines:
			if LINE[0:12] == 'PRETTY_NAME=':
				LINE = LINE.replace('PRETTY_NAME=', '')
				RELEASE_INFO.update({'PRETTY_NAME': LINE})

			elif LINE[0:5] == 'NAME=':
				LINE = LINE.replace('NAME=', '')
				RELEASE_INFO.update({'NAME': LINE})

			elif LINE[0:11] == 'VERSION_ID=':
				LINE = LINE.replace('VERSION_ID=', '')
				RELEASE_INFO.update({'VERSION_ID': LINE})

			elif LINE[0:8] == 'VERSION=':
				LINE = LINE.replace('VERSION=', '')
				RELEASE_INFO.update({'VERSION': LINE})

			elif LINE[0:17] == 'VERSION_CODENAME=':
				LINE = LINE.replace('VERSION_CODENAME=', '')
				RELEASE_INFO.update({'VERSION_CODENAME': LINE})

			elif LINE[0:3] == 'ID=':
				LINE = LINE.replace('ID=', '')
				RELEASE_INFO.update({'ID': LINE})

		return RELEASE_INFO

	def show_all(self):
		'''Mostra principais informaçoes do sistema do arquivo /etc/os-release'''
		RELEASE_INFO = self.get_info()
		for i in RELEASE_INFO:
			print(i, '=>', RELEASE_INFO[i])

	def info(self, type_info):
		RELEASE_INFO = self.get_info()

		if type_info == 'ALL':
			return RELEASE_INFO

		if type_info in RELEASE_INFO.keys():
			return str(RELEASE_INFO[type_info]) 
		else:
			return False


class InstallWine(PrintText, ReleaseInfo):

	def __init__(self):
		pass


	def run(self):
		self.show_all()
		print(self.info('ID'))


InstallWine().run()


