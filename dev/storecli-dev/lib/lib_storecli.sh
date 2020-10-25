#!/usr/bin/env bash
#

os_type=''
os_id=''
os_release=''
os_version=''
os_codename=''
sysname=''

# Kernel
os_type=$(uname -s)

if [[ -f '/usr/local/etc/os-release' ]]; then
	file_release='/usr/local/etc/os-release'
elif [[ -f '/etc/os-release' ]]; then
	file_release='/etc/os-release'
fi

#=============================================#
# os_id
#=============================================#
if [[ $os_type == 'FreeBSD' ]]; then
	os_id=$(uname -r)
elif [[ $os_type == 'Linux' ]]; then
	os_id=$(grep '^ID=' "$file_release" | sed 's/.*=//g;s/\"//g') # debian/ubuntu/linuxmint/fedora ...
fi


#=============================================#
# os_version
#=============================================#
if [[ "$file_release" ]]; then
	os_version=$(grep -m 1 '^VERSION_ID=' "$file_release" | sed 's/.*VERSION_ID=//g;s/\"//g')
elif [[ "$os_type" == 'FreeBSD' ]]; then
	os_version=$(uname -r)
fi

#=============================================#
# os_release
#=============================================#
if [[ "$file_release" ]]; then
	os_release=$(grep -m 1 '^VERSION=' "$file_release" | sed 's/.*VERSION=//g;s/\"//g;s/(//g;s/)//g;s/ //g')
fi


#=============================================#
# Codename
#=============================================#
if [[ "$file_release" ]] && [[ $(grep '^VERSION_CODENAME=' "$file_release") ]]; then
	os_codename=$(grep -m 1 '^VERSION_CODENAME=' "$file_release" | sed 's/.*VERSION_CODENAME=//g')
fi

_YESNO()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do programa, em que a resposta deve ser do tipo SIM ou NÃO (s/n)
	# esta função é para automatizar esta indagação.
	#
	#   se teclar "s" -----------------> retornar 0  
	#   se teclar "n" ou nada ---------> retornar 1.
	#
	# $1 = Mensagem a ser exibida para o usuário, a resposta deve ser SIM ou NÃO (s/n).
	
	# O usuário não deve ser indagado caso a opção "-y" ou --yes esteja presente 
	# na linha de comando. Nesse caso a função irá retornar '0' como se o usuário estivesse
	# aceitando todas as indagações.
	[[ "$AssumeYes" == 'True' ]] && return 0
		
	_println "$@ [${CYellow}s${CReset}/${CRed}n${CReset}]?: "
	read -t 15 -n 1 sn
	echo ' '

	if [[ "${sn,,}" == 's' ]]; then
		return 0
	else
		_green "${CYellow}A${CReset}bortando"
		return 1
	fi
}

_show_info()
{
	# Função para exibir mensagens padrão, como erro generico durante a instalação de um 
	# programa ou um mensagem generica de sucesso.
	[[ "$silent" == 'True' ]] && return 0
	case "$1" in
		AddFileDestktop) _green "Criando arquivo (.desktop)";;
		DownloadOnly) _green "Feito somente download";;
		PkgInstalled) _green "($2) está instalado";;
		SuccessInstalation) _green "($2) instalado com sucesso";;
		InstalationFailed) _red "Falha ao tentar instalar ($2)";;
		ProgramNotFound) _red "Programa indisponível para o seu sistema: $2";;
	esac
}

_list_applications()
{
	# Função para listar os programas disponíveis para instalação no sistema
	# também lista programas de uma categoria especifica, bastando informar essa
	# categoria como argumento.
	# EXEMPLO:
	#   storecli -l Acessorios  -> Lista somente a categoria acessorios

	if [[ -z $1 ]]; then
		printf "%s\n" "  Acessorios: " # Acessorios
		for APP in "${programs_acessory[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Desenvolvimento: " # Desenvolvimento
		for APP in "${programs_development[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Escritorio: " # Escritório
		for APP in "${programs_office[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Navegadores: " # Navegadores
		for APP in "${programs_browser[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Internet: " # Internt
		for APP in "${programs_internet[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Midia: " # Midia
		for APP in "${programs_midia[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Sistema: " # Sistema
		for APP in "${programs_system[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Preferencias: " # Preferências
		for APP in "${programs_preferences[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Gnome Shell: " # Gnome Shell
		for APP in "${programs_gnomeshell[@]}"; do
			printf "%s\n" "      $APP"
		done

		printf "\n"
		printf "%s\n" "  Wine: " # Gnome Shell
		for APP in "${programs_wine[@]}"; do
			printf "%s\n" "      $APP"
		done
		printf "\n"

		return 0
	fi

	for arg in "${@}"; do
		case "$arg" in
			Acessorios)
					printf "%s\n" "  Acessorios: "
					for APP in "${programs_acessory[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Desenvolvimento)
					printf "%s\n" "  Desenvolvimento: "
					for APP in "${programs_development[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Escritorio)
					printf "%s\n" "  Escritorio: "
					for APP in "${programs_office[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Navegadores)
					printf "%s\n" "  Navegadores: "
					for APP in "${programs_browser[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Internet)
					printf "%s\n" "  Internet: "
					for APP in "${programs_internet[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Midia)
					printf "%s\n" "  Midia: "
					for APP in "${programs_midia[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Sistema)
					printf "%s\n" "  Sistema: "
					for APP in "${programs_system[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Preferencias)
					printf "%s\n" "  Preferencias: "
					for APP in "${programs_preferences[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			GnomeShell)
					printf "%s\n" "  Gnome Shell: "
					for APP in "${programs_gnomeshell[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			Wine)
					printf "%s\n" "  Wine: "
					for APP in "${programs_wine[@]}"; do
						printf "%s\n" "      $APP"
					done
					printf "\n"
					;;
			*)
				printf "\n"
				_red "(_list_applications) categoria inválida: $arg"
				printf "\n"
					;;
		esac
		shift
	done	
}



__sudo__()
{
	# Função para executar comandos com o "sudo" e retornar '0' ou '1'.
	_print "${CYellow}E${CReset}xecutando ... sudo $@"
	if sudo "$@"; then
		return 0
	else
		_red "Falha: sudo $@"
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
	[[ -z $1 ]] && return 1

	# Se o arquivo/diretório não for removido por falta de privilegio 'root'
	# o comando de remoção será com 'sudo'.
	cd "$DirTemp"
	_print "Entrando no diretório ... $DirTemp"
	
	while [[ $1 ]]; do
		if ls "$1" 1> /dev/null 2>&1; then
			_yellow "Removendo ... $1"; sleep 0.04
			rm -rf "$1" 2> /dev/null || sudo rm -rf "$1"
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

__gpg__()
{
	_println "Verificando integridade "
	if gpg "$@" 1> "$OutputDevice" 2>&1; then  
		_syellow "OK"
	else
		_sred "FALHA"
		for X in "${@}"; do
			[[ -f "$X" ]] && __rmdir__ "$X"
		done
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

	if [[ -z $1 ]]; then
		_red "(gpg_import): opção incorreta detectada. Use gpg_import <file> | gpg_import <url>"
	fi

	if [[ -f "$1" ]]; then
		_print "Importando apartir do arquivo ... $1"
		if ! gpg --import "$1"; then
			_sred "FALHA"
			return 1
		fi
	else
		# Verificar se $1 e do tipo url ou arquivo remoto
		if ! echo "$1" | egrep '(http|ftp)' | grep -q '/'; then
			_red "(gpg_import): url inválida"
			return 1
		fi
		
		_println "Importando key apartir do url ... $1 "
		if is_executable curl && curl -s "$1" | gpg --import 1> /dev/null 2>&1; then
			echo "OK"
			return 0
		elif is_executable wget && wget -q -O- "$1" | gpg --import 1> /dev/null 2>&1; then
			echo "OK"
			return 0
		else
			_sred "FALHA"
			return 1
		fi
	fi
	return 1
}

get_html()
{
	# Verificar se $1 e do tipo url.
	if ! echo "$1" | egrep '(http:|ftp:|https:)' | grep -q '/'; then
		_red "(gpg_import): url inválida"
		return 1
	fi

	_yellow "Baixando o html apartir da url ... $1"
	echo ' ' > "$HtmlTemporaryFile"
	if is_executable curl; then
		curl -s "$1" -o "$HtmlTemporaryFile" || return 1
	elif is_executable wget; then
		wget -q "$1" -O "$HtmlTemporaryFile" || return 1
	else
		_red "Instale a ferramenta curl ou wget."
		return 1
	fi
	_yellow "Html salvo em ... $HtmlTemporaryFile"
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

	_print "Gerando hash do arquivo ... $1 $len_file "
	hash_file=$(sha256sum "$1" | cut -d ' ' -f 1)
	_println "Comparando valores "
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

	url="$1"
	path_file="$2"
	
	_yellow "Entrando no diretório ... $DirDownloads"
	cd "$DirDownloads"
	_blue "Baixando ... $2"
	_blue "Conectando ... $1"

	while true; do
		if is_executable curl; then
			curl -C - -S -L -o "$path_file" "$url" && break
		elif is_executable wget; then
			wget -c "$url" -O "$path_file" && break
		else
			return 1
			break
		fi

		_red "Falha no download"
		if _YESNO "Deseja tentar baixar novamente"; then
			continue
		else
			[[ -f "$path_file" ]] && __rmdir__ "$path_file"
			return 1
			break
		fi
	done
	[[ "$?" != '0' ]] && return 1
	return 0
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

	_green "Entrando no diretório ... $DirGitclone" 
	cd "$DirGitclone"
	dir_repo=$(basename "$1" | sed 's/.git//g')
	if [[ -d "$DirGitclone/$dir_repo" ]]; then
		_yellow "Encontrado: $DirGitclone/$dir_repo"
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

_unpack()
{
	# Obrigatório informar um arquivo no argumento $1.
	if [[ ! -f "$1" ]]; then
		_red "(_unpack) nenhum arquivo informado como argumento"
		return 1
	fi

	# Destino para descompressão.
	if [[ -d "$2" ]]; then 
		DirUnpack="$2"
	elif [[ -z "$DirUnpack" ]]; then
		_red "(_unpack): o diretório de descompressão e 'nulo'."
		return 1
	fi

	if [[ ! -d "$DirUnpack" ]]; then
		_yellow "(_unpack): criando o diretório ... $DirUnpack"
		mkdir -p "$DirUnpack"
	fi
	
	_yellow "Entrando no diretório ... $DirUnpack"
	cd "$DirUnpack"
	__rmdir__ $(ls)
	path_file="$1"

	# Detectar a extensão do arquivo.
	if [[ "${path_file: -6}" == 'tar.gz' ]]; then    # tar.gz - 6 ultimos caracteres.
		type_file='tar.gz'
	elif [[ "${path_file: -7}" == 'tar.bz2' ]]; then # tar.bz2 - 7 ultimos carcteres.
		type_file='tar.bz2'
	elif [[ "${path_file: -6}" == 'tar.xz' ]]; then  # tar.xz
		type_file='tar.xz'
	elif [[ "${path_file: -4}" == '.zip' ]]; then    # .zip
		type_file='zip'
	elif [[ "${path_file: -4}" == '.deb' ]]; then    # .deb
		type_file='deb'
	else
		_red "(_unpack) arquivo não suportado: $path_file"
		__rmdir__ "$path_file"
		return 1
	fi

	# Calcular o tamanho do arquivo
	local len_file=$(du -hs $path_file | awk '{print $1}')
	_println "Descomprimindo $len_file ... $path_file ... $(date +%H:%M:%S) "
	
	# Descomprimir.	
	case "$type_file" in
		'tar.gz') tar -zxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		'tar.bz2') tar -jxvf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		'tar.xz') tar -Jxf "$path_file" -C "$DirUnpack" 1> /dev/null 2>&1;;
		zip) unzip "$path_file" -d "$DirUnpack" 1> /dev/null 2>&1;;
		deb) ar -x "$path_file" --output="$DirUnpack" 1> /dev/null 2>&1;;
		*) return 1;;
	esac

	if [[ "$?" == '0' ]]; then
		_syellow "OK"
		return 0
	else
		_sred "FALHA"
		_red "(_unpack) erro: $path_file"
		__rmdir__ "$path_file"
		return 1
	fi
}


_pkg_manager_storecli()
{
	# Instalação dos programas, esta função recebe como parâmetro os pacotes a serem instalados
	# aluguns desses pacotes são instalados diretamente pelo gerenciador de pacotes da sua distro
	# Enquanto outros são instalados, seguindo um processo de download, descompressão e configuração.
	if [[ -z $1 ]]; then
		_list_applications
		return 1
	fi

	echo -e ".... $(date +%H:%M:%S) $____app_name____ V$__version__ ...."
	_clear_temp_dirs

	# Se o sistema for LinuxMint tricia, deverá ser tratado como Ubuntu bionic.
	case "$os_codename" in
		tina|tricia) export os_codename='bionic';;
	esac

	while [[ $1 ]]; do
		[[ -z $1 ]] && return 0 
		case "$1" in 
			Acessorios) _Acessory_All;;
			etcher) _etcher;;
			gnome-disk) _gnome_disk;;
			plank) _plank;;
			veracrypt) _veracrypt;;
			woeusb) _woeusb;;

			Desenvolvimento) _Dev_All;;      # Instalar todos da catgória Desenvolvimento.
			'android-studio') _android_studio;;
			codeblocks) _codeblocks;;
			java) _java;;
			idea) _idea_ic;;
			pycharm) _pycharm;;
			sublime-text) _sublime_text;;
			vim) _vim;;
			vscode) _vscode;;

			Escritorio) _Office_All;;
			atril) _atril;;
			'fontes-ms') _fontes_microsoft;;
			libreoffice) _libreoffice;;
			libreoffice-appimage) _libreoffice_appimage;;

			Navegadores) _Browser_All;;
			chromium) _chromium;;
			edge) _edge;;
			firefox) _firefox;;
			'google-chrome') _google_chrome;;
			'opera-stable') _opera_stable;;
			torbrowser) _torbrowser;;

			Internet) _Internet_All;;      # Instalar todos da catgória Internet.
			clipgrab) _clipgrab_appimage;;
			megasync) _megasync;;
			proxychains) _proxychains;;
			qbittorrent) _qbittorrent;;
			skype) _skype;;
			teamviewer) _teamviewer;;
			telegram) _telegram;;
			tixati) _tixati;;
			uget) _uget;;
			youtube-dl) _youtube_dl;;
			youtube-dl-gui) _youtube_dlgui;;
		
			Midia) _Midia_All;;
			blender) _blender;;
			celluloid) _celluloid;;
			cinema) _cinema;;
			codecs) _codecs;;
			'gnome-mpv') _gnome_mpv;;
			smplayer) _smplayer;;
			spotify) _spotify;;
			parole) _parole;;
			totem) _totem;;
			vlc) _vlc;;

			Sistema) _System_All;;
			bluetooth) _bluetooth;;
			bspwm) _bspwm;;
			compactadores) _compactadores;;
			gparted) _gparted;;
			peazip) _peazip;;
			refind) _refind;;
			stacer) _stacer;;
			virtualbox) _virtualbox;;

			ohmybash) _ohmybash;;			
			ohmyzsh) _ohmyzsh;;
			papirus) _papirus;;
			sierra) _sierra;;
		
			'dash-to-dock') _dashtodock;;
			'drive-menu') _drive_menu;;
			'gnome-backgrounds') _gnome_backgrounds;;
			'gnome-tweaks') _gnome_tweaks;;
			'topicons-plus') _topicons_plus;;
			
			Wine) _Wine_All;;
			wine) _install_wine;;
			winetricks) _install_script_winetricks;;
			epsxe-win) _epsxe_windows;;
			python37-windows-portable) _python37_windows32_portable;;
			python37-windows) _python37_windows32;;
			youtube-dl-gui-windows) _youtube_dlgui_windows;;
			install) ;;
			-y|--yes) ;;
			-d|--downloadonly) ;;
			-I|--ignore-cli) ;;
			*) _red "(_pkg_manager_storecli) programa não encontrado: $1"; return 1; break;;
		esac
		shift
	done
	return "$?"
}
