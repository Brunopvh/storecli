#!/usr/bin/env bash
#
# https://r6---sn-cg51pauxax-28ie.gvt1.com/edgedl/android/studio/ide-zips/2021.2.1.14/android-studio-2021.2.1.14-linux.tar.gz
# https://r6---sn-cg51pauxax-28ie.gvt1.com/edgedl/android/studio/ide-zips/2021.2.1.14/android-studio-2021.2.1.14-linux.tar.gz
#

setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='android-studio'
DESTINATION_DIR="${DIR_OPTIONAL}"/android-studio-x64

ICON_FILE="${DIR_HICOLOR}"/128x128/apps/studio.png
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/android-studio.desktop
PKG_FILE="$(getCachePkgs)"/android-studio-2021.2.1.14-linux.tar.gz
SCRIPT_FILE="${DIR_BIN}"/android-studio # DIR_BIN é fornecido por shell-libs
BIN_FILE="${DESTINATION_DIR}/android-studio"

LINK_FILE=None
APP_VERSION='2021.2'

PKG_URL='https://r6---sn-cg51pauxax-28ie.gvt1.com/edgedl/android/studio/ide-zips/2021.2.1.14/android-studio-2021.2.1.14-linux.tar.gz'
ONLINE_SIZE=''

HASH_TYPE='sha256'
HASH_VALUE='e98bb08ae6b4eaa9401b555a294d98615a6ade4c85b43c630a880313eab3c7b3'


function _uninstall_android_studio()
{
	echo -e "Desinstalando ... $APP_NAME"
    rm -rf "$DESTINATION_DIR" 
    rm -rf $ICON_FILE
    rm -rf $DESKTOP_FILE
    return 0
}


function _install_android_studio()
{
	# Instalar o android_studio.
	isRoot && {
		printErro "Você não pode ser o root."
		return 1
	}


	if [[ -d "$DESTINATION_DIR" ]]; then
        printErro "Desinstale a versão atual de ... $APP_NAME para prosseguir"
        sleep 0.2
        return 1
    fi

    # Verificar integridade.
    checkSha256 $PKG_FILE $HASH_VALUE || return $?

    local _tmp_dir=$(mktemp -d)
    local _tmp_file=$(mktemp)
    
    #             Arquivo    Destion da descompressão.
    unpackArchive $PKG_FILE $_tmp_dir || return $?

    green "Entrando no diretório ... $_tmp_dir"
    cd $_tmp_dir || return 1
    cd ./android-studio

    green "Copiando arquivos"
    mkdir -p "$DESTINATION_DIR"
    mkdir -p "${DIR_HICOLOR}"/128x128/apps
    cp -R * "${DESTINATION_DIR}/"
    cp bin/studio.png $ICON_FILE

    # Criar script
    green "Configurando $APP_NAME"
    echo "" > "$SCRIPT_FILE"
    
    #echo '#!/usr/bin/env bash' > ${SCRIPT_FILE}
    {
        echo -e "__work_dir=\$(pwd)"
        echo -e "cd ${DESTINATION_DIR}/bin"
        echo -e "./studio.sh \$@\n"
        echo -e "cd \$__work_dir"

    } > "${SCRIPT_FILE}"


    # Criar arquivo .desktop.
    echo "[Desktop Entry]" > "$_tmp_file"
    {
        echo "Name=Android Studio"
        echo -e "Version=$APP_VERSION"
        echo -e "Exec=$SCRIPT_FILE"
        echo -e "Icon=$ICON_FILE"
        echo "Terminal=false"
        echo "Categories=Development;"
        echo "Type=Application"
    } >> "$_tmp_file"

    cp -u "$_tmp_file" $DESKTOP_FILE
    addFileInDesktopDir "$DESKTOP_FILE"
    chmod 777 $DESKTOP_FILE
    chmod +x $SCRIPT_FILE
    chmod +x "$DESTINATION_DIR"/bin/studio.sh
    
    rm -rf $_tmp_dir
    rm -rf $_tmp_file
    return 0
}


function main()
{	
	
	
	if [[ $1 == 'uninstall' ]]; then
        _uninstall_android_studio 
    elif [[ $1 == 'install' ]]; then
        _install_android_studio
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return $?
    elif [[ $1 == 'installed' ]]; then
        isExecutable android_studio || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return $?	
}


# main $@