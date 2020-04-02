#!/usr/bin/env bash
#
#
VERSION='2020-04-01'
#
# StoreCli a sua loja de aplicativos via linha de comando.
# Download Configuração e Instalaçao de programas.
# Sistemas suportados, (Debian/Ubuntu/Mint/Fedora/ArchLinux)
#
#
#--------------------| REPOSITÓRIO |----------------------------#
# https://github.com/Brunopvh/storecli.git 
#
#--------------------| INSTALAÇÃO |-----------------------------#
# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/install.sh)" 
# sh -c "$(wget -q https://raw.github.com/Brunopvh/storecli/master/install.sh -O-)"
#
#--------------------| REFERÊNCIAS |----------------------------#
# http://shellscriptx.blogspot.com/2016/12/utilizando-expansao-de-variaveis.html
# https://www.vivaolinux.com.br/dica/Instalando-Google-Chrome-no-Arch-com-Git
# https://www.vivaolinux.com.br/dica/Guia-pos-instalacao-do-Fedora-22-Xfce-Spin
# 
#

#clear

function _c()
{
	# Alterar cores do terminal.
	[[ -z $2 ]] && { echo -e "\033[1;$1m"; return 0; }
	echo -e "\033[$2;$1m"
}

# root.
[[ $(id -u) == '0' ]] && { 
	echo "$(_c 31)=> Falha o usuário não pode ser o [root]$(_c)"
	exit 1
}

#========================================================#
# local path dirs.
#========================================================#
export readonly StoreCli_Path=$(dirname $(readlink -f "$0"))      # path deste arquivo.
export readlink StoreCli_Path_Lib="$StoreCli_Path/lib"            # path para libs.
export readlink StoreCli_Path_Scripts="$StoreCli_Path/scripts"    # path para scripts.
export readlink StoreCli_Path_Programs="$StoreCli_Path/programs"  # path das categorias.
export readlink StoreCli_Path_Python="$StoreCli_Path/python"      # path dos scripts python.

#========================================================#
# Scripts
#========================================================#
export Script_TorBrowser="$StoreCli_Path_Scripts/TorBrowser.sh"
export Script_UnPack="$StoreCli_Path_Scripts/UnPack.sh"
export Script_PackTargz="$StoreCli_Path_Scripts/PackTargz.sh"
export Script_Papirus="$StoreCli_Path_Scripts/papirus.sh"
export Script_AddRepo="$StoreCli_Path_Scripts/AddRepo.sh"
export Script_Pywine="$HOME/.local/bin/pywine-amd64/pywine.py"
export Script_Config_Path="$StoreCli_Path_Scripts/conf_path.sh"

#========================================================#
# Libs
#========================================================#
export Lib_array="$StoreCli_Path_Lib/array.sh"
export Lib_platform="$StoreCli_Path_Lib/platform.sh"            # Detecta o sistema.
export Lib_Info="$StoreCli_Path_Lib/info.sh"
export Lib_SysUtils="$StoreCli_Path_Lib/SysUtils.sh"
export Lib_HttpsTransfer="$StoreCli_Path_Lib/HttpsTransfer.sh"
export Lib_PackManager="$StoreCli_Path_Lib/PackManager.sh"          # Gerencia instalação dos pacotes.
export Lib_PackRemove="$StoreCli_Path_Lib/PackRemove.sh"            # Gerencia remoção dos pacotes.
export Lib_Package_Man_Cli="$StoreCli_Path_Lib/Package_man_cli.sh"  # Gerenciador de pacotes da distro.
export Lib_ShaSum="$StoreCli_Path_Lib/ShaSum.sh"
export Lib_GitClone="$StoreCli_Path_Lib/GitClone.sh"
export Lib_CheckUpdate="$StoreCli_Path_Lib/CheckUpdate.sh"
export Lib_Gpg="$StoreCli_Path_Lib/Gpg.sh"
export Lib_Color="$StoreCli_Path_Lib/Colors.sh"

#========================================================#
# Programs.
#========================================================#
export Lib_Acessorios="$StoreCli_Path_Programs/Acessorios.sh"
export Lib_Dev="$StoreCli_Path_Programs/Dev.sh"
export Lib_Escritorio="$StoreCli_Path_Programs/Escritorio.sh"
export Lib_Internet="$StoreCli_Path_Programs/Internet.sh"
export Lib_Midia="$StoreCli_Path_Programs/Midia.sh"
export Lib_Sistema="$StoreCli_Path_Programs/Sistema.sh"
export Lib_Preferencias="$StoreCli_Path_Programs/Preferencias.sh"
export Lib_Gnome_Shell="$StoreCli_Path_Programs/GnomeShell.sh"

#========================================================#
# Config.
#========================================================#
export Config_File="$HOME/.config/storecli.conf" # Arquivo de configuração para o usuário atual.

#========================================================#
# Import
#========================================================#
source "$Lib_array"
source "$Lib_platform"
source "$Lib_Info"
source "$Lib_SysUtils"
source "$Lib_HttpsTransfer"
source "$Lib_PackRemove"
source "$Lib_ShaSum"
source "$Lib_Gpg"
source "$Lib_CheckUpdate"
source "$Lib_Color"
source "$Lib_PackManager" 
source "$Lib_Package_Man_Cli"

source "$Lib_Acessorios"
source "$Lib_Dev"
source "$Lib_Escritorio"
source "$Lib_Internet"
source "$Lib_Midia"
source "$Lib_Sistema"
source "$Lib_Preferencias"
source "$Lib_Gnome_Shell"

#--------------------------------------------------------#
if [[ "$os_id" == 'opensuse-tumbleweed' ]]; then
	sysname=$(echo "$sysname" | sed 's/[0-9]\+//g') # Remover números do final.
fi

# linuxmint 19.x
if [[ "$os_id" == 'linuxmint' ]] && [[ $(echo "$os_version" | cut -c -2) -ge 19 ]]; then
	sysname="${os_id}$(echo $os_version | cut -c -2)" # Usar apenas o número 19.
fi

esp='-----------------'
space_line='======================================================='

#========================================================#
function _space_msg()
{
	# Espaçamento entre palavras.
	num="$((40-$1))"

	while [[ "$num" != '0' ]]; do
		echo -ne "-"
		num="$(($num-1))"
	done
}

#========================================================#

function space_msg()
{
	# Espaçamento entre palavras tamanho padrão 50 caracteres.
	num_string="${#1}" # Obter o tamana da string do primeiro parametro
	shift

	# Somar com o tamanho dos demais parametros caso tenha mais do que um.
	for c in "$@"; do
		num_string="$(($num_string+${#1}))"
		shift
	done

	# Subtrair 40 pelo tamanho total obtido.
	num="$((40-$num_string))" 

	while [[ "$num" != '0' ]]; do
		echo -ne "-" # Ecoar na tela sem quebrar linhas
		num="$(($num-1))"
	done
	echo -en ">"
}

#========================================================#

if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
	echo -e "Inserindo [$HOME/.local/bin] na variável PATH de [$USER]"
	PATH="$HOME/.local/bin:$PATH"
fi

#========================================================#
# Verificar executáveis.
#========================================================#
function _WHICH()
{
	if [[ -x $(command -v "$1" 2> /dev/null) ]]; then
		return 0
	else
		return 1
	fi
}

#========================================================#
# Verificar programas via cli necessários para este script.
#========================================================#
function _check_executable_cli()
{
while [[ $1 ]]; do
	_WHICH "$1" || {
		_red "$1 $(_space_msg ${#1}) [!]"
		return 1 
		break
	}
	shift
done
}

#=====================================================#
# Args
#=====================================================#
if [[ "$1" == '--help' ]] || [[ "$1" == '-h' ]]; then
	usage; exit 0

elif [[ "$1" == '--version' ]] || [[ "$1" == '-v' ]]; then
	echo -e "$(basename $0) V${VERSION}"; exit 0

elif [[ "$1" == '--logo' ]]; then
	_logo; exit 0 # LibInfo

elif [[ "$1" == '--configure' ]] || [[ "$1" == '-c' ]]; then
	# Lib SysUtils.sh
	_configure_system || { _red "Encerrando com erro."; exit 1; }
	exit 0

elif [[ "$1" == '--list' ]]; then
	_list_applications
	exit 0

elif [[ "$1" == '--upgrade' ]] || [[ "$1" == '-u' ]]; then
	_msg 'Aguarde...'
	"$StoreCli_Path/install.sh"
	exit "$?"

fi 

#========================================================#
# Verificar conexão com a internet.
#========================================================#
printf "=> Aguardando conexão (ping) "
if ! ping -c 1 8.8.8.8 1> /dev/null; then
	printf "\033[1;31m[-]\033[m\n"
	_red "[!] AVISO LEGAL: Você está off-line [pressione enter] "
	read enter
else
	printf "[OK]\n"
fi

#=====================================================#
# Verificações.
#=====================================================#
# Se o sistema for debian buster, verificar repositórios "main contrib e nonfree"
# sempre que este script for inicializado, caso não estejam disponiveis o usuario
# será indagado sobre adiciona-los ou não no sistema. 
if [[ "$os_codename" == 'buster' ]]; then
	grep -q 'deb http://deb.debian.org/debian buster main contrib non-free' '/etc/apt/sources.list' || {
		"$Script_AddRepo" --debian-repos
	}
fi

# Cli
_check_executable_cli "${array_cli_requeriments[@]}" || {

	_msg "Função $(_c 31)[_check_executable_cli]$(_c) retornou erro." 
	_msg "Execute:$(_c 31) $(basename $0) --configure $(_c) para resolver este erro."
	exit 1 
}

# Se o arquivo de configuração ainda não existir no sistema, será criado um arquivo vazio.
[[ ! -f "$Config_File" ]] && echo ' ' > "$Config_File"


#=====================================================#
# Quando a configuração deste script e concluida com exito ele gera uma linha no arquivo "$Config_File"
# com a seguinte string 'requeriments_false' isso significa que a primeira configuração foi executada 
# com sucesso no sistema. Sendo assim não será necessário configura-lo sempre que o script é executado
# porém se o arquivo não existir ou se esta string não for encontrada as funções de configuração deste
# script serão invocadas.
#=====================================================#
if ! grep -q 'requeriments false' "$Config_File"; then
	_white "$space_line"

	echo "=> Necessário executar a opção $(_c 32 0)--configure$(_c) pela primeira vez em seu sistema."
	echo -ne "=> Deseja executar esta ação agora $(_c 32)[s/n]$(_c)? : "

	read _input
	if [[ "${_input,,}" == 's' ]]; then
		_configure_system || {
			echo "$(_c 31)Encerrando com erro $(_c)" 
			exit 1
		}

	else
		_msg "Execute manualmente: $(_c 32)$(basename $0) --configure$(_c)"
		exit 0

	fi
	
fi

_create_dirs_user       # SysUtils.sh
"$Script_Config_Path"   # conf_path.sh


# Instalar o script pywine.
if ! _WHICH 'pywine'; then
	mkdir -p "$dir_temp"
	[[ -f "$dir_temp/conf_pywine.sh" ]] && rm "$dir_temp/conf_pywine.sh"
	url_conf_pywine='https://raw.github.com/Brunopvh/pywine/master/conf_pywine.sh'
	curl -SL "$url_conf_pywine" -o "$dir_temp/conf_pywine.sh" || exit 1
	chmod +x "$dir_temp/conf_pywine.sh"
	"$dir_temp/conf_pywine.sh"
fi

#=====================================================#
#------------------ End check system -----------------#
#=====================================================#

function _prog_not_found()
{
	_red "Programa indisponível para o seu sistema [$os_id]"
}

#=====================================================#
# Verificar e instalar atualização se disponível.
#=====================================================#

function _day_update()
{
	# Verificar se existe atualização deste script no github. Essa verificação será feita
	# uma vez por dia.
	if _check_update; then
		# Atualização disponivel, instalar imediatamente.
		"$StoreCli_Path/install.sh" 
	fi

	# Deletar linha que contém o dia da ultima verificação.
	sed -i '/^check_day/d' "$Config_File"

	# Gravar o dia atual no arquivo de configuração.
	echo -e "check_day $(date | awk '{print $3}')" >> "$Config_File"
}

#=====================================================#
_msg "[$os_type $os_id] $(space_msg "$os_type $os_id") Sistema"
_msg "[$dir_user_cache] $(space_msg $dir_user_cache) Downloads"

#=====================================================#
# Verificar nova versão uma vez por dia.
#=====================================================#
# O programa deve procurar por atualização no github uma vez por dia.
# Se não houver a string 'check_day' no arquivo de configuração então
# Será "chamada" a função _day_update que verifica se existe atualização
# disponível, e se houver ela sera instalada.
grep 'check_day' "$Config_File" 1> /dev/null || _day_update

# Dia atual
current_day=$(date | awk '{print $3}') 

# Dia da ultima verificação.
old_day=$(grep 'check_day' "$Config_File" | awk '{print $2}') 

# Se o dia de "hoje" for diferente do dia da ultima verificação, então execute a função _day_update.
if [[ "$current_day" != "$old_day" ]]; then 
	_day_update || { 
		_msg "Falha ao tentar instalar atualização. Execute $(_c 31)$(basename $0) --upgrade $(_c)"
	}
fi

#=====================================================#
# Gerenciar instalação dos pacotes atraves das libs.
#=====================================================#

function _msg_pack_instaled()
{
	# Informar ao usuário que determinado pacote já está instalado.
	_msg "$(_c 32 2)Já$(_c) instalado para remove-lo use: $(basename $0) $(_c 32)r$(_c)emove $1"
}

#=====================================================#
# Remover pacotes quebrados. Debian/Ubuntu/Mint.
#=====================================================#

function _quebrado()
{
	# Função para remover pacotes quebrados em sistemas debian.
	[[ ! -x $(command -v apt 2> /dev/null) ]] && { _prog_not_found; return 1; }	

	echo -e "$space_line"
	_msg "Limpando cache aguarde"
	if ! sudo sh -c 'apt-get clean; apt-get remove -y; apt-get autoremove -y'; then
		_red "Comando [apt-get clean; apt-get remove -y; apt-get autoremove -y] falhou"
	fi

	_msg "Executando [apt install -f -y; dpkg --configure -a]"
	if ! sudo sh -c 'apt install -f -y; dpkg --configure -a'; then
		_red "Comando [apt install -f -y; dpkg --configure -a; apt --fix-broken install] falhou"
	fi

	_msg "Executando apt update"
	sudo apt update 
	# sudo apt install --yes --force-yes -f
	# sudo apt --fix-broken install 

	_green "OK"
}

#=====================================================#

for arg in "$@"; do
		if [[ "$arg" == '--downloadonly' ]] || [[ "$arg" == '-d' ]]; then
			export download_only='on'
		elif [[ "$arg" == '--yes' ]] || [[ "$arg" == '-y' ]]; then
			export install_yes='on'
		fi
done

#=====================================================#
# Execução do programa atraves dos argumentos recebidos.
#=====================================================#

if [[ ! -z $1 ]]; then
	while [[ $1 ]]; do
		case "$1" in
			install) shift; _packmanager_install "$@"; exit "$?";; # PackManager.sh
			remove)  _packremove "$@"; exit "$?";; # PackRemove.sh
			--list) _list_applications; exit "$?";;
			--quebrado) _quebrado; exit "$?";;
			--debian-repos) "$Script_AddRepo" --debian-repos;;
			*) _white "Comando não encontrado $(space_msg $1) [$1]"; sleep 1;;
		esac
		shift
	done
else
	#_logo
	usage
fi

exit "$?"
