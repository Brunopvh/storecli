#!/usr/bin/env bash
#
#

_c()
{
	[[ -z $2 ]] || echo -e "\033[$2;$1m"
	[[ ! -z $2 ]] || echo -e "\033[1;$1m"
}

_usage()
{
cat <<EOF
  Use: 
     sudo $(basename $0)     Para instalar no sistema em /opt.
     $(basename $0)          Para instalar na HOME em ~/.local/bin.
     $(basename $0)           Exibe ajuda.
EOF
}

if [[ "$1" == '--help' ]]; then _usage; exit; fi

[[ ! -x $(command -v bash 2> /dev/null) ]] && { _c 31; echo ">> Instale o shell [bash]"; _c; exit 1; }

G='https://github.com'
R="$G/Brunopvh/storecli.git"
[[ -d "/tmp/up_$USER" ]] && { cd /tmp && rm -rf "up_$USER"; }

_gitclone()
{
mkdir -p "/tmp/up_$USER"; cd "/tmp/up_$USER"

	if git clone "$R"; then
		return 0
	else
		return 1
	fi
}

# ~/.bashrc
_conf_path_bash()
{
if ! grep "^export PATH.*$HOME/.local/bin.*" ~/.bashrc 1> /dev/null; then
	echo "$(_c 32)==> Adicionando: ~/.local/bin em PATH [~/.bashrc] $(_c)"
	echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc

else
	echo "$(_c 32 0)$PATH$(_c)"

fi
}

# ~/.zshrc
_conf_path_zsh()
{
	[[ -x $(command -v zsh 2> /dev/null) ]] || return 0

	if ! grep "^export PATH.*$HOME/.local/bin.*" ~/.zshrc 1> /dev/null; then
		echo "$(_c 32)==> Adicionando: ~/.local/bin em PATH [~/.zshrc] $(_c)"
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
	else
		echo "$(_c 32 0)$PATH$(_c)"
	fi
}

_root_install()
{
	[[ -d '/opt/storecli-amd64' ]] && rm -rf '/opt/storecli-amd64'
	mv "/tmp/up_$USER/storecli" '/opt/storecli-amd64'
	rm -rf "/tmp/up_$USER/storecli" 2> /dev/null
	chomd -R a+x '/opt/storecli-amd64'
	ln -sf '/opt/storecli-amd64/storecli.sh' '/usr/local/bin/storecli'
	return "$?"
}

_user_install()
{
	[[ -d ~/'.local/bin/storecli-amd64' ]] && rm -rf ~/'.local/bin/storecli-amd64'
	mkdir -p ~/'.local/bin'
	mv "/tmp/up_$USER/storecli" ~/'.local/bin/storecli-amd64'
	rm -rf "/tmp/up_$USER/storecli" 2> /dev/null
	chmod -R a+x ~/'.local/bin/storecli-amd64'
	ln -sf ~/'.local/bin/storecli-amd64/storecli.sh' ~/'.local/bin/storecli'
}

#------------------------------------#
# Install
#------------------------------------#
_gitclone "$R" || { echo "$(_c 31)>> Erro [_gitclone] $(_c)"; exit 0; }

echo "$(_c 32 0)>> Instalando $(_c)"

if [[ $(id -u) == '0' ]]; then
	_root_install
else
	_user_install; _conf_path_bash; _conf_path_zsh
fi

exit
