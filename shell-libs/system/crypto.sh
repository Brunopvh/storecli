#!/usr/bin/env bash
#
#


gpgVerify()
{
	# Verifica a integridade de um arquivo com gpg.
	# $1 = arquivo.asc
	# $2 = arquivo a ser verificado.

	echo -ne "Verificando integridade do arquivo ... $(basename $2) "
	gpg --verify "$1" "$2" 1> "$SHELL_STATUS_FILE" 2>&1
	if [[ $? == 0 ]]; then  
		echo "OK"
		return 0
	else
		printErro "GPG"
		sleep 1
		return 1
	fi
}



gpgImportKey()
{
	# Função para importar uma chave com o comando gpg --import <file>
	#
	#   gpgImportKey file
	
	if ! isFile "$1"; then
		printErro "gpgImportKey - nenhum arquivo encontrado"
		return 1
	fi

	printf "Importando key ... $1 "
	if gpg --import "$1" 1> /dev/null 2>&1; then
		echo "OK"
		return 0
	else
		printErro "gpgImportKey"
		return 1
	fi
	
}


function getSha256()
{
	# Retorna o sha256sum de um arquivo
	sha256sum "$1" | cut -d ' ' -f 1
}


function getSha512()
{
	# Retorna o sha512sum de um arquivo
	sha512sum "$1" | cut -d ' ' -f 1
}


function checkSha256()
{
    # arg 1 = arquivo
    # arg 2 = hash original
    #
	# Esta função compara a hash de um arquivo local no disco com
	# uma hash informada no parametro "$2" (hash original). 
	#   Ou seja "$1" é o arquivo local e "$2" é uma hash
	# if ! isFile $1; then msgErroParam "checkSha256"; return 1; fi
	
	# Verificar os parâmetros.
	if [[ -z "$2" ]] || [[ ! -f $1 ]]; then
		msgErroParam "checkSha256"
		return 1
	fi

	# Verificar se o tamanho do hash a verifcar contém os 64 caracteres.
	if [[ "${#2}" != 64 ]]; then

		return 1
	fi

	echo -ne "Verificando integridade do arquivo ... $(basename $1) "
	local _hash_file=$(getSha256 $1)

	# Calucular o tamanho do arquivo
	# len_file=$(du -hs $1 | awk '{print $1}')
	# printf "%-15s%65s\n" "HASH original" "$2"
	# printf "%-15s%65s\n" "HASH local" "$hash_file"

	if [[ "$_hash_file" == "$2" ]]; then echo 'OK'; return 0; fi
	
	red "ERRO"
	red "arquivo inseguro ... $1"
	return 1
}




function checkSha512()
{
    # arg 1 = arquivo/string
    # arg 2 = hash original
    #
	# Esta função compara a hash de um arquivo local no disco com
	# uma hash informada no parametro "$2" (hash original). 
	#   Ou seja "$1" é o arquivo local e "$2" é uma hash
	# if ! isFile $1; then msgErroParam "checkSha256"; return 1; fi
	
	if [[ -z "$2" ]] || [[ ! -f $1 ]]; then
		msgErroParam "checkSha512"
		return 1
	fi

	echo -ne "Verificando integridade do arquivo ... $(basename $1) "
	local _hash_file=$(getSha512 $1)

	# Calucular o tamanho do arquivo
	# len_file=$(du -hs $1 | awk '{print $1}')
	# printf "%-15s%65s\n" "HASH original" "$2"
	# printf "%-15s%65s\n" "HASH local" "$hash_file"

	if [[ "$_hash_file" == "$2" ]]; then echo 'OK'; return 0; fi
	
	red "ERRO"
	red "arquivo inseguro ... $1"
	return 1
}

