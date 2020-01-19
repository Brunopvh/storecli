#!/usr/bin/env bash
#
#

function _check_update()
{
	local REPO='https://github.com/Brunopvh/storecli.git'
	local RAWREPO="https://raw.githubusercontent.com/Brunopvh/storecli/master/storecli.sh"
	local DESTINATION_FILE="$dir_temp/storecli.sh"
	local dir_temp="/tmp/Update_StoreCli_$USER"
	local esp='----------------------------------------'

	[[ ! -d "$dir_temp" ]] && mkdir -p "$dir_temp"
	[[ -f "$DESTINATION_FILE" ]] && rm "$DESTINATION_FILE"

	echo "Verificando atualização no github aguarde..."
	curl -# -LS "$RAWREPO" -o "$DESTINATION_FILE"

	# Filtrar versão do arquivo baixado do github.
	NEW_VERSION=$(grep -m 1 'VERSION=' "$DESTINATION_FILE" | sed "s/.*=//g;s/'//g")	
	# Versão do arquivo programa atual.
	CURRENT_VERSION="$VERSION"

	if [[ "$CURRENT_VERSION" != "$NEW_VERSION" ]]; then
		echo "=> Nova versão disponível: $NEW_VERSION"
		return 0
	elif [[ "$CURRENT_VERSION" == "$NEW_VERSION" ]]; then
		echo "=> Nenhuma atualização disponível."
		return 1
	else
		return 1
	fi

	# Deletar linha que contém o dia da ultima verificação.
	sed -i '/^check_day/d' "$Config_File"

	# Gravar o dia atual no arquivo de configuração.
	echo -e "check_day $(date | awk '{print $3}')" >> "$Config_File"
}