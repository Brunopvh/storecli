#!/usr/bin/env bash
#

function loopApt() # -> int
{
	local _procs=''

	while true; do
		_procs=$(ps aux)
		proc_apt_install=$(echo "$_procs" | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
		proc_apt_systemd=$(echo "$_procs" | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
		proc_dpkg_install=$(echo "$_procs" | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
		proc_python_aptd=$(echo "$_procs" | grep 'root.*apt' | egrep -m 1 '(aptd)' | awk '{print $2}')
	 	
		[[ $proc_apt_install != '' ]] && waitPid $proc_apt_install
		[[ $proc_apt_systemd != '' ]] && waitPid $proc_apt_systemd
		[[ $proc_dpkg_install != '' ]] && waitPid $proc_dpkg_install
		[[ $proc_python_aptd != '' ]] && waitPid $proc_python_aptd

		break
	done

}


function waitAptProcess()
{
	# Verificar se existe algum processo APT em execução.
	loopApt
}

runGdebi()
{
	waitAptProcess

	echo -e "Executando ... sudo gdebi $@"
	if sudo gdebi "$@"; then return 0; fi
	red "(runGdebi) erro: gdebi $@"
	return 1		
}

runDpkg()
{
	waitAptProcess

	echo -e "Executando ... sudo dpkg $@"
	if sudo dpkg "$@"; then return 0; fi

	sred "(runDpkg): Erro sudo dpkg $@"
	return 1
}

runApt()
{
	# Antes de proseguir com a instalação devemos verificar se já 
	# existe outro processo de instalação com apt em execução para não
	# causar erros.
	# sudo rm /var/lib/dpkg/lock-frontend 
	# sudo rm /var/cache/apt/archives/lock
	
	waitAptProcess
	[[ -f '/var/lib/dpkg/lock-frontend' ]] && sudo rm -rf '/var/lib/dpkg/lock-frontend'
	[[ -f '/var/cache/apt/archives/lock' ]] && sudo rm -rf '/var/cache/apt/archives/lock'

	echo -e "Executando ... sudo apt $@"
	if sudo apt "$@"; then return 0; fi
	sred "(runApt): Erro sudo apt $@"
	return 1	
}

aptKeyAdd()
{
	isAdmin || return 1

	if [[ ! -f $1 ]]; then
		printErro "aptKeyAdd: arquivo não encontrado."
		return 1
	fi

	echo -ne "Adicionando key apartir do arquivo ... $1 "
	sudo apt-key add "$1"
	[[ $? == 0 ]] && {
		echo OK
		return 0
	}
	printErro "aptKeyAdd"
	return 1
}


function existsDebianRepo()
{
	local _repo="$1"
	find /etc/apt -name *.list | xargs grep "^${_repo}" 1> /dev/null 2>&1 || return $?
	return 0
}

addRepoApt()
{
	# $1 = repositório para adicionar em /etc/apt/sources.list.d/
	# Se o repositório já existir em outro arquivo a adição do repositório
	# será IGNORADA.

	# $2 = Nome do arquivo para gravar o repositório (.list). Se o arquivo já existir
	# a adição do repositório será IGNORADA. 

	# IMPORTANTE: antes de adicionar os repositório, é necessário adicionar o key.pub 
	# de cada repositório adicionado, evitando assim possíveis problemas quando atualizar 
	# o cache do apt (sudo apt update).
	if [[ -z $2 ]]; then
		printErro "(addRepoApt): informe um arquivo para adicionar o repositório"
		return 1
	fi

	if isFile "$2"; then echo -e "[PULANDO] arquivo já existe ... $2"; return 0; fi
	if existsDebianRepo "$1"; then echo -e "[PULANDO] repositório j́á existe em /etc/apt"; return 0; fi

	local repo="$1"
	local file_repo="$2"
	#find /etc/apt -name *.list | xargs grep "^${repo}" 2> /dev/null

	printInfo "Adicionando repositório em ... $file_repo"
	echo -e "$repo" | sudo tee "$file_repo"
	runApt update || return $?
	return 0
}


#=============================================================#
# Remover pacotes quebrados em sistemas debian.
#=============================================================#

runAptBroke()
{
	if ! isExecutable apt; then
		red "(runAptBroke) esta opção só está disponível para sistemas baseados em Debian"
		return 0
	fi

    sudoCommand dpkg --configure -a
    sudoCommand apt clean
    sudoCommand apt remove
    sudoCommand apt install -y -f

	if [[ $(grep '^ID=' /etc/os-release | cut -d '=' -f 2) == 'debian' ]]; then
		sudoCommand apt --fix-broken install
	fi
	
	
	# sudo apt install --yes --force-yes -f 
}

