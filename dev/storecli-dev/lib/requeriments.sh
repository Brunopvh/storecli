#!/usr/bin/env bash
#
#
#

# Utilitários de linha de comando para distribuições Linux.
requeriments_cli_linux=(
	wget curl gawk unzip python3 git zenity 
)

# Utilitários de linha de comando para sistemas baseados em debian.
requeriments_cli_debian=(
	aptitude gdebi dirmngr apt-transport-https gnupg gpgv2 gpgv xz-utils
)

#=============================================================#
# Utilitários para python2/python3
# alguns pacotes são equivalentes porem com nomes diferentes de 
# acordo com cada distribuição, por exemplo: no Fedora31 o executável
# 'python' e para a versão 3.7.x do python, já no debian o python3.7
# equivale ao executável python3, uma vez que python no debian é
# referente ao python2.7.
#    Por isso a necessidade de separar corretamente os nomes dos
# pacotes em cada "requeriments". As vezes podemos aproveitar o mesmo
# nome de pacote para várias distros como por exemplo 'curl', 'wget',
# 'git' entre outros. 
#=============================================================#

# Python2 Ubuntu
requeriments_python2_ubuntu=(
'python' 'python-pip' 'python-setuptools'
)

# Python3 debian
requeriments_python3_debian=( 
'python3' 'python3-pip' 'python3-setuptools'
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
		_yellow "Executando: pip3 install wheel wget --user"
		pip3 install wheel wget --user || return 1 
		return 0
	fi

	if is_executable 'pip'; then
		_yellow "Executando: pip install wheel wget --user"
		pip install wheel wget --user || return 1 
		return 0
	fi

	if is_executable 'pip2'; then
		_yellow "Executando: pip2 install wheel --user"
		pip2 install wheel --user || return 1 
	fi
	
	return 0 
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

	# Instalar utilitários para python3.
	__pkg__ "${requeriments_python3_fedora[@]}" || return 1
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
_config_requeriments_debian()
{
	_APT update || return 1
	__pkg__ "${requeriments_cli_linux[@]}" || return 1
	__pkg__ "${requeriments_cli_debian[@]}" || return 1
	__pkg__ "${requeriments_python3_debian[@]}" || return 1
	return 0
}

_config_requeriments_archlinux()
{
	__pkg__ "${requeriments_cli_linux[@]}" || return 1
	__pkg__ python3 'python-pip' 'python-setuptools' 'python-pmw' || return 1
	__pkg__ binutils || return 1
	return 0

	# xdpinfo
	# __pkg__ 'xorg-xdpyinfo'
}


#=============================================================#
# Istalar dependências de acordo com cada sistema.
#=============================================================#
_install_requeriments_all_system()
{
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
	return 0
}


_run_configuration_dep()
{
	# Instalar os requerimentos atraves da função "_install_requeriments_all_system"
	# que gerencia as demais funções, se a instalação dos pacotes for executada
	# com sucesso, será gravado as seguintes informações no arquivo de configuração
	# (configFILE) "requeriments OK". Isso significa que o programa não irá mais 
	# verificar as dependências ao iniciar.

	export AssumeYes='True'
	_ping || return 1
	
	while ! _install_requeriments_all_system; do
		if _YESNO "Deseja repetir"; then # Usar a função _YESNO - que irá retornar 1 ou 0.
			# Usuário digitou 's'
			continue
		else
			# Usuário digitou qualquer valor diferente de 's' ou deixou o tempo
			# limite esgotar sem responder nada - ENCERRAR COM ERRO.
			_red "Encerrando com erro"
			return 1
			break
		fi
	done

	# Função _install_requeriments_all_system foi executada com sucesso prosseguir.
	if ! grep -q 'requeriments OK' "$configFILE"; then
		_yellow "Gravando log em ($configFILE)"
		echo 'requeriments OK' >> "$configFILE"
	fi
	return 0
}

check_requeriments_sys()
{
	# Verificar requerimentos minimos de sistema para que os programas possam ser 
	# instalados com sucesso. Esta função será executada sempre que o programa iniciar.
	local requeriments=(
		'sudo'
		'wget'
		'curl'
		)

	for i in "${requeriments[@]}"; do
		if ! is_executable "$i"; then
			_red "(check_requeriments_sys): programa não encontrado ... $i"
			_red "Execute o comando a seguir para instalar todas as dependências: ${CRed}$__script__ --configure${CReset}"
			return 1
			break
		fi
	done
}
