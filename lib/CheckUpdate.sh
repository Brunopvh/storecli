#!/usr/bin/env bash
#
# Este módulo serve para verificar e instalar atualizações do script storecli
#

function _install_update_storecli()
{
	# sh -c "$(curl -fsSL https://raw.github.com/Brunopvh/storecli/master/setup.sh)"
	_ping || return 1
	"$Script_Setup_Storecli" || return 1
	return 0
}

function _check_update_storecli()
{
	# Esta função deve procurar por atualizações.
	local url_storecli='https://raw.github.com/Brunopvh/storecli/master/storecli.sh'
	local file_storecli_version="$Dir_Downloads/storecli.sh"

	# dia atual                      	
	day=$(date +%d)

	# dia em que a ultima busca por atualizaçãoes por executada.
	day_update=$(grep -m 1 "day_update" "$Config_File" | cut -d' ' -f 2 2> /dev/null)

	if [[ "$day" == "$day_update" ]]; then
		return 0
	elif [[ -f "$file_storecli_version" ]]; then
		rm "$file_storecli_version"
	fi  


	white "Procurando por atualização no github aguarde"

	# Baixar o arquivo principal que contém a ultima versão do github.
	if ! curl -fsSL "$url_storecli" -o "$file_storecli_version"; then
		red "Falha ao buscar atualização"
		return 1
	fi

	# Procurar a versão do github no arquivo baixado.
	new_version=$(grep -m 1 ^'VERSION=' "$file_storecli_version" | sed "s/VERSION=//g;s/'//g")
	
	# Comparar veresão atual com a versão do programa no github.
	white "Versão local ${Green}$VERSION${Reset} versão do github ${Yellow}$new_version${Reset}"
	if [[ "$VERSION" == "$new_version" ]]; then
		white "Não existem atualizações disponíveis"
		# Deletar linha que contém o dia da ultima verificação.
		sed -i '/^day_update/d' "$Config_File"
		
		# Gravar o dia atual no arquivo de configuração para indicar
		# que a busca por atualização foi executada hoje.
		echo -e "day_update $day" >> "$Config_File"
		return 1
	else
		white "Nova versão disponível"
	fi

	
	_install_update_storecli || return 1
	
	# Deletar linha que contém o dia da ultima verificação.
	sed -i '/^day_update/d' "$Config_File"

	# Gravar o dia atual no arquivo de configuração para indicar
	# que a busca por atualização foi executada hoje.
	echo -e "day_update $day" >> "$Config_File"
}
