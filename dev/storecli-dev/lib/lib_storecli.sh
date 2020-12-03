#!/usr/bin/env bash
#

[[ ! -d "$DirTemp" ]] && DirTemp=$(mktemp --directory)
[[ ! -d "$path_libs" ]] && path_libs=$(pwd)
[[ -z "$columns" ]] && {
	source "$path_libs"/print_text.sh || exit 1
}

os_type=''
os_id=''
os_release=''
os_version=''
os_codename=''

# Kernel
os_type=$(uname -s)

if [[ -f '/usr/local/etc/os-release' ]]; then
	file_release='/usr/local/etc/os-release'
elif [[ -f '/etc/os-release' ]]; then
	file_release='/etc/os-release'
fi


# os_id
if [[ $os_type == 'FreeBSD' ]]; then
	os_id=$(uname -r)
elif [[ $os_type == 'Linux' ]]; then
	os_id=$(grep '^ID=' "$file_release" | sed 's/.*=//g;s/\"//g') # debian/ubuntu/linuxmint/fedora ...
fi

# os_version
if [[ "$file_release" ]]; then
	os_version=$(grep -m 1 '^VERSION_ID=' "$file_release" | sed 's/.*VERSION_ID=//g;s/\"//g')
elif [[ "$os_type" == 'FreeBSD' ]]; then
	os_version=$(uname -r)
fi

# os_release
if [[ "$file_release" ]]; then
	os_release=$(grep -m 1 '^VERSION=' "$file_release" | sed 's/.*VERSION=//g;s/\"//g;s/(//g;s/)//g;s/ //g')
fi


# Codename
if [[ "$file_release" ]] && [[ $(grep '^VERSION_CODENAME=' "$file_release") ]]; then
	os_codename=$(grep -m 1 '^VERSION_CODENAME=' "$file_release" | sed 's/.*VERSION_CODENAME=//g')
fi

_YESNO()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do programa, em que a resposta deve ser do tipo SIM ou NÃO (s/n)
	# esta função automatiza as indagações.
	#
	#   se teclar "s" -----------------> retornar 0  
	#   se teclar "n" ou nada ---------> retornar 1.
	#
	# $1 = Mensagem a ser exibida para o usuário, a resposta deve ser SIM ou NÃO (s/n).
	
	# O usuário não deve ser indagado caso a opção "-y" ou --yes esteja presente 
	# na linha de comando. Nesse caso a função irá retornar '0' como se o usuário estivesse
	# aceitando todas as indagações.
	[[ "$AssumeYes" == 'True' ]] && return 0
		
	printf "$@ ${CYellow}s${CReset}/${CRed}N${CReset}?: "
	read -t 15 -n 1 sn
	echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		printf "${CRed}Abortando${CReset}\n"
		return 1
	fi
}

_loop_pid()
{
	# Esta função serve para executar um loop enquanto um determinado processo
	# do sistema está em execução, por exemplo um outro processo de instalação
	# de pacotes, como o "apt install" ou "pacman install" por exemplo, o pid
	# deve ser passado como argumento $1 da função. Enquanto esse processo existir
	# o loop ira bloquar a execução deste script, que será retomada assim que o
	# processo informado for encerrado.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"

	while true; do
		ALL_PROCS=$(ps aux)
		if [[ $(echo -e "$ALL_PROCS" | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]]; then 
			break
		fi

		Char="${array_chars[$num_char]}"		
		echo -ne "Aguardando processo com pid [$Pid] finalizar [${Char}]\r" # $(date +%H:%M:%S)
		sleep 0.15
		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	echo -e "Aguardando processo com pid [$Pid] ${CYellow}finalizado${CReset} [${Char}]"	
}

_isroot()
{
	printf " + Autênticação necessária para ${CYellow}${USER}${CReset}: \n"
	if [[ $(sudo id -u) == '0' ]]; then
		return 0	
	else
		_red "(_isroot): falha na autênticação."
		return 1
	fi
}

is_admin(){
	printf "Autênticação necessária para prosseguir "
	if [[ $(sudo id -u) == 0 ]]; then
		printf "OK\n"
		return 0
	else
		printf "\033[0;31mFALHA\033[m\n"
		return 1
	fi
}


_GDEBI()
{
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
	Pid_Python_Aptd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(aptd)' | awk '{print $2}')

	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
		sleep 0.2
	done


	while [[ ! -z $Pid_Apt_Systemd ]]; do 
		_loop_pid "$Pid_Apt_Systemd"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
		sleep 0.2
	done
	
	while [[ ! -z $Pid_Dpkg_Install ]]; do 
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
		sleep 0.2
	done

	echo -e "Executando ... sudo gdebi $@"
	if sudo gdebi "$@"; then
		return 0
	else
		_red "(_GDEBI) erro: gdebi $@"
		return 1	
	fi	
}


_DPKG()
{
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
	Pid_Python_Aptd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(aptd)' | awk '{print $2}')

	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
		sleep 0.2
	done


	while [[ ! -z $Pid_Apt_Systemd ]]; do 
		_loop_pid "$Pid_Apt_Systemd"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
		sleep 0.2
	done
	
	while [[ ! -z $Pid_Dpkg_Install ]]; do 
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
		sleep 0.2
	done

	_msg "Executando ... sudo dpkg $@"
	if sudo dpkg "$@"; then
		return 0
	else
		_sred "(_DPKG): Erro sudo dpkg $@"
		return 1
	fi
}

_APT()
{
	# Antes de proseguir com a instalação devemos verificar se já 
	# existe outro processo de instalação com apt em execução para não
	# causar erros.
	#sudo rm /var/lib/dpkg/lock-frontend 
	#sudo rm /var/cache/apt/archives/lock
	
	Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
	Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
	Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')

	# Processo apt install em execução no sistema
	while [[ ! -z $Pid_Apt_Install ]]; do
		_loop_pid "$Pid_Apt_Install"
		Pid_Apt_Install=$(ps aux | grep 'root.*apt' | egrep -m 1 '(install|upgrade|update)' | awk '{print $2}')
		sleep 0.2
	done

	# Processo apt systemd em execução no sistema
	while [[ ! -z $Pid_Apt_Systemd ]]; do
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Apt_Systemd=$(ps aux | grep 'root.*apt' | egrep -m 1 '(apt.systemd)' | awk '{print $2}')
		sleep 0.2
	done

	# Processo dpkg install em execução no sistema
	while [[ ! -z $Pid_Dpkg_Install ]]; do
		_loop_pid "$Pid_Dpkg_Install"
		Pid_Dpkg_Install=$(ps aux | grep 'root.*dpkg' | egrep -m 1 '(install)' | awk '{print $2}')
		sleep 0.2
	done

	[[ -f '/var/lib/dpkg/lock-frontend' ]] && sudo rm -rf '/var/lib/dpkg/lock-frontend'
	[[ -f '/var/cache/apt/archives/lock' ]] && sudo rm -rf '/var/cache/apt/archives/lock'

	_msg "Executando ... sudo apt $@"
	if sudo apt "$@"; then
		return 0
	else
		_sred "(_APT): Erro sudo apt $@"
		return 1
	fi
}

_apt_key_add()
{
	is_admin || return 1

	if [[ -f "$1" ]]; then
		printf "(_apt_key_add) Adicionando key apartir do arquivo ... $1 "
		sudo apt-key add "$1" || return 1
	else 
		if ! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/'; then
			_red "(_apt_key_add): url inválida $1"
			return 1
		fi

		# Obter key apartir do url $1.
		local TEMP_FILE_KEY="$(mktemp)-tmp.key"

		printf "Adicionando key apartir do url ... $1 "
		__download__ "$1" "$TEMP_FILE_KEY" 1> /dev/null || return 1

		# Adicionar key
		if [[ $? == 0 ]]; then
			sudo apt-key add "$TEMP_FILE_KEY" || return 1
			return 0
		else
			printf "${CRed}FALHA no download${CReset}\n"
			return 1
		fi
	fi
}

_addrepo_in_sources_list()
{
	# $1 = repositório para adicionar em /etc/apt/sources.list.d/
	# Se o repositório já existir em outro arquivo a adição do repositório
	# será IGNORADA.

	# $2 = Nome do arquivo para gravar o repositório. Se o arquivo já existir
	# a adição do repositório será IGNORADA. 

	# IMPORTANTE antes de adicionar os repositório, e necessário adicionar key.pub 
	# para cada repositório, para evitar problemas quando atualizar o cache do apt (sudo apt update)
	if [[ -z $2 ]]; then
		printf "\033[0;31m(_addrepo_in_sources_list): informe um arquivo para adicionar o repositório\033[m\n"
		return 1
	fi

	local repo="$1"
	local file_repo="$2"
	find /etc/apt -name *.list | xargs grep "^${repo}" 2> /dev/null
	if [[ $? == 0 ]] || [[ -f "$file_repo" ]]; then
		printf "${CGreen}INFO${CReset} ... repositório já existe em /etc/apt pulando.\n"
		return 0
	else
		printf "${CGreen}A${CReset}dicionando repositório em ... $file_repo\n"
		echo -e "$repo" | sudo tee "$file_repo"
		_APT update || return 1
	fi
	return 0
}


#=============================================================#
# Remover pacotes quebrados em sistemas debian.
#=============================================================#
_BROKE()
{
	if [[ ! -x $(command -v apt 2> /dev/null) ]]; then
		_red "(_BROKE) esta opção só está disponível para sistemas baseados em Debian"
		return 0
	fi

	
	_yellow "Executando: dpkg --configure -a"
	_DPKG --configure -a

	_yellow "Executando: apt clean"
	_APT clean

	_yellow "Executando: apt remove"
	_APT remove
	
	_yellow "Executando: apt install -y -f"
	_APT install -y -f

	_yellow "Executando: apt --fix-broken install"
	_APT --fix-broken install
	
	# sudo apt install --yes --force-yes -f 
}


_RPM()
{
	_print "Executando ... sudo rpm $@"
	if sudo rpm "$@"; then
		return 0
	else
		_sred "(_RPM): Erro sudo rpm $@"
		return 1
	fi
}

_DNF()
{
	_msg "Executando ... sudo dnf $@"
	if sudo dnf "$@"; then
		return 0
	else
		_sred "(_DNF): Erro sudo dnf $@"
		return 1
	fi
}

_rpm_key_add()
{
	is_admin || return 1

	if [[ -f "$1" ]]; then
		printf "(_rpm_key_add) Adicionando key apartir do arquivo ... $1 "
		sudo rpm --import "$1" || return 1
	else 
		if ! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/'; then
			_red "(_apt_key_add): url inválida $1"
			return 1
		fi

		# Obter key apartir do url $1.
		local TEMP_FILE_KEY="$(mktemp)_rpm_key_add.key"

		printf "Adicionando key apartir do url ... $1 "
		__download__ "$1" "$TEMP_FILE_KEY" 1> /dev/null || return 1 

		if [[ $? == 0 ]]; then
			sudo rpm --import "$TEMP_FILE_KEY" || return 1
			return 0
		else
			printf "${CRed}FALHA no download${CReset}\n"
			return 1
		fi
	fi
}


_addrepo_in_fedora()
{
	# $1 = url do repositório.
	# $2 = Nome do arquivo para gravar o repositório.

	[[ -z $2 ]] && {
		printf "\033[0;31m(_addrepo_in_fedora): informe um arquivo para adicionar o repositório\033[m\n"
		return 1
	}

	# Verificar se $1 e do tipo url.
	! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/' && {
		_red "(_addrepo_in_fedora): url inválida"
		return 1
	}

	local url_repo="$1"
	local file_repo="$2"
	local temp_file_repo=$(mktemp)

	if [[ -f "$file_repo" ]]; then
		printf "${CGreen}INFO${CReset} ... repositório já existe em /etc/yum.repos.d pulando.\n"
	else
		printf "${CGreen}A${CReset}dicionando repositório em ... $file_repo "
		__download__ "$url_repo" "$temp_file_repo" 1> /dev/null || return 1
		__sudo__ mv "temp_file_repo" "$file_repo" 
		__sudo__ chown root:root "$file_repo"
		_syellow "OK"
	fi
	return 0
}

_ZYPPER()
{
	pidZypperInstall=$(ps aux | grep 'root.*zypper' | egrep -m 1 '(install)' | awk '{print $2}')

	# Processo zypper install em execução no sistema.
	while [[ ! -z $pidZypperInstall ]]; do
		_loop_pid "$pidZypperInstall"
		pidZypperInstall=$(ps aux | grep 'root.*zypper' | egrep -m 1 '(install)' | awk '{print $2}')
	done

	_print "Executando ... sudo zypper $@"
	if sudo zypper "$@"; then
		return 0
	else
		_red "(_ZYPPER): Erro sudo zypper $@"
		return 1
	fi
}

_PACMAN()
{
	Pid_Pacman_Install=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
	while [[ ! -z $Pid_Pacman_Install ]]; do
		_loop_pid "$Pid_Pacman_Install"
		Pid_Pacman_Install=$(ps aux | grep 'root.*pacman' | egrep -m 1 '(-S|y)' | awk '{print $2}')
		sleep 0.2
	done

	_print "Executando ... sudo pacman $@"
	if sudo pacman "$@"; then
		return 0
	else
		_red "(_PACMAN): Erro sudo pacman $@"
		return 1
	fi
}

_PKG()
{
	# FreeBSD
	Pid_Pkg_Install=$(ps aux | grep 'root.*pkg' | egrep -m 1 '(install|update)' | awk '{print $2}')
	[[ ! -z $Pid_Pkg_Install ]] && _loop_pid "$Pid_Pkg_Install"

	_print "Executando ... sudo pkg $@"
	if sudo pkg "$@"; then
		return 0
	else
		_red "(PKG): Erro sudo pkg $@"
		return 1
	fi
}

_FLATPAK()
{
	if flatpak "$@"; then
		return 0
	else
		_red "Falha: flatpak $@"
		return 1
	fi
}

__pkg__()
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
		elif [[ "$os_id" == 'opensuse-leap' ]] || [[ "$os_id" == 'opensuse-tumbleweed' ]]; then
			_ZYPPER download "$@" || return 1
		elif [[ "$os_id" == 'arch' ]]; then
			_PACMAN -S --noconfirm --needed --downloadonly "$@" || return 1
		else
			_red "(__pkg__) Erro: $@"
			return 1
		fi
		return "$?"
	
	elif [[ "$DownloadOnly" == 'True' ]]; then
		# Somente baixar os pacotes.
		if [[ $(uname -s) == 'FreeBSD' ]]; then 
			_PKG install "$@"
			return 
		fi
		
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install --download-only "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER download "$@" || return 1;;
			fedora) _DNF install --downloadonly "$@" || return 1;;
			arch) _PACMAN -S --needed --downloadonly "$@" || return 1;;
		esac
	elif [[ "$AssumeYes" == 'True' ]]; then 
		# Assumir yes para indagações durante a instalação, equivalênte ao comando
		# apt install -y / aptitude install -y em sistemas debian.
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install -y "$@"; return; fi
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install --yes "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install -y "$@" || return 1;;
			fedora) _DNF install -y "$@" || return 1;;
			arch) _PACMAN -S --noconfirm --needed "$@" || return 1;;
		esac
	else
		if [[ $(uname -s) == 'FreeBSD' ]]; then _PKG install "$@"; return; fi
		case "$os_id" in
			debian|ubuntu|linuxmint) _APT install "$@" || return 1;;
			opensuse-leap|opensuse-tumbleweed) _ZYPPER install "$@" || return 1;;
			fedora) _DNF install "$@" || return 1;;
			arch) _PACMAN -S --needed "$@" || return 1;;
		esac
	fi
}

__sudo__()
{
	# Função para executar comandos com o "sudo" e retornar '0' ou '1'.
	echo -e "${CYellow}E${CReset}xecutando ... sudo $@"
	if sudo "$@"; then
		return 0
	else
		_red "Falha ... sudo $@"
		return 1
	fi
}

__rmdir__()
{
	# Função para remover diretórios e arquivos, inclusive os arquivos é diretórios
	# que o usuário não tem permissão de escrita, para isso será usado o "sudo".
	#
	# Use:
	#     __rmdir__ <diretório> ou
	#     __rmdir__ <arquivo>
	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# o comando de remoção será com 'sudo'.
	
	[[ -z $1 ]] && return 1
	while [[ $1 ]]; do		
		cd $(dirname "$1")
		if [[ -f "$1" ]] || [[ -d "$1" ]] || [[ -L "$1" ]]; then
			printf "Removendo ... $1\n"
			rm -rf "$1" 2> /dev/null || sudo rm -rf "$1"
			sleep 0.08
		else
			_red "Não encontrado ... $1"
		fi
		shift
	done
}

_clear_temp_dirs()
{
	# Limpar diretórios temporários.
	cd "$DirTemp" && __rmdir__ $(ls)
	cd "$DirUnpack" && __rmdir__ $(ls)
	cd "$DirGitclone" && __rmdir__ $(ls)
}

gpg_verify()
{
	echo -ne "Verificando integridade do arquivo ... $(basename $2) "
	gpg --verify "$1" "$2" 1> /dev/null 2>&1
	if [[ $? == '0' ]]; then  
		_syellow "OK"
	else
		_sred "FALHA"
		sleep 1
		return 1
	fi
	return 0
}

gpg_import()
{
	# Função para importar um chave com o comando gpg --import <file>
	# esta função também suporta informar um arquivo remoto ao invés de um arquivo
	# no armazenamento local.
	# EX:
	#   gpg_import url
	#   gpg_import file
	
	[[ -z $1 ]] && {
		_red "(gpg_import): opção incorreta detectada. Use gpg_import <file> | gpg_import <url>"
	}

	if [[ -f "$1" ]]; then
		printf "Importando apartir do arquivo ... $1 "
		if gpg --import "$1" 1> /dev/null 2>&1; then
			_syellow "OK"
			return 0
		else
			_sred "FALHA"
			return 1
		fi
	else
		# Verificar se $1 e do tipo url ou arquivo remoto
		if ! echo "$1" | egrep '(http|ftp)' | grep -q '/'; then
			_red "(gpg_import): url inválida"
			return 1
		fi
		
		local TempFileAsc="$(mktemp)_gpg_import"
		printf "Importando key apartir da url ... $1 "
		__download__ "$1" "$TempFileAsc" 1> /dev/null || return 1
			
		# Importar Key
		if gpg --import "$TempFileAsc" 1> /dev/null 2>&1; then
			_syellow "OK"
			rm -rf "$TempFileAsc"
			return 0
		else
			_sred "FALHA"
			rm -rf "$TempFileAsc"
			return 1
		fi
	fi
}

get_html()
{
	# Verificar se $1 e do tipo url.
	if ! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/'; then
		_red "(get_html): url inválida"
		return 1
	fi

	rm -rf "$HtmlTemporaryFile"
	cd "$DirTemp"
	printf "Conectando ... $1 "
	__download__ "$1" "$HtmlTemporaryFile" 1> /dev/null || return 1

	if [[ $? == '0' ]]; then
		printf 'OK\n'
		return 0
	else
		_sred "FALHA"
		return 1
	fi
}

_get_html_page()
{
	# $1 = url
	# $2 = filtro a ser aplicado no contéudo html.
	# 
	# EX: _get_html_page URL --find 'name-file.tar.gz'
	#     _get_html_page URL

	# Verificar se $1 e do tipo url.
	! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/' && {
		_red "(_get_html_page): url inválida"
		return 1
	}

	local temp_file_html="$(mktemp).html"
	__download__ "$1" "$temp_file_html" 1> /dev/null || return 1

	if [[ "$2" == '--find' ]]; then
		shift 2
		Find="$1"
		grep -m 1 "$Find" "$temp_file_html"
	else
		cat "$temp_file_html"
	fi
	rm -rf "$temp_file_html" 2> /dev/null
}

__shasum__()
{
	# Esta função compara a hash de um arquivo local no disco com
	# uma hash informada no parametro "$2" (hash original). 
	#   Ou seja "$1" é o arquivo local e "$2" é uma hash
	local hash_file=''
	if [[ ! -f "$1" ]]; then
		_red "(__shasum__) arquivo inválido: $1"
		return 1
	fi

	if [[ -z "$2" ]]; then
		_red "(__shasum__) use: __shasum__ <arquivo> <hash>"
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
		_syellow 'OK'
		return 0
	else
		_sred 'FALHA'
		_red "(__shasum__): removendo arquivo inseguro ... $1"
		rm -rf "$1"
		return 1
	fi
}

__download__()
{
	if [[ -z $2 ]]; then
		_red "Necessário informar um arquivo de destino."
		return 1
	fi

	if [[ -f "$2" ]]; then
		_blue "Arquivo encontrado: $2"
		return 0
	fi

	local url="$1"
	local path_file="$2"
	local count=3
	
	cd "$DirDownloads"
	[[ ! -z $path_file ]] && _blue "Salvando em ... $path_file"
	_blue "Conectando ... $1"

	while true; do
		if [[ ! -z $path_file ]]; then
			if is_executable aria2c; then
				aria2c -c "$url" -d "$(dirname $path_file)" -o "$(basename $path_file)" && break
			elif is_executable curl; then
				curl -C - -S -L -o "$path_file" "$url" && break
			elif is_executable wget; then
				wget -c "$url" -O "$path_file" && break
			else
				return 1
				break
			fi
		else
			if is_executable aria2c; then
				aria2c -c "$url" -d "$DirDownloads" && break
			elif is_executable curl; then
				curl -C - -S -L -O "$url" && break
			elif is_executable wget; then
				wget -c "$url" && break
			else
				return 1
				break
			fi
		fi

		_red "Falha no download"
		sleep 0.1
		local count="$(($count-1))"
		if [[ $count > 0 ]]; then
			_yellow "Tentando novamente. Restando [$count] tentativa(s) restante(s)."
			continue
		else
			[[ -f "$path_file" ]] && __rmdir__ "$path_file"
			_sred "$(print_line)"
			return 1
			break
		fi
	done
	if [[ "$?" == '0' ]]; then
		return 0
	else
		_sred "$(print_line)"
	fi
}

_gitclone()
{
	if [[ -z $1 ]]; then
		_red "(_gitclone) use: _gitclone <repo.git>"
		return 1
	fi

	if ! is_executable git; then
		_yellow "Necessário instalar o pacote 'git"
		__pkg__ git || return 1
	fi

	_print "Entrando no diretório ... $DirGitclone" 
	cd "$DirGitclone"
	dir_repo=$(basename "$1" | sed 's/.git//g')
	if [[ -d "$DirGitclone/$dir_repo" ]]; then
		_yellow "Diretório encontrado ... $DirGitclone/$dir_repo"
		if _YESNO "Deseja remover o diretório clonado anteriormente"; then
			__rmdir__ "$dir_repo"
		else
			return 0
		fi
	fi

	_blue "Clonando ... $1"
	if ! git clone "$1"; then
		_red "(_gitclone): falha"
		return 1
	fi
	return 0
}

_show_loop_procs()
{
	# Esta função serve para executar um loop enquanto um determinado processo
	# do sistema está em execução, por exemplo um outro processo de instalação
	# de pacotes, como o "apt install" ou "pacman install" por exemplo, o pid
	# deve ser passado como argumento $1 da função. Enquanto esse processo existir
	# o loop ira bloquar a execução deste script, que será retomada assim que o
	# processo informado for encerrado.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"
	local MensageText="$2"
	
	while true; do
		ALL_PROCS=$(ps aux)
		[[ $(echo -e "$ALL_PROCS" | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]] && break
		
		Char="${array_chars[$num_char]}"		
		echo -ne "$MensageText ${CYellow}[${Char}]${CReset}\r" # $(date +%H:%M:%S)
		sleep 0.12
		
		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	echo -e "$MensageText [${Char}] OK"	
}


_unpack()
{
	# Obrigatório informar um arquivo no argumento $1.
	if [[ ! -f "$1" ]]; then
		printf "\033[0;31m (_unpack): nenhum arquivo informado como argumento\033[m\n"
		return 1
	fi

	# Destino para descompressão.
	if [[ -d "$2" ]]; then 
		DirUnpack="$2"
	elif [[ -z "$DirUnpack" ]]; then
		DirUnpack=$(pwd)
	fi

	printf "Entrando no diretório ... $DirUnpack\n"
	cd "$DirUnpack"

	if [[ ! -w "$DirUnpack" ]]; then
		printf "\033[0;31m(_unpack): Você não tem permissão de escrita [-w] em ... $DirUnpack\n"
		return 1
	fi
	
	__rmdir__ $(ls)
	path_file="$1"

	# Detectar a extensão do arquivo.
	if [[ "${path_file: -6}" == 'tar.gz' ]]; then    # tar.gz - 6 ultimos caracteres.
		type_file='TarGz'
	elif [[ "${path_file: -7}" == 'tar.bz2' ]]; then # tar.bz2 - 7 ultimos carcteres.
		type_file='TarBz2'
	elif [[ "${path_file: -6}" == 'tar.xz' ]]; then  # tar.xz
		type_file='TarXz'
	elif [[ "${path_file: -4}" == '.zip' ]]; then    # .zip
		type_file='Zip'
	elif [[ "${path_file: -4}" == '.deb' ]]; then    # .deb
		type_file='DebPkg'
	else
		printf "\033[0;31m(_unpack): FALHA arquivo não suportado ... $path_file\033[m\n"
		return 1
	fi

	# Calcular o tamanho do arquivo
	local len_file=$(du -hs $path_file | awk '{print $1}')
	
	# Descomprimir de acordo com cada extensão de arquivo.	
	if [[ "$type_file" == 'TarGz' ]]; then
		tar -zxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1 &
	elif [[ "$type_file" == 'TarBz2' ]]; then
		tar -jxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1 &
	elif [[ "$type_file" == 'TarXz' ]]; then
		tar -Jxf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1 &
	elif [[ "$type_file" == 'Zip' ]]; then
		unzip "$path_file" -d "$DirUnpack" 1> /dev/null 2>&1 &
	elif [[ "$type_file" == 'DebPkg' ]]; then
		
		if [[ -f /etc/debian_version ]]; then    # Descompressão em sistemas DEBIAN
			ar -x "$path_file" 1> /dev/null 2>&1  &
		else                                     # Descompressão em outros sistemas.
			ar -x "$path_file" --output="$DirUnpack" 1> /dev/null 2>&1 &
		fi
	fi	

	# echo -e "$(date +%H:%M:%S)"
	_show_loop_procs "$!" "Descompactando ... $(basename $path_file) em ... $DirUnpack"

	# Verificar se a extração foi concluida com sucesso.
	if [[ "$?" != '0' ]]; then
		printf "\033[0;31m(_unpack): FALHA na descompressão do arquivo $path_file\033[m\n"
		__rmdir__ "$path_file"
		return 1
	fi
}
