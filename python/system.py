#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinSystem: 

	def __init__(self, master): 
		self.master = master

		self.padxPadrao = 15
		self.padyPadrao = 4
		self.backgroundPadrao = 'white'
		self.fontPadrao = 10
		self.widthPadrao = 15
		self.heightPadrao = 1

		
		self.Container1 = Frame(master)
		self.Container1["pady"] = self.padyPadrao
		self.Container1["padx"] = self.padxPadrao
		self.Container1.pack()

		self.Container2 = Frame(master)
		self.Container2["pady"] = self.padyPadrao
		self.Container2["padx"] = self.padxPadrao
		self.Container2.pack()

		self.Container3 = Frame(master)
		self.Container3["pady"] = self.padyPadrao
		self.Container3["padx"] = self.padxPadrao
		self.Container3.pack()

		self.Container4 = Frame(master)
		self.Container4["pady"] = self.padyPadrao
		self.Container4["padx"] = self.padxPadrao
		self.Container4.pack()

		self.Container5 = Frame(master)
		self.Container5["pady"] = self.padyPadrao
		self.Container5["padx"] = self.padxPadrao
		self.Container5.pack()

		self.Container6 = Frame(master)
		self.Container6["pady"] = self.padyPadrao
		self.Container6["padx"] = self.padxPadrao
		self.Container6.pack()

		self.Container7 = Frame(master)
		self.Container7["pady"] = self.padyPadrao
		self.Container7["padx"] = self.padxPadrao
		self.Container7.pack()

		self.Container8 = Frame(master)
		self.Container8["pady"] = self.padyPadrao
		self.Container8["padx"] = self.padxPadrao
		self.Container8.pack()

#=========================================================#
# Criação dos botões
#=========================================================#

		self.msg_show_info = Label(self.Container1)
		self.msg_show_info['text'] = ''
		self.msg_show_info['width'] = 30
		self.msg_show_info['height'] = 3
		self.msg_show_info['background'] = "green"
		self.msg_show_info['font'] = ('Calibri', '12')
		self.msg_show_info.pack()

		
		self.botao_voltar = Button(self.Container1)
		self.botao_voltar["command"] = self.close_windows
		self.botao_voltar['text'] = 'Voltar'
		self.botao_voltar.configure(
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.botao_voltar.pack()

		self.bluetooth = Button(self.Container2)
		self.bluetooth.configure(
							text='bluetooth',
							command=self.install_bluetooth, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.bluetooth.pack(side=LEFT)

		self.info_bluetooth = Button(self.Container2)
		self.info_bluetooth.configure(
							text='info',
							command=self.show_info_bluetooth, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							
							)
		self.info_bluetooth.pack(side=RIGHT)

		self.compactadores = Button(self.Container3)
		self.compactadores.configure(
								text='compactadores', 
								command=self.install_compactadores,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.compactadores.pack(side=LEFT)

		self.info_compactadores = Button(self.Container3)
		self.info_compactadores.configure(
								text='info', 
								command=self.show_info_compactadores,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_compactadores.pack(side=RIGHT)

		self.gparted = Button(self.Container4)
		self.gparted.configure(
								text='gparted', 
								command=self.install_gparted,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.gparted.pack(side=LEFT)

		self.info_gparted = Button(self.Container4)
		self.info_gparted.configure(
								text='info', 
								command=self.show_info_gparted,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_gparted.pack(side=RIGHT)


		self.peazip = Button(self.Container5)
		self.peazip.configure(
							text='peazip', 							
							command=self.install_peazip,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.peazip.pack(side=LEFT)

		self.info_peazip = Button(self.Container5)
		self.info_peazip.configure(
								text='info', 
								command=self.show_info_peazip,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_peazip.pack(side=RIGHT)


		self.refind = Button(self.Container6)
		self.refind.configure(
							text='refind', 							
							command=self.install_refind,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.refind.pack(side=LEFT)

		self.info_refind = Button(self.Container6)
		self.info_refind.configure(
								text='info', 
								command=self.show_info_refind,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_refind.pack(side=RIGHT)


		self.stacer = Button(self.Container7)
		self.stacer.configure(
							text='stacer', 							
							command=self.install_stacer,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.stacer.pack(side=LEFT)

		self.info_stacer = Button(self.Container7)
		self.info_stacer.configure(
								text='info', 
								command=self.show_info_stacer,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_stacer.pack(side=RIGHT)



		self.virtualbox = Button(self.Container8)
		self.virtualbox.configure(
							text='virtualbox', 							
							command=self.install_virtualbox,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.virtualbox.pack(side=LEFT)

		self.info_virtualbox = Button(self.Container8)
		self.info_virtualbox.configure(
								text='info', 
								command=self.show_info_virtualbox,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_virtualbox.pack(side=RIGHT)

	def close_windows(self):
		self.master.destroy()
	
	def install_bluetooth(self):
		system('storecli install --yes bluetooth')

	def show_info_bluetooth(self):
		self.msg_show_info['text'] = 'Instalar firmware e ferramentas\npara gerenciar bluetooth'

	def install_compactadores(self):
		system('storecli install --yes compactadores')

	def show_info_compactadores(self):
		self.msg_show_info['text'] = 'Instala ferramentas\ncom suporte a compressão\ne descompressão de arquivos'

	def install_gparted(self):
		system('storecli install --yes gparted')

	def show_info_gparted(self):
		self.msg_show_info['text'] = 'Ferramenta de interface gráfica\npara manipular partições de disco'

	def install_peazip(self):
		system('storecli install --yes peazip')

	def show_info_peazip(self):
		self.msg_show_info['text'] = 'Utilitário de interface gráfica\npara compressão e descompressão\nde arquivos'

	def install_refind(self):
		system('storecli install --yes refind-mpv')

	def show_info_refind(self):
		self.msg_show_info['text'] = 'Gerenciador de boot EFI gráfico\npara sistemas\nLinux, Windows, BSD e MacOs'

	def install_stacer(self):
		system('storecli install --yes stacer')

	def show_info_stacer(self):
		self.msg_show_info['text'] = 'Stacer é um utilitário gráfico\npara gerenciar processos do sistema'

	def install_virtualbox(self):
		system('storecli install --yes virtualbox')

	def show_info_virtualbox(self):
		self.msg_show_info['text'] = 'VirtualBox é um software\nde virtualização'

	



