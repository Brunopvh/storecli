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

		
		self.msg_opcao = Button(self.Container1)
		self.msg_opcao["text"]= "Clique em um programa\npara instalar"
		self.msg_opcao["width"] = 25
		self.msg_opcao["background"] = "green"
		self.msg_opcao["font"] = ("Calibri", "12")
		self.msg_opcao.pack()

		
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
		self.etcher.pack()

		self.gnome_disk = Button(self.Container3)
		self.gnome_disk.configure(
								text="gnome-disk", 
								command=self.install_gnomedisk,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.gnome_disk.pack()

		self.veracrypt = Button(self.Container4)
		self.veracrypt.configure(
								text="veracrypt", 
								command=self.install_veracrypt,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.veracrypt.pack()

		self.woeusb = Button(self.Container5)
		self.woeusb.configure(
							text="woeusb", 							
							command=self.install_woeusb,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.woeusb.pack()


	def close_windows(self):
		self.master.destroy()
	
	def install_etcher(self):
		os.system('storecli install --yes etcher')

	def install_gnomedisk(self):
		os.system('storecli install --yes gnome-disk')

	def install_veracrypt(self):
		os.system('storecli install --yes veracrypt')

	def install_woeusb(self):
		os.system('storecli install --yes woeusb')


