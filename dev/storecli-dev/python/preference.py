#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinPreference: 

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

		self.ohmybash = Button(self.Container2)
		self.ohmybash.configure(
							text='oh-my-bash',
							command=self.install_ohmybash, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.ohmybash.pack(side=LEFT)

		self.info_ohmybash = Button(self.Container2)
		self.info_ohmybash.configure(
							text='info',
							command=self.show_info_ohmybash, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							
							)
		self.info_ohmybash.pack(side=RIGHT)

		self.ohmyzsh = Button(self.Container3)
		self.ohmyzsh.configure(
								text='oh-myz-sh', 
								command=self.install_ohmyzsh,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.ohmyzsh.pack(side=LEFT)

		self.info_ohmyzsh = Button(self.Container3)
		self.info_ohmyzsh.configure(
								text='info', 
								command=self.show_info_ohmyzsh,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_ohmyzsh.pack(side=RIGHT)

		self.papirus = Button(self.Container4)
		self.papirus.configure(
								text='papirus icon theme', 
								command=self.install_papirus,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.papirus.pack(side=LEFT)

		self.info_papirus = Button(self.Container4)
		self.info_papirus.configure(
								text='info', 
								command=self.show_info_papirus,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_papirus.pack(side=RIGHT)


		self.sierra = Button(self.Container5)
		self.sierra.configure(
							text='sierra theme', 							
							command=self.install_sierra,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.sierra.pack(side=LEFT)

		self.info_sierra = Button(self.Container5)
		self.info_sierra.configure(
								text='info', 
								command=self.show_info_sierra,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_sierra.pack(side=RIGHT)


		

	def close_windows(self):
		self.master.destroy()
	
	def install_ohmybash(self):
		system('storecli install --yes ohmybash')

	def show_info_ohmybash(self):
		self.msg_show_info['text'] = 'O Oh-My-Bash é um conjunto de\nestilização para seu terminal\ncom shell bash'

	def install_ohmyzsh(self):
		system('storecli install --yes ohmyzsh')

	def show_info_ohmyzsh(self):
		self.msg_show_info['text'] = 'O Oh-My-Zsh é um conjunto de\nestilização para seu terminal\ncom shell zsh'

	def install_papirus(self):
		system('storecli install --yes papirus')

	def show_info_papirus(self):
		self.msg_show_info['text'] = 'Papirus e um cojunto de\ntema de icones para\nsistemas Linux'

	def install_sierra(self):
		system('storecli install --yes sierra')

	def show_info_sierra(self):
		self.msg_show_info['text'] = 'Sierra e um tema com o\nvizual do MacOs 10.12 para\nsistemas Linux'



