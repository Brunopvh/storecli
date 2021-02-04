#!/usr/bin/env bash
#
#
#

# Utilitários de linha de comando para distribuições Linux.
requeriments_cli_linux=(
	wget curl aria2 gawk unzip python3 git zenity xterm 
)

# Python2 Ubuntu
requeriments_python2_ubuntu=(
'python' 'python-pip' 'python-setuptools'
)

# Python3 Fedora
requeriments_python3_fedora=(
	python3 python3-pip python3-setuptools
)

# Python3 Opensuse Leap
requeriments_python3_opensuseleap=(
'python3' 'python3-pip' 'python3-setuptools'
)

# Python3 FreeBSD
requeriments_python3_freebsd=(
'python3' 'python37' 'py37-pip' 'py37-pip-tools'
)

# Módulos python3
_config_python3()
{

	if is_executable 'pip3'; then
		_yellow "Executando: pip3 install wheel --user"
		pip3 install wheel --user && return 0 
	elif is_executable 'pip'; then
		_yellow "Executando: pip install wheel --user"
		pip install wheel --user && return 0 
	elif is_executable 'pip2'; then
		_yellow "Executando: pip2 install wheel --user"
		pip2 install wheel --user && return 0
	else
		_red "(_config_python3): Falha instale o pacote pip ou pip3"
		return 1
	fi
}

#=============================================================#

# FreeBSD
_config_requeriments_freebsd()
{
	# Instalar ferramentas de linha de comando.
	__pkg__ "${requeriments_cli_linux[@]}" || return 1

	# Instalar utilitários para python3.
	_msg "Instalando: ${requeriments_python3_freebsd[@]}"
	__pkg__ "${requeriments_python3_freebsd[@]}" || return 1
	return 0
}


#=============================================================#

# Fedora e derivados
_config_requeriments_fedora()
{
	# Instalar ferramentas de linha de comando.
	__pkg__ "${requeriments_cli_linux[@]}" || return 1
	__pkg__ python3 python3-pip python3-setuptools || return 1
	return 0
}

#=============================================================#
# Opensuse Leap
#=============================================================#
_config_requeriments_opensuseleap()
{
	_yellow "Executando: zypper ref"
	_ZYPPER ref
	__pkg__ "${requeriments_cli_linux[@]}" || return 1
	
	# Instalar utilitários para python3.
	__pkg__ "${requeriments_python3_opensuseleap[@]}" || return 1
		
	return 0
}

# Debian
check_debian_nonfree_repo()
{
	local os_id=$(grep '^ID=' /etc/os-release | sed 's/ID=//g')
	local os_codename=$(grep '^VERSION_CODENAME=' /etc/os-release | sed 's/VERSION_CODENAME=//g')

	[[ "$os_id" == 'debian' ]] || return
	[[ "$os_codename" != 'buster' ]] && {
		_red "(check_debian_nonfree_repo): seu sistema não é Debian Buster, adicione os repositórios main contrib non-free manualmente."
		return 1
	}

	# Verificar e adicionar repositório main no Debian.
	if find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${os_codename} main"; then
		printf "Repositório main encontrado pulando.\n"
	else
		printf "${CGreen}A${CReset}dicionando repositório main em ... /etc/apt/sources.list "
		echo "deb http://deb.debian.org/debian ${os_codename} main" | sudo tee -a /etc/apt/sources.list
	fi

	# Verificar e adicionar repositório contrib e non-free no debian.
	if find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${os_codename} main contrib non-free"; then
		echo "Repositório main contrib non-free encontrado pulando"
	elif find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${os_codename} main non-free contrib"; then
		echo "Repositório main non-free contrib encontrado pulando"
	elif find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${os_codename} contrib non-free"; then
		echo "Repositório contrib non-free encontrado"
	elif find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${os_codename} non-free contrib"; then
		echo "Repositório contrib non-free contrib encontrado"
	else
		echo -ne "Adicionando repositório contrib non-free em /etc/apt/sources.list "
		echo "deb http://deb.debian.org/debian ${os_codename} contrib non-free" | sudo tee -a /etc/apt/sources.list
	fi
}

_config_requeriments_debian()
{
	check_debian_nonfree_repo
	_APT update || return 1
	__pkg__ "${requeriments_cli_linux[@]}" || return 1
	__pkg__ aptitude gdebi dirmngr apt-transport-https gnupg gpgv2 gpgv xz-utils || return 1
	__pkg__ python3 python3-pip python3-setuptools || return 1
	return 0
}

_config_requeriments_archlinux()
{
	local requeriments_python3_archlinux=(python3 python-pip python-setuptools)
	
	for APP in "${requeriments_cli_linux[@]}"; do 
		__pkg__ "$APP" || {
			return 1
			break
		}
	done
	
	for APP in "${requeriments_python3_archlinux[@]}"; do
		__pkg__ "$APP" || {
			return 1
			break
		}
	done

	__pkg__ binutils || return 1
	return 0
	
	# __pkg__ 'xorg-xdpyinfo'
}


#=============================================================#
# Istalar dependências de acordo com cada sistema.
#=============================================================#
_install_requeriments()
{
	AssumeYes='True'
	_yellow "Configurando dependências deste programa"
	if [[ "$os_id" == 'arch' ]]; then
		_config_requeriments_archlinux || { 
			_red 'Falha: (_config_requeriments_archlinux)'
			return 1
		}
	elif [[ "$os_id" == 'debian' ]]; then
		_config_requeriments_debian || { 
			_red 'Falha: (_config_requeriments_debian)'
			return 1
		}
	elif [[ "$os_id" == 'ubuntu' ]] || [[ "$os_id" == 'linuxmint' ]]; then
		_config_requeriments_debian || { 
			_red 'Falha: (_config_requeriments_ubuntu)'
			return 1
		}
	elif [[ "$os_id" == 'fedora' ]]; then
		_config_requeriments_fedora || { 
			_red 'Falha: (_config_requeriments_fedora)'
			return 1
		}
	elif [[ "$os_id" == 'opensuse-leap' ]] || [[ "$os_id" == 'opensuse-tumbleweed' ]]; then
		_config_requeriments_opensuseleap || { 
			_red 'Falha: (_config_requeriments_opensuseleap)'
			return 1
		}
	elif [[ $(uname -s) == 'FreeBSD' ]]; then
		_config_requeriments_freebsd || { 
			_red 'Falha: (_config_requeriments_freebsd)'
			return 1
		}
	else
		_red "Seu sistema não é suportado por este programa, use a opção --ignore-cli"
		return 1
	fi

	_config_python3 || return 1
	if ! grep -q 'requeriments OK' "$configFILE"; then
		_yellow "Gravando log em ($configFILE)"
		echo 'requeriments OK' >> "$configFILE"
	fi
	return 0
}

check_requeriments_cli()
{
	# Verificar requerimentos minimos de sistema para que os programas possam ser 
	# instalados com sucesso. Esta função será executada sempre que o programa iniciar.
	LIST_REQUERIMENTS_UNIX=(sudo wget awk zenity find curl python3)
	for R in "${LIST_REQUERIMENTS_UNIX[@]}"; do
		if ! is_executable "$R"; then
			_red "Dependência não encontrada ... $R"
			_sred "Execute ... $__script__ --configure"
			return 1
			break
		fi
	done
}
