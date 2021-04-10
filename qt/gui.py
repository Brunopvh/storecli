#!/usr/bin/env python3

import sys, os
from PyQt5.QtWidgets import (
	QWidget, QVBoxLayout, QHBoxLayout,
	QPushButton, QAction, qApp,
	QSpacerItem, QLabel, QComboBox,
	QSizePolicy, QMainWindow, QApplication,
	QGridLayout, QMessageBox, QFileDialog,
	QGroupBox, QLineEdit,
)

from PyQt5.QtCore import QMetaObject, Qt
from PyQt5.QtGui import QIcon, QPixmap
   
_script = os.path.abspath(os.path.realpath(__file__))
dir_of_executable = os.path.dirname(_script)                       

__author__ = 'Bruno Chaves'
__version__ = '2021-04-10'
__repo__ = 'https://github.com/Brunopvh/storecli'


class MainGui(QMainWindow):
    def __init__(self, parent=None):
        super().__init__()
        self.setMinimumSize(350, 500)
        self.grid_A = QGridLayout()
        self.group_A = QComboBox()

        self.btn_acessory = QPushButton("Acessorios", self)
        self.grid_A.addWidget(self.btn_acessory)
        self.group_A.setLayout(self.grid_A)

        self.setupTopBar()
        self.show()

    def setupTopBar(self):

        self.statusBar()
        menubar = self.menuBar()

        #==== Menu Arquivo ====#
        fileMenu = menubar.addMenu('&Arquivo')

        # 1 Definir ações/opções do menu arquivo.
        exitAct = QAction(QIcon('exit.png'), '&Sair', self)
        exitAct.setShortcut('Ctrl+Q')
        exitAct.setStatusTip('Fechar janela')
        exitAct.triggered.connect(self.exitApp)

        # 2 - Adicionar ações ao menu arquivo
        fileMenu.addAction(exitAct)

        #==== Menu Sobre ====#
        aboutMenu = menubar.addMenu('&Sobre')

        # Ações do menu sobre.
        versionMenu = aboutMenu.addMenu('Versão')
        authorMenu = aboutMenu.addMenu('Autor')
        siteMenu = aboutMenu.addMenu('Site')

        # Adicionar ações
        versionMenu.addAction(__version__)
        authorMenu.addAction(__author__)
        siteMenu.addAction(__repo__)

    def exitApp(self):
        qApp.quit()

class GuiAcessory(QWidget):
    def __init__(self, parent=None):
        pass

class GuiDevelopment(QWidget):
    def __init__(self, parent=None):
        pass




if __name__ == '__main__':
    app = QApplication(sys.argv)
    wind = MainGui()
    wind.show()
    app.exec_()