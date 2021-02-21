#!/usr/bin/env bash
#

_println()
{
	# Imprimir mensagens sem quebrar linhas.
	echo -ne " + $@"
}

_print()
{
	echo -e " + $@"
}


system_pkgmanager()
{
	# Função para instalar os pacotes via linha de comando de acordo 
	# o gerenciador de pacotes de cada sistema.

	#=============================================================#
	# Somente baixar os pacotes caso receber '-d' ou '--downloadonly'
	# na linha de comando.
	#=============================================================#
	
	if [[ "$DownloadOnly" == 'True' ]] && [[ "$AssumeYes" == 'True' ]]; then 
		# Somente baixar os pacotes e assumir yes para indagações.
		if [[ $(uname -s) == 'FreeBSD' ]]; then 
			_PKG install -y "$@" || return 1
		elif [[ -f /etc/debian_version ]] && [[ -x $(which apt 2> /dev/null) ]]; then
			_APT install --download-only --yes "$@" || return 1
		elif [[ -f /etc/fedora-release ]] && [[ -x $(which dnf 2> /dev/null) ]]; then
			_DNF install --downloadonly -y "$@" || return 1
		elif [[ "$OS_ID" == 'opensuse-leap' ]] || [[ "$OS_ID" == 'opensuse-tumbleweed' ]]; then
			_ZYPPER download "$@" || return 1
		elif [[ "$OS_ID" == 'arch' ]]; then
			_PACMAN -S --noconfirm --needed --downloadonly "$@" || return 1
		else
			red "(system_pkgmanager) Erro: $@"
			return 1
		fi
		return "$?"
	
	elif [[ "$DownloadOnly" == 'True' ]]; then
		# Somente baixar os pacotes.
		if [[ $(uname -s) == 'FreeBSD' ]]; then 
			_PKG install "$@"
			return 
		fi
		
		case "$OS_ID" in
			debian|ubuntu|linuxmint) _APT install --download-only "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER download "$@" || return 1;;
			fedora) _DNF install --downloadonly "$@" || return 1;;
			arch) _PACMAN -S --needed --downloadonly "$@" || return 1;;
		esac
	elif [[ "$AssumeYes" == 'True' ]]; then 
		# Assumir yes para indagações durante a instalação, equivalênte ao comando
		# apt install -y / aptitude install -y em sistemas debian.
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install -y "$@"; return; fi
		case "$OS_ID" in
			debian|ubuntu|linuxmint) _APT install --yes "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install -y "$@" || return 1;;
			fedora) _DNF install -y "$@" || return 1;;
			arch) _PACMAN -S --noconfirm --needed "$@" || return 1;;
		esac
	else
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install "$@"; return; fi
		case "$OS_ID" in
			debian|ubuntu|linuxmint) _APT install "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install "$@" || return 1;;
			fedora) _DNF install "$@" || return 1;;
			arch) _PACMAN -S --needed "$@" || return 1;;
		esac
	fi
}

_clear_temp_dirs()
{
	# Limpar diretórios temporários.
	cd "$DirTemp" && __rmdir__ $(ls)
	cd "$DirUnpack" && __rmdir__ $(ls)
	cd "$DirGitclone" && __rmdir__ $(ls)
}

__shasum__()
{
	# Esta função compara a hash de um arquivo local no disco com
	# uma hash informada no parametro "$2" (hash original). 
	#   Ou seja "$1" é o arquivo local e "$2" é uma hash
	local hash_file=''
	if [[ ! -f "$1" ]]; then
		red "(__shasum__) arquivo inválido: $1"
		return 1
	fi

	if [[ -z "$2" ]]; then
		red "(__shasum__) use: __shasum__ <arquivo> <hash>"
		return 1
	fi

	# Calucular o tamanho do arquivo
	len_file=$(du -hs $1 | awk '{print $1}')

	printf "Gerando hash do arquivo ... $1 $len_file\n"
	hash_file=$(sha256sum "$1" | cut -d ' ' -f 1)
	printf "%-15s%65s\n" "HASH original" "$2"
	printf "%-15s%65s\n" "HASH local" "$hash_file"
	printf "Comparando valores "
	if [[ "$hash_file" == "$2" ]]; then
		syellow 'OK'
		return 0
	else
		sred 'FALHA'
		red "(__shasum__): removendo arquivo inseguro ... $1"
		rm -rf "$1"
		return 1
	fi
}
