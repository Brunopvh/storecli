#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import os, sys
import argparse
import urllib.request
from time import sleep

try:
    from tqdm import tqdm
except:
    print('Instale o módulo tqdm: pip3 install tqdm --user')
    sys.exit()

__version__ = '2020-08-05'

columns = os.get_terminal_size(0)[0]
line = ('-' * columns)

class DownloadProgressBar(tqdm):
    def update_to(self, b=1, bsize=1, tsize=None):
        if tsize is not None:
            self.total = tsize
        self.update(b * bsize - self.n)


def exec_download(url, output_path):
    with DownloadProgressBar(
    						unit='B', 
    						unit_scale=True,
							miniters=1, 
							desc=url.split('/')[-1]
							) as t:
        urllib.request.urlretrieve(url, filename=output_path, reporthook=t.update_to)

class Wcli:
	def __init__(self):
		pass

	def get_info_url(self, url):
		info = urllib.request.urlopen(url)
		length = int(info.getheader('content-length'))
		lengthMB = (length) / int(1024 * 1024)

		if length:
			print(info.getheader())
			return length

	def run(self, url, output_path):
		size = self.get_info_url(url)
		print('Baixando: {:.2f}'.format(size))
		exec_download(url, output_path)



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
	dest='url',
	type=str,
	required=True,
	help='Informe um URL'
	)


args = parser.parse_args()

output_path = '/home/bruno/Downloads/peazip-progresso.exe'
#url = 'https://ufpr.dl.sourceforge.net/project/peazip/7.3.2/peazip-7.3.2.WIN64.exe'

if args.destination_file:
	Wcli().run(args.url, args.destination_file)




