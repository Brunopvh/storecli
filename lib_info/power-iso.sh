#!/usr/bin/env bash
#
# https://www.poweriso.com/download-poweriso-for-linux.htm
#

setDirsUser

INSTALLATION_TYPE='user'
APP_NAME='poweriso'
DESTINATION_DIR="${DIR_OPTIONAL}"/poweriso-x64

# ICON_FILE="${DIR_HICOLOR}"/64x64/apps/poweriso.svg
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/poweriso.desktop
PKG_FILE="$(getCachePkgs)"/poweriso-x64-1.1.tar.gz
SCRIPT_FILE="${DIR_BIN}"/poweriso # DIR_BIN é fornecido por shell-libs
BIN_FILE="${DESTINATION_DIR}/poweriso"

LINK_FILE=None
APP_VERSION='1.1'

PKG_URL='https://www.poweriso.com/poweriso-x64-1.1.tar.gz'
ONLINE_SIZE='482M'

HASH_TYPE='sha256'
HASH_VALUE='d30cbf69b6b3f65241b909e7e26acba133993f440f3dbdf86f362889108aab44'


function _uninstall_poweriso()
{
	echo -ne "Desinstalando ... $APP_NAME "
    rm -rf "$DESTINATION_DIR" || echo ERRO
    rm -rf $ICON_FILE
    rm -rf $DESKTOP_FILE
    rm -rf $SCRIPT_FILE
    echo OK
    return 0
}


function _install_poweriso()
{
	# Instalar o poweriso.
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
    mv poweriso-* poweriso
    cd poweriso
    
    green "Copiando arquivos"
    mkdir -p "$DESTINATION_DIR"
    mkdir -p "${DIR_HICOLOR}"/64x64/apps
    cp -R * "${DESTINATION_DIR}/"
    #cp bin/poweriso.svg $ICON_FILE

    # Criar script
    green "Configurando poweriso"
    echo "" > "$SCRIPT_FILE"
    
    #echo '#!/usr/bin/env bash' > ${SCRIPT_FILE}
    {
        echo -e "export LD_LIBRARY_PATH=${DESTINATION_DIR}"
        echo -e "export QT_QPA_PLATFORM_PLUGIN_PATH=${DESTINATION_DIR}"
        echo -e "cd ${DESTINATION_DIR} \n"
        echo -e "./poweriso &"
        echo -e "unset LD_LIBRARY_PATH"

    } > "${SCRIPT_FILE}"


    # Criar arquivo .desktop.
    echo "[Desktop Entry]" > "$_tmp_file"
    {
        echo "Name=PowerIso"
        echo -e "Version=$APP_VERSION"
        echo -e "Exec=$DIR_BIN/poweriso"
        echo "Terminal=false"
        echo "Categories=Multimedia;"
        echo "Type=Application"
    } >> "$_tmp_file"

    cp -u "$_tmp_file" $DESKTOP_FILE
    addFileInDesktopDir "$DESKTOP_FILE"
    chmod 777 $DESKTOP_FILE
    chmod +x $SCRIPT_FILE
    chmod +x "$DESTINATION_DIR"/poweriso
    
    rm -rf $_tmp_dir
    rm -rf $_tmp_file
    return 0
}


function main()
{	
	
	
	if [[ $1 == 'uninstall' ]]; then
        _uninstall_poweriso 
    elif [[ $1 == 'install' ]]; then
        _install_poweriso
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return $?
    elif [[ $1 == 'installed' ]]; then
        isExecutable poweriso || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return $?	
}


# main $@