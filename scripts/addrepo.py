#!/usr/bin/env python3
# -*- coding: utf-8 -*-
 
import sys
import argparse
import tempfile
from os import path, geteuid, makedirs, remove, system
from shutil import copyfile
from time import sleep


# Cores
CRed='\033[0;31m'
CGreen='\033[0;32m'
CYellow='\033[0;33m'
CBlue='\033[1;34m'
CWhite='\033[0;37m'
CReset='\033[0m'

# root
if geteuid() != int('0'):
	print(f'{CRed}[!] Você precisa ser o root{CReset}')
	sys.exit('1')

 
tmpDir = '/tmp/addrepo_temp'
tmpFile = (f'{tmpDir}/tmp.conf')
if path.isdir(tmpDir) == False:
	makedirs(tmpDir)

if path.isfile(tmpFile) == True:
	remove(tmpFile)

if path.isfile('/etc/pacman.conf.copia') == False:
	print(f'{CYellow}Fazendo backup do arquivo: /etc/pacman.conf{CReset}')
	copyfile('/etc/pacman.conf', '/etc/pacman.conf.copia')



#print(tmpFile.name); exit()

def usage():
	print(f"""   
   Use: {path.basename(sys.argv[0])} --repo arch""")


class AddRepo:
	def __init__(self):
		pass

	def archlinux(self):
		file_pacman_conf = '/etc/pacman.conf'
		content_conf = open(file_pacman_conf, 'rt')
		lines_content_conf = content_conf.readlines()

		for num in range(0, len(lines_content_conf)):
			line = str(lines_content_conf[num]).replace('\n', '')
			
			if (line == str('#[multilib]')) or (line == str('[multilib]')):
				numLineMirrorLis = int(num + 1) # Linha que está em baixo do [multilib]
				lines_content_conf[numLineMirrorLis] = 'Include = /etc/pacman.d/mirrorlist\n'
				lines_content_conf[num] = '[multilib]\n'

		
		# Gravar o novo conteúdo em um arquivo temporário.
		content_temp = open(tmpFile, 'w+')
		for X in lines_content_conf:
			X = str(X)
			content_temp.write(f'{X}')

		content_temp.seek(0)
		content_temp.close()
		print(f'{CYellow}[+] Configurando: /etc/pacman.conf{CReset}')
		copyfile(tmpFile, '/etc/pacman.conf')

		print(f'{CYellow}[>] Atualizando repostórios {CReset}')
		system('pacman -Sy')
			

parser = argparse.ArgumentParser(description='Habilita repostório em distribuições Linux.')

__version__ = '2020-06-02'


parser.add_argument(
	'-v', '--version', 
	action='version', 
	version="%(prog)s ("+__version__+")"
	)

parser.add_argument(
	'-u', '--usage',
	action='store_const', 
	dest='usage',
	const=usage,
	help='Mostra ajuda'
	)

parser.add_argument(
	'-r', '--repo', 
	action='store', 
	dest='distro',
	type=str,
	help='Adicionar repostório'
	)


args = parser.parse_args()

if args.usage:
	usage()
elif args.distro:
	if args.distro == 'arch':
		AddRepo().archlinux()