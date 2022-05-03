#!/usr/bin/env bash
#
# 
# Esse arquivo inicializa variáveis, e o core de funções shell-libs
# 
#
#

#__file_init__=$(readlink -f "$0")
#__dir_of_project__=$(dirname $__file_init__)

[[ -z $SHELL_LIBS ]] && {
	echo "ERRO ... diretório SHELL_LIBS não encontrado."
	exit 1
}


SHELL_DEVICE_FILE="/tmp/$(whoami)/device.txt"
SHELL_STATUS_FILE="/tmp/$(whoami)/status.txt"
export STATUS_OUTPUT=0


mkdir -p /tmp/$(whoami)
touch $SHELL_DEVICE_FILE
touch $SHELL_STATUS_FILE


source ~/.bashrc

[[ -z $HOME ]] && HOME=~/

# Inserir ~/.local/bin em PATH se não existir.
echo "$PATH" | grep -q "$HOME/.local/bin" || {
	export PATH="$HOME/.local/bin:$PATH"
}


export readonly LIB_COLORS="${SHELL_LIBS}/common/colors.sh"
export readonly LIB_PRINT_TEXT="${SHELL_LIBS}/common/print_text.sh"
export readonly LIB_STRING="${SHELL_LIBS}/common/string.sh"
export readonly LIB_UTILS="${SHELL_LIBS}/common/utils.sh"
export readonly LIB_SYSTEM="${SHELL_LIBS}/system/sys.sh"
export readonly LIB_PLATFORM="${SHELL_LIBS}/system/platform.sh"
export readonly LIB_APP_DIRS="${SHELL_LIBS}/system/appdirs.sh"
export readonly LIB_REQUESTS="${SHELL_LIBS}/request/requests.sh"
export readonly LIB_APT_BASH="${SHELL_LIBS}/system/apt-bash.sh"
export readonly LIB_CRIPTO="${SHELL_LIBS}/system/crypto.sh"

# Importar módulos common
if [[ -f "${LIB_COLORS}" ]]; then source "${LIB_COLORS}"; else echo -e "Não encontrado ..." "${LIB_COLORS}"; fi
if [[ -f "${LIB_PRINT_TEXT}" ]]; then source "${LIB_PRINT_TEXT}"; else echo -e "Não encontrado ..." "${LIB_PRINT_TEXT}"; fi
if [[ -f "${LIB_STRING}" ]]; then source "${LIB_STRING}"; else echo -e "Não encontrado ..." "${LIB_STRING}"; fi
if [[ -f "${LIB_UTILS}" ]]; then source "${LIB_UTILS}"; else echo -e "Não encontrado ..." "${LIB_UTILS}"; fi

# Importar módulos system
if [[ -f "${LIB_SYSTEM}" ]]; then source "${LIB_SYSTEM}"; else echo -e "Não encontrado ..." "${LIB_SYSTEM}"; fi
if [[ -f "${LIB_PLATFORM}" ]]; then source "${LIB_PLATFORM}"; else echo -e "Não encontrado ..." "${LIB_PLATFORM}"; fi
if [[ -f "${LIB_APP_DIRS}" ]]; then source "${LIB_APP_DIRS}"; else echo -e "Não encontrado ..." "${LIB_APP_DIRS}"; fi
if [[ -f "${LIB_APT_BASH}" ]]; then source "${LIB_APT_BASH}"; else echo -e "Não encontrado ..." "${LIB_APT_BASH}"; fi
if [[ -f "${LIB_CRIPTO}" ]]; then source "${LIB_CRIPTO}"; else echo -e "Não encontrado ..." "${LIB_CRIPTO}"; fi

# Importar módulos request
if [[ -f "${LIB_REQUESTS}" ]]; then source "${LIB_REQUESTS}"; else echo -e "Não encontrado ..." "${LIB_REQUESTS}"; fi







