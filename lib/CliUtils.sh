#!/usr/bin/env bash
#
# Este módulo e usado para instalar as dependências deste programa
# storecli --configure
#

source "$Lib_Arrays"
source "$Lib_Platform"
#source "$Lib_PkgManSystem"


# Utilitários de linha de comando para distribuições Linux.
array_cli_linux=(
'curl' 'wget' 'git' 'gawk' 'unzip' 'python3' 'python2' 'xterm' 'zenity' 
)

array_cli_ubuntu=(
'curl' 'wget' 'git' 'gawk' 'unzip' 'python3' 'python' 'xterm' 
)

# Utilitários de linha de comando para sistemas baseados em debian.
array_cli_debian=(
'aptitude' 'gdebi' 'dirmngr' 'apt-transport-https' 'gnupg' 'gpgv2' 'gpgv' 'xz-utils'
)

# FreeBSD
array_cli_freebsd=(
'curl' 'wget' 'git' 'gawk' 'xterm' 'unzip' 'zenity'
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
'python3' 'python3-pip' 'python3-setuptools' 'python3-tk'
)

# Python3 Fedora
array_python3_fedora=(
'python3' 'python3-pip' 'python3-setuptools' 'python3-tkinter.x86_64'
)

# Python3 Opensuse Leap
array_python3_opensuseleap=(
'python3' 'python3-pip' 'python3-setuptools' 'python3-tk'
)

# Python2 FreeBSD
array_python_freebsd=(
'python27' 'py27-pip-19.1.1' 'py27-pip-tools-4.1.0'
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
	yellow "Executando: [_config_python]"
	echo -e "$space_line"
	if _WHICH 'pip3'; then
		pip3 install wheel --user
		pip3 install wget --user 
	elif _WHICH 'pip'; then
		pip install whell --user 
		pip install wget --user 
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
	white "Executando [_config_freebsd_requeriments]"
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
			#return 1
			break
		fi
	done


	# Instalar utilitários para python3.
	for c in "${array_python3_freebsd[@]}"; do
		yellow "Instalando: $c"
		if ! _package_man_distro "$c"; then
			red "Falha: $c"
			#return 1
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
	white "Executando [_config_fedora_requeriments]"
	echo -e "$space_line"

	# Instalar ferramentas de linha de comando.
	yellow "Instalando: ${array_cli_linux[@]}"
	if ! _package_man_distro "${array_cli_linux[@]}"; then
		red "Falha: ${array_cli_linux[@]}"
		return 1
	fi
	
	# Instalar utilitários para python2.
	yellow "Instalando: ${array_python2_debian[@]}" 
	if ! _package_man_distro "${array_python2_debian[@]}"; then
		red "Falha: ${array_python2_debian[@]}"
		return 1
	fi
	
	# Instalar utilitários para python3 no fedora.
	yellow "Instalando: ${array_python3_fedora[@]}"
	
	if ! _package_man_distro "${array_python3_fedora[@]}"; then
		red "Falha: ${array_python3_fedora[@]}"
		return 1
	fi
	return 0
}

#=============================================================#
# Opensuse Leap
#=============================================================#
_config_opensuseleap_requeriments()
{
	echo "$space_line"
	yellow "Executando: _config_opensuseleap_requeriments"
	echo "$space_line"

	sudo zypper ref

	# Instalar ferramentas de linha de comando.
	yellow "Instalando: ${array_cli_linux[@]}"
	if ! _package_man_distro "${array_cli_linux[@]}"; then
		red "Falha: ${array_cli_linux[@]}"
		red "Instale os pacotes acima manualmente, ou tente novamente com o comando: ${CYellow}$Script_root --configure${CReset}"
		return 1	
	fi

	# Instalar utilitários para python2.
	yellow "Instalando: ${array_python2_debian[@]}" 
	if ! _package_man_distro "${array_python2_debian[@]}"; then
		red "Falha: ${array_python2_debian[@]}"
		return 1
	fi
	
	# Instalar utilitários para python3 no fedora.
	yellow "Instalando: ${array_python3_fedora[@]}"
	
	if ! _package_man_distro "${array_python3_opensuseleap[@]}"; then
		red "Falha: ${array_python3_opensuseleap[@]}"
		return 1
	fi
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
	case "$os_codename" in 
		focal) _package_man_distro 'python' 'python-pip-whl' 'python-setuptools' || return 1;;
		*) _package_man_distro 'python' 'python-pip' 'python-setuptools' || return 1;;
	esac
	
	# Instalar utilitários para python3.
	for c in "${array_python3_debian[@]}"; do
		echo -e "$space_line"
		yellow "Instalando: $c"
		echo -e "$space_line"
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
	white "Instalando: ${array_cli_linux[@]}"
	_package_man_distro "${array_cli_linux[@]}" || return 1

	white "Instalando: python3 python-pip python-setuptools"
	_package_man_distro python3 'python-pip' 'python-setuptools'

	# Suporte ao NTFS - sudo pacman -S ntfs-3g 
	# _package_man_distro 'ntfs-3g'
	# sudo modprobe fuse
	
	white "Instalando: binutils"
	_package_man_distro binutils

	# Base-Devel
	# white "Instalando: base-devel"
	# _package_man_distro 'base-devel'

	# xdpinfo
	# _package_man_distro 'xorg-xdpyinfo'
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
	elif [[ "$os_id" == 'opensuse-leap' ]]; then
		_config_opensuseleap_requeriments || return 1
	elif [[ "$os_id" == 'arch' ]]; then
		_config_archlinux_requeriments || return 1
	elif [[ "$os_id" == '12.1-RELEASE' ]]; then     # FreeBSD 12.1
		_config_freebsd_requeriments || return 1   
	elif [[ "$os_id" == '12.1-STABLE' ]]; then      # GhostBSD -> freebsd12.1-stable
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
		white "Gravando log em [$Config_File]"
		echo 'requeriments OK' >> "$Config_File"
	fi
	return 0
}


_check_cli_utils()
{
	# Sempre que o programa executar sem o argumento --ignore-cli
	# Verificar os requerimentos de linha de comando.
	
	if [[ ! -x $(which wget 2> /dev/null) ]]; then
		red "Falha wget - execute  ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	elif [[ ! -x $(which curl 2> /dev/null) ]]; then
		red "Falha curl - execute  ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	elif [[ ! -x $(which git 2> /dev/null) ]]; then
		red "Falha git - execute  ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	elif [[ ! -x $(which awk 2> /dev/null) ]]; then
		red "Falha (awk - execute  ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	elif [[ ! -x $(which unzip 2> /dev/null) ]]; then
		red "Falha (unzip - execute  ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	elif [[ ! -x $(which xterm 2> /dev/null) ]]; then
		red "Falha: xterm - execute ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	elif [[ ! -x $(which python2 2> /dev/null) ]] && [[ ! -x $(which python2.7 2> /dev/null) ]]; then
		red "Falha (python2 - execute  ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	elif [[ ! -x $(which python3 2> /dev/null) ]] && [[ ! -x $(which python3.7 2> /dev/null) ]]; then
		red "Falha (python3 - execute  ${CYellow}$(readlink -f $0) --configure${CReset} para solucionar este problema"
	fi
			
	return 0
}
