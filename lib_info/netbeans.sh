#!/usr/bin/env bash
#
#
#
#setDirsRoot

setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='netbeans'
DESTINATION_DIR="${DIR_OPTIONAL}"/netbeans

BIN_FILE="${DESTINATION_DIR}"/bin/netbeans
ICON_DIR="${DIR_HICOLOR}"/32X32/apps
ICON_FILE="${ICON_DIR}"/netbeans.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/netbeans.desktop
SCRIPT_FILE="${DIR_BIN}"/netbeans
LINK_FILE=$DIR_BIN/netbeans

APP_VERSION='12.5'
PKG_FILE="$(getCachePkgs)"/netbeans-12.5-bin.zip
PKG_ICON_CACHE="$(getCachePkgs)"/netbeans.png

PKG_URL='https://archive.apache.org/dist/netbeans/netbeans/12.5/netbeans-12.5-bin.zip'
ICON_URL=''

ONLINE_SIZE=''
HASH_TYPE='sha512'
HASH_VALUE='3186f6281c7008d8a3aa2ca7df2b291c1c72b4bb82cd38ebf744c33fd477ed38b8cb859740ed27bb8c498ff3f59354a70627a6f16b775207b5cd2813ebeaa7fc'


function _uninstall_netbeans()
{
	green "Desinstalando ... $APP_NAME"
    rm -rf $DESTINATION_DIR
    rm -rf $ICON_FILE
    rm -rf $DESKTOP_FILE 
    rm -rf $SCRIPT_FILE
    rm -rf $LINK_FILE
    removeFileDesktop $DESKTOP_FILE
    return 0
}


function _createnetbeansDesktopFile()
{

    echo '[Desktop Entry]' > "$DESKTOP_FILE"
    {

        echo "Encoding=UTF-8";
        echo "Name=Apache NetBeans IDE";
        echo "Comment=The Smarter Way to Code";
        echo -e "Exec=/bin/sh ${DESTINATION_DIR}/bin/netbeans";
        echo -e "Icon=$ICON_FILE"
        echo "Categories=Application;Development;Java;IDE";
        echo "Version=$APP_VERSION";
        echo "Type=Application";
        echo "Terminal=0";

    } >> "$DESKTOP_FILE"

    addFileInDesktopDir "$DESKTOP_FILE"
}

function _install_netbeans_zip()
{
    #
    #

    isRoot && {
        printErro "Você não pode ser o root."
        return 1
    }

	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi
    
    checkSha512 $PKG_FILE $HASH_VALUE || return $?

    local _tmp_file=$(mktemp) 
    local _tmp_dir=$(mktemp -d)   
    mkdir -p "$DESTINATION_DIR"
    mkdir -p "${ICON_DIR}"

    #             Arquivo    Destion da descompressão.
    unpackArchive $PKG_FILE $_tmp_dir || return $?

    green "Entrando no diretório ... $_tmp_dir"
    cd $_tmp_dir || return 1
    cd netbeans
    

    green "Copiando arquivos"
    cp -R -u * "${DESTINATION_DIR}"/
    cp -R -u ./nb/netbeans.png "$ICON_FILE"
    chmod +x "${DESTINATION_DIR}"/bin/netbeans
    ln -sf "${DESTINATION_DIR}"/bin/netbeans $LINK_FILE

    _createnetbeansDesktopFile
    rm -rf $_tmp_file
    rm -rf $_tmp_dir
    return 0
}




function _install_netbeans()
{
    _install_netbeans_zip
}

function main()
{
	
	if [[ $1 == 'uninstall' ]]; then
        _uninstall_netbeans
    elif [[ $1 == 'install' ]]; then
        _install_netbeans
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return 1
        #download $ICON_URL $PKG_ICON_CACHE || return 1
    elif [[ $1 == 'install' ]]; then
        isExecutable netbeans || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}


# main $@
