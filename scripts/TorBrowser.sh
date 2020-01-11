#!/usr/bin/env bash
# 
# Tor Browser install
#
VER='2019-12-05'
#


function _c()
{
	if [[ -z $2 ]]; then
		echo -e "\033[1;$1m"
		
	elif [[ $2 ]]; then
		echo -e "\033[$2;$1m"

	fi
}

if [[ $(id -u) == '0' ]]; then echo "==> [Erro] usuário não pode ser o $(_c 31)[root]$(_c)"; exit 1; fi


dir_default=~/.cache/downloads        # Downloads
dir_space_tor="/tmp/space_tor_$USER"  # Temp
log_w="$dir_default/wget-log"
arq_dow=$(basename "$0")
_tmp=$(mktemp)

esp='------------'

mkdir -p "$dir_default" "$dir_space_tor" ~/.local/bin ~/.local/share/applications
cd "$dir_default"

requeriments_cli=('curl' 'tar' 'gpgv' 'gpg')

array_tor=(
~/'.local/bin/torbrowser-amd64'                         # Dir
~/'.local/share/applications/start-tor-browser.desktop' # .desktop
~/'.local/bin/torbrowser'                               # Run.
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

#-------------------------------------------#

function _exist_executable()
{
while [[ $1 ]]; do

	if [[ ! -x $(command -v "$1" 2> /dev/null) ]]; then
		echo "$(_c 31)Erro: $1 $(_c)"
		exit 1; break
	fi

	shift
done

}

#-------------------------------------------#

_exist_executable "${requeriments_cli[@]}"

#-------------------------------------------#

#=============================================#
# Path User
#=============================================#
function _conf_path_zsh()
{
	command -v zsh 2> /dev/null || return 0
	
	if echo "$PATH" | grep -q "$HOME/.local/bin"; then return 0; fi

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

	if echo "$PATH" | grep -q "$HOME/.local/bin"; then return 0; fi

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
export tor_url_asc="$tor_domain/$tor_version/${tor_name}.asc"
export tor_path_file="$dir_default/$tor_name"
export tor_path_file_asc="$dir_default/${tor_name}.asc"
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
# asc
if [[ ! -f "$tor_path_file_asc" ]]; then _curl "$tor_url_asc" "$tor_path_file_asc"; fi

# tar.xz
if [[ -f "$tor_path_file" ]]; then
	echo -e "$esp $(_c 32)[INFO]$(_c) $esp"
	echo "==> O arquivo $(_c 35)já$(_c) existe em $tor_path_file"
	echo "==> 'Pulando' o download"
	return 0

else
	_curl "$tor_url_dow" "$tor_path_file" 

fi
}

#=============================================#
# unpack
#=============================================#

function _unpack_tor_browser()
{
# $1 = arquivo a descomprimir.
	local path_arq="$1"

	# Limpar o conteúdo do diretório antes de descomprimir.
	cd "$dir_space_tor" && rm -rf * 1> /dev/null 2>&1 
	echo -e "$(_c 32)==> $(_c)Descompactando: [$path_arq]"
	echo -e "$(_c 32)==> $(_c)Destino: [$dir_space_tor]"

	# Detectar a extensão do arquivo.
	if [[ "${path_arq: -6}" == 'tar.gz' ]]; then # tar.gz, 6 ultimos caracteres.
		type_arq='tar.gz'

	elif [[ "${path_arq: -7}" == 'tar.bz2' ]]; then # tar.bz2
		type_arq='tar.bz2'

	elif [[ "${path_arq: -6}" == 'tar.xz' ]]; then # tar.xz
		type_arq='tar.xz'

	else
		echo "$(_c 31)Arquivo não suportado: [$path_arq] $(_c)"
		return 1

	fi

	# Descomprimir.
	case "$type_arq" in
		'tar.gz') tar -zxvf "$path_arq" -C "$dir_space_tor" 1> /dev/null;;
		'tar.bz2') tar -jxvf "$path_arq" -C "$dir_space_tor" 1> /dev/null;;
		'tar.xz') tar -Jxf "$path_arq" -C "$dir_space_tor" 1> /dev/null;;
		*) return 1;;
	esac

}

#=============================================#
# Gpg 
#=============================================#

function _check_sig_tor()
{
# https://support.torproject.org/tbb/how-to-verify-signature/
# gpg --auto-key-locate nodefault,wkd --locate-keys torbrowser@torproject.org
# gpg --output ./tor.keyring --export 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290
local url_asc_tor='https://openpgpkey.torproject.org/.well-known/openpgpkey/torproject.org/hu/kounek7zrdx745qydx6p59t9mqjpuhdf'
local path_keyring="$dir_space_tor/tor.keyring"

if [[ -f "$path_keyring" ]]; then rm "$path_keyring"; fi

	echo "==> Importando chaves"
	curl -LSs "$url_asc_tor" -o- | gpg --import -

	echo "==> Gerando arquivo de verificação"	
	gpg --output "$path_keyring" --export 0xEF6E286DDA85EA2A4BA7DE684E2C6E8793298290

	echo "==> Checando assinatura do arquivo [$tor_path_file]"
	gpgv --keyring "$path_keyring" "$tor_path_file_asc" "$tor_path_file" || return 1

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

	_check_sig_tor || { echo "$(_c 31)==> Falha arquivo não confiavél [$tor_path_file]$(_c)"; exit 1; }

	_unpack_tor_browser "$tor_path_file" || {
		echo "Função $(_c 31)_unpack_tor_browser$(_c) retornou [erro]"
		exit 1
	}

echo "$(_c 32)==> $(_c)Instalando"
cd "$dir_space_tor" 
mv $(ls -d tor-browser*) "${array_tor[0]}" # Mover para ~/.local/bin
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

torbrowser # Abrir o navegador.
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
		if [[ -f "$c" ]] || [[ -d "$c" ]] || [[ -L "$c" ]]; then
			echo -e "$(_c 32)==> $(_c)Removendo: $c"
			rm -rf "$c"
		else
			echo "$(_c 31)==> $(_c)Não encontrado: $c"
		fi
	done
fi

}

#-------------------------------------------#

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
