#!/usr/bin/env python3
#

from os import system
from tkinter import *

class WinDevelopment: 

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

		self.android_studio = Button(self.Container2)
		self.android_studio.configure(
							text="android-studio",
							command=self.install_android_studio, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.android_studio.pack(side=LEFT)

		self.info_android_studio = Button(self.Container2)
		self.info_android_studio.configure(
							text='info',
							command=self.show_info_android_studio, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_android_studio.pack(side=RIGHT)

		self.codeblocks = Button(self.Container3)
		self.codeblocks.configure(
								text='codeblocks', 
								command=self.install_codeblocks,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.codeblocks.pack(side=LEFT)

		self.info_codeblocks = Button(self.Container3)
		self.info_codeblocks.configure(
							text='info',
							command=self.show_info_codeblocks, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_codeblocks.pack(side=RIGHT)


		self.pycharm = Button(self.Container4)
		self.pycharm.configure(
								text="pycharm", 
								command=self.install_pycharm,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.pycharm.pack(side=LEFT)

		self.info_pycharm = Button(self.Container4)
		self.info_pycharm.configure(
							text='info',
							command=self.show_info_pycharm, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_pycharm.pack(side=RIGHT)

		self.sublime_text = Button(self.Container5)
		self.sublime_text.configure(
							text="sublime-text", 							
							command=self.install_sublime_text,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.sublime_text.pack(side=LEFT)

		self.info_sublime_text = Button(self.Container5)
		self.info_sublime_text.configure(
							text='info',
							command=self.show_info_sublime_text, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_sublime_text.pack(side=RIGHT)


		self.vim = Button(self.Container6)
		self.vim.configure(
							text='vim', 							
							command=self.install_vim,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.vim.pack(side=LEFT)

		self.info_vim = Button(self.Container6)
		self.info_vim.configure(
							text='info',
							command=self.show_info_vim, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_vim.pack(side=RIGHT)


		self.vscode = Button(self.Container7)
		self.vscode.configure(
							text="vscode", 							
							command=self.install_vscode,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.vscode.pack(side=LEFT)

		self.info_vscode = Button(self.Container7)
		self.info_vscode.configure(
							text='info',
							command=self.show_info_vscode, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=5,
							height=self.heightPadrao,
							)
		self.info_vscode.pack(side=RIGHT)


	def close_windows(self):
		self.master.destroy()
	
	def install_android_studio(self):
		system('storecli install --yes android_studio')

	def show_info_android_studio(self):
		self.msg_show_info['text'] = 'android_studio'

	def install_codeblocks(self):
		system('storecli install --yes codeblocks')

	def show_info_codeblocks(self):
		self.msg_show_info['text'] = 'codeblocks'

	def install_pycharm(self):
		system('storecli install --yes pycharm')

	def show_info_pycharm(self):
		self.msg_show_info['text'] = 'pycharm'

	def install_sublime_text(self):
		system('storecli install --yes sublime-text')

	def show_info_sublime_text(self):
		self.msg_show_info['text'] = 'Editor de texto'

	def install_vim(self):
		system('storecli install --yes vim')

	def show_info_vim(self):
		self.msg_show_info['text'] = 'Vim e um editor de texto'

	def install_vscode(self):
		system('storecli install --yes vscode')

	def show_info_vscode(self):
		self.msg_show_info['text'] = 'Visual Studio Code\ne um editor de texto\nmultiplataforma da microsoft'


