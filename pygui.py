#!/usr/bin/env python3

"""


Este será um GUI gráfico para o script storecli.

INSTALAÇÃO
sudo sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"

 USO
storecli --help
storecli --configure
storecli -> Abre com o GUI zenity


"""


import os
import sys
from tkinter import *

__version__ = '2020-06-16'

# Endereço deste script no disco.
dir_root = os.path.dirname(os.path.realpath(__file__)) 

 # Diretório onde o terminal está aberto.
dir_run = os.getcwd()                                 

# Inserir o diretório atual no path do python 
# print(sys.path)                          
sys.path.insert(0, dir_root)

from libpy.acessory import WinAcessory
from libpy.development import WinDevelopment
from libpy.office import WinOffice
from libpy.internet import WinInternet							

class WinHome: 

	def __init__(self, master): 
		self.master = master
		self.frame = Frame(self.master)
		self.frame.pack()

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


		self.msg_opcao = Button(self.Container1)
		self.msg_opcao["text"]= "Clique em uma\ncatgória"
		self.msg_opcao["width"] = 25
		self.msg_opcao["background"] = "green"
		self.msg_opcao["font"] = ("Calibri", "12")
		self.msg_opcao.pack()

		
		self.botao_sair = Button(self.Container1)
		self.botao_sair["command"] = self.Container1.quit
		self.botao_sair['text'] = 'Sair'
		self.botao_sair.configure(
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.botao_sair.pack()

		self.buttonAcessoty = Button(self.Container2)
		self.buttonAcessoty.configure(
							text="Acessórios",
							command=self.wind_acessory, 
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.buttonAcessoty.pack()

		self.buttonDevelopment = Button(self.Container3)
		self.buttonDevelopment.configure(
								text="Desenvolvimento", 
								command=self.wind_development,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.buttonDevelopment.pack()

		self.buttonOffice = Button(self.Container4)
		self.buttonOffice.configure(
								text="Escritório", 
								command=self.wind_office,
								background=self.backgroundPadrao, 
								font=self.fontPadrao, 
								width=self.widthPadrao,
								height=self.heightPadrao,
								)
		self.buttonOffice.pack()

		self.buttonInternet = Button(self.Container5)
		self.buttonInternet.configure(
							text="Internet", 							
							command=self.wind_internet,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.buttonInternet.pack()

		self.buttonMidia = Button(self.Container6)
		self.buttonMidia.configure(
							text="Midia", 							
							command=self.wind_midia,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.buttonMidia.pack()

		self.buttonSystem = Button(self.Container7)
		self.buttonSystem.configure(
							text="Sistema", 							
							command=self.wind_system,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.buttonSystem.pack()

		self.buttonPreference = Button(self.Container8)
		self.buttonPreference.configure(
							text="preferencias", 							
							command=self.wind_prefence,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.buttonPreference.pack()

		self.buttonGshell = Button(self.Container9)
		self.buttonGshell.configure(
							text="Gnome Shell", 							
							command=self.wind_gnomeshell,
							background=self.backgroundPadrao, 
							font=self.fontPadrao, 
							width=self.widthPadrao,
							height=self.heightPadrao,
							)
		self.buttonGshell.pack()

	#--------------------[ AÇÃO DOS BOTÕES ]----------------------#
	
	def wind_acessory(self):
		self.newWindow = Toplevel(self.master)
		self.newWindow.title('Acessórios')
		self.app = WinAcessory(self.newWindow)

	def wind_development(self):
		self.newWindow = Toplevel(self.master)
		self.newWindow.title('Desenvolvimento')
		self.app = WinDevelopment(self.newWindow)

	def wind_office(self):
		self.newWindow = Toplevel(self.master)
		self.newWindow.title('Escritório')
		self.app = WinOffice(self.newWindow)

	def wind_internet(self):
		self.newWindow = Toplevel(self.master)
		self.newWindow.title('Internet')
		self.app = WinInternet(self.newWindow)

	def wind_midia(self):
		print('Clicou em midia')

	def wind_system(self):
		print('Clicou em sistema')

	def wind_prefence(self):
		print('Clicou em preferencias')

	def wind_gnomeshell(self):
		print('Clicou em gnome shell')



root = Tk()
app = WinHome(root) 
root.title('Menu Principal')
root.geometry("290x440")
root.mainloop() 