#!/usr/bin/env python3
# -*- coding: utf-8 -*-
 
import sys, os, re
import argparse
import tempfile
import shutil
from time import sleep

__version__ = '2021-03-06'

# Cores
CRed='\033[0;31m'
CGreen='\033[0;32m'
CYellow='\033[0;33m'
CBlue='\033[1;34m'
CWhite='\033[0;37m'
CReset='\033[0m'

# root
if os.geteuid() != int('0'):
	print(f'{CRed}[!] Você precisa ser o root{CReset}')
	sys.exit('1')

tmpFile = tempfile.NamedTemporaryFile(delete=False).name
tmpDir = tempfile.TemporaryDirectory().name
os.makedirs(tmpDir)

def usage():
	print(f"""   
   Use: {os.path.basename(sys.argv[0])} --repo arch
        {os.path.basename(sys.argv[0])} --repo debian
        {os.path.basename(sys.argv[0])} --repo fedora
""")


def read_file(file):
	if os.path.isfile(file) == False:
		print(f'O arquivo inexistente ... {file}')
		return False

	with open(file, 'rt') as f:
		lines = f.read().split('\n')

	return lines

def write_file(file: str, content: list) -> bool:
	"""
	Recebe um arquivo é uma lista, grava o contéudo da lista
	no arquivo que será aberto em modo 'w'. OBS: Quebras de 
	linha '\n' são adicionadas ao fim de cada elemento da lista.
	"""
	print(f'Gravando dados no arquivo ... {file} ', end='')
	try:
		with open(file, 'w+') as f:
			for L in content:
				if L != '':
					f.write(f'{L}\n')

	except Exception as err:
		print(err)
		return False
	else:
		print('OK')
		return True

class SysInfo:
	release_file = '/etc/os-release'

	def __init__(self):
		pass

	def get_lines(self):
		with open(self.release_file, 'rt') as f:
			lines = f.read().split('\n')

		return lines

	def get_info(self):
		from platform import system
		if system() == 'Linux':
			RELEASE_INFO = {'kernel_type': 'Linux'}
		else:
			import sys
			sys.exit('Seu sistema não é Linux')

		lines = self.get_lines()

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
		RELEASE_INFO = self.get_info()
		for i in RELEASE_INFO:
			print(i, '=>', RELEASE_INFO[i])

	def show(self, type_info):
		RELEASE_INFO = self.get_info()

		if type_info == 'ALL':
			return RELEASE_INFO

		if type_info in RELEASE_INFO.keys():
			return str(RELEASE_INFO[type_info]) 
		else:
			return 'False'
	

class AddRepo(SysInfo):
	def __init__(self):
		pass

	def archlinux(self):
		# Verificar se o sistema e ArchLinux.
		if self.show('ID') != 'arch':
			print(f'{CRed}[!] Seu sistema não é ArchLinux{CReset}')
			return
		
		file_backup_pacman = '/etc/pacman.conf.bak'

		# Criar backup do arquivo /etc/pacman.conf se ainda não existir.
		if os.path.isfile(file_backup_pacman) == True:
			print(f'{CYellow}[+] Backup encontrado: {file_backup_pacman}{CReset}')
		else:
			print(f'{CYellow}[+] Fazendo backup do arquivo: {file_backup_pacman}{CReset}')
			shutil.copyfile('/etc/pacman.conf', file_backup_pacman)

		LinesPacmanConf = read_file('/etc/pacman.conf')

		for num in range(0, len(LinesPacmanConf)):
			line = str(LinesPacmanConf[num])
			
			if (line == str('#[multilib]')) or (line == str('[multilib]')):
				numLineMirrorList = int(num + 1) # Linha que está em baixo do [multilib]
				LinesPacmanConf[numLineMirrorList] = 'Include = /etc/pacman.d/mirrorlist'
				LinesPacmanConf[num] = '[multilib]'

		# Gravar o novo conteúdo em um arquivo temporário.
		write_file(tmpFile, LinesPacmanConf)

		print(f'{CYellow}[+] Configurando: /etc/pacman.conf{CReset}')
		shutil.copyfile(tmpFile, '/etc/pacman.conf')

		print(f'{CYellow}[+] Atualizando repostórios {CReset}')
		os.system('pacman -Sy')
			
	def debian(self):
		# Verificar se o sistema e Debian.
		if self.show('ID') != 'debian':
			print(f'{CRed}[!] Seu sistema não é Debian{CReset}')
			return False

		if self.show('VERSION_CODENAME' == ''):
			return False
		
		os_codename = self.show('VERSION_CODENAME')
		debianRepoMain = str((f'deb http://deb.debian.org/debian {os_codename} main'))
		debianRepoContrib = str((f'deb http://deb.debian.org/debian {os_codename} contrib'))
		debianRepoNonfree = str((f'deb http://deb.debian.org/debian {os_codename} non-free'))
		debianMainContribNonfree = str((f'deb http://deb.debian.org/debian {os_codename} main contrib non-free'))
		file_backup_apt = '/etc/apt/sources.list.bak'

		if os.path.isfile(file_backup_apt) == False:
			print(f'Criando backup do arquivo ... /etc/apt/sources.list')
			shutil.copyfile('/etc/apt/sources.list', file_backup_apt)

		contentSources = read_file('/etc/apt/sources.list')
		RegExp = re.compile(r'^deb .*buster main.*')
		for num in range(0, len(contentSources)):
			if num > len(contentSources):
				break

			line = str(contentSources[num])
			add = True
			if not RegExp.findall(line) == []:
				if line == debianMainContribNonfree:
					add = False
					break

				print(f'Repositório main encontrado na linha ... {num}')
				NewLine = re.sub(r'^deb', '# deb', line)
				print(f'Substituindo por ... {NewLine}')
				contentSources[num] = NewLine

			num += 1

		# Gravar o novo conteúdo em um arquivo temporário.
		if add == True:
			print('Adicionando repositório main contrib non-free')
			contentSources.append(debianMainContribNonfree)
		else:
			print('OK')
			return True

		write_file(tmpFile, contentSources)
		print(f'{CYellow}Copiando {tmpFile} => /etc/apt/sources.list{CReset}')
		os.remove('/etc/apt/sources.list')
		shutil.copyfile(tmpFile, '/etc/apt/sources.list')

		print(f'{CYellow}Atualizando repostórios{CReset}')
		os.system('apt update')
		print('OK')

	def fedora(self):
		# sudo dnf repolist
		# sudo dnf repository-packages fedora list
		# sudo dnf repository-packages fedora list available
		# sudo dnf repository-packages fedora list installed
		# sudo vim /etc/yum.repos.d/grafana.repo
		# sudo dnf config-manager --add-repo /etc/yum.repos.d/grafana.repo
		# sudo dnf --enablerepo=grafana install grafana  
		# sudo dnf --disablerepo=fedora-extras install grafana
		# dnf --best upgrade
		# 

		# Verificar se o sistema e Fedora.
		if self.show('ID') != 'fedora':
			print(f'{CRed}[!] Seu sistema não é Fedora{CReset}')
			return False

		repoFusionFree = 'https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release'
		repoFusionNonFree = 'https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release'

		print(f"{CYellow}Adicionando os seguintes repositórios: {CReset}")
		print(repoFusionNonFree)
		print(repoFusionFree)
		print("fedora-workstation-repositories")
		
		os.system(f'sudo dnf install -y {repoFusionFree}-$(rpm -E %fedora).noarch.rpm')
		os.system(f'sudo dnf install -y {repoFusionNonFree}-$(rpm -E %fedora).noarch.rpm') 
		os.system('sudo dnf install -y fedora-workstation-repositories')


parser = argparse.ArgumentParser(description='Habilita repostório em distribuições Linux.')

parser.add_argument(
	'-v', '--version', 
	action='version', 
	version=(f"%(prog)s {__version__}")
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
	elif args.distro == 'debian':
		AddRepo().debian()
	elif args.distro == 'fedora':
		AddRepo().fedora()
