#!/usr/bin/env bash
#
#

#setDirsRoot
setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='freetube'
DESTINATION_DIR="${DIR_OPTIONAL}"/freetube
BIN_FILE="${DESTINATION_DIR}"/freetube.AppImage
ICON_FILE="${DIR_HICOLOR}"/256x256/apps/freetube.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/freetube.desktop
SCRIPT_FILE="${DIR_BIN}"/freetube
LINK_FILE=None

APP_VERSION='0.12'
PKG_FILE="$(getCachePkgs)"/freetube-0.12.AppImage
PKG_ICON_CACHE="$(getCachePkgs)"/freetube.png

PKG_URL='https://github.com/FreeTubeApp/FreeTube/releases/download/v0.12.0-beta/freetube_0.12.0_amd64.AppImage'
ICON_URL=''

ONLINE_SIZE=''
HASH_TYPE='sha256'
HASH_VALUE='aa3902a7c9677b8b0a0f189536a8a39de0644c6fcd8d543fcf5a69ae43652e94'


function __uninstall_freetube()
{
	green "Desinstalando ... $APP_NAME"
    rm -rf $DESTINATION_DIR
    # rm -rf $ICON_FILE
    rm -rf $DESKTOP_FILE 
    rm -rf $SCRIPT_FILE
    return 0
}


function _createFreetubeDesktopFile()
{

    echo '[Desktop Entry]' > "$DESKTOP_FILE"
    {
        echo "Name=FreeTube"
        echo "Exec=freetube"
        echo "Version=1.0"
        echo -e "Icon=$ICON_FILE"
        echo "Terminal=false"
        echo "Type=Application"
        echo "Categories=Network;"
    } >> "$DESKTOP_FILE"

    addFileInDesktopDir "$DESKTOP_FILE"
}

function __install_freetube_appimage()
{
    # https://github.com/FreeTubeApp/FreeTube/releases/tag/v0.12.0-beta
    # https://github.com/FreeTubeApp/FreeTube/releases/download/v0.12.0-beta/freetube_0.12.0_amd64.AppImage
    
    isRoot && {
        printErro "Você não pode ser o root."
        return 1
    }

	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi
    
    checkSha256 $PKG_FILE $HASH_VALUE || return $?

    local _tmp_file=$(mktemp)    
    mkdir -p "$DESTINATION_DIR"
    mkdir -p "${DIR_HICOLOR}"/256x256/apps

    green "Copiando arquivos"
    cp -u "$PKG_FILE" "$BIN_FILE"
    cp -u "${dir_of_project}"/data/icons/freetube.png "${ICON_FILE}"
    
    echo '#!/usr/bin/env bash' > $SCRIPT_FILE

    {
        echo -e "\ncd $DESTINATION_DIR"
        echo -e "$BIN_FILE --no-sandbox"
    } >> $SCRIPT_FILE


    chmod +x $SCRIPT_FILE
    chmod +x "$BIN_FILE"
    _createFreetubeDesktopFile
    rm -rf $_tmp_file
    return 0
}




function __install_freetube()
{
    __install_freetube_appimage
}

function main()
{
	
	if [[ $1 == 'uninstall' ]]; then
        __uninstall_freetube
    elif [[ $1 == 'install' ]]; then
        __install_freetube
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return 1
        #download $ICON_URL $PKG_ICON_CACHE || return 1
    elif [[ $1 == 'install' ]]; then
        isExecutable freetube || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}


# main $@
