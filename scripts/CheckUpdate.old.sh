#!/usr/bin/env bash
#
#
#

function _chekupdate()
{

	REPO='https://github.com/Brunopvh/storecli.git'
	RAWREPO="https://raw.githubusercontent.com/Brunopvh/storecli/master/storecli.sh"

	DESTINATION="/tmp/Storecli_Up_$USER"
	DESTINATION_FILE="$DESTINATION/storecli.sh"

	mkdir -p "$DESTINATION"

	echo "==> Verificando atualização no [github] aguarde..."
	curl -# -L -S "$RAWREPO" -o "$DESTINATION_FILE"

	export NEW_VERSION=$(grep 'VERSION=' "$DESTINATION_FILE" | sed "s/.*=//g;s/'//g" | awk '{print $1}')
	#echo "Versão disponível: $NEW_VERSION"
}

_chekupdate