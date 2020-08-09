#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#

import os, sys
import platform
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


def exec_download(url, output_path=None):
    with DownloadProgressBar(
    						unit='B', 
    						unit_scale=True,
							miniters=1, 
							desc=url.split('/')[-1]
							) as t:
        
    	if output_path == None:
    		urllib.request.urlretrieve(url, reporthook=t.update_to)
    	else:
        	urllib.request.urlretrieve(url, filename=output_path, reporthook=t.update_to)


class WebCli:
	def __init__(self):
		pass

	def get_info_url(self, url):
		info = urllib.request.urlopen(url)
		try:
			length = int(info.getheader('content-length'))
		except:
			pass

		if length:
			# lengthMB = float(length / int(1024 * 1024))
			# print(info.getheader())
			return length

		return None

	def run(self, url, output_path=None):
		print(f'Conectando .... {url}')
		
		if output_path != 'None':
			print(f'Salvando arquivo em ... {output_path}')
			exec_download(url, output_path)
		else:
			exec_download(url)


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

if args.destination_file:
	WebCli().run(args.URL, args.destination_file)




