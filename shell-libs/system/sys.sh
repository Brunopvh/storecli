#!/usr/bin/env bash
#
#
# - REQ-LIB = print_text
# - REQ-LIB = utils
#
# + REQ-COREUTILS = cut
# + REQ-COREUTILS = file
# + REQ-COREUTILS = id
# + REQ-COREUTILS = whoami
#
# + REQ-SYSTEM = awk
# + REQ-SYSTEM = unzip
# + REQ-SYSTEM = tar
# + REQ-SYSTEM = gpg
# + REQ-SYSTEM = shasum
#
#





function setStatusErro(){
	echo '1' > $SHELL_STATUS_FILE
}


function isFile(){
	# $1 = arquivo para verificar.
	[[ -f "$1" ]] && return 0
	return 1
}


function isDir(){
    # $1 = diretório para verificar.
	[[ -d "$1" ]] && return 0
	return 1
}

isAdmin(){
	# Verifica se o usuário atual é administrador.
	[[ $(whoami) == 'root' ]] && return 0

	printf "Autênticação necessária para prosseguir "
	if [[ $(sudo id -u) == 0 ]]; then
		printf "OK\n"
		return 0
	else
		printErro "ERRO"
		return 1
	fi
}

function isRoot()
{
	# Verifica se o usuário atual é o root.
	[[ $(id -u) == 0 ]] && return 0
	return 1
}


function isExecutable()
{
	# Função para verificar se um executável existe no PATH do sistema.
	if [[ -x $(command -v "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}


function _remove_files_root(){
    # args = string/diretórios/arquivos.
    # type args = string.
    #
	
	
	[[ -z $1 ]] && return 1

	echo -e "Deseja ${CRed}deletar${CReset} os seguintes arquivos/diretórios?: "
	for _dir in "${@}"; do echo -e "$_dir"; done
	
	question "" || return 1
    printLine

	while [[ $1 ]]; do	
        if [[ $(dirname $1) == '/' ]]; then
            echo -e "PULANDO ... $1"
            shift
            continue
        fi
	
		cd $(dirname "$1")
		echo -e "Removendo ... $1"
		#rm -rf "$1"
		shift
	done
}


function removeFiles()
{
    # args = string/diretórios/arquivos.
    # type args = string.
    #
	
	
	[[ -z $1 ]] && return 1

	echo -e "Deseja ${CRed}deletar${CReset} os seguintes arquivos/diretórios?: "
	for _dir in "${@}"; do echo -e "$_dir"; done
	
	question "" || return 1

	while [[ $1 ]]; do	
        if [[ $(dirname $1) == "$HOME" ]]; then
            echo -e "PULANDO ... $1"
            shift
            continue
        fi
	

        if [[ ! -w $1 ]]; then
            green "PULANDO ... você não tem permissão de escrita [w] em ... $1"
            shift
            continue
        fi

		cd $(dirname "$1")
		echo -e "Removendo ... $1"
		rm -rf "$1"
		shift
	done
}


function fileInfo(){
	# Retorna informções de um arquivo com base no comando file.
	[[ ! -f $1 ]] && {
		msgErroParam "fileInfo"
		return 1
	}

	file "$1" | cut -d ' ' -f 2
}


sudoCommand()
{
	# Função para executar comandos com o "sudo" e retornar '0' ou '1'.
	echo -e "Executando ... sudo $@"
	if sudo "$@"; then return 0; fi
	
	msgErro "sudo $@"
	return 1
}


function unpackArchive()
{
	# Descomprime arquivos mostrando um loop no stdout.
	local _unpackDir=$(pwd)

	if ! isFile "$1"; then
		msgErroParam 'unpack_archive'
		return 1
	fi


	if [[ -d $2 ]]; then _unpackDir="$2"; fi


	[[ ! -w "$_unpackDir" ]] && { 
		red "Você não tem permissão de escrita [-w] em ... $_unpackDir"
		return 1	
	}

	local path_file="$1"
	unpack "$path_file" "$_unpackDir" 1> $SHELL_DEVICE_FILE 2>&1 &
	
	# echo -e "$(date +%H:%M:%S)"
	loopPid "$!" "Descompactando ... $(basename $path_file)"
	[[ $(cat $SHELL_STATUS_FILE) == 0 ]] && return 0
	msgErro "unpack_archive"
	return 1
}



function unpack()
{
	# Descomprimir vários tipos de arquivos.
	#
	# $1 = arquivo a ser descomprimido - (obrigatório)
	# $2 = diretório de saída - (opcional)
	
	local _unpackDir=$(pwd)

	if ! isFile "$1"; then
		msgErroParam 'unpack_archive'
		return 1
	fi


	if [[ -d $2 ]]; then _unpackDir="$2"; fi


	[[ ! -w "$_unpackDir" ]] && { 
		red "Você não tem permissão de escrita [-w] em ... $_unpackDir"
		return 1	
	}

	# Obter o tipo de arquivo
	path_file="$1"
	extension_file=$(fileInfo $1)

	
	# Calcular o tamanho do arquivo
	# local len_file=$(du -hs $path_file | awk '{print $1}')
	echo -ne "Descompactando ... $(basename $1) "

	# Descomprimir de acordo com cada extensão de arquivo.	
	if [[ "$extension_file" == 'gzip' ]]; then
		tar -zxvf "$path_file" -C "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'bzip2' ]]; then
		tar -jxvf "$path_file" -C "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'XZ' ]]; then
		tar -Jxf "$path_file" -C "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'Zip' ]]; then
		unzip -o "$path_file" -d "$_unpackDir" 1> /dev/null 2>&1
	elif [[ "$extension_file" == 'Debian' ]]; then
		
		if [[ -f /etc/debian_version ]]; then    # Descompressão em sistemas DEBIAN
			ar -x "$path_file" 1> /dev/null 2>&1 
		else                                     # Descompressão em outros sistemas.
			ar -x "$path_file" --output="$_unpackDir" 1> /dev/null 2>&1
		fi
	fi

	# echo -e "$(date +%H:%M:%S)"
	if [[ $? == 0 ]]; then
		echo "OK"
		echo "0" > $SHELL_STATUS_FILE
	else
		msgErro "unpack_archive"
		echo "1" > $SHELL_STATUS_FILE
		return 1
	fi

	return 0
}


function exists_files()
{
    # arg 1 = strings/arquivos
    #
	# Verificar a existencia de arquivos, também suporta mais de um arquivo a ser testado.
    #
	# exists_files arquivo1 arquivo2 arquivo3 ...
	# se um arquivo informado como parâmetro não existir, esta função irá retornar 1.

	[[ -z $1 ]] && return 1
	export STATUS_OUTPUT=0

	while [[ $1 ]]; do
		if [[ ! -f "$1" ]]; then
			export STATUS_OUTPUT=1
			echo -e "ERRO ... o arquivo não existe $1"
            break
		fi
		shift
	done

	[[ "$STATUS_OUTPUT" == 0 ]] && return 0
	setStatusErro
	return 1
}



function addDesktopEntry() # -> None
{
	# arg 1 - $1 = Nome do arquivo a ser criado.
	# arg 2 - $2 = Um array com informações do arquivo.
    #    
    # Criar arquivo desktop - a extensão de arquivo (.desktop) é adicionada automáticamente.
	
	local _desktop_file="$1"; shift
	local _desktop_info="$@"; _desktop_file+=".desktop"
	local _path_file="$DIR_DESKTOP_ENTRY"/$_desktop_file

	echo -e "Criando arquivo .desktop ... $_desktop_file"
	echo '[Desktop Entry]' > $_path_file
	
	while [[ $1 ]]; do
		echo "Criando ... $1"
		echo "$1" >> $_path_file
		shift
	done

	chmod 777 $_path_file
}




