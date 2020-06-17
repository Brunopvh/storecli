#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinInternet: 

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

		self.chromium = Button(self.Container2)
		self.chromium.configure(
							text='chromium',
							command=self.install_chromium, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.chromium.pack()

		self.firefox = Button(self.Container3)
		self.firefox.configure(
								text='firefox', 
								command=self.install_firefox,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.firefox.pack()

		self.google_chrome = Button(self.Container4)
		self.google_chrome.configure(
								text="google-chrome", 
								command=self.install_google_chrome,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.google_chrome.pack()

		self.megasync = Button(self.Container5)
		self.megasync.configure(
							text="megasync", 							
							command=self.install_megasync,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.megasync.pack()

		self.opera_stable = Button(self.Container6)
		self.opera_stable.configure(
							text='opera-stable', 							
							command=self.install_opera_stable,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.opera_stable.pack()

		self.qbittorrent = Button(self.Container7)
		self.qbittorrent.configure(
							text='qbittorrent', 							
							command=self.install_qbittorrent,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.qbittorrent.pack()

		self.skype = Button(self.Container8)
		self.skype.configure(
							text='skype', 							
							command=self.install_skype,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.skype.pack()

		self.teamviewer = Button(self.Container9)
		self.teamviewer.configure(
							text='teamviewer', 							
							command=self.install_teamviewer,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.teamviewer.pack()

		self.telegram = Button(self.Container10)
		self.telegram.configure(
							text='telegram', 							
							command=self.install_telegram,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.telegram.pack()

		self.tixati = Button(self.Container11)
		self.tixati.configure(
							text='tixati', 							
							command=self.install_tixati,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.tixati.pack()

		self.torbrowser = Button(self.Container12)
		self.torbrowser.configure(
							text='torbrowser', 							
							command=self.install_torbrowser,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.torbrowser.pack()

		self.uget = Button(self.Container13)
		self.uget.configure(
							text='uget', 							
							command=self.install_uget,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.uget.pack()

		self.youtube_dl = Button(self.Container14)
		self.youtube_dl.configure(
							text='youtube-dl', 							
							command=self.install_youtube_dl,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.youtube_dl.pack()

		self.youtube_dl_gui = Button(self.Container15)
		self.youtube_dl_gui.configure(
							text='youtube-dl-gui', 							
							command=self.install_youtube_dl_gui,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.youtube_dl_gui.pack()


	def close_windows(self):
		self.master.destroy()
	
	def install_chromium(self):
		system('storecli install --yes chromium')

	def install_firefox(self):
		system('storecli install --yes firefox')

	def install_google_chrome(self):
		system('storecli install --yes google-chrome')

	def install_megasync(self):
		system('storecli install --yes megasync')

	def install_opera_stable(self):
		system('storecli install --yes opera-stable')

	def install_qbittorrent(self):
		system('storecli install --yes qbittorrent')

	def install_skype(self):
		system('storecli install --yes skype')

	def install_teamviewer(self):
		system('storecli install --yes teamviewer')

	def install_telegram(self):
		system('storecli install --yes telegram')

	def install_tixati(self):
		system('storecli install --yes tixati')

	def install_torbrowser(self):
		system('storecli install --yes torbrowser')

	def install_uget(self):
		system('storecli install --yes uget')

	def install_youtube_dl(self):
		system('storecli install --yes youtube-dl')

	def install_youtube_dl_gui(self):
		system('storecli install --yes youtube-dl-gui')


