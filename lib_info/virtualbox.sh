#!/usr/bin/env bash
#
#

setDirsRoot

INSTALLATION_TYPE='root'
APP_NAME='virtualbox'
DESTINATION_DIR="${DIR_OPTIONAL}"/VirtualBox
PKG_FILE=$(getCachePkgs)/VirtualBox-6.1.34-150636-Linux_amd64.run

APP_VERSION='6.1'
PKG_URL='https://download.virtualbox.org/virtualbox/6.1.34/VirtualBox-6.1.34-150636-Linux_amd64.run'

ONLINE_SIZE=''

HASH_TYPE='sha256'
HASH_VALUE='1e47ac7b0b71bc29aa6fe880f85f300fa7b2c921b01fda1de56144db13703a48'

URL_EXTENSION_PACK='https://download.virtualbox.org/virtualbox/6.1.34/Oracle_VM_VirtualBox_Extension_Pack-6.1.34.vbox-extpack'
PKG_VBOX_EXT_PACK=$(getCachePkgs)/Oracle_VM_VirtualBox_Extension_Pack-6.1.34.vbox-extpack



#===================================================================#
# INFO 
#===================================================================#

function _setValuesLinuxMint()
{
    # https://www.virtualbox.org/download/hashes/6.1.34/SHA256SUMS
    #
    #
    #

    if [[ $ID_LIKE == 'debian' ]]; then # LinuxMint Debian Edition  
        if [[ "$VERSION_ID" == 4 ]]; then # LinuxMint 4 - debbie
            PKG_URL='https://download.virtualbox.org/virtualbox/6.1.34/virtualbox-6.1_6.1.34-150636~Debian~buster_amd64.deb' 
            PKG_FILE=$(getCachePkgs)/virtualbox-6.1_6.1.34-150636~Debian~buster_amd64.deb
            HASH_VALUE='55c8bbdab804ef522975b9d1d3db58d9dc3955b0b443cfa4a2e634e596dcf049'
        elif [[ "$VERSION_ID" == 5 ]]; then # LinuxMint 4 - debbie
            PKG_URL='https://download.virtualbox.org/virtualbox/6.1.34/virtualbox-6.1_6.1.34-150636.1~Debian~bullseye_amd64.deb' 
            PKG_FILE=$(getCachePkgs)/virtualbox-6.1_6.1.34-150636.1~Debian~bullseye_amd64.deb
            HASH_VALUE='61b77e533e7ddc49571ec885f392c964b233b3d2b682965f8979df22982afbfa'
        fi  
    elif [[ $ID_LIKE == 'ubuntu' ]]; then # LinuxMint Ubuntu Base
        echo 'Falta código para LinuxMint base Ubuntu'
        sleep 1
    fi  

}

function _setValuesDebian()
{
    if [[ "$VERSION_ID" == 11 ]]; then ## Debian 10 Buster
        PKG_URL='https://download.virtualbox.org/virtualbox/6.1.34/virtualbox-6.1_6.1.34-150636.1~Debian~bullseye_amd64.deb' 
        PKG_FILE=$(getCachePkgs)/virtualbox-6.1_6.1.34-150636.1~Debian~bullseye_amd64.deb
        HASH_VALUE='61b77e533e7ddc49571ec885f392c964b233b3d2b682965f8979df22982afbfa'
    elif [[ "$VERSION_ID" == 10 ]]; then ## Debian 10 Buster
        PKG_URL='https://download.virtualbox.org/virtualbox/6.1.34/virtualbox-6.1_6.1.34-150636~Debian~buster_amd64.deb' 
        PKG_FILE=$(getCachePkgs)/virtualbox-6.1_6.1.34-150636~Debian~buster_amd64.deb
        HASH_VALUE='55c8bbdab804ef522975b9d1d3db58d9dc3955b0b443cfa4a2e634e596dcf049'
    elif [[ "$VERSION_ID" == 9 ]]; then ## Debian 9
        PKG_URL='https://download.virtualbox.org/virtualbox/6.1.34/virtualbox-6.1_6.1.34-150636.1~Debian~stretch_amd64.deb' 
        PKG_FILE=$(getCachePkgs)/virtualbox-6.1_6.1.34-150636.1~Debian~stretch_amd64.deb
        HASH_VALUE='7738ab90c0aeba95e1e7acfdda027c8a10983ecf0ce2874126133a9434a8a4d9'
    else
        echo '_setValuesDebian ... Sistema não suportado'
    fi 
     
}


function setValues()
{
    case "$ID" in
        debian) _setValuesDebian;;
        linuxmint) _setValuesLinuxMint;;
        *) install_vbox_generic;;
    esac
}

#===================================================================#
# UNINSTALL
#===================================================================#

function _uninstall_virtualbox_debian()
{
    runApt remove virtualbox-6.1
}


function __uninstall_virtualbox()
{
    green "Desinstalando ... $APP_NAME"
    if [[ -f /etc/debian_version ]]; then 
        _uninstall_virtualbox_debian 
    else
        printErro "Seu sistema não é suportado."
        return 1
    fi    
}


#===================================================================#
# VBOX EXT PACK
#===================================================================#


install_vbox_ext_pack()
{
    # Após instalar o virtualbox no sistema, devemos executar esta
    # função para instalar o pacote extensionpack (em qualquer distro)
    # uma vez que está função funciona da mesma maneira em qualquer 
    # distribuição linux. 
    #   Baixa o pacote (extensionpack) e instala usando o virtualbox
    # e adiciona o usuário atual no grupo  vboxuser.
    #

    isExecutable virtualbox || {
        printErro "Instale o virtualbox para prosseguir."
        return 1
    }


    local HASH_VALUE_EXT_PACK='d7856f0688b6d2ed1e8bff0b367efa952068b03fa5a3a29b46db08cfd5d9a810'

    checkSha256 $PKG_VBOX_EXT_PACK $HASH_VALUE_EXT_PACK || return 1
    sudoCommand VBoxManage extpack install --replace "$PKG_VBOX_EXT_PACK"
    printLine '='
    question "Deseja adicionar $(whoami) ao grupo ${CGreen}vboxusers${CReset}" || return 1 
    sudoCommand usermod -a -G vboxusers $(whoami)  
    printLine '~'
}



config_vbox_drv()
{
    # https://sempreupdate.com.br/como-instalar-o-virtualbox-no-arch-linux/
    # https://wiki.archlinux.org/index.php/VirtualBox_(Portugu%C3%AAs)
    # https://www.virtualbox.org/wiki/Linux_Downloads
    # https://www.edivaldobrito.com.br/sbinvboxconfig-nao-esta-funcionando/

    printInfo "Configurando vboxdrv"
    sudoCommand /sbin/rcvboxdrv setup
    sudoCommand /sbin/vboxconfig
    sudoCommand modprobe vboxdrv

    # Configuração para carregar o módulo durante o boot.
    # sudo echo vboxdrv >> /etc/modules-load.d/virtualbox.conf

}


#===================================================================#
# INSTALL
#===================================================================#

function _install_virtualbox_debfile()
{
    # sudo apt install build-essential module-assistant
    # sudo apt install linux-headers-$(uname -r)
    # sudo apt install libsdl-ttf2.0-0 dkms
    #


    # Verificar integridade do arquivo
    checkSha256 $PKG_FILE $HASH_VALUE || return $?

    # runApt faz parte do pacote shell-libs no arquivo apt-bash.sh
    runApt update
    runApt install build-essential module-assistant linux-headers-$(uname -r)
    runApt install $PKG_FILE
}



install_vbox_generic()
{
    # Virtualbox para qualquer Linux.
    # Encontar os urls de downloads do executável .run (dor virtualbox)
    # e o arquivo que contém as hashs sha256 para cada versão do virtualbox
    #
    # O download do arquivo contendo as hashs e semelhante ao comando
    # abixo, ATENÇÃO a mudança de versão do virtualbox (6.x)
    # wget https://www.virtualbox.org/download/hashes/6.1.6/SHA256SUMS
    #
    # https://download.virtualbox.org/virtualbox/6.1.6/VirtualBox-6.1.6-137129-Linux_amd64.run
    #
    # sudo /etc/init.d/vboxdrv setup
    # sudo /sbin/vboxconfig
    # sudo /sbin/rcvboxdrv setup
    #

    checkSha256 $PKG_FILE $HASH_VALUE || return $?
    chmod +x "$PKG_FILE"
    sudoCommand "$PKG_FILE"

    config_vbox_drv
        
}


function __install_virtualbox()
{
    # https://www.virtualbox.org/wiki/Linux_Downloads
    #
    
    if [[ -f /etc/debian_version ]]; then
        _install_virtualbox_debfile
        
    else
        install_vbox_generic
    fi

    install_vbox_ext_pack
}


function main()
{
    setValues

    if [[ $1 == 'uninstall' ]]; then
        __uninstall_virtualbox
    elif [[ $1 == 'install' ]]; then
        __install_virtualbox
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return $?
        download $URL_EXTENSION_PACK $PKG_VBOX_EXT_PACK || return $?
    elif [[ $1 == 'installed' ]]; then
        isExecutable virtualbox || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}