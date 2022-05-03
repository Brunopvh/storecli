#!/usr/bin/env bash
#
#

setDirsRoot


INSTALLATION_TYPE='root'
APP_NAME='sublime-text'
DESTINATION_DIR="${DIR_OPTIONAL}"/sublime_text
ICON_FILE="${DIR_HICOLOR}"/256x256/apps/sublime-text.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/sublime_text.desktop
PKG_FILE="$(getCachePkgs)"/sublime_text_build_4126_x64.tar.xz
SCRIPT_FILE="${DIR_BIN}"/sublime-text

LINK_FILE=None
APP_VERSION='4126'
PKG_URL='https://download.sublimetext.com/sublime_text_build_4126_x64.tar.xz'
ONLINE_SIZE='17.3M'

HASH_TYPE='sha256'
HASH_VALUE='5c64e534cce0032e54d3c7028e8d6b3bdef28f3fd28a26244a360a2ce75450a1'



function createSublimeTextDirIcon()
{
	[[ $(id -u) == 0 ]] && return
	mkdir -p "${DIR_HICOLOR}"/128x128/apps
}


function __uninstall_sublime_text()
{
	green "Desinstalando ... $APP_NAME"
    sudoCommand rm -rf $DESTINATION_DIR
    sudoCommand rm -rf $ICON_FILE
    sudoCommand rm -rf $DESKTOP_FILE
    sudoCommand rm -rf $SCRIPT_FILE
    return 0
}


function add_desktop_entry_sublime(){
    #
    local _tmp_file=$(mktemp)


    echo '[Desktop Entry]' > $_tmp_file

    {
        echo -e "Version=$APP_VERSION";
        echo -e "Type=Application";
        echo -e "Name=Sublime Text";
        echo -e "GenericName=Text Editor";
        echo -e "Comment=Sophisticated text editor for code, markup and prose";
        echo -e "Exec=/opt/sublime_text/sublime_text";
        echo -e "Terminal=false";
        echo -e "MimeType=text/plain;";
        echo -e "Icon=$ICON_FILE";
        echo -e "Categories=TextEditor;Development;";
        echo -e "StartupNotify=true";
        echo -e "Actions=new-window;new-file;";

        echo -e "[Desktop Action new-window]";
        echo -e "Name=New Window";
        echo -e "Exec=/opt/sublime_text/sublime_text --launch-or-new-window";
        echo -e "OnlyShowIn=Unity;";

        echo -e "[Desktop Action new-file]";
        echo -e "Name=New File";
        echo -e "Exec=/opt/sublime_text/sublime_text --command new_file";
        echo -e "OnlyShowIn=Unity;";
    } >> $_tmp_file


    sudoCommand cp -u $_tmp_file "$DESKTOP_FILE"
    sudoCommand chmod +x "$DESKTOP_FILE"
    sudo rm $_tmp_file

}

function __install_sublime_text_tarfile()
{
	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi

    checkSha256 $PKG_FILE $HASH_VALUE || return $?
    local _tmp_dir=$(mktemp -d)
    local _tmp_file=$(mktemp)
    
    #             Arquivo    Destion da descompressão.
    unpackArchive $PKG_FILE $_tmp_dir || return $?
    green "Entrando no diretório ... $_tmp_dir"
    cd $_tmp_dir || return 1

    green "Copiando arquivos"
    sleep 0.3
    sudoCommand cp -R ./sublime_text "${DESTINATION_DIR}"
    #sudoCommand cp -u ./sublime_text/sublime_text.desktop "${DESKTOP_FILE}"

    green "Configurando ... $APP_NAME"

    add_desktop_entry_sublime  
    sudoCommand chmod 755 "${DESKTOP_FILE}"
    sudoCommand chmod +x "${DESTINATION_DIR}"/sublime_text
    sudoCommand cp -u sublime_text/Icon/256x256/sublime-text.png "${ICON_FILE}"
    sudoCommand cp -u sublime_text/Icon/128x128/sublime-text.png /usr/share/icons/hicolor/128x128/apps/sublime-text.png
    sudoCommand cp -u sublime_text/Icon/48x48/sublime-text.png /usr/share/icons/hicolor/48x48/apps/sublime-text.png
    sudoCommand cp -u sublime_text/Icon/32x32/sublime-text.png /usr/share/icons/hicolor/32x32/apps/sublime-text.png
    sudoCommand cp -u sublime_text/Icon/16x16/sublime-text.png /usr/share/icons/hicolor/16x16/apps/sublime-text.png

    addFileInDesktopDir "$DESKTOP_FILE"
    
    # Criar script para linha de commando.
    echo -e "${DESTINATION_DIR}/sublime_text $@" > $_tmp_file
    sudoCommand cp -u $_tmp_file "$SCRIPT_FILE"
    sudoCommand chmod 755 /usr/local/bin/sublime-text
    
    rm -rf $_tmp_dir
    rm -rf $_tmp_file
    return 0
}

function _installSublimeText()
{
	__install_sublime_text_tarfile
}

function main()
{
	if [[ $1 == 'uninstall' ]]; then
       __uninstall_sublime_text 
    elif [[ $1 == 'install' ]]; then
        _installSublimeText
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return $?
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return 0
}
