#!/usr/bin/env bash
#
# Este módulo serve para verificar e instalar atualizações do script storecli
#

function _install_update_storecli()
{
	_ping || return 1
	"$Script_Setup_Storecli" || return 1
	return 0
}

function _check_update_storecli()
{
	# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)" || return 1
	local url_storecli='https://raw.github.com/Brunopvh/storecli/master/storecli.sh'
	local storecli_temp="$dir_temp/storecli.sh"

	# Este programa deve procurar por atualizações uma vez por dia
	# sendo assim após verificar por atualizações no dia de hoje
	# esse dia sera gravado no arquivo de configuração, indicando que a buscar
	# por atualização já foi feita hoje não será gravada a data completa, apenas o
	# dia, pois assim se o dia gravado no arquivo de configuração for diferente
	# do dia de hoje, a busca por atualização deve ser executada, se o dia de
	# hoje for igual o dia da ultima verificação então esta função deve ser encerrada
	# 

	# dia de hoje - usar o sed para apagar strings e utilizar apenas números.                       
	#day=$(date | awk '{print $2}')	
	day=$(date +%d)

	# dia em que a ultima busca por atualizaçãoes por executada.
	day_update=$(grep -m 1 "day_update" "$Config_File" | cut -d' ' -f 2 2> /dev/null)

	if [[ "$day" == "$day_update" ]]; then
		return 0
	fi  

	white "Procurando por atualização no github aguarde"

	# Baixar o arquivo principal que contém a ultima versão do github.
	curl -# -fsSL "$url_storecli" -o "$dir_temp/storecli.sh" || return 1

	# Procurar a versão atual no arquivo.
	new_version=$(grep -m 1 ^'VERSION=' "$storecli_temp" | sed "s/VERSION=//g;s/'//g")
	
	# Comparar veresão atual com a versão do programa no github.
	white "Versão do github: $new_version"
	if [[ "$VERSION" == "$new_version" ]]; then
		white "Não existem atualizações disponíveis"
		# Deletar linha que contém o dia da ultima verificação.
		sed -i '/^day_update/d' "$Config_File"
		
		# Gravar o dia atual no arquivo de configuração para indicar
		# que a busca por atualização foi executada hoje.
		echo -e "day_update $day" >> "$Config_File"
		return 1
	else
		white "Versão local ${Yellow}$VERSION${Reset}"
	fi

	# Instalar nova versão
	_YESNO "Deseja baixar e instalar a atualização" || return 1
	_install_update_storecli || return 1
	
	# Deletar linha que contém o dia da ultima verificação.
	sed -i '/^day_update/d' "$Config_File"

	# Gravar o dia atual no arquivo de configuração para indicar
	# que a busca por atualização foi executada hoje.
	echo -e "day_update $day" >> "$Config_File"
}
