#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinMidia: 

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

		self.celluloid = Button(self.Container2)
		self.celluloid.configure(
							text='celluloid',
							command=self.install_celluloid, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.celluloid.pack(side=LEFT)

		self.info_celluloid = Button(self.Container2)
		self.info_celluloid.configure(
							text='info',
							command=self.show_info_celluloid, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							
							)
		self.info_celluloid.pack(side=RIGHT)

		self.cinema = Button(self.Container3)
		self.cinema.configure(
								text='cinema', 
								command=self.install_cinema,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.cinema.pack(side=LEFT)

		self.info_cinema = Button(self.Container3)
		self.info_cinema.configure(
								text='info', 
								command=self.show_info_cinema,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_cinema.pack(side=RIGHT)

		self.codecs = Button(self.Container4)
		self.codecs.configure(
								text='codecs', 
								command=self.install_codecs,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.codecs.pack(side=LEFT)

		self.info_codecs = Button(self.Container4)
		self.info_codecs.configure(
								text='info', 
								command=self.show_info_codecs,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_codecs.pack(side=RIGHT)


		self.spotify = Button(self.Container5)
		self.spotify.configure(
							text='spotify', 							
							command=self.install_spotify,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.spotify.pack(side=LEFT)

		self.info_spotify = Button(self.Container5)
		self.info_spotify.configure(
								text='info', 
								command=self.show_info_spotify,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_spotify.pack(side=RIGHT)


		self.gnome_mpv = Button(self.Container6)
		self.gnome_mpv.configure(
							text='gnome-mpv', 							
							command=self.install_gnome_mpv,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.gnome_mpv.pack(side=LEFT)

		self.info_gnome_mpv = Button(self.Container6)
		self.info_gnome_mpv.configure(
								text='info', 
								command=self.show_info_gnome_mpv,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_gnome_mpv.pack(side=RIGHT)


		self.parole = Button(self.Container7)
		self.parole.configure(
							text='parole', 							
							command=self.install_parole,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.parole.pack(side=LEFT)

		self.info_parole = Button(self.Container7)
		self.info_parole.configure(
								text='info', 
								command=self.show_info_parole,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_parole.pack(side=RIGHT)



		self.smplayer = Button(self.Container8)
		self.smplayer.configure(
							text='smplayer', 							
							command=self.install_smplayer,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.smplayer.pack(side=LEFT)

		self.info_smplayer = Button(self.Container8)
		self.info_smplayer.configure(
								text='info', 
								command=self.show_info_smplayer,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_smplayer.pack(side=RIGHT)



		self.totem = Button(self.Container9)
		self.totem.configure(
							text='totem', 							
							command=self.install_totem,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.totem.pack(side=LEFT)

		self.info_totem = Button(self.Container9)
		self.info_totem.configure(
								text='info', 
								command=self.show_info_totem,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_totem.pack(side=RIGHT)



		self.vlc = Button(self.Container10)
		self.vlc.configure(
							text='vlc', 							
							command=self.install_vlc,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.vlc.pack(side=LEFT)


		self.info_vlc = Button(self.Container10)
		self.info_vlc.configure(
								text='info', 
								command=self.show_info_vlc,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=5,
								height=self.heightPadrao,
								)
		self.info_vlc.pack(side=RIGHT)




	def close_windows(self):
		self.master.destroy()
	
	def install_celluloid(self):
		system('storecli install --yes celluloid')

	def show_info_celluloid(self):
		self.msg_show_info['text'] = 'celluloid é um player de vídeo'

	def install_cinema(self):
		system('storecli install --yes cinema')

	def show_info_cinema(self):
		self.msg_show_info['text'] = 'cinema é um player de vídeo'

	def install_codecs(self):
		system('storecli install --yes codecs')

	def show_info_codecs(self):
		self.msg_show_info['text'] = 'Instala vários codecs\npara reprodução de audio e vídeo'

	def install_spotify(self):
		system('storecli install --yes spotify')

	def show_info_spotify(self):
		self.msg_show_info['text'] = 'Spotify é um serviço\nde streaming de música'

	def install_gnome_mpv(self):
		system('storecli install --yes gnome-mpv')

	def show_info_gnome_mpv(self):
		self.msg_show_info['text'] = 'gnome-mpv é um player de vídeo'

	def install_parole(self):
		system('storecli install --yes parole')

	def show_info_parole(self):
		self.msg_show_info['text'] = 'parole é um player de vídeo'

	def install_smplayer(self):
		system('storecli install --yes smplayer')

	def show_info_smplayer(self):
		self.msg_show_info['text'] = 'smplayer é um player de vídeo'

	def install_totem(self):
		system('storecli install --yes totem')

	def show_info_totem(self):
		self.msg_show_info['text'] = 'totem é um player de vídeo'

	def install_vlc(self):
		system('storecli install --yes vlc')

	def show_info_vlc(self):
		self.msg_show_info['text'] = 'vlc é um player de vídeo'



