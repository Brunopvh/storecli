#!/usr/bin/env bash
#
#

setDirsUser

INSTALLATION_TYPE='root'
APP_NAME='vscode'
DESTINATION_DIR="${DIR_OPTIONAL}"/vscode-x64
ICON_FILE="${DIR_HICOLOR}"/128x128/apps/vscode.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/vscode.desktop
PKG_FILE="$(getCachePkgs)"/vscode.tar.gz
SCRIPT_FILE="${DIR_BIN}"/code
BIN_FILE="${DESTINATION_DIR}"/bin/code

#LINK_FILE="${DIR_BIN}"/vscode
APP_VERSION='1.0'
PKG_URL='https://update.code.visualstudio.com/latest/linux-x64/stable'
ONLINE_SIZE=''

HASH_TYPE='sha256'
HASH_VALUE=''



function createDirsCode()
{
	[[ $(id -u) == 0 ]] && return
	mkdir -p "${DIR_HICOLOR}"/128x128/apps
    mkdir -p ~/.local/bin
    mkdir -p ~/.local/opt    
    mkdir -p $DESTINATION_DIR
}


function __uninstall_vscode()
{
	green "Desinstalando ... $APP_NAME"

    if [[ -f /etc/debian_version ]]; then
        runApt remove code
    else
        rm -rf $DESTINATION_DIR
        rm -rf $ICON_FILE
        rm -rf $DESKTOP_FILE
        rm -rf $SCRIPT_FILE
    fi
    return 0
}


function add_desktop_entry_vscode(){
    #
    local _tmp_file=$(mktemp)

    echo '[Desktop Entry]' > $_tmp_file

    {
        echo -e "Version=$APP_VERSION";
        echo -e "Type=Application";
        echo -e "Name=Code";
        echo -e "GenericName=Text Editor";
        echo -e "Comment=code";
        echo -e "Exec=$BIN_FILE";
        echo -e "Terminal=false";
        echo -e "MimeType=text/plain;";
        echo -e "Icon=$ICON_FILE";
        echo -e "Categories=TextEditor;Development;";
        echo -e "StartupNotify=true";
        #echo -e "Actions=new-window;new-file;";

    } >> $_tmp_file

    cp -u $_tmp_file "$DESKTOP_FILE"
    chmod +x "$DESKTOP_FILE"
    rm $_tmp_file
}


function __install_vscode_tarfile()
{
	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi

    #checkSha256 $PKG_FILE $HASH_VALUE || return $?

    local _tmp_dir=$(mktemp -d)
    local _tmp_file=$(mktemp)
    
    #             Arquivo    Destion da descompressão.
    unpackArchive $PKG_FILE $_tmp_dir || return $?
    green "Entrando no diretório ... $_tmp_dir"
    cd $_tmp_dir || return 1
    #mv $(ls -d *Code*) code
    cd VSCode-linux-x64
    
    green "Copiando arquivos"
    createDirsCode
    cp -R -u . "${DESTINATION_DIR}"/.
    cp -u ./resources/app/resources/linux/code.png $ICON_FILE
    chmod +x "${BIN_FILE}"

    green "Configurando ... $APP_NAME"

    echo '#!/usr/bin/env bash' > $SCRIPT_FILE
    {
        echo -e "\ncd ${DESTINATION_DIR}/bin \n"
        echo -e "./code $@"
    } >> $SCRIPT_FILE

    chmod +x $SCRIPT_FILE
    add_desktop_entry_vscode
    addFileInDesktopDir "$DESKTOP_FILE"
    
    rm -rf $_tmp_dir
    rm -rf $_tmp_file
    return 0
}


function __install_vscode_debfile(){
    #
    runApt install $PKG_FILE
}




function installVsCode()
{

    if [[ -f /etc/debian_version ]]; then
        __install_vscode_debfile
    else
	   __install_vscode_tarfile
    fi

}

function setValues(){

    if [[ -f /etc/debian_version ]]; then
        PKG_FILE=$(getCachePkgs)/'vscode-amd64.deb'
        PKG_URL='https://update.code.visualstudio.com/latest/linux-deb-x64/stable'
    fi

}

function main()
{
    setValues

	if [[ $1 == 'uninstall' ]]; then
       __uninstall_vscode 
    elif [[ $1 == 'install' ]]; then
        installVsCode
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return $?
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}
