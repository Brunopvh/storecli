#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinGshell: 

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

		self.dash_todock = Button(self.Container2)
		self.dash_todock.configure(
							text='dash-to-dock',
							command=self.install_dash_todock, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.dash_todock.pack(side=LEFT)

		self.info_dash_todock = Button(self.Container2)
		self.info_dash_todock.configure(
							text='info',
							command=self.show_info_dash_todock, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							
							)
		self.info_dash_todock.pack(side=RIGHT)

		self.drive_menu = Button(self.Container3)
		self.drive_menu.configure(
								text='drive-menu', 
								command=self.install_drive_menu,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.drive_menu.pack(side=LEFT)

		self.info_drive_menu = Button(self.Container3)
		self.info_drive_menu.configure(
								text='info', 
								command=self.show_info_drive_menu,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_drive_menu.pack(side=RIGHT)


		self.gnome_backgrounds = Button(self.Container4)
		self.gnome_backgrounds.configure(
							text='gnome-backgrounds', 							
							command=self.install_gnome_backgrounds,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.gnome_backgrounds.pack(side=LEFT)

		self.info_gnome_backgrounds = Button(self.Container4)
		self.info_gnome_backgrounds.configure(
								text='info', 
								command=self.show_info_gnome_backgrounds,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_gnome_backgrounds.pack(side=RIGHT)


		self.gnome_tweaks = Button(self.Container5)
		self.gnome_tweaks.configure(
							text='gnome-tweaks', 							
							command=self.install_gnome_tweaks,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.gnome_tweaks.pack(side=LEFT)

		self.info_gnome_tweaks = Button(self.Container5)
		self.info_gnome_tweaks.configure(
								text='info', 
								command=self.show_info_gnome_tweaks,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_gnome_tweaks.pack(side=RIGHT)


		self.topicons_plus = Button(self.Container6)
		self.topicons_plus.configure(
								text='topicons-plus', 
								command=self.install_topicons_plus,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.topicons_plus.pack(side=LEFT)

		self.info_topicons_plus = Button(self.Container6)
		self.info_topicons_plus.configure(
								text='info', 
								command=self.show_info_topicons_plus,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_topicons_plus.pack(side=RIGHT)
		

	def close_windows(self):
		self.master.destroy()
	
	def install_dash_todock(self):
		system('storecli install --yes dash-to-dock')

	def show_info_dash_todock(self):
		self.msg_show_info['text'] = 'Dock para o gnome shell'

	def install_drive_menu(self):
		system('storecli install --yes drive-menu')

	def show_info_drive_menu(self):
		self.msg_show_info['text'] = 'Extensão para exibir midias\nremoviveis no top bar do gnome'

	def install_gnome_backgrounds(self):
		system('storecli install --yes gnome-backgrounds')

	def show_info_gnome_backgrounds(self):
		self.msg_show_info['text'] = 'Papeis de parede para gnome'

	def install_gnome_tweaks(self):
		system('storecli install --yes gnome-tweaks')

	def show_info_gnome_tweaks(self):
		self.msg_show_info['text'] = 'Ferramenta para gerenciar\nextensões e a aparencia\ndo gnome'

	def install_topicons_plus(self):
		system('storecli install --yes topicons-plus')

	def show_info_topicons_plus(self):
		self.msg_show_info['text'] = 'Extensão para exibir icones de\nprogramas no top bar do gnome'

