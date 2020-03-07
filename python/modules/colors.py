#!/usr/bin/env python3
#
#

Red = '\033[1;31m'
Green = '\033[1;32m'
Yellow = '\033[1;33m'
White = '\033[1;37m'
Reset = '\033[m'

class C:
	"""
	Altera a cor do terminal (Color).
	"""

	def red():
		print(Red, end='')

	def green():
		print(Green, end='')

	def yellow():
		print(Yellow, end='')

	def white():
		print(White, end='')

	def reset():
		print(Reset, end='')
		
#----------------------------------------------------------#
class msg:
	"""
	Exibe mensagem com determinada cor.
	"""

	def red(text):
		print('=> ', end='')
		C.red()
		print(f'{text}')
		C.reset()
	
	def green(text):
		print('=> ', end='')
		print(f'{Green}{text}{Reset}')

	def yellow(text):
		print('=> ', end='')
		print(f'{Yellow}{text}{Reset}')
		

	def white(text):
		print('=> ', end='')
		print(f'{White}{text}{Reset}')