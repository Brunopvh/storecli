#!/usr/bin/env bash
# 
# Tor Browser install
#
VER='2019-11-30'
#

#clear

function _c()
{
	if [[ -z $2 ]]; then
		echo -e "\033[1;$1m"
		
	elif [[ $2 ]]; then
		echo -e "\033[$2;$1m"

	fi
}

if [[ $(id -u) == '0' ]]; then echo "==> [Erro] usuário não pode ser o $(_c 31)[root]$(_c)"; exit 1; fi


dir_default=~/.cache/downloads # Downloads
dir_space_tor="/tmp/space_tor_$USER" # Temp
log_w="$dir_default/wget-log"
arq_dow=$(basename "$0")
_tmp=$(mktemp)
esp='-------------'

mkdir -p "$dir_default" "$dir_space_tor" ~/.local/bin ~/.local/share/applications
cd "$dir_default"

requeriments_cli=('curl' 'tar')

array_tor=(
~/'.local/bin/torbrowser-amd64' # Dir
~/'.local/share/applications/start-tor-browser.desktop' # .desktop
~/'.local/bin/torbrowser' # Run.
)

function _usage_tor()
{
cat <<EOF
Use: 
   $(basename $0) --install|--remove|--downloadonly|--help

   --install          Instala Tor Browser em ~/.local/bin
   --remove           Desinstalar Tor Browser.
   --help             Exibe este menu e sai.
   --version          Exibe Versão e sai.
   --downloadonly     Somente baixa a ultima versão do Tor Browser
	                   Ex: $(basename $0) --install --downloadonly
EOF

exit 0
}

function _exist_executable()
{
while [[ $1 ]]; do

	if [[ -x $(command -v "$1" 2> /dev/null) ]]; then
		echo -en "\r"

	elif [[ ! -x $(command -v "$1" 2> /dev/null) ]]; then
		echo "$(_c 31)==> $(_c)Erro: $1"
		exit 1; break
	fi
	shift

done

}

#=============================================#
# Path User
#=============================================#
function _conf_path_zsh()
{
	command -v zsh 2> /dev/null || return 0
	
	# ~/.zshrc
	! grep -q "^export.*$HOME/.local/bin.*" ~/.zshrc && {
		echo "==> Adicionando: ~/.local/bin em PATH [~/.zshrc]"
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.zshrc
	
	zsh ~/'.zshrc'
	}
}

#-------------------------------------------#

function _conf_path_bash()
{
	# ~/.bashrc
	! grep -q "^export.*$HOME/.local/bin.*" ~/.bashrc && {
		echo "==> Adicionando: ~/.local/bin em PATH [~/.bashrc]"
		echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
	
	bash ~/'.bashrc'
	}
}


#=============================================#
# Url
#=============================================#
function _get_info_tor()
{
# url = domain/version/name
echo "$(_c 32)==> $(_c)Aguarde..."

tor_page='https://www.torproject.org/download/'
tor_domain='https://dist.torproject.org/torbrowser'
tor_html=$(wget -q "$tor_page" -O- | grep -m 1 'torbrowser.*linux.*64.*tar')

export tor_name=$(echo "$tor_html" | sed 's|.*\/||g;s|\".*||g')
export tor_version=$(echo "$tor_name" | sed 's/tor-browser-linux64-//g;s/_en-US.tar.xz//g')
export tor_url_dow="$tor_domain/$tor_version/$tor_name"
export tor_path_file="$dir_default/$tor_name"
}

#=============================================#
# Informações/Progresso de download com wget
#=============================================#
_progress(){
n=1
while [[ ! $(grep '99%' "$log_w") && ! $(grep 'Done' "$_tmp") ]]; do
	_porcentagem=$(awk '{print $7}' "$log_w" | tail -n 2 | sed -n 1p)
	_velocidade=$(awk '{print $8}' "$log_w" | tail -n 2 | sed -n 1p)
	case "$n" in
	1) echo -en "$(_c 31) [ | ]$(_c 32) $_porcentagem $(_c 33)$_velocidade$(_c) \r\r";;
	2) echo -en "$(_c 31) [ / ]$(_c 32) $_porcentagem $(_c 33)$_velocidade$(_c) \r\r";;
	3) echo -en "$(_c 31) [ - ]$(_c 32) $_porcentagem $(_c 33)$_velocidade$(_c) \r\r";;
	4) echo -en "$(_c 31) [ \ ]$(_c 32) $_porcentagem $(_c 33)$_velocidade$(_c) \r\r";;
	esac

	if [[ "$n" == "4" ]]; then
	    sleep 0.1
	    n=1
	else
	    sleep 0.1
	    let n=n+1
	fi
done
echo -en "$(_c 31) [ | ]$(_c 35) $_porcentagem $(_c 34)$_velocidade $(_c)"
echo "Done" > $_tmp
}


#=============================================#
# Download via wget
#=============================================#
function _wget()
{
# $1 = url
# $2 = arquivo.
echo -e "$(_c 32)==> $(_c)Baixando: $1"
echo -e "$(_c 32)==> $(_c)Destino: $2"

while [[ ! $(grep 'Done' "$_tmp") ]] && wget -c -b "$1" -O "$2" | sed '/Continuando\|escrita/d'; do
	_progress;
done
}	

#=============================================#
# Download via curl
#=============================================#
function _curl()
{
# $1 = url
# $2 = arquivo.
echo -e "$(_c 32)==> $(_c)Baixando: $1"
echo -e "$(_c 32)==> $(_c)Destino: $2"
	curl -LS -C - "$1" -o "$2" || return 1
}

#=============================================#
function _download_tor()
{
[[ $(pidof wget) ]] && kill -9 $(pidof wget)
[[ -f "$log_w" ]] && rm "$log_w"

if [[ -f "$tor_path_file" ]]; then
	echo -e "$esp $(_c 32)[INFO]$(_c) $esp"
	echo "==> O arquivo $(_c 35)já$(_c) existe em $tor_path_file"
	echo "==> 'Pulando' o download"
	return 0

else
	# _wget "$tor_url_dow" "$tor_path_file" # Download com wget
	_curl "$tor_url_dow" "$tor_path_file" # Download com curl

fi
}

#=============================================#
# unpack
#=============================================#
function _unpack_tor_browser()
{
# $1 = arquivo a descomprimir.
# $2 = destino da descompressão.
local arq="$1"
local dir_temp="$2"

cd "$dir_temp" && rm -rf * 1> /dev/null 2>&1 
mkdir -p "$dir_temp"

	echo -e "$(_c 32)==> $(_c)Descompactando: ["$arq"]"
	echo -e "$(_c 32)==> $(_c)Destino: ["$dir_temp"]"

if [[ $(echo "$arq" | grep 'tar.gz') ]]; then
	tar -zxvf "$arq" -C "$dir_temp" 1> /dev/null	

elif [[ $(echo "$arq" | grep 'tar.bz2') ]]; then
	tar -jxvf "$arq" -C "$dir_temp" 1> /dev/null

elif [[ $(echo "$arq" | grep 'tar.xz') ]]; then
	tar -Jxf "$arq" -C "$dir_temp" 1> /dev/null

else
	echo "$(_c 31)==> $(_c)Arquivo inválido: $arq"
	return 1
fi

}

#=============================================#
# Install
#=============================================#
function _install_tor_browser()
{

_conf_path_bash
_conf_path_zsh
_get_info_tor 
_download_tor	

	[[ "$2" == '--downloadonly' ]] && {
		echo "$(_c 32)==> $(_c)$(basename $0): Feito somente download."
		return 0
	}


if [[ -x $(command -v torbrowser 2> /dev/null) ]]; then
	echo -e "$esp $(_c 32)[INFO]$(_c) $esp"
	echo "Tor Browser $(_c 35)já$(_c) instalado."
	return 0
fi

_unpack_tor_browser "$tor_path_file" "$dir_space_tor"
if [[ $? != '0' ]]; then 
	echo "==> Função $(_c 31)_unpack_tor_browser$(_c) retornou [erro]"
	exit 1
fi

echo "$(_c 32)==> $(_c)Instalando"
cd "$dir_space_tor"; mv $(ls -d tor-browser*) "${array_tor[0]}" # Mover para ~/.local/bin
chmod -R +x "${array_tor[0]}" # Permissão de execução.
cd "${array_tor[0]}"; ./start-tor-browser.desktop --register-app # Gerar arquivo .desktop

# Gerar script para chamada via linha de comando.
touch "${array_tor[2]}"
	echo '#!/usr/bin/env bash' > "${array_tor[2]}" # array_tor[2] = ~/.local/bin/torbrowser
	echo -e "\ncd ${array_tor[0]}"  >> "${array_tor[2]}"
	echo './start-tor-browser.desktop' >> "${array_tor[2]}"

chmod +x "${array_tor[2]}"
cp -u "${array_tor[1]}" ~/Desktop/ 2> /dev/null
cp -u "${array_tor[1]}" ~/'Área de trabalho'/ 2> /dev/null
cp -u "${array_tor[1]}" ~/'Área de Trabalho'/ 2> /dev/null

torbrowser
}

#=============================================#
# Remove
#=============================================#
function _remove_tor_browser()
{
if [[ ! -x $(command -v torbrowser 2> /dev/null) ]]; then
	echo -e "$esp $(_c 32)[INFO]$(_c) $esp"
	echo "Tor Browser $(_c 31)não$(_c) está instalado."
	return 0

elif [[ -x $(command -v torbrowser 2> /dev/null) ]]; then
	for c in "${array_tor[@]}"; do
		if [[ -f "$c" ]] || [[ -d "$c" ]]; then
			echo -e "$(_c 32)==> $(_c)Removendo: $c"
			rm -rf "$c"
		else
			echo "$(_c 31)==> $(_c)Não encontrado: $c"
		fi
	done
fi

}

#-------------------------------------------#

_exist_executable "${requeriments_cli[@]}"

if [[ -z $1 ]]; then _usage_tor; exit 1; fi

#-------------------------------------------#

while [[ $1 ]]; do
	
	case "$1" in
		--install) _install_tor_browser "$@";;
		--remove) _remove_tor_browser;;
		--help) _usage_tor; exit 0;;
		--version) echo -e "$(basename $0) V$VER";;
		--downloadonly) echo -ne " \r";;
		*) _usage_tor; exit 1;;

	esac
	shift
done

#-------------------------------------------#

exit "$?"
