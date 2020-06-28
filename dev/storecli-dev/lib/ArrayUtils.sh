#!/usr/bin/env bash
#


# Etcher
declare -A destinationFilesEtcher
destinationFilesEtcher=(
	[file_desktop]="$directoryUSERapplications/balena-etcher-electron.desktop"
	[file_appimage]="$directoryUSERbin/balena-etcher-electron"
	)