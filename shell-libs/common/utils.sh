#!/usr/bin/env bash
#
#
# - REQ-LIB = print_text
#
# + REQ-SYSTEM = awk
#

question()
{
	# Indagar o usuário com uma pergunta em que a resposta deve ser do tipo SIM ou NÃO (s/n)
	# esta função automatiza as indagações.
	#
	#   se o usuário teclar "s|S" -----------------> retornar 0  
	#   se o usuário teclar "n|N" ou nada ---------> retornar 1
	#
	# $1 = Mensagem a ser exibida para o usuário, a resposta deve ser SIM ou NÃO (s/n).
    # o tempo de espera pela resposta é de 15s.
	#
    # O usuário NÃO será indagado, caso a variável $AssumeYes tiver valor igual "True".
    # nesse caso essa função SEMPRE irá retornar 0, sem perguntar nada.

	[[ "$AssumeYes" == 'True' ]] && return 0
		
	echo -ne "$@ ${CGreen}s${CReset}/${CRed}N${CReset}?: "
	read -t 15 -n 1 yesno
	echo ' '

	case "${yesno,,}" in
		s|y) return 0;;
		*) printf "${CRed}Abortando${CReset}\n"; return 1;;
	esac
}

loopPid()
{
    # arg 1 = int - deve ser um pid em execução.
    # arg 2 = string - texto a ser exibido no terminal em quanto o processe estiver em execução.
    # type arg 1 = int
    # type arg 2 = string/text
    #
	# Função para executar um loop enquanto determinado processo (PID) do sistema está em 
    # execução. Por exemplo um outro processo de instalação de pacotes, como o "apt install" ou 
    # "pacman install" por exemplo, o pid deve ser passado como argumento $1 da função. Enquanto 
    # esse processo existir o loop irá bloquar a execução deste script, que será retomada assim que o
	# processo informado for encerrado.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"
	local MensageText=''

	[[ $2 ]] && MensageText="$2"
    
    # Preencher a linha atual com espaços em branco.
	echo -ne "$(printf "%-$(tput cols)s" | tr ' ' ' ')\r" 

	while true; do
        # Todos os processos em execução no sistema.
		ALL_PROCS=$(ps aux) 

        # Verificar se o processo passado em $1 está em execução no sistema.
		[[ $(echo -e "$ALL_PROCS" | grep -m 1 "$Pid" | awk '{print $2}') != "$Pid" ]] && break
		
		Char="${array_chars[$num_char]}"		
		echo -ne "$MensageText ${CYellow}[${Char}]${CReset}\r" # $(date +%H:%M:%S)
		sleep 0.15
		
		num_char="$(($num_char+1))"
		[[ "$num_char" == '4' ]] && num_char='0'
	done
	#echo -e "$MensageText [${Char}] OK"
	echo -e "$MensageText [${Char}] "	
}

waitPid()
{
    # arg 1 = int - PID do sistema.
    # type arg 1 = int
	# Função semelhante a "loop_pid", porém nessa função NÃO é permitido exibir uma mensagem personalizada.
	# impede a execução de código enquanto determinado PID estiver em execução.
	local array_chars=('\' '|' '/' '-')
	local num_char='0'
	local Pid="$1"

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

