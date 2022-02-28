#!/usr/bin/env bash
#
#

# Utilitários de linha de comando para distribuições Linux.
requeriments_cli_linux=(curl git aria2 gawk unzip python3 zenity xterm)

# Python3 Fedora
requeriments_python3_fedora=(python3 python3-pip python3-setuptools)

# Python3 Opensuse Leap
requeriments_python3_opensuseleap=(python3 python3-pip python3-setuptools)

# Python3 ArchLinux.
requeriments_python3_archlinux=(python3 python-pip python-setuptools)

# Python3 FreeBSD
requeriments_python3_freebsd=(python3 python37 py37-pip py37-pip-tools)


#=============================================================#
# FreeBSD
#=============================================================#
_config_requeriments_freebsd()
{
	# Instalar ferramentas de linha de comando.
	_PKG install "${requeriments_cli_linux[@]}" || return 1
	msg "Instalando: ${requeriments_python3_freebsd[@]}"
	_PKG install "${requeriments_python3_freebsd[@]}" || return 1
	return 0
}


#=============================================================#
# Fedora
#=============================================================#
_config_requeriments_fedora()
{
	# Instalar ferramentas de linha de comando.
	_DNF install -y "${requeriments_cli_linux[@]}" || return 1
	_DNF install -y python3 python3-pip python3-setuptools || return 1
	return 0
}

#=============================================================#
# Opensuse Leap
#=============================================================#
_config_requeriments_opensuseleap()
{
	yellow "Executando: zypper ref"
	_ZYPPER ref
	_ZYPPER install "${requeriments_cli_linux[@]}" || return 1
	_ZYPPER "${requeriments_python3_opensuseleap[@]}" || return 1
	return 0
}

#=============================================================#
# Debian
#=============================================================#
check_debian_nonfree_repo()
{
	local OS_ID=$(grep '^ID=' /etc/os-release | sed 's/ID=//g')
	local VERSION_CODENAME=$(grep '^VERSION_CODENAME=' /etc/os-release | sed 's/VERSION_CODENAME=//g')

	[[ "$OS_ID" == 'debian' ]] || return 0
	[[ "$VERSION_CODENAME" != 'buster' ]] && {
		print_erro "(check_debian_nonfree_repo): seu sistema não é Debian Buster, adicione os repositórios main contrib non-free manualmente."
		return 1
	}

	# Verificar e adicionar repositório main no Debian.
	if find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${VERSION_CODENAME} main"; then
		print_info "Repositório main encontrado pulando"
	else
		printf "${CGreen}A${CReset}dicionando repositório main em ... /etc/apt/sources.list "
		echo "deb http://deb.debian.org/debian ${VERSION_CODENAME} main" | sudo tee -a /etc/apt/sources.list
	fi

	# Verificar e adicionar repositório contrib e non-free no debian.
	if find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${VERSION_CODENAME} main contrib non-free"; then
		echo "Repositório main contrib non-free encontrado pulando"
	elif find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${VERSION_CODENAME} main non-free contrib"; then
		echo "Repositório main non-free contrib encontrado pulando"
	elif find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${VERSION_CODENAME} contrib non-free"; then
		echo "Repositório contrib non-free encontrado"
	elif find /etc/apt -name *.list | xargs grep "^deb.*debian.org" | grep -q "debian ${VERSION_CODENAME} non-free contrib"; then
		echo "Repositório contrib non-free contrib encontrado"
	else
		echo -ne "Adicionando repositório contrib non-free em /etc/apt/sources.list "
		echo "deb http://deb.debian.org/debian ${VERSION_CODENAME} contrib non-free" | sudo tee -a /etc/apt/sources.list
	fi
}

_config_requeriments_debian()
{
	check_debian_nonfree_repo
	_APT update || return 1
	_APT install -y "${requeriments_cli_linux[@]}" || return 1
	_APT install -y aptitude gdebi dirmngr apt-transport-https gnupg gpgv2 gpgv xz-utils || return 1
	_APT install -y python3 python3-pip python3-setuptools || return 1
	return 0
}

_config_requeriments_archlinux()
{
	# Instalar dependências no archlinux
	for APP in "${requeriments_cli_linux[@]}"; do 
		system_pkgmanager "$APP" || {
			return 1
			break
		}
	done
	
	for APP in "${requeriments_python3_archlinux[@]}"; do
		system_pkgmanager "$APP" || {
			return 1
			break
		}
	done

	system_pkgmanager binutils || return 1
	return 0
	
	# system_pkgmanager 'xorg-xdpyinfo'
}


#=============================================================#
# Istalar dependências de acordo com cada sistema.
#=============================================================#
_install_requeriments()
{
	AssumeYes='True'
	yellow "Configurando dependências deste programa"
	if [[ "$OS_ID" == 'arch' ]]; then
		_config_requeriments_archlinux || { 
			print_erro '(_config_requeriments_archlinux)'
			return 1
		}
	elif [[ "$OS_ID" == 'debian' ]]; then
		_config_requeriments_debian || { 
			print_erro '(_config_requeriments_debian)'
			return 1
		}
	elif [[ "$OS_ID" == 'ubuntu' ]] || [[ "$OS_ID" == 'linuxmint' ]]; then
		_config_requeriments_debian || { 
			print_erro '(_config_requeriments_ubuntu)'
			return 1
		}
	elif [[ "$OS_ID" == 'fedora' ]]; then
		_config_requeriments_fedora || { 
			print_erro '(_config_requeriments_fedora)'
			return 1
		}
	elif [[ "$OS_ID" == 'opensuse-leap' ]] || [[ "$OS_ID" == 'opensuse-tumbleweed' ]]; then
		_config_requeriments_opensuseleap || { 
			print_erro '(_config_requeriments_opensuseleap)'
			return 1
		}
	elif [[ $(uname -s) == 'FreeBSD' ]]; then
		_config_requeriments_freebsd || { 
			print_erro '(_config_requeriments_freebsd)'
			return 1
		}
	else
		print_erro "Seu sistema não é suportado por este programa, use a opção --ignore-cli"
		return 1
	fi

	# Gravar informação de sucesso em $ConfigFile.
	if ! grep -q 'requeriments OK' "$ConfigFile"; then
		print_info "Gravando log em ... $ConfigFile"
		echo 'requeriments OK' >> "$ConfigFile"
	fi
	return 0
}

install_appcli()
{
	# https://github.com/Brunopvh/app-cli/tree/v0.1.3
	# Versão deste programa escrita em python

	local URL_REPO_APPCLI='https://github.com/Brunopvh/app-cli/archive/refs/heads/v0.1.3.tar.gz'
	local PATH_PKG_APPCLI="$DirDownloads/appcli-v0.1.3.tar.gz"

	download "$URL_REPO_APPCLI" "$PATH_PKG_APPCLI" || return 1
	unpack_archive "$PATH_PKG_APPCLI" $DirUnpack || return 1
	cd $DirUnpack
	mv $(ls -d app-*) app-cli
	cd app-cli
	python3 setup.py install --user

	python3 -m appcli -h 1> /dev/null 2> /dev/null || return 1
	return 0
}

check_requeriments_cli()
{
	# Verificar requerimentos minimos de sistema para que os programas possam ser 
	# instalados com sucesso. Esta função será executada sempre que o programa iniciar.
	LIST_REQUERIMENTS_UNIX=(awk zenity find curl python3)
	for R in "${LIST_REQUERIMENTS_UNIX[@]}"; do
		if [[ ! -x $(command -v $R)  ]]; then
			print_erro "(check_requeriments_cli) dependência não encontrada ... $R"
			sred "Execute ... $__script__ --configure"
			return 1
			break
		fi
	done
}
