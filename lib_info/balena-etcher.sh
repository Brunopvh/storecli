#!/usr/bin/env bash
#
#

#setDirsRoot
setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='balena-etcher'
DESTINATION_DIR="${DIR_OPTIONAL}"/balenaEtcher
ICON_FILE="${DIR_HICOLOR}"/128x128/apps/etcher.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/balena-etcher.desktop
SCRIPT_FILE="${DIR_BIN}"/balena-etcher
LINK_FILE=None
APP_VERSION='1.6'

PKG_FILE="$(getCachePkgs)"/balenaEtcher-1.6.0-x64.AppImage
PKG_ICON_CACHE="$(getCachePkgs)"/balena-etcher.png

PKG_URL='https://github.com/balena-io/etcher/releases/download/v1.6.0/balenaEtcher-1.6.0-x64.AppImage'
ICON_URL='https://raw.github.com/balena-io/etcher/master/assets/icon.png'

ONLINE_SIZE='None'
HASH_TYPE='sha512'
HASH_VALUE='1497ba78fa454bd556ee212bb3e1ef9dbb47fe799099da96326ddd2e3eb06096e7564b3d7c55ce8a3e973cdae4dea8f7c2620b71850115b2f2c7e8485ee29b00'


function __uninstall_etcher()
{
	green "Desinstalando ... $APP_NAME"
    rm -rf $DESTINATION_DIR
    rm -rf $ICON_FILE
    rm -rf $DESKTOP_FILE 
    rm -rf $SCRIPT_FILE
    return 0
}


function __install_etcher()
{
	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi
    
    checkSha512 $PKG_FILE $HASH_VALUE || return $?

    local _tmp_file=$(mktemp)    
    mkdir -p "$DESTINATION_DIR"
    mkdir -p "${DIR_HICOLOR}"/128x128/apps

    green "Copiando arquivos"
    cp "$PKG_FILE" $_tmp_file 
    cp $_tmp_file "${DESTINATION_DIR}/balena-etcher.AppImage"
    rm -rf $_tmp_file
    cp $PKG_ICON_CACHE $_tmp_file
    cp $_tmp_file $ICON_FILE
    rm -rf $_tmp_file

    green "Configurando $APP_NAME"

    # Criar arquivo .desktop.
    echo "[Desktop Entry]" > "$_tmp_file"
    {
        echo "Name=BalenaEtcher"
        echo "Comment=Flash OS images to SD cards and USB drives, safely and easily"
        echo "Version=$APP_VERSION"
        echo "Icon=$ICON_FILE"
        echo "Exec=$SCRIPT_FILE"
        echo "Terminal=false"
        echo "Keywords=etcher;flash;usb;"
        echo "Categories=Utility;"
        echo "Type=Application"
    } >> "$_tmp_file"

    cp -u "$_tmp_file" $DESKTOP_FILE
    chmod +x $DESKTOP_FILE
    chmod +x "$DESTINATION_DIR"/balena-etcher.AppImage
    
    echo '' > $_tmp_file
    {
        echo ""
        echo -e "${DESTINATION_DIR}/balena-etcher.AppImage --no-sandbox"
    } >> $_tmp_file

    cp -u $_tmp_file $SCRIPT_FILE
    chmod +x "$SCRIPT_FILE"
    addFileInDesktopDir "$DESKTOP_FILE"
    
    rm -rf $_tmp_file
    return 0
}

function main()
{
	
	if [[ $1 == 'uninstall' ]]; then
        __uninstall_etcher
    elif [[ $1 == 'install' ]]; then
        __install_etcher
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return 1
        download $ICON_URL $PKG_ICON_CACHE || return 1
    elif [[ $1 == 'install' ]]; then
        isExecutable balena-etcher || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}


# main $@
