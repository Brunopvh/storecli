#!/usr/bin/env bash



_loop_wget()
{
	# Esta função serve para executar um loop enquanto um determinado processo
	# do sistema está em execução, por exemplo um outro processo de instalação
	# de pacotes, como o "apt install" ou "pacman install" por exemplo, o pid
	# deve ser passado como argumento $1 da função. Enquanto esse processo existir
	# o loop ira bloquar a execução deste script, que será retomada assim que o
	# processo informado for encerrado.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"
	local MensageText="$2"
	local Time='0'

	while true; do
		ALL_PROCS=$(ps aux)
		if [[ $(echo -e "$ALL_PROCS" | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]]; then 
			break
		fi

		Char="${array_chars[$num_char]}"		
		echo -ne "$MensageText $(($Time / 4))s \033[0;33m[${Char}]\033[m\r" # $(date +%H:%M:%S)
		sleep 0.25
		
		num_char="$(($num_char+1))"
		Time="$(($Time+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	echo -e "$MensageText $(($Time / 4))s \033[0;33m[${Char}]\033[m"	
}

__wget__()
{
    # Wget
    if [[ ! -x $(command -v wget 2> /dev/null) ]]; then
        printf "Instale o 'wget' para prosseguir\n"
        return 1
    fi
    
    # Awk
    if [[ ! -x $(command -v awk 2> /dev/null) ]]; then
        printf "Instale o 'awk' para prosseguir\n"
        return 1
    fi
    
    #local wget_dir_temp=$(mktemp --directory)
    local wget_dir_temp=~/Downloads/wget-teste; mkdir -p "$wget_dir_temp"
    local wget_log="$wget_dir_temp/wget-log"
    cd "$wget_dir_temp" || return 1
    wget -b "$@"
    PidWget="$!"
    
    _loop_wget "$PidWget" "Baixando"
    
    
   # rm -rf "$wget_dir_temp"
}


