#!/usr/bin/env bash
#
#---------------------------------------------------------#
# INFO
#  Este programa gerencia módulos para o bash instala/remove/atualiza ...
# os módulos são instalados em ~/.local/lib/bash para o usuário e
# /usr/local/lib/bash para o root.
#
#---------------------------------------------------------#
# INSTALAÇÃO
# A instalação correta deste programa deve ser feita por meio do
# script setup.sh
#  Instalação via curl: bash -c "$(curl -fsSL https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)"
#
#  Instalação via wget: bash -c "$(wget -q -O- https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)"
#
#  Instalação via git:  git clone https://github.com/Brunopvh/bash-libs.git 
#                       cd bash-libs
#                       chmod +x setup.sh 
#                       ./setup.sh install
#
# Após a instalação sera criado um link em ~/.local/bin/shm OU /usr/local/bin/shm
# se você fez a instalação para o usuário talvez seja necessário reiniciar a sessão no seu 
# sistema ou use source ~/.bashrc para ter e executavel disponível.
# 
# OBS: para verificar se ~/.local/bin faz parte do seu PATH na sessão atual execute echo $PATH.
#---------------------------------------------------------#
#

readonly __version__='0.1.1'
readonly __appname__='shm'
readonly __script__=$(readlink -f "$0")
readonly dir_of_project=$(dirname "$__script__")

if [[ -x $(command -v aria2c) ]]; then
	clientDownloader='aria2c'
elif [[ -x $(command -v wget) ]]; then
	clientDownloader='wget'
elif [[ -x $(command -v curl) ]]; then
	clientDownloader='curl'
else
	echo "ERRO ... instale curl ou wget para prosseguir."
	exit 1
fi

function show_import_erro()
{
	echo "ERRO shm: $@"
	echo -e "Visite https://github.com/Brunopvh/bash-libs"
	sleep 1
}

# Setar Diretório cache e arquivos de configuração.
if [[ $(id -u) == 0 ]]; then
	DIR_CACHE_SHM="/var/cache/$__appname__"
	DIR_CONFIG_SHM="/etc/${__appname__}.conf"
	PATH_BASH_LIBS='/usr/local/lib/bash'
else
	DIR_CACHE_SHM=~/.cache/"$__appname__"
	DIR_CONFIG_SHM=~/.config/"$__appname__"
	PATH_BASH_LIBS=~/.local/lib/bash
fi

[[ ! -d $PATH_BASH_LIBS ]] && {
	show_import_erro "Diretório para importação de módulos não encontrado."
	exit 1
}

USER_SHELL=$(basename $SHELL)
if [[ $USER_SHELL == 'zsh' ]]; then
	if [[ $(id -u) == 0 ]]; then
		_shell_config_file='/etc/zsh/zshrc'
	else
		_shell_config_file=~/.zshrc
	fi
elif [[ $USER_SHELL == 'bash' ]]; then
	if [[ $(id -u) == 0 ]]; then
		_shell_config_file='/etc/bash.bashrc'
	else
		_shell_config_file=~/.bashrc
	fi
fi

FILE_MODULES_LIST="$PATH_BASH_LIBS/modules.list"
FILE_DB_APPS="$DIR_CONFIG_SHM/installed-apps.list"

# Módulos em bash necessários para o funcionamento deste programa.
readonly RequerimentsList=(
	os.sh
	utils.sh
	print_text.sh
	requests.sh
	config_path.sh
	)

function check_local_modules()
{
	# Verificar se todos os módulos estão instalados no sistema.
	for MOD in "${RequerimentsList[@]}"; do
		if [[ ! -f "$PATH_BASH_LIBS/$MOD" ]]; then
			show_import_erro "Módulo não encontrado $PATH_BASH_LIBS/$MOD"
			return 1
			break
		fi
	done
	return 0
}

check_local_modules || exit 1
source "$PATH_BASH_LIBS"/print_text.sh
source "$PATH_BASH_LIBS"/utils.sh
source "$PATH_BASH_LIBS"/os.sh
source "$PATH_BASH_LIBS"/requests.sh
source "$PATH_BASH_LIBS"/config_path.sh

readonly TEMPORARY_DIR=$(mktemp --directory -u)
readonly TEMPORARY_FILE=$(mktemp -u)
readonly DIR_UNPACK="$TEMPORARY_DIR/unpack"
readonly DIR_DOWNLOAD="$TEMPORARY_DIR/download"

readonly URL_RAW_REPO='https://raw.github.com/Brunopvh/bash-libs/v0.1.1'
readonly URL_ARCHIVE='https://github.com/Brunopvh/bash-libs/archive'
readonly URL_TARFILE_LIBS="$URL_ARCHIVE/v0.1.1.tar.gz"
readonly URL_MODULES_LIST="$URL_RAW_REPO/libs/modules.list"
readonly URL_SHM="$URL_RAW_REPO/shm.sh"

USER_SHELL=$(basename $SHELL)

if [[ $USER_SHELL == 'zsh' ]]; then
	if [[ -f ~/.zshrc ]]; then
		__shell_config_file__=~/.zshrc
	elif [[ -f /etc/zsh/zshrc ]]; then
		__shell_config_file__=/etc/zsh/zshrc
	else
		echo "ERRO ... arquivo de configuração zshrc não encontrado"
		sleep 1
	fi
elif [[ $USER_SHELL == 'bash' ]]; then
	if [[ -f ~/.bashrc ]]; then
		__shell_config_file__=~/.bashrc
	elif [[ -f /etc/bash.bashrc ]]; then
		__shell_config_file__=/etc/bash.bashrc
	else
		echo "ERRO ... arquivo de configuração bashrc não encontrado"
		sleep 1
	fi
fi

function usage()
{
cat <<EOF
    Use: $__appname__ [opções] [argumentos]
         $__appname__ [agumento]

   Opções: 
     -h|--help                Mostra ajuda e sai.
     -c|--configure           Configura este programa para primeiro uso no sistema.
     -u|--self-update         Atualiza este programa para ultima versão disponível no github.
    
     -U|--upgrade             Instala a ultima versão de um módulo mesmo que este ja exista no sistema
                              essa opção deve ser usada com a opção --install.
                              EX: $__appname__ --upgrade --install requests pkgmanager
        
     -l|--list [Argumento]    Se não for passado nehum arguento, mostra os módulos disponíveis para instalação 
                              se receber o argumento [installed], mostra os módulos instalados para o seu usuário.
                                EX: $__appname__ --list
                                    $__appname__ --list installed

     -i|--install [módulo]    Instala um ou mais módulos.
                              EX: $__appname__ --install pkgmanager

     -r|--remove [módulo]     Remove um ou mais módulos.

     --info [módulo]          Mostra informações de um ou mais módulos.
                              EX: $__appname__ --info print_text platform

   Argumentos:
     up|update                Atualiza a lista de módulos disponíveis para instalação      


EOF
}

function create_dirs
{
	mkdir -p "$TEMPORARY_DIR"
	mkdir -p "$DIR_DOWNLOAD"
	mkdir -p "$DIR_UNPACK"
	mkdir -p "$DIR_CONFIG_SHM"
	mkdir -p "$DIR_CACHE_SHM"
	mkdir -p "$PATH_BASH_LIBS"
}

function clean_temp_files()
{
	rm -rf "$TEMPORARY_DIR" 2> /dev/null
	rm -rf "$TEMPORARY_FILE" 2> /dev/null
}


function exists_file()
{
	# Verificar a existencia de arquivos
	# $1 = Arquivo a verificar.
	# Também suporta uma mais de um arquivo a ser testado.
	# exists_file arquivo1 arquivo2 arquivo3 ...
	# se um arquivo informado como parâmetro não existir, esta função irá retornar 1.

	[[ -z $1 ]] && return 1
	export STATUS_OUTPUT=0

	while [[ $1 ]]; do
		if [[ ! -f "$1" ]]; then
			export STATUS_OUTPUT=1
			echo -e "ERRO ... o arquivo não existe $1"
			#sleep 0.05
		fi
		shift
	done

	[[ "$STATUS_OUTPUT" == 0 ]] && return 0
	return 1
}

function get_modules_list()
{
	# Baixa e salva o arquivo que contém a lista de todos os módulos disponíveis para instalação.
	[[ -f $TEMPORARY_FILE ]] && rm -rf $TEMPORARY_FILE 2> /dev/null
	download "$URL_MODULES_LIST" "$TEMPORARY_FILE" 1> /dev/null 2>&1 &
	loop_pid "$!" "Baixando $URL_MODULES_LIST"
	export Upgrade='True' # Sobreescrever versões anteriores quando a variável Upgrade for igual a True.
	__copy_files "$TEMPORARY_FILE" "$FILE_MODULES_LIST" 
}

function __copy_files()
{
	if [[ "$Upgrade" == 'True' ]]; then
		echo -ne "Atualizando ... $2 "
		cp -R "$1" "$2" 1> /dev/null 2>&1
	else
		echo -ne "Instalando ... $2 "
		if [[ -f "$2" ]]; then
			echo "... módulo já instalado [PULANDO]"
			return 0
		else
			cp -R "$1" "$2" 1> /dev/null 2>&1
		fi 
	fi

	[[ $? == 0 ]] && echo 'OK' && return 0
	echo 'ERRO'
	sleep 1
	return 1
}

function install_modules()
{
	# Instala os módulos recebidos como parâmetro desta função.
	print_line
	echo -e "${CGreen}I${CReset}nstalando os seguintes módulos/libs:\n"
	n=0
	for PKG in "${@}"; do
		[[ "$n" == 2 ]] && n=0 && echo
		printf "%-20s" "$PKG "
		n="$(($n + 1))"
	done
	echo

	echo -e "Baixando arquivos arguarde"
	download "$URL_TARFILE_LIBS" "$DIR_DOWNLOAD"/bash-libs.tar.gz 1> /dev/null 2>&1 || return 1
	[[ "$DownloadOnly" == 'True' ]] && print_info "Feito somente download!" && return 0
	
	unpack_archive "$DIR_DOWNLOAD"/bash-libs.tar.gz "$DIR_UNPACK" || return 1
	cd $DIR_UNPACK
	mv $(ls -d bash-*) bash-libs
	cd bash-libs/libs

	while [[ $1 ]]; do
		local module="$1"
		[[ "${module[@]:0:1}" == '-' ]] && {
			# Recebido uma opção ao inves de um argumento.
			print_erro "(install_modules) argumento inválido detectado ... $module"
			sleep 0.5
			return 1
			break
		}

		if [[ -f "${module}.sh" ]]; then
			__copy_files "${module}.sh" "$PATH_BASH_LIBS/${module}.sh" || { return 1; break; }
			grep -q ^"export readonly $module=$PATH_BASH_LIBS/${module}.sh" ~/.shmrc || {
					echo -e "export readonly $module=$PATH_BASH_LIBS/${module}.sh" >> ~/.shmrc
				}
		else
			print_erro "Módulo indisponível para instalação $module"
			sleep 0.5
		fi
		shift
	done
	print_line
}

function __configure__()
{
	if [[ ! -f "$FILE_MODULES_LIST" ]]; then
		get_modules_list || return 1
	fi
	
	config_bashrc
	config_zshrc	
	
	grep -q ^"export PATH_BASH_LIBS=$PATH_BASH_LIBS" ~/.shmrc || {
		echo -e "export PATH_BASH_LIBS=$PATH_BASH_LIBS" >> ~/.shmrc
	}

	grep -q "^source .*shmrc" "$__shell_config_file__" || {
		echo "source ~/.shmrc 1>/dev/null 2>&1" >> "$__shell_config_file__"
	}
}

function show_info_modules()
{
	# Mostra informações de um ou mais módulos recebidos como argumento.
	[[ -z $1 ]] && print_erro 'Falta um ou mais argumentos.' && exit 1
	print_line '*'
	for MOD in "${@}"; do
		if grep -q ^"$MOD" "$FILE_MODULES_LIST"; then
			grep ^"$MOD" "$FILE_MODULES_LIST"
		else
			print_erro "módulo não encontrado ... $MOD"
		fi
	done
}

function get_installed_modules()
{
	# find "$PATH_BASH_LIBS" -name '*.sh'
	echo '' > "$FILE_DB_APPS"
	find "$PATH_BASH_LIBS" -name '*.sh' | sed 's|.*/||g;s|.sh||g' >> "$FILE_DB_APPS"
}

function list_modules()
{
	if [[ -z $1 ]]; then
		cut -d '=' -f 1 "$FILE_MODULES_LIST"
	elif [[ "$1" == 'installed' ]]; then
		find "$PATH_BASH_LIBS" -name '*.sh'	
	fi
}

function self_update()
{
	#cd "$dir_of_project"
	cd "$PATH_BASH_LIBS"
	env AssumeYes='True' ./setup.sh
}

function main_shm()
{
	create_dirs

	for ARG in "${@}"; do
		case "$ARG" in
			-y|--yes) AssumeYes='True';;
			-d|--downloadonly) DownloadOnly='True';;
			-U|--upgrade) Upgrade='True';;
			-h|--help) usage; return 0; break;;
			-v|--version) echo -e "$__version__"; return 0; break;;
		esac
	done

	[[ -f $FILE_MODULES_LIST ]] || get_modules_list

	while [[ $1 ]]; do
		case "$1" in
			-U|--upgrade) ;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			-v|--version) ;;
			-h|--help) ;;
			-c|--configure) __configure__; return "$?"; break;;
			-u|--self-update) self_update; break;;
			-i|--install) shift; install_modules "$@"; return "$?"; break;;
			-r|--remove) shift; remove_modules "$@";;
			-l|--list) shift; list_modules "$@";;

			--info) shift; show_info_modules "$@"; return 0; break;;
			
			
			up|update) get_modules_list;;
			*) print_erro "argumento invalido detectado."; return 1; break;;
		esac
		shift
	done

	clean_temp_files
}


if [[ ! -z $1 ]]; then
	ArgumentsList=()
	ListIntallerModules=()
	ListRemoveModules=()
	main_shm "$@" 
fi
	