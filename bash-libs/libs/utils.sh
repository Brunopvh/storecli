#!/usr/bin/env bash
#
version_utils='2021-03-20'
#
# - REQUERIMENT = print_text
#

function show_import_erro()
{
	echo "ERRO: $@"
	if [[ -x $(command -v curl) ]]; then
		echo -e "Execute ... bash -c \"\$(curl -fsSL https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)\""
	elif [[ -x $(command -v wget) ]]; then
		echo -e "Execute ... bash -c \"\$(wget -q -O- https://raw.github.com/Brunopvh/bash-libs/main/setup.sh)\""
	fi
	sleep 1
}

# print_text
if [[ $imported_print_text != 'True' ]]; then
	if ! source "$PATH_BASH_LIBS"/print_text.sh 2> /dev/null; then
		show_import_erro "módulo print_text.sh não encontrado em ... $PATH_BASH_LIBS"
		exit 1
	fi
fi

export readonly imported_utils='True'

question()
{
	# Será necessário indagar o usuário repetidas vezes durante a execução
	# do programa, em que a resposta deve ser do tipo SIM ou NÃO (s/n)
	# esta função automatiza as indagações.
	#
	#   se teclar "s" -----------------> retornar 0  
	#   se teclar "n" ou nada ---------> retornar 1.
	#
	# $1 = Mensagem a ser exibida para o usuário, a resposta deve ser SIM ou NÃO (s/n).
	
	# O usuário não deve ser indagado caso a opção "-y" ou --yes esteja presente 
	# na linha de comando. Nesse caso a função irá retornar '0' como se o usuário estivesse
	# aceitando todas as indagações.
	[[ "$AssumeYes" == 'True' ]] && return 0
		
	echo -ne "$@ ${CGreen}s${CReset}/${CRed}N${CReset}?: "
	read -t 15 -n 1 yesno
	echo ' '

	case "${yesno,,}" in
		s|y) return 0;;
		*) printf "${CRed}Abortando${CReset}\n"; return 1;;
	esac
}

loop_pid()
{
	# Função para executar um loop enquanto determinado processo
	# do sistema está em execução, por exemplo um outro processo de instalação
	# de pacotes, como o "apt install" ou "pacman install" por exemplo, o pid
	# deve ser passado como argumento $1 da função. Enquanto esse processo existir
	# o loop ira bloquar a execução deste script, que será retomada assim que o
	# processo informado for encerrado.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"
	local MensageText=''

	[[ $2 ]] && MensageText="$2"

	echo -ne "$(printf "%-$(tput cols)s" | tr ' ' ' ')\r" # Preencher a linha atual com espaços em branco.
	while true; do
		ALL_PROCS=$(ps aux)
		[[ $(echo -e "$ALL_PROCS" | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]] && break
		
		Char="${array_chars[$num_char]}"		
		echo -ne "$MensageText ${CYellow}[${Char}]${CReset}\r" # $(date +%H:%M:%S)
		sleep 0.12
		
		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	echo -e "$MensageText [${Char}] OK"	
}

wait_pid()
{
	# Função semelhante a "loop_pid" porém esta não permite exibir uma mensagem personalizada.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"

	# Chechar se Pid é um digito
	echo $Pid | grep -q [[:digit:]]
	[[ $? == 0 ]] || return

	while true; do
		ALL_PROCS=$(ps aux)
		if [[ $(echo -e "$ALL_PROCS" | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]]; then 
			break
		fi

		Char="${array_chars[$num_char]}"		
		echo -ne "Aguardando processo com pid [$Pid] finalizar [${Char}]\r" # $(date +%H:%M:%S)
		sleep 0.15
		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	echo -e "Aguardando processo com pid [$Pid] ${CYellow}finalizado${CReset} [${Char}]"	
}

