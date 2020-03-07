#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
SYS_INFO_VERSION = '2020-03-06'
#
#-------------------- USO --------------------------#
# from sys_info import SysInfo
# info = SysInfo()
#
# info = SysInfo()
# os_id = info.get_id()
# os_version = info.get_version()
# os_codename = info.get_codename()
# os_version_id = info.get_version_id()
#
# print(os_id)
# print(os_version)
# print(os_codename)
# print(os_version)
# print(os_version_id)
#

import os, platform

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

	def get_id(self):
		"""
		debian/ubuntu/fedora...
		"""
		for i in lines_release:
			if i[0:3] == 'ID=':
				os_id = i.replace('\n', '').replace('"', '').replace('ID=', '')
				break

		self.os_id = os_id
		return self.os_id
		
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

		