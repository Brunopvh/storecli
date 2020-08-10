#!/usr/bin/env bash
#

__wget__()
{
	# Função para baixar arquivos usando a ferramenta 'wget'.
	# $1 = url
	# $2 = arquivo (opcional)
	# __wget url file
	#
	[[ -z "$DirDownloads" ]] && DirDownloads=$(pwd)
	url="$1"
	wgetLogfile="$DirDownloads/wget-log"
	chars=('\' '|' '/' '-')
	num='0'

	if [[ -z $1 ]]; then
		echo -e "(__wget__) informe um URL"
		return 1
	fi
	
	cd "$DirDownloads"
	#[[ -z $(pidof wget) ]] || kill -9 $(pidof wget)
	[[ -f "$wgetLogfile" ]] && rm "$wgetLogfile"
	
	echo -e "Conectando: $url"
	if [[ -z $2 ]]; then 
		wget -b -c "$url" > /dev/null || echo -e "(__wget__) falha"
	elif [[ $2 ]]; then
		path_file="$2"
		echo -e "Destino: $path_file"
		wget -b "$url" -O "$path_file" > /dev/null || echo -e "(__wget__) falha"
	fi
		
	PidWget=$(pidof wget)

	while true; do
		line_progress=$(grep '%' "$wgetLogfile" | tail -n 3 | sed -n 1p)
		current_rec=$(echo "$line_progress" | awk '{print $1}')
		current_prog=$(echo "$line_progress" | awk '{print $7}' | sed 's/\%//g')
		current_speed=$(echo "$line_progress" | awk '{print $8}')
		current_ETA=$(echo "$line_progress" | awk '{print $9}')
		
		show_prog=$(printf '%10s%%\n' "Prog[$current_prog]")
		show_rec=$(printf '%14s\n' "Rec[$current_rec]")
		show_speed=$(printf '%12s' "Vel[$current_speed]")
		show_eta="$(printf '%13s\n' "ETA[$current_ETA]")"
		
		[[ ! -z $current_prog ]] && ProgressInfo="$show_rec $show_speed $show_prog $show_eta (${chars[$num]})"

		if [[ -z $current_rec ]]; then
			echo -ne "Baixando: aguarde (${chars[$num]})" "\r"
		elif [[ ! -z $show_prog ]]; then
			echo -ne "Baixando: $ProgressInfo" "\r"
		fi
		
		sleep 0.1
		PidWget=$(pidof wget)

		if [[ -z "$PidWget" ]] || [[ $(grep '100%' "$wgetLogfile" 1> /dev/null) ]]; then
			if [[ -z $ProgressInfo ]]; then
				echo -e "Baixando: aguarde OK"
				break
			elif [[ ! -z $ProgressInfo ]]; then
				echo -e "$ProgressInfo OK"
				break
			fi
		fi
		
		num="$(($num+1))"
		[[ "$num" == '4' ]] && num='0'
	done
	return 0
}



