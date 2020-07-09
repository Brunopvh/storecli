#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinBrowser: 

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

		self.Container9 = Frame(master)
		self.Container9["pady"] = self.padyPadrao
		self.Container9["padx"] = self.padxPadrao
		self.Container9.pack()

		self.Container10 = Frame(master)
		self.Container10["pady"] = self.padyPadrao
		self.Container10["padx"] = self.padxPadrao
		self.Container10.pack()

		self.Container11 = Frame(master)
		self.Container11["pady"] = self.padyPadrao
		self.Container11["padx"] = self.padxPadrao
		self.Container11.pack()

		self.Container12 = Frame(master)
		self.Container12["pady"] = self.padyPadrao
		self.Container12["padx"] = self.padxPadrao
		self.Container12.pack()

		self.Container13 = Frame(master)
		self.Container13["pady"] = self.padyPadrao
		self.Container13["padx"] = self.padxPadrao
		self.Container13.pack()

		self.Container14 = Frame(master)
		self.Container14["pady"] = self.padyPadrao
		self.Container14["padx"] = self.padxPadrao
		self.Container14.pack()

		self.Container15 = Frame(master)
		self.Container15["pady"] = self.padyPadrao
		self.Container15["padx"] = self.padxPadrao
		self.Container15.pack()


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

		self.chromium = Button(self.Container2)
		self.chromium.configure(
							text='chromium',
							command=self.install_chromium, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.chromium.pack(side=LEFT)

		self.info_chromium = Button(self.Container2)
		self.info_chromium.configure(
								text='info', 
								command=self.show_info_chromium,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_chromium.pack(side=RIGHT)

		self.firefox = Button(self.Container3)
		self.firefox.configure(
								text='firefox', 
								command=self.install_firefox,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.firefox.pack(side=LEFT)

		self.info_firefox = Button(self.Container3)
		self.info_firefox.configure(
								text='info', 
								command=self.show_info_firefox,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_firefox.pack(side=RIGHT)

		self.google_chrome = Button(self.Container4)
		self.google_chrome.configure(
								text="google-chrome", 
								command=self.install_google_chrome,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.google_chrome.pack(side=LEFT)

		self.info_google_chrome = Button(self.Container4)
		self.info_google_chrome.configure(
								text='info', 
								command=self.show_info_google_chrome,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_google_chrome.pack(side=RIGHT)

		self.opera_stable = Button(self.Container5)
		self.opera_stable.configure(
							text='opera-stable', 							
							command=self.install_opera_stable,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.opera_stable.pack(side=LEFT)

		self.info_opera_stable = Button(self.Container5)
		self.info_opera_stable.configure(
								text='info', 
								command=self.show_info_opera_stable,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_opera_stable.pack(side=RIGHT)


		self.torbrowser = Button(self.Container6)
		self.torbrowser.configure(
							text='torbrowser', 							
							command=self.install_torbrowser,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.torbrowser.pack(side=LEFT)

		self.info_torbrowser = Button(self.Container6)
		self.info_torbrowser.configure(
								text='info', 
								command=self.show_info_torbrowser,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_torbrowser.pack(side=RIGHT)


	def close_windows(self):
		self.master.destroy()

	def show_ok(self):
		print('---------------------------------------------')
		print('OK')
	
	def install_chromium(self):
		system('storecli install --yes chromium')
		self.show_ok()

	def show_info_chromium(self):
		self.msg_show_info['text'] = 'Chromium é um\nnavegador de internet'

	def install_firefox(self):
		system('storecli install --yes firefox')
		self.show_ok()

	def show_info_firefox(self):
		self.msg_show_info['text'] = 'Firefox é um navegador de internet'


	def install_google_chrome(self):
		system('storecli install --yes google-chrome')
		self.show_ok()

	def show_info_google_chrome(self):
		self.msg_show_info['text'] = 'Google chrome é um\nnavegador de internet'


	def install_opera_stable(self):
		system('storecli install --yes opera-stable')
		self.show_ok()

	def show_info_opera_stable(self):
		self.msg_show_info['text'] = 'Opera é um\nnavegador de internet'

	def install_torbrowser(self):
		system('storecli install --yes torbrowser')
		self.show_ok()

	def show_info_torbrowser(self):
		self.msg_show_info['text'] = 'TorBrowser é um\nnavegador de internet'



