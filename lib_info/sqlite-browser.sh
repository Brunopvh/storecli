#!/usr/bin/env bash
#
# https://sqlitebrowser.org/dl/
#
# https://github.com/sqlitebrowser/sqlitebrowser
#

INSTALLATION_TYPE='user'
APP_NAME='sqlite-browser'
DESTINATION_DIR="${DIR_OPTIONAL}"/sqlite-browser
ICON_DIR="${DIR_HICOLOR}"/128x128/apps

ICON_FILE="${ICON_DIR}"/sqlite-browser.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/sqlite-browser.desktop
PKG_FILE="$(getCachePkgs)"/DB_Browser_for_SQLite-v3.12.2-x86_64.AppImage
SCRIPT_FILE="${DIR_BIN}"/sqlite-browser
LINK_FILE=None

APP_VERSION='3.12.2'
PKG_URL='https://download.sqlitebrowser.org/DB_Browser_for_SQLite-v3.12.2-x86_64.AppImage'
ONLINE_SIZE=''

HASH_TYPE='sha256'
HASH_VALUE=''


function _uninstall_sqlite_browser()
{
	green "Desinstalando ... $APP_NAME"
    
    if [[ -f /etc/debian_version ]]; then
        runApt remove sqlitebrowser
    else
        rm -rf $DESTINATION_DIR
        rm -rf $ICON_FILE
        rm -rf $DESKTOP_FILE 
        rm -rf $SCRIPT_FILE
    fi
    return 0
}


function _install_sqlite_browser_appimage()
{
	# Instalar o sqlite-browser.
    if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi
    
    checkSha256 $PKG_FILE $HASH_VALUE || return $?

    #local _tmp_file=$(mktemp)    
    mkdir -p "$DESTINATION_DIR"
    mkdir -p "${ICON_DIR}"

    green "Copiando arquivos"
    cp $PKG_FILE "${DESTINATION_DIR}/sqlite-browser.AppImage"
    cp "${dir_of_project}"/data/icons/sqlite-browser.png "${ICON_FILE}"
    
    green "Configurando $APP_NAME"

    # Criar arquivo .desktop.
    echo "[Desktop Entry]" > "$DESKTOP_FILE"
    {
        echo "Name=SQLite Browser"
        echo "Comment=sqlite-browser"
        echo -e "Version=$APP_VERSION"
        echo -e "Icon=$ICON_FILE"
        echo -e "Exec=$SCRIPT_FILE"
        echo "Terminal=false"
        echo "Categories=Utility;"
        echo "Type=Application"
    } >> "$DESKTOP_FILE"

    
    chmod +x $DESKTOP_FILE
    chmod +x "$DESTINATION_DIR"/sqlite-browser.AppImage
    
    echo '' > $SCRIPT_FILE
    {
        echo ""
        echo -e "${DESTINATION_DIR}/sqlite-browser.AppImage --no-sandbox"
    } >> $SCRIPT_FILE


    chmod +x "$SCRIPT_FILE"
    addFileInDesktopDir "$DESKTOP_FILE"
    return 0
	
}


function _install_sqlite_browser(){
    #

    if [[ -f /etc/debian_version ]]; then
        runApt install sqlitebrowser
    else
        _install_sqlite_browser_appimage
    fi
}


function main()
{	
	setDirsUser
	
	if [[ $1 == 'install' ]]; then
        _install_sqlite_browser
    elif [[ $1 == 'uninstall' ]]; then
        _uninstall_sqlite_browser
    elif [[ $1 == 'get' ]]; then
        #download $PKG_URL $PKG_FILE || return $?
        return 0
    elif [[ $1 == 'installed' ]]; then
        isExecutable sqlite-browser || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return $?	
}


# main $@