#!/usr/bin/env bash
#
#
#

KERNEL_TYPE=$(uname -s)

[[ -f /etc/os-release ]] && source /etc/os-release


function getDistroVersion() # -> number
{
    # Obter o número de versão da distro Linux
    grep 'VERSION_ID=' /etc/os-release | sed 's/VERSION_ID=//g;s/"//g'
}
