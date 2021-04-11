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
sys.path.insert(0, dir_of_executable)

# local libs
from langs import categories_buttons

__author__ = 'Bruno Chaves'
__version__ = '2021-04-10'
__repo__ = 'https://github.com/Brunopvh/storecli'


class MainGui(QMainWindow):
    switch_window = QtCore.pyqtSignal()

    def __init__(self, parent=None):
        super().__init__()
        self.setMinimumSize(300, 500)
        self.setWindowTitle('Storecli Qt Gui')

        self.container = QWidget()
        self.setCentralWidget(self.container)
        self.grid_window = QGridLayout(self)
        self.main_widgets = MainWidgets(self.container)

        self.setupUI()

    def setupUI(self):
        self.setupTopBar()
        self.grid_window.addWidget(self.main_widgets, 0, 0, Qt.AlignCenter)
        self.setLayout(self.grid_window)
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

class MainWidgets(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        # Definir Grids e Grupos para os botões/widgets
        self.grid_A = QGridLayout()
        self.grid_master = QGridLayout()
        self.group_A = QGroupBox('Categorias')
        self.group_A.setFixedWidth(200)
        self.group_master = QGroupBox('Exemplo')

        # Definir os botões de categorias
        self.btn_acessory = QPushButton(categories_buttons['acessory'], self)
        self.btn_development = QPushButton(categories_buttons['development'], self)

        # Adicionar os botões nos containers/grids
        self.grid_A.addWidget(self.btn_acessory)
        self.grid_A.addWidget(self.btn_development)
        self.group_A.setLayout(self.grid_A)

        # Adicionar grupos de containers/grids ao grid/container principal para exibir na janela
        self.grid_master.addWidget(self.group_A)
        self.setLayout(self.grid_master)

class WinAcessory(QWidget):
    def __init__(self, parent=None):
        pass

class WinDevelopment(QWidget):
    def __init__(self, parent=None):
        pass

class ControllerGui(object):

    def __init__(self):
        pass

    def show_login(self):
        self.login = Login()
        self.login.switch_window.connect(self.show_main)
        self.login.show()

    def show_main(self):
        self.window_gui = MainGui()
        self.window_gui.switch_window.connect(self.show_login)
        self.login.close()
        self.window.show()



if __name__ == '__main__':
    app = QApplication(sys.argv)
    wind = MainGui()
    wind.show()
    app.exec_()