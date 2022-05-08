#!/usr/bin/env bash
#

#===================================================================#
# Wine installer
#===================================================================#

function wine_installer()
{
	#

	[[ -z $1 ]] && return 1

	[[ $forceInstall == True ]] || {
		if wine_app_is_installed $APP_NAME; then
			printInfo "$APP_NAME já está instalado."
			return 0
		fi
	}

	local db_file=$(getDataBaseFile)
	green "Instalando ... $1"
	sed -i "/^${APP_NAME}.*/d" $db_file
	wine "$1"
	
	if [[ $? == 0 ]]; then
		echo -e "$APP_NAME          > True > None" >> $db_file
		return 0
	fi

	_status_out=$?
	echo -e "$APP_NAME          > False > None" >> $db_file
	return $_status_out
}






function _installNotepad_plus_plus()
{

	# Verificar integridade.
    checkSha256 $PKG_FILE $HASH_VALUE || return $?
    wine_installer $PKG_FILE
}


function ConfigNotepad_plus_plus()
{
	#
	local PKG_URL='https://github.com/notepad-plus-plus/notepad-plus-plus/releases/download/v8.4/npp.8.4.Installer.x64.exe'
	local PKG_FILE=$(getCachePkgs)/'npp.8.4.Installer.x64.exe'
	local APP_NAME='notepad++'
	local DESTINATION_DIR=""
	#local DESKTOP_FILE.="${DIR_DESKTOP_ENTRY}"/firefox.desktop
	local APP_VERSION='8.4'
	local ONLINE_SIZE=''
	local HASH_TYPE='sha256'
	local HASH_VALUE='662450bbbe1d642bddd5501f65de830341ac4c7846b4fe9ad8512c9e2888d129'

	if [[ $1 == 'install' ]]; then
		_installNotepad_plus_plus
	elif [[ $1 == 'uninstall' ]]; then
		echo 'Falta código'
	elif [[ $1 == 'get' ]]; then
		download $PKG_URL $PKG_FILE
	else
		printErro "Parâmetro incorreto detectado."
		return 1
	fi

}






#===================================================================#
# Fontes Microsoft
#===================================================================#
function uninstall_ms_core_fonts()
{
	echo "Falta código"
}


function install_ms_core_fonts()
{
	# https://www.vivaolinux.com.br/dica/Instalando-fontes-basicas-para-o-Wine
	#

	local fonts=(
			arial32.exe
			arialb32.exe
			comic32.exe
			courie32.exe
			georgi32.exe
			impact32.exe
			times32.exe
			trebuc32.exe
			verdan32.exe
			webdin32.exe
	)

	for file in "${fonts[@]}"; do
		wine "$(getCachePkgs)"/$file
	done

}

function ConfigMsCoreFonts()
{
	#
	local APP_NAME='ms-core-fonts'

	local pkg_urls=(
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/arial32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/arialb32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/comic32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/courie32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/georgi32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/impact32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/times32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/trebuc32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/verdan32.exe
			http://ufpr.dl.sourceforge.net/sourceforge/corefonts/webdin32.exe
		)


	if [[ $1 == 'install' ]]; then
		install_ms_core_fonts
	elif [[ $1 == 'uninstall' ]]; then
		uninstall_ms_core_fonts
	elif [[ $1 == 'get' ]]; then
		for URL in "${pkg_urls[@]}"; do
			download $URL $(getCachePkgs)/$(basename $URL)
		done
	else
		printErro "Parâmetro incorreto detectado."
		return 1
	fi

}



function ConfigTorBrowser()
{
	# https://www.torproject.org/pt-BR/download/
	#
	# https://www.torproject.org/dist/torbrowser/11.0.11/torbrowser-install-win64-11.0.11_pt-BR.exe
	#

	local PKG_URL='https://www.torproject.org/dist/torbrowser/11.0.11/torbrowser-install-win64-11.0.11_pt-BR.exe'
	local PKG_FILE=$(getCachePkgs)/'torbrowser-install-win64-11.0.11_pt-BR.exe'
	local APP_NAME='torbrowser'
	local APP_VERSION='11.0.11'
	local ONLINE_SIZE=''
	local HASH_TYPE='sha256'
	local HASH_VALUE='59c0c749cb024a216a69c576c3eecf9ea2e17d54154b91157cb1bd416b750487'

	if [[ $1 == 'install' ]]; then
		# Verificar integridade.
    	checkSha256 $PKG_FILE $HASH_VALUE || return $?
    	wine_installer $PKG_FILE
	elif [[ $1 == 'uninstall' ]]; then
		echo 'Falta código'
	elif [[ $1 == 'get' ]]; then
		download $PKG_URL $PKG_FILE
	else
		printErro "Parâmetro incorreto detectado."
		return 1
	fi

}




function ConfigFirefox()
{
	#
	local PKG_URL='https://download-installer.cdn.mozilla.net/pub/firefox/releases/99.0.1/win64/pt-BR/Firefox%20Setup%2099.0.1.exe'
	local PKG_FILE=$(getCachePkgs)/'FirefoxSetup2099.0.1.exe'
	local APP_NAME='firefox'
	local DESTINATION_DIR=""
	local DESKTOP_FILE="${DIR_DESKTOP_ENTRY}"/firefox.desktop
	local APP_VERSION='99.0.1'
	local ONLINE_SIZE='55M'
	local HASH_TYPE='sha256'
	local HASH_VALUE='f64119374118ed4aae3e3137399d4e5c0c927c1ec8d1e3c876118bbb9f69b269'

	if [[ $1 == 'install' ]]; then
		# Verificar integridade.
    	checkSha256 $PKG_FILE $HASH_VALUE || return $?
    	wine_installer $PKG_FILE
	elif [[ $1 == 'uninstall' ]]; then
		echo 'Falta código'
	elif [[ $1 == 'get' ]]; then
		download $PKG_URL $PKG_FILE
	else
		printErro "Parâmetro incorreto detectado."
		return 1
	fi

}



function _installPycharm()
{
	# Verificar integridade.
    checkSha256 $PKG_FILE $HASH_VALUE || return $?
    wine_installer $PKG_FILE
}


function ConfigPycharm()
{
	#
	# local PKG_URL='https://download-cdn.jetbrains.com/python/pycharm-community-2021.3.1.exe'
	# local HASH_VALUE='af74570c3989f3075b8851e4c97791b1a5ccb919b33a7b843eca0af076d5ea67'
	# local PKG_URL='https://download-cdn.jetbrains.com/python/pycharm-community-2020.1.3.exe'
	
	local PKG_URL='https://download-cdn.jetbrains.com/python/pycharm-community-2018.1.3.exe'
	local PKG_FILE=$(getCachePkgs)/pycharm-community-2018.1.3.exe
	local APP_NAME='pycharm'
	local DESTINATION_DIR=""
	local APP_VERSION='2020.1.3'
	local ONLINE_SIZE='272M'
	local HASH_TYPE='sha256'
	#local HASH_VALUE='46d42d441390a449d3f8f877a7aee5e87c999dbf80e014334dc5d544603d3381'
	local HASH_VALUE='dd50018d220465fc934930245fd322a5d619b515326585b8b39a647400f479c4'


	if [[ $1 == 'install' ]]; then
		_installPycharm
		ConfigPython3 install
	elif [[ $1 == 'uninstall' ]]; then
		echo 'Falta código'
	elif [[ $1 == 'get' ]]; then
		download $PKG_URL $PKG_FILE
		ConfigPython3 get
	else
		printErro "Parâmetro incorreto detectado."
		return 1
	fi

}



function ConfigRevoUninstaller()
{
	#
	# local PKG_URL='https://download-cdn.jetbrains.com/python/pycharm-community-2021.3.1.exe'
	# local HASH_VALUE='af74570c3989f3075b8851e4c97791b1a5ccb919b33a7b843eca0af076d5ea67'
	# local PKG_URL='https://download-cdn.jetbrains.com/python/pycharm-community-2020.1.3.exe'
	
	local PKG_URL='https://download.revouninstaller.com/download/revosetup.exe'
	local PKG_FILE=$(getCachePkgs)/revosetup.exe
	local APP_NAME='revo-uninstaller'
	local DESTINATION_DIR=""
	local APP_VERSION=''
	local ONLINE_SIZE=''
	local HASH_TYPE='sha256'
	local HASH_VALUE='dd50018d220465fc934930245fd322a5d619b515326585b8b39a647400f479c4'


	if [[ $1 == 'install' ]]; then
		wine_installer $PKG_FILE
	elif [[ $1 == 'uninstall' ]]; then
		echo 'Falta código'
	elif [[ $1 == 'get' ]]; then
		download $PKG_URL $PKG_FILE
	else
		printErro "Parâmetro incorreto detectado."
		return 1
	fi

}





function _installPython3()
{

	# Verificar integridade.
    checkSha256 $PKG_FILE $HASH_VALUE || return $?
    wine_installer $PKG_FILE
}


function ConfigPython3()
{
	#
	local PKG_URL='https://www.python.org/ftp/python/3.7.8/python-3.7.8-amd64.exe'
	local PKG_FILE=$(getCachePkgs)/'python-3.7.8-amd64.exe'
	local APP_NAME='python3'
	local DESTINATION_DIR=""
	local APP_VERSION=''
	local ONLINE_SIZE=''
	local HASH_TYPE='sha256'
	local HASH_VALUE='a43ed63251a5e0d2cf1bbe9f6a75389675d091aaeeaae5d1be27ffb2e329e373'

	if [[ $1 == 'install' ]]; then
		_installPython3
	elif [[ $1 == 'uninstall' ]]; then
		echo 'Falta código'
	elif [[ $1 == 'get' ]]; then
		download $PKG_URL $PKG_FILE
	else
		printErro "Parâmetro incorreto detectado."
		return 1
	fi

}

