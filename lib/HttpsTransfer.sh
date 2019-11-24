#!/usr/bin/env bash
#
# 
#
# Requeriments curl wget
# curl -# -C - -o <file> -O <url> 
# curl  -o <file> -O <url>
# 
# Use:
# source HttpTransfer.sh
# _dow <url> <path/arquivo_saida> --wget --> Baixa com wget
# _dow <url> <path/arquivo_saida> --curl --> Baixa com curl
#

function cor() { echo -e "\e[1;$1m"; }

dir_default=~/'.cache/downloads'
log_w="$dir_default/wget-log"
_tmp=$(mktemp)

mkdir -p "$dir_default"
cd "$dir_default"

#=============================================#
# Informações/Progresso de download
#=============================================#
_progress(){
n=1
while [[ ! $(grep '99%' "$log_w") && ! $(grep 'Done' "$_tmp") ]]; do
	_porcentagem=$(awk '{print $7}' "$log_w" | tail -n 2 | sed -n 1p)
	_velocidade=$(awk '{print $8}' "$log_w" | tail -n 2 | sed -n 1p)
	case "$n" in
	1) echo -en "$(cor 31) [ | ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	2) echo -en "$(cor 31) [ / ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	3) echo -en "$(cor 31) [ - ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	4) echo -en "$(cor 31) [ \ ]$(cor 32) $_porcentagem $(cor 33)$_velocidade$(cor) \r\r";;
	esac

	if [[ "$n" == "4" ]]; then
	    sleep 0.1
	    n=1
	else
	    sleep 0.1
	    let n=n+1
	fi
done
echo -e "$(cor 31) [ | ]$(cor 35) $_porcentagem $(cor 34)$_velocidade $(cor)"
echo -e "Done" > "$_tmp"
}



#==================================#
# wget
#==================================#
function _Wget()
{
# $1 = url
# $2 = path_arq
local url="$1"
local path_arq="$2"

cd "$dir_default"
[[ $(pidof wget) ]] && kill -9 $(pidof wget)
[[ -f "$log_w" ]] && rm "$log_w"

echo -e "==> Baixando: [$url]"
if [[ -z $2 ]]; then  
	while [[ ! $(grep 'Done' "$_tmp") ]] && wget -c -b "$url" | sed '/Continuando\|escrita/d'; do
		_progress;
	done

elif [[ -d $(dirname "$2") ]]; then
	echo -e "==> Destino: [$path_arq]"
	while [[ ! $(grep 'Done' "$_tmp") ]] && wget -c -b "$url" -O "$path_arq" | sed '/Continuando\|escrita/d'; do
		_progress;
	done

fi
}


#==================================#
# Curl
#==================================#
function _Curl()
{
# $1 = url
# $2 = path_arq
local url="$1"
local path_arq="$2"

echo -e "==> Baixando: [$url]"
if [[ -z $2 ]]; then 
	curl -# -C - -O "$url" 

elif [[ -d $(dirname "$2") ]]; then
	echo -e "==> Destino: [$path_arq]"
	#curl -# -C - -o "$path_arq" -O "$url"
	curl -C - -o "$path_arq" -O "$url"

fi
}


#==================================#
# _dow url path_arq
#==================================#
function _dow()
{
	[[ -f "$2" ]] && { 
		echo "==> O arquivo já existe em [$2]"
		echo "==> 'Pulando' o download" 
		return 0 
	}

if [[ "$3" == '--wget' ]]; then
	echo "[wget]"
	_Wget "$@"

elif [[ "$3" == '--curl' ]]; then
	echo "[curl]"
	_Curl "$@"

else
	echo "==> Use: _dow <url> <file> --wget|--curl"
	return 1

fi

# Exit
if [[ $? == '0' ]]; then
	return 0

else
	echo "==> Função [_dow] retornou erro"
	return 1
fi
}
