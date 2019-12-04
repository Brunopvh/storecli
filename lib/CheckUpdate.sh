#!/usr/bin/env bash
#
#
#

function _chekupdate()
{

local REPO='https://github.com/Brunopvh/storecli.git'
local RAWREPO="https://raw.githubusercontent.com/Brunopvh/storecli/master/storecli.sh"

local DESTINATION="/tmp/Storecli_Up_$USER"
local DESTINATION_FILE="$DESTINATION/storecli.sh"

	mkdir -p "$DESTINATION"

	echo "==> Verificando atualização no [github] aguarde..."
	curl -# -LS "$RAWREPO" -o "$DESTINATION_FILE"

	export NEW_VERSION=$(grep 'VERSION=' "$DESTINATION_FILE" | sed "s/.*=//g;s/'//g" | awk '{print $1}')
}

#_chekupdate
