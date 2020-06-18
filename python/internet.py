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

		self.megasync = Button(self.Container1)
		self.megasync.configure(
							text="megasync", 							
							command=self.install_megasync,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.megasync.pack(side=LEFT)

		self.info_megasync = Button(self.Container1)
		self.info_megasync.configure(
								text='info', 
								command=self.show_info_megasync,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_megasync.pack(side=RIGHT)
		

		self.qbittorrent = Button(self.Container2)
		self.qbittorrent.configure(
							text='qbittorrent', 							
							command=self.install_qbittorrent,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.qbittorrent.pack(side=LEFT)

		self.info_qbittorrent = Button(self.Container2)
		self.info_qbittorrent.configure(
								text='info', 
								command=self.show_info_qbittorrent,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_qbittorrent.pack(side=RIGHT)


		self.skype = Button(self.Container3)
		self.skype.configure(
							text='skype', 							
							command=self.install_skype,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.skype.pack(side=LEFT)

		self.info_skype = Button(self.Container3)
		self.info_skype.configure(
								text='info', 
								command=self.show_info_skype,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_skype.pack(side=RIGHT)

		self.teamviewer = Button(self.Container4)
		self.teamviewer.configure(
							text='teamviewer', 							
							command=self.install_teamviewer,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.teamviewer.pack(side=LEFT)

		self.info_teamviewer = Button(self.Container4)
		self.info_teamviewer.configure(
								text='info', 
								command=self.show_info_teamviewer,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_teamviewer.pack(side=RIGHT)


		self.telegram = Button(self.Container5)
		self.telegram.configure(
							text='telegram', 							
							command=self.install_telegram,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.telegram.pack(side=LEFT)

		self.info_telegram = Button(self.Container5)
		self.info_telegram.configure(
								text='info', 
								command=self.show_info_telegram,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_telegram.pack(side=RIGHT)


		self.tixati = Button(self.Container6)
		self.tixati.configure(
							text='tixati', 							
							command=self.install_tixati,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.tixati.pack(side=LEFT)

		self.info_tixati = Button(self.Container6)
		self.info_tixati.configure(
								text='info', 
								command=self.show_info_tixati,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_tixati.pack(side=RIGHT)


		self.uget = Button(self.Container7)
		self.uget.configure(
							text='uget', 							
							command=self.install_uget,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.uget.pack(side=LEFT)

		self.info_uget = Button(self.Container7)
		self.info_uget.configure(
								text='info', 
								command=self.show_info_uget,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_uget.pack(side=RIGHT)

		self.youtube_dl = Button(self.Container8)
		self.youtube_dl.configure(
							text='youtube-dl', 							
							command=self.install_youtube_dl,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.youtube_dl.pack(side=LEFT)

		self.info_youtube_dl = Button(self.Container8)
		self.info_youtube_dl.configure(
								text='info', 
								command=self.show_info_youtube_dl,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_youtube_dl.pack(side=RIGHT)



		self.youtube_dl_gui = Button(self.Container9)
		self.youtube_dl_gui.configure(
							text='youtube-dl-gui', 							
							command=self.install_youtube_dl_gui,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.youtube_dl_gui.pack(side=LEFT)

		self.info_youtube_dl_gui = Button(self.Container9)
		self.info_youtube_dl_gui.configure(
								text='info', 
								command=self.show_info_youtube_dl_gui,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_youtube_dl_gui.pack(side=RIGHT)


	def close_windows(self):
		self.master.destroy()

	def install_megasync(self):
		system('storecli install --yes megasync')

	def show_info_megasync(self):
		self.msg_show_info['text'] = 'Megasync'

	def install_qbittorrent(self):
		system('storecli install --yes qbittorrent')

	def show_info_qbittorrent(self):
		self.msg_show_info['text'] = 'Qbittorrent e um gerenciador\nde bittorrent'

	def install_skype(self):
		system('storecli install --yes skype')

	def show_info_skype(self):
		self.msg_show_info['text'] = 'Skype'

	def install_teamviewer(self):
		system('storecli install --yes teamviewer')

	def show_info_teamviewer(self):
		self.msg_show_info['text'] = 'Teamviewer'

	def install_telegram(self):
		system('storecli install --yes telegram')

	def show_info_telegram(self):
		self.msg_show_info['text'] = 'Telegram'

	def install_tixati(self):
		system('storecli install --yes tixati')

	def show_info_tixati(self):
		self.msg_show_info['text'] = 'Tixati e um gerenciador\nde bittorrent'

	def install_uget(self):
		system('storecli install --yes uget')

	def show_info_uget(self):
		self.msg_show_info['text'] = 'Uget e um gerenciador\nde downloads'

	def install_youtube_dl(self):
		system('storecli install --yes youtube-dl')

	def show_info_youtube_dl(self):
		self.msg_show_info['text'] = 'youtube-dl baixa vídeos do\nyoutube via linha de comando'

	def install_youtube_dl_gui(self):
		system('storecli install --yes youtube-dl-gui')

	def show_info_youtube_dl_gui(self):
		self.msg_show_info['text'] = 'YoutubeDlGui e um GUI gráfico para\no youtube-dl'


