#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

__version__ = '2020-08-05'

import os, sys
import platform
import argparse
import urllib.request

try:
	import progress.bar
except Exception as err:
	print(err)
	print('Execute ... pip3 install progress --user')
	sys.exit('1')

try:
	columns = os.get_terminal_size()[0]
except:
	columns = 40

line = ('-' * columns)


class ProgressBar():
	def __init__(self):
		self.pbar = None

	def __call__(self, block_num, block_size, total_size):
		if not self.pbar:
			self.pbar = progressbar.ProgressBar(maxval=total_size)
			self.pbar.start()

		downloaded = block_num * block_size
		if downloaded < total_size:
			self.pbar.update(downloaded)
		else:
			self.pbar.finish()


def run_download(url, output_path):
	print(f'Conectando ... {url}')
	
	try:
		urllib.request.urlretrieve(url, output_path, ProgressBar())
	except:
		sys.exit(1)
	else:
		sys.exit(0)



parser = argparse.ArgumentParser(
			description='Ferramenta para download de arquivos da com python3/urllib'
			)

parser.add_argument(
	'-v', '--version', 
	action='version', 
	version=(f"%(prog)s {__version__}")
	)

# Arquivo de destino
parser.add_argument(
	'-o', '--output', 
	action='store', 
	dest='destination_file',
	type=str,
	help='Informe um arquivo de destino'
	)


# URL.
parser.add_argument(
	'-u', '--url', 
	action='store', 
	dest='URL',
	type=str,
	required=True,
	help='Informe um URL'
	)


args = parser.parse_args()

# output_path = '/home/bruno/Downloads/peazip-progresso.exe'
# url = 'https://ufpr.dl.sourceforge.net/project/peazip/7.3.2/peazip-7.3.2.WIN64.exe'

if __name__ == '__main__':
	if args.destination_file:
		run_download(args.URL, args.destination_file)




