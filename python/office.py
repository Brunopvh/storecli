#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinOffice: 

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

		self.atril = Button(self.Container2)
		self.atril.configure(
							text='atril',
							command=self.install_atril, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.atril.pack(side=LEFT)

		self.info_atril = Button(self.Container2)
		self.info_atril.configure(
							text='info',
							command=self.show_info_atril, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_atril.pack(side=RIGHT)


		self.fontes_microsoft = Button(self.Container3)
		self.fontes_microsoft.configure(
								text='fontes microsoft', 
								command=self.install_fontes_microsoft,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.fontes_microsoft.pack(side=LEFT)

		self.info_fontes_microsoft = Button(self.Container3)
		self.info_fontes_microsoft.configure(
							text='info',
							command=self.show_info_fontes_microsoft, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_fontes_microsoft.pack(side=RIGHT)

		self.libreoffice = Button(self.Container4)
		self.libreoffice.configure(
								text='libreoffice', 
								command=self.install_libreoffice,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.libreoffice.pack(side=LEFT)

		self.info_libreoffice = Button(self.Container4)
		self.info_libreoffice.configure(
							text='info',
							command=self.show_info_libreoffice, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_libreoffice.pack(side=RIGHT)

		self.libreoffice_appimage = Button(self.Container5)
		self.libreoffice_appimage.configure(
							text='libreoffice Appimage', 							
							command=self.install_libreoffice_appimage,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.libreoffice_appimage.pack(side=LEFT)

		self.info_libreoffice_appimage = Button(self.Container5)
		self.info_libreoffice_appimage.configure(
							text='info',
							command=self.show_info_libreoffice_appimage, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_libreoffice_appimage.pack(side=RIGHT)


	def close_windows(self):
		self.master.destroy()
	
	def install_atril(self):
		system('storecli install --yes atril')

	def show_info_atril(self):
		self.msg_show_info['text'] = 'Vizualizador de PDF do Mate'

	def install_fontes_microsoft(self):
		system('storecli install --yes fontes-ms')

	def show_info_fontes_microsoft(self):
		self.msg_show_info['text'] = 'Instala algumas fontes da microsoft\nArial Times New Roman etc.'

	def install_libreoffice(self):
		system('storecli install --yes libreoffice')

	def show_info_libreoffice(self):
		self.msg_show_info['text'] = 'LibreOffice é uma suíte de\nprodutividade de escritório completa'

	def install_libreoffice_appimage(self):
		system('storecli install --yes libreoffice-appimage')

	def show_info_libreoffice_appimage(self):
		self.msg_show_info['text'] = 'LibreOffice é uma suíte de\nprodutividade de escritório completa\n(AppImage)'


