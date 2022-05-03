#!/usr/bin/env bash
#
#
# - REQ-LIB = print_text
# - REQ-LIB = utils
# - REQ-LIB = sys
#
# REQ-SYSTEM = wget|curl
#

if isExecutable curl; then
	clientDownloader='curl'
elif isExecutable wget; then
	clientDownloader='wget'
else
	clientDownloader='None'
	printErro "requests: Instale curl ou wget para prosseguir."
fi



function checkInternet(){
	# https://www.vivaolinux.com.br/dica/Wget-Verificando-existencia-de-arquivo-remoto
	# https://www.vivaolinux.com.br/dica/Verificar-se-site-esta-online-via-linha-de-comando
	#

	#if isExecutable ping; then
	#	ping -c 1 8.8.8.8 #1> /dev/null 2>&1 || return $?
	if isExecutable curl; then
		curl -Is 'www.google.com' 1> /dev/null 2>&1 && return 0
	elif isExecutable wget; then
		wget -q 'www.google.com' -O /dev/null && return 0
	else
		return 1
	fi	

	_status=$?
	sred "Você não está conectado a INTERNET"
	return $_status
}


function webRequest()
{
    # arg 1 = string/url
    # type arg 1 = string 
    #
    # rtype = retorna o request feito em url $1
    #
	# aria2c -d $(dirname "$temp_file") -o $(basename "$temp_file") "$@" 1> /dev/null || return 1
	#
	case "$clientDownloader" in
		curl) curl -A curl -s -S -L "$@";;
		wget) wget -q -O- "$@";;
		*) return 1;;
	esac
}


function download()
{
    # $1 = URL
	# $2 = Output File - (Opcional)
	#
	# Baixa arquivos da internet.
	# Requer um gerenciador de downloads wget, curl, aria2
	# 
	# https://curl.se/
	# https://www.gnu.org/software/wget/
	# https://aria2.github.io/manual/pt/html/README.html
	# 
	


	[[ -f "$2" ]] && {
		green "Arquivo encontrado ... $2"
		return 0
	}

	local url="$1"
	local path_file="$2"

	if [[ "$clientDownloader" == 'None' ]]; then
		printErro "(download) Instale curl|wget para prosseguir."
		sleep 0.1
		return 1
	fi


	checkInternet || return $?

	echo -e "Baixando ... $url"

	clientDownloader='curl'

	if [[ ! -z $path_file ]]; then
		case "$clientDownloader" in 
			aria2c) 
					aria2c -c "$url" -d "$(dirname $path_file)" -o "$(basename $path_file)" 
					;;
			curl)
				curl -C - -S -L -o "$path_file" "$url"
					;;
			wget)
				wget -c "$url" -O "$path_file"
					;;
		esac
	else
		case "$clientDownloader" in 
			aria2c) 
					aria2c -c "$url"
					;;
			curl)
					curl -C - -S -L -O "$url"
					;;
			wget)
				wget -c "$url"
					;;
		esac
	fi

	[[ $? == 0 ]] && return 0
	printErro '(download)'
	return 1
}



getHtmlFile()
{
    # $1 = URL
	# $2 = Arquivo de saida.
    #
	# Salava uma página html em um arquivo.
	

	[[ "${#@}" == 2 ]] || {
		msgErroParam "getHtmlFile"
		return 1
	}
	
	if [[ -z $2 ]]; then
		msgErroParam "getHtmlFile"
		return 1
	fi
	
	# Verificar se $1 e do tipo url.
	if ! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/'; then
		red "(get_html): url inválida"
		return 1
	fi

	download "$1" "$2" 1> /dev/null 2>&1 || return $?
	return 0
}


getHtmlPage()
{
    # $1 = url - obrigatório.
	# $2 = ativar filtro.
	# $3 = filtro a ser aplicado no contéudo html - opcional.
	# 
	# Baixa uma página da web e retorna o contéudo na saida padrão 'stdout'
	#
	#
	# Opções:
	#      --find texto    -> Buscar uma ocorrência de texto.
	#      --finda-ll texto -> Busca todas as ocorrências de texto.
	#

	# Verificar se $1 e do tipo url.
	! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/' && {
		red "(_getHtmlPage): url inválida"
		return 1
	}

	local temp_file_html=$(mktemp); rm -rf "$temp_file_html" 2> /dev/null
	download "$1" "$temp_file_html" 1> /dev/null 2>&1 || return $?

	if [[ "$2" == '--find' ]]; then
		Find="$3"
		grep -m 1 "$Find" "$temp_file_html"
	elif [[ "$2" == '--find-all' ]]; then
		Find="$3"
		grep "$Find" "$temp_file_html"
	else
		cat "$temp_file_html"
	fi
	rm -rf "$temp_file_html" 2> /dev/null
}
