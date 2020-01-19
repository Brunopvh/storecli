#!/bin/sh
#
# Modificado em: 2020-01-18
# Autor: Bruno Chaves
#
# Instalador do pacote storecli.
# Requerimentos: git e o shell bash.
# use ./install.sh
#

#--------------------------------------------------#

esp='-----------------------------------------'
dir_temp="/tmp/Update_StoreCli_$USER"
dir_bin="$HOME/.local/bin"
github='https://github.com'
repo="$github/Brunopvh/storecli.git"

#--------------------------------------------------#

_c()
{
	[ -z $2 ] && { printf "\033[1;$1m\n"; return 0; }
	printf "\033[$2;$1m\n"
}

#--------------------------------------------------#

_msg()
{
	echo "=> $@"
}

#--------------------------------------------------#
# Verificar utilitários via linha de comando.
_cli()
{
	if [ -x "$(command -v $1 2>/dev/null)" ]; then
		return 0
	else 
		return 1
	fi
}

#--------------------------------------------------#
# Verificar requisitos minimos de sistema para instalar o pacote 'storecli'
_check()
{
	_cli git || {
		_msg "$(_c 31)Falha ............... instale o pacote [git]$(_c)"
		return 1
	}

	_cli bash || {
		_msg "$(_c 31)Falha ............... instale o shell $(_c 32 2)[bash]$(_c)"
		return 1
	}

	mkdir -p "$dir_bin" "$dir_temp"

}

#--------------------------------------------------#
# Clonar o repositório do pacote storecli.
_GitClone()
{
	cd "$dir_temp" && rm -rf *
	_msg "Clonando: $repo"
	_msg "Destino: $(pwd)"

	if git clone "$repo"; then 
		return 0
	else
		_msg "$(_c 31)Falha ao tentar clonar o repositório [$repo] $(_c)"
		return 1
	fi
}

#--------------------------------------------------#

_remove()
{
	if [ -d "$HOME/.local/bin/storecli-amd64" ]; then
		_msg "$(_c 31)Desinstalando: $HOME/.local/bin/storecli-amd64 $(_c)"
		rm -Rf "$HOME/.local/bin/storecli-amd64" 1> /dev/null 2>&1
		rm -Rf "$HOME/.local/bin/storecli" 1> /dev/null 2>&1
	fi
}

#--------------------------------------------------#

_Install()
{
	_GitClone || return 1
	_remove

	_msg "$(_c 32 2)Instalando: $HOME/.local/bin/storecli-amd64 $(_c)"
	mv "$(ls -d $dir_temp/storecli)" "$dir_bin/storecli-amd64"
	ln -sf "$HOME/.local/bin/storecli-amd64/storecli.sh" "$HOME/.local/bin/storecli"

	if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
		PATH="$HOME/.local/bin:$PATH"
	fi

	if _cli storecli; then
		storecli --logo
		_msg "$(storecli --version)"
		_msg "Use: $(_c 32 2)storecli --help $(_c)"
		return 0
	else
		_msg "$(_c 31)Falha ao tentar instalar [storecli]. $(_c)"
		return 1
	fi
}

#--------------------------------------------------#

_path_bash()
{
	if grep -q "^export.*$HOME/.local/bin.*" ~/.bashrc; then 
		_msg "[~/.bashrc] já configurado."
		return 0
	fi


	_msg "Configurando [PATH] no arquivo .......... ~/.bashrc"
	echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
	bash ". ~/.bashrc"

}

_path_zsh()
{
	_cli zsh || return 0

	if grep -q "^export.*$HOME/.local/bin.*" ~/.zshrc; then 
		_msg "[~/.zshrc] já configurado."
		return 0
	fi

	_msg "Configurando [PATH] no arquivo .......... ~/.zshrc"
	echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
	zsh ". ~/.zshrc"

}

#--------------------------------------------------#

_Config_Path()
{
	if echo "$PATH" | grep -q "$HOME/.local/bin"; then return 0; fi

	_path_bash # Configurar ~/.bashrc se for necessário.
	_path_zsh # Configurar ~/.zshrc se for necessário.
}

#--------------------------------------------------#
_Run()
{
	[ $(id -u) -eq 0 ] && { _msg "$(_c 31)Usuário não pode ser o [root] saindo... $(_c)"; return 1; }
	_check || exit 1
	_Install || exit 1

	_Config_Path

	if ! echo "$PATH" | grep "$HOME/.local/bin" 1> /dev/null; then
		_msg "Reinicie seu shell para aplicar as alterações na variável PATH"
		read -p "Pressione enter para sair: " enter
	fi
}

_Run || exit 1

