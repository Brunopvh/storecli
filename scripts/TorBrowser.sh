#!/usr/bin/env bash
# 
# Tor Browser install
#
VER='2019-11-21'
#

#clear

function cor() { echo -e "\033[1;$1m"; }

if [[ $(id -u) == '0' ]]; then echo "==> [Erro] usuário não pode ser o $(cor 31)[root]$(cor)"; exit 1; fi


dir_default=~/.cache/downloads
dir_space_tor="/tmp/space_tor_$USER"
log_w="$dir_default/wget-log"
arq_dow=$(basename "$0")
_tmp=$(mktemp)
esp='---------------'

mkdir -p "$dir_default" "$dir_space_tor" ~/.local/bin ~/.local/share/applications
cd "$dir_default"

requeriments_cli=('wget' 'tar')

array_tor=(
~/'.local/bin/torbrowser-amd64' # Dir
~/'.local/share/applications/start-tor-browser.desktop' # .desktop
~/'.local/bin/torbrowser' # Run.
)

function _usage_tor()
{
cat <<EOF
Use: $(basename $0) --install|--remove|--downloadonly|--help
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
	if [[ -x $(command -v "$1") ]]; then
		echo -en "\r"

	elif [[ ! -x $(command -v "$1") ]]; then
		echo "$(cor 31)==> $(cor)Erro: $1"
		exit 1; break
	fi
	shift
done

}

#=============================================#
# Path User
#=============================================#
function _conf_paht_zsh()
{
if [[ ! $(grep "^export PATH.*$HOME/.local/bin.*" ~/.zshrc) ]]; then
	echo "==> Adicionando $(cor 32)~/.local/bin$(cor) em PATH [~/.bashrc]"
	echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
fi
}

function _conf_path_user()
{

if [[ ! $(grep "^export PATH.*$HOME/.local/bin.*" ~/.bashrc) ]]; then
	echo "==> Adicionando $(cor 32)~/.local/bin$(cor) em PATH [~/.bashrc]"
	echo "export PATH=$HOME/.local/bin:$PATH" >> ~/.bashrc
fi

if [[ -x $(command -v zsh) ]]; then _conf_path_zsh; fi
}


#=============================================#
# Url
#=============================================#
function _get_info_tor()
{
# url = domain/version/name
echo "$(cor 32)==> $(cor)Aguarde..."

tor_page='https://www.torproject.org/download/'
tor_domain='https://dist.torproject.org/torbrowser'
tor_html=$(wget -q "$tor_page" -O- | grep -m 1 'torbrowser.*linux.*64.*tar')

export tor_name=$(echo "$tor_html" | sed 's|.*\/||g;s|\".*||g')
export tor_version=$(echo "$tor_name" | sed 's/tor-browser-linux64-//g;s/_en-US.tar.xz//g')
export tor_url_dow="$tor_domain/$tor_version/$tor_name"
export tor_path_file="$dir_default/$tor_name"
}

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
echo -en "$(cor 31) [ | ]$(cor 35) $_porcentagem $(cor 34)$_velocidade $(cor)"
echo "Done" > $_tmp
}


#=============================================#
# $1 = url $2 = arquivo.
#=============================================#
function _wget()
{
echo -e "$(cor 32)==> $(cor)Baixando: $1"
echo -e "$(cor 32)==> $(cor)Destino: $2"

while [[ ! $(grep 'Done' "$_tmp") ]] && wget -c -b "$1" -O "$2" | sed '/Continuando\|escrita/d'; do
	_progress;
done
}	

function _download_tor()
{
[[ $(pidof wget) ]] && kill -9 $(pidof wget)
[[ -f "$log_w" ]] && rm "$log_w"

if [[ -f "$tor_path_file" ]]; then
	echo -e "$esp $(cor 32)[INFO]$(cor) $esp"
	echo "==> O arquivo $(cor 35)já$(cor) existe em $tor_path_file"
	echo "==> 'Pulando' o download"
	return 0

else
	_wget "$tor_url_dow" "$tor_path_file" 

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

	echo -e "$(cor 32)==> $(cor)Descompactando: ["$arq"]"
	echo -e "$(cor 32)==> $(cor)Destino: ["$dir_temp"]"

if [[ $(echo "$arq" | grep 'tar.gz') ]]; then
	tar -zxvf "$arq" -C "$dir_temp" 1> /dev/null	

elif [[ $(echo "$arq" | grep 'tar.bz2') ]]; then
	tar -jxvf "$arq" -C "$dir_temp" 1> /dev/null

elif [[ $(echo "$arq" | grep 'tar.xz') ]]; then
	tar -Jxf "$arq" -C "$dir_temp" 1> /dev/null

else
	echo "$(cor 31)==> $(cor)Arquivo inválido: $arq"
	return 1
fi

}

#=============================================#
# Install
#=============================================#
function _install_tor_browser()
{

_conf_path_user
_get_info_tor 
_download_tor	

if [[ "$2" == '--downloadonly' ]]; then
	echo "$(cor 35)==> $(cor)$(basename $0): Feito somente download."
	return 0
fi

if [[ -x $(command -v torbrowser 2> /dev/null) ]]; then
	echo -e "$esp $(cor 32)[INFO]$(cor) $esp"
	echo "Tor Browser $(cor 35)já$(cor) instalado."
	return 0
fi

_unpack_tor_browser "$tor_path_file" "$dir_space_tor"
if [[ $? != '0' ]]; then 
	echo "==> Função $(cor 31)_unpack_tor_browser$(cor) retornou [erro]"
	exit 1
fi

echo "$(cor 32)==> $(cor)Instalando"
cd "$dir_space_tor"; mv $(ls -d tor-browser*) "${array_tor[0]}" # Mover para ~/.local/bin
chmod -R +x "${array_tor[0]}" # Permissão de execução.
cd "${array_tor[0]}"; ./start-tor-browser.desktop --register-app # Gerar arquivo .desktop

# Gerar script para chamada via linha de comando.
touch "${array_tor[2]}"
echo '#!/usr/bin/env bash' > "${array_tor[2]}"
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
	echo -e "$esp $(cor 32)[INFO]$(cor) $esp"
	echo "Tor Browser $(cor 31)não$(cor) está instalado."
	return 0

elif [[ -x $(command -v torbrowser 2> /dev/null) ]]; then
	for c in "${array_tor[@]}"; do
		if [[ -f "$c" ]] || [[ -d "$c" ]]; then
			echo -e "$(cor 32)==> $(cor)Removendo: $c"
			rm -rf "$c"
		else
			echo "$(cor 31)==> $(cor)Não encontrado: $c"
		fi
	done
fi

}


_exist_executable "${requeriments_cli[@]}"


if [[ -z $1 ]]; then _usage_tor; exit 1; fi
while [[ $1 ]]; do
	
	case "$1" in
		--install) _install_tor_browser "$@";;
		--remove) _remove_tor_browser;;
		--help) _usage_tor; exit 0;;
		--version) echo -e "$(basename $0) V$VER";;
		--downloadonly) echo -ne "\r";;
		*) _usage_tor; exit 1;;

	esac
	shift
done

exit "$?"
