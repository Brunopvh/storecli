#!/usr/bin/env bash
#

__curl__()
{
	url="$1"
	path_file="$2"
	if [[ -z $2 ]]; then
		curl -C - -S -L -O "$url" || {
			_red "Falha: curl -S -L -O"
			return 1
		}
		return 0
	elif [[ $2 ]]; then
		_blue "Destino: $path_file"
		curl -C - -S -L -o "$path_file" "$url" || {
			_red "Falha: curl -S -L -o"
			rm "$path_file" 2> /dev/null
			return "$?"
		}
		return "$?"
	fi

}

__wget__()
{
	url="$1"
	path_file="$2"
	if [[ -z $2 ]]; then
		wget -c "$url" || {
			_red "Falha: wget -c $url"
			return 1
		}
		return 0
	elif [[ $2 ]]; then
		_blue "Destino: $path_file"
		wget -c "$url" -O "$path_file" || {
			_red "Falha: wget -c -O"
			rm "$path_file" 2> /dev/null
			return 1
		}
		return 0
	fi	
}



_dow()
{
	if [[ -f "$2" ]]; then
		_blue "Arquivo encontrado: $2"
		return 0
	fi

	cd "$directoryUSERdownloads"
	_blue "Baixando: $1"

	#__curl__ "$@"
	__wget__ "$@"

	if [[ "$?" == '130' ]]; then
		_red "Cancelado com Ctrl c"
		return 130
	fi

}


_gitclone()
{

	if [[ -z $1 ]]; then
		_red "(_gitclone) use: _gitclone <repo.git>"
		return 1
	fi

	cd "$DirGitclone"
	dir_repo=$(basename "$1" | sed 's/.git//g')
	if [[ -d "$DirGitclone/$dir_repo" ]]; then
		_yellow "Encontrado: $DirGitclone/$dir_repo"
		if _YESNO "Deseja remover o diretório clonado anteriormente"; then
			__RMDIR "$dir_repo"
		else
			return 0
		fi
	fi

	_blue "Clonando: $1"
	_blue "Destino: $(pwd)"
	if ! git clone "$1"; then
		_red "(_gitclone) falha"
		return 1
	fi
	return 0
}