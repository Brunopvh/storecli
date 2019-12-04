#!/usr/bin/env python3
#
#
VER = '2019-11-13'
#

import os, platform, re


# Cores 
red = '\033[1;31m'
green = '\033[1;32m'
yellow = '\033[1;33m'
reset = '\033[m'

Red = '\033[1;31;5m'
Green = '\033[1;32;5m'
Yellow = '\033[1;33;5m'

# texto = re.sub(".!?,", texto, "")

# platform()
"""
platform.machine()
    Arch

platform.node()

platform.platform(aliased=0, terse=0)

platform.processor()

platform.python_build()

platform.python_compiler()

platform.python_branch()

platform.python_implementation()

platform.python_revision()

platform.python_version()

platform.python_version_tuple()

platform.release()

platform.system()

platform.system_alias(system, release, version)

platform.version()

platform.uname()

"""

os_type = str(platform.system())

#-------------------------------------------------#

if os.path.isfile('/usr/lib/os-release') == True:
	arq_release = '/usr/lib/os-release'
	rel = open(arq_release, 'r')
	
elif os.path.isfile('/etc/os-release') == True:
	arq_release = '/etc/os-release'
	rel = open(arq_release, 'r')

#-------------------------------------------------#
# Name/ID
def _sys_name(sys_name=' '):

	if os_type == 'Linux':
		for line in rel.readlines():
			if line[0:3] == 'ID=':
				line = line.replace('ID=', '').replace('\n', '')
				sys_name = line 
				break

		rel.seek(0)

	elif os_type == 'Windows':
		sys_name = str(platform.system())

	return sys_name

#-------------------------------------------------#
# system version
def _sys_version(sys_version=' '):
	
	if os_type == 'Linux':
		for line in rel.readlines():
			line = str(line)

			if line[0:11] == 'VERSION_ID=':
				line = line.replace('VERSION_ID=', '').replace('\n', '').replace('"', '')
				sys_version = line 
				break

		rel.seek(0)

	elif os_type == 'Windows':
		sys_version = str(platform.uname()[3])
	
	return sys_version
		
#-------------------------------------------------#
# Codiname
def _sys_codiname(sys_codiname=' '):

	if os_type == 'Linux':
		cont_rel = rel.readlines()

		if (sys_name == 'debian'):
			sys_codiname = cont_rel[4].replace('\n', '').replace('VERSION_CODENAME=', '')

		elif (sys_name == 'ubuntu') or (sys_name == 'linuxmint'):
			for num in range(0, len(cont_rel)):
				if 'VERSION_CODENAME=' in cont_rel[num]:
					sys_codiname = cont_rel[num].replace('VERSION_CODENAME=', '').replace('\n', '')

		elif sys_name == 'fedora':
			sys_codiname = cont_rel[1].replace('\n', '').replace('VERSION=', '').replace('"', '').lower().strip()			
			sys_codiname = sys_codiname.replace('(', '').replace(')', '').replace(' ', '')
			

		rel.seek(0)

	elif os_type == 'Windows':
		sys_codiname = str(platform.release())


	num_int = re.findall('\d', sys_codiname)
	for char in num_int:
		sys_codiname = sys_codiname.replace(char, '')


	return sys_codiname

#-------------------------------------------------#
# Run
sys_name = _sys_name(' ') 
sys_version = _sys_version(' ') 
sys_codiname = _sys_codiname(' ') 



#rel.close()















