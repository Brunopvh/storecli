#!/usr/bin/env bash
#
# Checar todas as requerimentos de sistema
#

req_cli=(
    curl
    awk
    python3
    xterm
    unzip
)


function command_exists() {
  command -v "$@" >/dev/null 2>&1
}


function checkReq(){
    for cmd in "${req_cli[@]}"; do
        command_exists "$cmd" || { 
            echo -e " ! NOT FOUND ... $cmd"
            return 1
            break 
            }
    done
    

}


checkReq || exit 1
exit 0
