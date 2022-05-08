#!/usr/bin/env bash
#
#


function _conf_ubuntu(){
    _conf_debian

}


function _conf_debian(){
    runApt update
    runApt install curl xterm unzip gawk
}


function _conf_fedora(){
    echo
}






function InstallSysRequeriments(){
   
    if isLinuxmintDebianEdition; then
        _conf_debian
    elif isLinuxmint || isUbuntu; then
        _conf_ubuntu
    else
        return 1
    fi
   

   return 1
}
