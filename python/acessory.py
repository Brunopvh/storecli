#!/usr/bin/env python3
#

import os
from tkinter import *

class WinAcessory: 

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
		self.Container1.pack(side=TOP)

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

		self.etcher = Button(self.Container2)
		self.etcher.configure(
							text="etcher",
							command=self.install_etcher, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.etcher.pack(side=LEFT)

		self.info_etcher = Button(self.Container2)
		self.info_etcher.configure(
							text='info',
							command=self.show_info_etcher, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_etcher.pack(side=RIGHT)


		self.gnome_disk = Button(self.Container3)
		self.gnome_disk.configure(
								text="gnome-disk", 
								command=self.install_gnomedisk,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.gnome_disk.pack(side=LEFT)

		self.info_gnome_disk = Button(self.Container3)
		self.info_gnome_disk.configure(
							text='info',
							command=self.show_info_gnome_disk, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_gnome_disk.pack(side=RIGHT)

		self.veracrypt = Button(self.Container4)
		self.veracrypt.configure(
								text="veracrypt", 
								command=self.install_veracrypt,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.veracrypt.pack(side=LEFT)

		self.info_veracrypt = Button(self.Container4)
		self.info_veracrypt.configure(
							text='info',
							command=self.show_info_veracrypt, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_veracrypt.pack(side=RIGHT)


		self.woeusb = Button(self.Container5)
		self.woeusb.configure(
							text="woeusb", 							
							command=self.install_woeusb,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.woeusb.pack(side=LEFT)

		self.info_woeusb = Button(self.Container5)
		self.info_woeusb.configure(
							text='info',
							command=self.show_info_woeusb, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_woeusb.pack(side=RIGHT)


	def close_windows(self):
		self.master.destroy()
	
	def install_etcher(self):
		os.system('storecli install --yes etcher')

	def show_info_etcher(self):
		self.msg_show_info['text'] = 'Balena Etcher\né um utilitário para criar\nunidades de midia bootáveis'

	def install_gnomedisk(self):
		os.system('storecli install --yes gnome-disk')

	def show_info_gnome_disk(self):
		self.msg_show_info['text'] = 'Utilitário para formatar e\nmanipular unidades de disco\ne midias removiveis'

	def install_veracrypt(self):
		os.system('storecli install --yes veracrypt')

	def show_info_veracrypt(self):
		self.msg_show_info['text'] = 'Veracrypt encrypta e decrypta\npartições de disco e unidades\nremoviveis'

	def install_woeusb(self):
		os.system('storecli install --yes woeusb')

	def show_info_woeusb(self):
		self.msg_show_info['text'] = 'WoeUsb cria midias bootáveis\ncom o sistema Windows'

