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


function isDebian(){
    
    grep -q -m 1 ^'ID=debian' /etc/os-release || return 1
    [[ -f /etc/debian_version ]] || return 1
    return 0
}




function isLinuxmint(){
    
    grep -q -m 1 ^'ID=ubuntu' /etc/os-release || return 1
    grep -q -m 1 ^'ID_LIKE=debian' /etc/os-release && return 1
    [[ -f /etc/debian_version ]] || return 1
    return 0
}




function isUbuntu(){
    
    grep -q -m 1 ^'ID=linuxmint' /etc/os-release || return 1
    [[ -f /etc/debian_version ]] || return 1
    return 0
}


function isLinuxmintDebianEdition(){
    # 
    grep -q -m 1 ^'NAME="LMDE"' /etc/os-release || return 1
    grep -q -m 1 ^'ID_LIKE=debian' /etc/os-release || return 1
    grep -q -m 1 ^'ID=linuxmint' /etc/os-release || return 1
    return 0
}