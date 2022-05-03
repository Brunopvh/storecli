#!/usr/bin/env bash
#
#
		
export DIR_BIN=~/.local/bin
export DIR_LIB=~/.local/lib
export DIR_SHARE=~/.local/share
export DIR_THEMES=~/.themes
export DIR_OPTIONAL=~/.local/opt
export DIR_DESKTOP_ENTRY=~/.local/share/applications
export DIR_ICONS=~/.local/share/icons
export DIR_HICOLOR=~/.local/share/icons/hicolor


function createUserDirs(){

	# Criar os diretório na HOME do usuário.
	mkdir -p $DIR_BIN
	mkdir -p $DIR_LIB
	mkdir -p $DIR_SHARE
	mkdir -p $DIR_THEMES
	mkdir -p $DIR_OPTIONAL
	mkdir -p $DIR_DESKTOP_ENTRY
	mkdir -p $DIR_ICONS
	mkdir -p $DIR_HICOLOR	
}




