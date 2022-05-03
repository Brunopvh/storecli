#!/usr/bin/env bash
#
#

#setDirsRoot
setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='stacer'
DESTINATION_DIR="${DIR_OPTIONAL}"/stacer-x64
BIN_FILE="${DESTINATION_DIR}"/stacer.AppImage
#ICON_FILE="${DIR_HICOLOR}"/128x128/apps/etcher.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/stacer.desktop
SCRIPT_FILE="${DIR_BIN}"/stacer
LINK_FILE=None

APP_VERSION='1.1'
PKG_FILE="$(getCachePkgs)"/Stacer-1.1.0-x64.AppImage
PKG_ICON_CACHE="$(getCachePkgs)"/stacer.png

PKG_URL='https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/Stacer-1.1.0-x64.AppImage'
ICON_URL=''

ONLINE_SIZE=''
HASH_TYPE='sha256'
HASH_VALUE='1a6a555d596ec978d54fbe1b924a4555c3a5b39b4f9bf17bc6efe31fcb178594'


function setInfo(){
	if [[ -f /etc/debian_version ]]; then
		PKG_URL='https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb'
		PKG_FILE="$(getCachePkgs)"/'stacer_1.1.0_amd64.deb'
	fi 
}


function __uninstall_stacer()
{
	green "Desinstalando ... $APP_NAME"
    rm -rf $DESTINATION_DIR
    # rm -rf $ICON_FILE
    rm -rf $DESKTOP_FILE 
    rm -rf $SCRIPT_FILE
    return 0
}


function _createStacerDesktopFile()
{

    echo '[Desktop Entry]' > "$DESKTOP_FILE"
    {
        echo "Name=Stacer"
        echo -e "Exec=$SCRIPT_FILE"
        echo "Version=$APP_VERSION"
        echo "Terminal=false"
        echo "Type=Application"
        echo "Categories=Network;"
    } >> "$DESKTOP_FILE"

    addFileInDesktopDir "$DESKTOP_FILE"
	chmod 777 "$DESKTOP_FILE"
}

function __install_stacer_appimage()
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
    #mkdir -p "${DIR_HICOLOR}"/128x128/apps

    green "Copiando arquivos"
    cp -u "$PKG_FILE" "$BIN_FILE"
    chmod +x "$BIN_FILE"


    green "Criando script ... $SCRIPT_FILE"
    echo '#!/usr/bin/env bash' > $SCRIPT_FILE

    {
        echo -e "\ncd $DESTINATION_DIR"
        echo -e "$BIN_FILE --no-sandbox"
    } >> $SCRIPT_FILE


    chmod +x $SCRIPT_FILE
    _createStacerDesktopFile
    rm -rf $_tmp_file
    return 0
}




function __install_stacer()
{
    __install_stacer_appimage
}

function main()
{
	
	if [[ $1 == 'uninstall' ]]; then
        __uninstall_stacer
    elif [[ $1 == 'install' ]]; then
        __install_stacer
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return 1
        #download $ICON_URL $PKG_ICON_CACHE || return 1
    elif [[ $1 == 'install' ]]; then
        isExecutable stacer || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}


# main $@
