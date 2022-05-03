#!/usr/bin/env bash
#
#

INSTALLATION_TYPE='user'
APP_NAME='pycharm-community'
DESTINATION_DIR="${DIR_OPTIONAL}"/pycharm-community
ICON_FILE="${DIR_HICOLOR}"/64x64/apps/pycharm.svg
DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/pycharm-community.desktop
PKG_FILE="$(getCachePkgs)"/pycharm-community-2021.3.1.tar.gz
SCRIPT_FILE="${DIR_BIN}"/pycharm
LINK_FILE=None
APP_VERSION='1.0'
PKG_URL='https://download-cdn.jetbrains.com/python/pycharm-community-2021.3.1.tar.gz'
ONLINE_SIZE='482M'
HASH_TYPE='sha256'
HASH_VALUE='f5dd6e642ee65fa96d0ea8447d4a75589ce4258434222c4d9df00d1e5a46a8f5'


function _uninstall_pycharm()
{
	green "Desinstalando ... $APP_NAME"
    rm -rf $DESTINATION_DIR
    rm -rf $ICON_FILE
    rm -rf $DESKTOP_FILE
    return 0
}


function _install_pycharm()
{
	# Instalar o pycharm.
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
    mv pycharm-* pycharm
    cd pycharm
    
    green "Copiando arquivos"
    mkdir -p "$DESTINATION_DIR"
    mkdir -p "${DIR_HICOLOR}"/64x64/apps
    cp -R * "${DESTINATION_DIR}/"
    cp bin/pycharm.svg $ICON_FILE

    green "Configurando pycharm"

    # Criar arquivo .desktop.
    echo "[Desktop Entry]" > "$_tmp_file"
    {
        echo "Name=Pycharm Community"
        echo "Version=$APP_VERSION"
        echo "Icon=$ICON_FILE"
        echo "Exec=$DESTINATION_DIR/bin/pycharm.sh"
        echo "Terminal=false"
        echo "Categories=Development;IDE;"
        echo "Type=Application"
    } >> "$_tmp_file"

    cp -u "$_tmp_file" $DESKTOP_FILE
    addFileInDesktopDir "$DESKTOP_FILE"
    chmod 777 $DESKTOP_FILE
    chmod +x "$DESTINATION_DIR"/bin/pycharm.sh
    
    rm -rf $_tmp_dir
    rm -rf $_tmp_file
    return 0
}


function main()
{	
	setDirsUser
	
	if [[ $1 == 'uninstall' ]]; then
        _uninstall_pycharm 
    elif [[ $1 == 'install' ]]; then
        _install_pycharm
    elif [[ $1 == 'get' ]]; then
        download $PKG_URL $PKG_FILE || return $?
    elif [[ $1 == 'installed' ]]; then
        isExecutable pycharm || return 1
    else
        printErro 'Parâmetro incorreto.'
        return 1
    fi

    return $?	
}


# main $@