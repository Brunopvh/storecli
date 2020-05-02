#!/usr/bin/env bash
#
#

source "$Lib_Arrays"
source "$Lib_Platform"
#source "$Lib_PkgManSystem"


# Utilitários de linha de comando para distribuições Linux.
array_cli_linux=(
'curl' 'wget' 'git' 'gawk' 'unzip' 'python3' 'python2' 'xterm' 'zenity'
)

array_cli_ubuntu=(
'curl' 'wget' 'git' 'gawk' 'unzip' 'python3' 'python' 'xterm' 'zenity'
)

# Utilitários de linha de comando para sistemas baseados em debian.
array_cli_debian=(
'aptitude' 'gdebi' 'dirmngr' 'apt-transport-https' 'gnupg' 'gpgv2' 'gpgv' 'xz-utils'
)

# FreeBSD
array_cli_freebsd=(
'git' 'curl' 'wget' 'xterm' 'gawk' 'unzip'
)

#=============================================================#
# Utilitários para python2/python3
# alguns pacotes são equivalentes porem com nomes diferentes de 
# acordo com cada distribuição, por exemplo: no Fedora31 o executável
# 'python' e para a versão 3.7.x do python, já no debian o python3.7
# equivale ao executável python3, uma vez que python no debian é
# referente ao python2.7.
#    Por isso a necessidade de separar corretamente os nomes dos
# pacotes em cada "array". As vezes podemos aproveitar o mesmo
# nome de pacote para várias distros como por exemplo 'curl', 'wget',
# 'git' entre outros. 
#=============================================================#

# Python2 Ubuntu
array_python2_ubuntu=(
'python' 'python-pip' 'python-setuptools'
)

# Python2 debian
array_python2_debian=( 
'python2' 'python-pip' 'python-setuptools'
)

# Python3 debian
array_python3_debian=( 
'python3' 'python3-pip' 'python3-setuptools'
)

# Python2 FreeBSD
array_python_freebsd=(
'py27-pip-19.1.1' 'py27-pip-tools-4.1.0'
)

# Python3 FreeBSD
array_python3_freebsd=(
'python3' 'python37' 'py37-pip' 'py37-pip-tools'
)



#=============================================================#
# Módulos python3
_config_python()
{
	echo -e "$space_line"
	msg "Instalando módulos python3"
	echo -e "$space_line"
	if _WHICH 'pip3'; then
		pip3 install wheel --user || return 1 
		pip3 install wget --user || return 1
	elif _WHICH 'pip'; then
		pip install whell --user || return 1
		pip install wget --user || return 1
	else
		red "Instale o pacote 'pip'"
	fi
	return 0 
}

#=============================================================#

# Fedora e derivados
_config_freebsd_requeriments()
{
	echo -e "$space_line"
	msg "Executando [_config_freebsd_requeriments]"
	echo -e "$space_line"

	# Instalar ferramentas de linha de comando.
	for c in "${array_cli_freebsd[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done
	

	# Instalar utilitários para python2.
	for c in "${array_python_freebsd[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done


	# Instalar utilitários para python3.
	for c in "${array_python3_freebsd[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done
	return 0
}


#=============================================================#

# Fedora e derivados
_config_fedora_requeriments()
{
	echo -e "$space_line"
	msg "Executando [_config_fedora_requeriments]"
	echo -e "$space_line"

	# Instalar ferramentas de linha de comando.
	for c in "${array_cli_linux[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done
	

	# Instalar utilitários para python2.
	for c in "${array_python2_debian[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done


	# Instalar utilitários para python3.
	for c in "${array_python3_debian[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done
	return 0
}

#=============================================================#

# Ubuntu
_config_ubuntu_requeriments()
{
	sudo apt update
	echo -e "$space_line"
	yellow "Executando [_config_ubuntu_requeriments]"
	echo -e "$space_line"

	# Instalar ferramentas de linha de comando para Ubuntu e derivados.
	for c in "${array_cli_ubuntu[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done

	# Instalar utilitários para sistemas Debian.
	for c in "${array_cli_debian[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done

	# Instalar utilitários para python2.
	for c in "${array_python2_ubuntu[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done

	# Instalar utilitários para python3.
	for c in "${array_python3_debian[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done
	return 0
}

# Debian
_config_debian_requeriments()
{
	sudo apt update
	echo -e "$space_line"
	yellow "Executando [_config_debian_requeriments]"
	echo -e "$space_line"

	# Instalar ferramentas de linha de comando.
	for c in "${array_cli_linux[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done


	# Instalar utilitários para sistemas Debian.
	for c in "${array_cli_debian[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done

	# Instalar utilitários para python2.
	for c in "${array_python2_debian[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done


	# Instalar utilitários para python3.
	for c in "${array_python3_debian[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			return 1
			break
		fi
	done
	return 0
}

#=============================================================#

# ArchLinux
_config_archlinux_requeriments()
{
	msg "Instalando: ${array_cli_linux[@]}"
	_package_man_distro "${array_cli_linux[@]}" || return 1

	msg "Instalando: python3 python-pip python-setuptools"
	_package_man_distro python3 python-pip python-setuptools

	# Suporte ao NTFS - sudo pacman -S ntfs-3g 
	#_package_man_distro 'ntfs-3g'
	#sudo modprobe fuse
	
	msg "Instalando: binutils"
	_package_man_distro binutils

	# Base-Devel
	# msg "Instalando: base-devel"
	#_package_man_distro 'base-devel'

	# xdpinfo
	# sudo pacman -S xorg-xdpyinfo
}

#=============================================================#

# Usar as funções acima para instalar as dependências de acordo
# com cada sistema.
_config_system_requeriments()
{
	# Executar configuração de acordo com cada sistema.
	if [[ "$os_id" == 'debian' ]]; then
		_config_debian_requeriments || return 1
	elif [[ "$os_id" == 'ubuntu' ]] || [[ "$os_id" == 'linuxmint' ]]; then
		_config_ubuntu_requeriments || return 1
	elif [[ "$os_id" == 'fedora' ]]; then
		_config_fedora_requeriments || return 1
	elif [[ "$os_id" == 'arch' ]]; then
		_config_archlinux_requeriments || return 1
	elif [[ "$os_id" == '12.1-RELEASE' ]]; then
		_config_freebsd_requeriments || return 1
	else
		red "Seu sistema não é suportado [$os_id]"
		return 1
	fi

	# Depois de instalar as ferramentas de linha de comando. Prosseguir com
	# a instalação do python2 e python3 incluindo o módulo 'wget' para python3.
	if _config_python; then
		yellow "Função [_config_python] foi executada com sucesso"
		return 0
	else
		red "Função [_config_python] retornou erro"
		return 1
	fi	
}


configure_all()
{
	# Instalar os requerimentos atraves da função "_config_system_requeriments"
	# que gerencia as demais funções, se a instalação dos pacotes for executada
	# com sucesso, será gravado as seguintes informações no arquivo de configuração
	# (Config_File) "requeriments OK". Isso significa que o programa não irá mais 
	# verificar as dependências ao iniciar.

	export install_yes='True'
	
	while ! _config_system_requeriments; do
		if _YESNO "Deseja repetir"; then # Usar a função _YESNO - que irá retornar 1 ou 0.
			# Usuário digitou 's'
			continue
		else
			# Usuário digitou qualquer valor diferente de 's' ou deixou o tempo
			# limite esgotar sem responder nada - ENCERRAR COM ERRO.
			red "Encerrando com erro"
			return 1
			break
		fi
	done

	# Função _config_system_requeriments foi executada com sucesso prosseguir.
	if ! grep -q 'requeriments OK' "$Config_File"; then
		msg "Gravando log em [$Config_File]"
		echo 'requeriments OK' >> "$Config_File"
	fi
	return 0
}


_check_cli_utils()
{
	for c in "${array_cli_linux[@]}"; do
		if ! _WHICH "$c"; then
			red "Falha $space_line [$c]"
			return 1
			break
		fi
	done
	return 0
}
