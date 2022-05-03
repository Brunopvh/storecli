#!/usr/bin/env bash
#


function appInfo()
{
    #
    if [[ "${#@}" != 1 ]]; then
        printErro "Parâmetro incorreto detectado."
        return 1
    fi
    

    local app="$1"

    grep -q "$app" "${WINECLI_LIB_PATH}"/names.txt || {
        printErro "Pacote não encontrado ... $app"
        return 1
    }

    printf "%-15s" "Nome";      grep "$app" "${WINECLI_LIB_PATH}"/names.txt | cut -d '>' -f 1 | sed 's/^ //g'
    printf "%-15s" "Categoria"; grep "$app" "${WINECLI_LIB_PATH}"/names.txt | cut -d '>' -f 2 | sed 's/^ //g'
    printf "%-15s" "Info";      grep "$app" "${WINECLI_LIB_PATH}"/names.txt | cut -d '>' -f 3 | sed 's/^ //g'   
    
}


function _showAppsDevelopment()
{
    # https://www.geeksforgeeks.org/sort-command-linuxunix-examples/
    # 
    print "Desenvolvimento\n"
    grep 'Development' "${WINECLI_LIB_PATH}"/names.txt | cut -d '>' -f 1 | sort

}


function _showAppsAcessory()
{
    
    print "Acessórios\n"
    grep 'Acessory' "${WINECLI_LIB_PATH}"/names.txt | cut -d '>' -f 1 | sort

}

function showCategories()
{
    _showAppsAcessory
    _showAppsDevelopment    
}


function showInstalledApps()
{
    if ! isFile $(getDataBaseFile); then return 1; fi

    echo -e 'APPS instalados'
    echo
    grep 'True' $(getDataBaseFile) | cut -d '>' -f 1
}

function showApps()
{
    # https://terminalroot.com.br/2020/10/10-exemplos-para-voce-usar-o-sed-como-ninja.html
    # https://terminalroot.com.br/2015/07/30-exemplos-do-comando-sed-com-regex.html
    # 
    
    cut -d '>' -f 1 "${WINECLI_LIB_PATH}"/names.txt | sed "/^NOME.*/d;s/^/ /g" | sort 

}









