#!/usr/bin/env bash
#
#


#=====================================================#
# Debian Bluetooth
#=====================================================#
function _bluetooth()
{
	if [[ "$os_id" != 'debian' ]]; then
		yellow "Este pacote está disponível apenas para sistemas Debian"
		return 1
	fi

	_package_man_distro bluez 'bluez-firmware' 'bluez-hcidump'
	echo -e "$space_line"
	white "1 - ${Green}G${Reset}NOME"
	white "2 - ${Green}K${Reset}DE"
	white "3 - ${Green}L${Reset}XDE/${Green}X${Reset}FCE/${Green}L${Reset}XQT/${Green}M${Reset}ATE"
	
	while true; do

		white "Selecione a sua interface gráfica: ${Green}(1 / 2 / 3): ${Reset}" 
		read -t 10 -n 1 desktop; echo ' '

		case "${desktop,,}" in
			1) _package_man_distro 'gnome-bluetooth';;
			2) _package_man_distro bluedevil;;
			3) _package_man_distro blueman;;
			*) 
			white "Opição inválida, você pode ${Green}repetir${Reset} ou ${Red}cancelar${Reset} [r/c]: " 
			read -t 10 -n 1 input; echo ' '
			if [[ "${input,,}" == 'r' ]]; then
				continue	
			else
				return 0; break
			fi		
			;;
		esac	
		break	
	done
}

 _brightnessctl()
 {
 	# https://linuxdicasesuporte.blogspot.com/2018/11/controle-de-brilho-da-tela-por-linha-de_5.html
 	case "$os_id" in
 		debian|ubuntu|linuxmint) _package_man_distro brightnessctl;;
		arch) _package_man_distro brightnessctl;;
		fedora) _package_man_distro brightnessctl;;
	esac
 }

#=====================================================#
# Compactadores
#=====================================================#
function _compactadores()
{

	local compactadores_debian=(
		'p7zip-full' 'p7zip' 'p7zip-rar' 'cabextract' 'unzip' 'xz-utils' 'lhasa' 
		'unace' 'arc' 'arj' 'lzma' 'rar' 'unrar-free' 'zip' 'ncompress'
	)

	local compactadores_fedora=(
		'zip' 'ncompress' 'xarchiver' 'arj' 'cabextract' 'unzip' 'p7zip' 'lzma' 'arc' 
	)

	local compactadores_arch=( 
		'tar' 'gzip' 'bzip2' 'unzip' 'unrar' 'p7zip'
	)


	if _WHICH 'zypper'; then
		_package_man_distro "${compactadores_fedora[@]}"
	elif _WHICH 'dnf'; then
		_package_man_distro "${compactadores_fedora[@]}"
	elif _WHICH 'apt'; then
		_package_man_distro "${compactadores_debian[@]}"
	elif _WHICH 'pacman'; then
		_package_man_distro "${compactadores_arch[@]}"
	else
		_INFO 'pkg_not_found' 'compactadores'
		return 1
	fi
}


#=====================================================#
# Debian Firmwares
#=====================================================#
function _firmware()
{
	if [[ "$os_id" != 'debian' ]]; then
		yellow "Este pacote está disponível apenas para sistemas Debian"
		return 1
	fi

	case "$1" in
		firmware-ralink) _package_man_distro 'firmware-ralink';;
		firmware-atheros) _package_man_distro 'firmware-atheros';;
		firmware-realtek) _package_man_distro 'firmware-realtek';;
		firmware-linux-nonfree) _package_man_distro 'firmware-linux-nonfree';;
	esac
}


#=====================================================#
# Gparted
#=====================================================#
function _gparted()
{
	_package_man_distro gparted
}


_peazip()
{
	# Url fixo versão 6.8
	local peazip_url_download='http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
	local path_file="$Dir_Downloads/$(basename $peazip_url_download)"
	local hash_file='c88f31bbe733ef5895472c78a9d84130a88d2cffd7262d115394b65bbc796d56'

	_dow "$peazip_url_download" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi
		
	if _WHICH 'peazip'; then
		_INFO 'pkg_are_instaled' 'peazip'
		return 0 
	fi

	_check_sum "$path_file" "$hash_file" || return 1
	_unpack "$path_file" || return 1

	
	cd "$Dir_Unpack"
	mv -v $(ls -d peazip*) "$Dir_Unpack/peazip-amd64" 1> /dev/null
	sudo mv "$Dir_Unpack/peazip-amd64" '/opt/'
	sudo chown -R root:root "/opt/peazip-amd64" #1> /dev/null # root é o dono.
	sudo chmod -R a+x "/opt/peazip-amd64"

	cd '/opt/peazip-amd64'
	sudo cp -u FreeDesktop_integration/peazip.desktop "${array_peazip_dirs[0]}" # .desktop
	sudo cp -u FreeDesktop_integration/peazip.png "${array_peazip_dirs[1]}"     # PNG.
	sudo cp -u peazip "${array_peazip_dirs[2]}"                                 # binario.

	# Atalho desktop
	cp -u "${array_peazip_dirs[0]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_peazip_dirs[0]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_peazip_dirs[0]}" ~/Desktop/ 2> /dev/null

	if _WHICH 'peazip'; then
		_INFO 'pkg_sucess' 'peazip'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'peazip'
		return 1
	fi
}

#=====================================================#
# Refind
#=====================================================#
function _refind_zip()
{
	# https://sourceforge.net/projects/refind/postdownload
	# http://www.rodsbooks.com/refind/
	# http://www.rodsbooks.com/refind/installing.html
	# https://sourceforge.net/p/refind/code/ci/master/tree/
	local url_rpm='https://ufpr.dl.sourceforge.net/project/refind/0.6.11/refind-0.6.11-1.x86_64.rpm'
	local url_zip='https://sourceforge.net/projects/refind/files/0.12.0/refind-bin-0.12.0.zip/download'
	local path_file="$Dir_Downloads/refind-bin-0.12.0.zip"
	
	_dow "$url_zip" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi
	
	# Já instalado.
	if _WHICH 'refind-install'; then
		_INFO 'pkg_are_instaled' 'refind-install'
		return 0
	fi
	
	_unpack "$path_file" || return 1
	cd "$Dir_Unpack"
	mv $(ls -d refind*) refind
	sudo mv refind "${array_refind_dirs[0]}"
	
	# Criar script para execução
	echo '#!/usr/bin/env bash' | sudo tee "${array_refind_dirs[1]}"
	{
		echo "cd ${array_refind_dirs[0]}"
		echo "./refind-install \$@"
	} | sudo tee -a "${array_refind_dirs[1]}"
	
	sudo chmod -R +x "${array_refind_dirs[0]}"
	sudo chmod a+x "${array_refind_dirs[1]}"
	
}

function _refind()
{
	case "$os_id" in
		debian|ubuntu|linuxmint|arch) _package_man_distro refind;;
		*) _refind_zip;;
	esac
	
	if _WHICH 'refind-install'; then
		_INFO 'pkg_sucess' 'refind-install'
		return 0
	else
		_INFO 'pkg_instalation_failed' 'refind-install'
		return 1
	fi
}


#=====================================================#
# Stacer
#=====================================================#
function _stacer_debian()
{
	# https://github.com/oguzhaninan/Stacer/releases
	# https://github.com/oguzhaninan/Stacer
	local url='https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/stacer_1.1.0_amd64.deb'
	local path_file="$Dir_Downloads/$(basename $url)"

	_dow "$url" "$path_file" || return 1

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$url"
		return 0 
	fi

	_DPKG --install "$path_file"
}

_stacer_fedora()
{
	_package_man_distro stacer	
}


_stacer_archlinux()
{
	# https://aur.archlinux.org/packages/stacer/
	# https://github.com/oguzhaninan/Stacer
	# https://github.com/oguzhaninan/Stacer/releases
	#
	# qt5-charts hicolor-icon-theme qt5-declarative qt5-declarative qt5-tools ccache

	local url_appimage='https://github.com/oguzhaninan/Stacer/releases/download/v1.1.0/Stacer-1.1.0-x64.AppImage'
	local path_file="$Dir_Downloads/Stacer-1.1.0-x64.AppImage"
	
	_package_man_distro 'qt5-charts' 'hicolor-icon-theme' 'qt5-declarative' 'qt5-declarative' 'qt5-tools'
	
	_dow "$url_appimage" "$path_file" || return 1
	sudo cp "$path_file" "${array_stacer_dirs[stacer_file_appimage]}"
	sudo chmod a+x "${array_stacer_dirs[stacer_file_appimage]}"
	sudo ln -sf "${array_stacer_dirs[stacer_file_appimage]}" "${array_stacer_dirs[stacer_link]}"

	# Criar arquivo '.desktop'
	yellow "Criando arquivo .desktop"
	echo '[Desktop Entry]' | sudo tee "${array_stacer_dirs[stacer_file_desktop]}"
	{
		echo "Encoding=UTF-8"
		echo "Name=Stacer"
		echo "Exec=stacer"
		echo "Comment=Linux System Optimizer and Monitoring"
		echo "Version=1.0"
		echo "Terminal=false"
		echo "Icon=stacer"
		echo "Keywords=stacer;monitor;"
		echo "Type=Application"
		echo "Categories=Utility;System;"
	} | sudo tee -a "${array_stacer_dirs[stacer_file_desktop]}"

	yellow "Criando atalho na Área de Trabalho"
	# sudo chmod +rwx "${array_stacer_dirs[stacer_file_desktop]}"
	cp -u "${array_stacer_dirs[stacer_file_desktop]}" ~/'Área de Trabalho'/ 2> /dev/null
	cp -u "${array_stacer_dirs[stacer_file_desktop]}" ~/'Área de trabalho'/ 2> /dev/null
	cp -u "${array_stacer_dirs[stacer_file_desktop]}" ~/Desktop/ 2> /dev/null
}


function _stacer()
{
	case "$os_id" in
		debian|ubuntu|linuxmint) _stacer_debian;;
		arch) _stacer_archlinux;;
		*) _INFO pkg_not_found stacer;;
	esac
}


#=====================================================#
# Vitualbox
#=====================================================#

function _virtualbox_extpack()
{
	# Após instalar o virtualbox no sistema, devemos executar esta
	# função para instalar o pacote extensionpack (em qualquer distro)
	# uma vez que está função funciona da mesma maneira em qualquer 
	# distribuição linux. 
	#   Baixa o pacote (extensionpack) instala o pacote usando o virtualbox
	# e adiciona o usuário atual no grupo  vboxuser.
	#
	white "Aguarde"
	local vb_pag="https://www.virtualbox.org/wiki/Downloads"
	local vb_html=$(grep -m 1 "Oracle.*Ext.*vbox.*" <<< $(curl -sL "$vb_pag"))
	local vb_url=$(echo "$vb_html" | sed 's/.*href="//g;s/">.*//g')
	local path_file="$Dir_Downloads/$(basename $vb_url)"

	_dow "$vb_url" "$path_file" || return 1
	
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Instalação
	yellow "Instalando Extension Pack"
	sudo VBoxManage extpack install --replace "$path_file"

	_YESNO "Deseja adicionar $USER ao grupo ${Green}vboxusers${Reset}" || return 1
	
	#sudo gpasswd -a "$USER" vboxusers  
	sudo usermod -a -G vboxusers $USER	
}

#-----------------------------------------------------#

function _virtualbox_fedora()
{
	local requeriments_vb_fedora=(
		'libgomp' 
		'glibc-headers' 
		'glibc-devel' 
		'kernel-headers' 
		'dkms' 
		'qt5-qtx11extras' 
		'libxkbcommon' 
		'kernel-devel' 
		'binutils' 
		'gcc' 
		'make' 
		'patch'
	)

	_package_man_distro "${requeriments_vb_fedora[@]}"
	_package_man_distro $(rpm -qa kernel | sort -V | tail -n 1) 
	_package_man_distro kernel-devel-$(uname -r)

	_dow "https://www.virtualbox.org/download/oracle_vbox.asc" "$Dir_Downloads/oracle_vbox.asc"
	yellow "Importando: $Dir_Downloads/oracle_vbox.asc"
	sudo rpm --import "$Dir_Downloads/oracle_vbox.asc"
	
	white "Adicionando repositório: http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo"
	sudo sh -c 'curl -s -o /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo'
	
	case "$os_version" in
		31) _package_man_distro 'VirtualBox-6.0' || return 1;;
		32) _package_man_distro 'VirtualBox-6.1' || return 1;;
	esac
	
	# Módulos
	white "Configurando módulos"
	sudo sh -c '/usr/lib/virtualbox/vboxdrv.sh setup'
	sudo sh -c '/sbin/vboxconfig'

	# Instalar o pacote ExtensionPack.
	_virtualbox_extpack 
}


function _virtualbox_debian()
{
	# find /etc/apt -name *.list | xargs grep "^deb .*download\.virtualbox\.org.*debian buster contrib$" 2> /dev/null
		
	local url_libvpx='http://ftp.us.debian.org/debian/pool/main/libv/libvpx/libvpx5_1.7.0-3+deb10u1_amd64.deb'
	local path_libvpx="$Dir_Downloads/$(basename $url_libvpx)"
	local sum_libvpx='72d8466a4113dd97d2ca96f778cad6c72936914165edafbed7d08ad3a1679fec'
	local vbox_file="/etc/apt/sources.list.d/virtualbox.list"

	case "$os_codename" in
		buster) vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian buster contrib";;
		bionic|trica|focal) vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib";;
		*) red "Seu sistema ainda não tem suporte a instalação do virtualbox por meio deste script"; return 1;;
	esac

	
	# Limpar o cache antes de adicionar as chaves (recomendado).
	white "Limpando o cache do (apt)"
	_APT clean
	# sudo rm -rf /var/lib/apt/lists/* 1> /dev/null 2> /dev/null
	
	echo -ne "Adicionando key: https://www.virtualbox.org/download/oracle_vbox_2016.asc "
	sudo sh -c 'curl -sL https://www.virtualbox.org/download/oracle_vbox_2016.asc | apt-key add -' || return 1
		
	echo -ne "Adicionando key: https://www.virtualbox.org/download/oracle_vbox.asc "
	sudo sh -c 'curl -sL https://www.virtualbox.org/download/oracle_vbox.asc | apt-key add -' || return 1
		
	echo -ne "Adicionando repositório "
	echo "$vbox_repo" | sudo tee "$vbox_file"
	
	# Atualizar o cache 'apt update' apartit da função _APT.
	_APT update 
	
	# Dependências
	echo "$space_line"
	
	#_package_man_distro libvpx6 
	_package_man_distro 'module-assistant' 'build-essential' 'libsdl-ttf2.0-0' dkms
	_package_man_distro linux-headers-$(uname -r)
	
	if [[ "$os_codename" == 'focal' ]]; then
		_dow "$url_libvpx" "$path_libvpx" || return 1
		_check_sum "$path_libvpx" "$sum_libvpx" || return 1
		_DPKG --install "$path_libvpx" || _BROKE
	fi
	
	echo -e "$space_line"
	_package_man_distro 'virtualbox-6.0' || return 1
	_virtualbox_extpack
}

#-----------------------------------------------------#
function _virtualbox_archlinux()
{
	# https://sempreupdate.com.br/como-instalar-o-virtualbox-no-arch-linux/
	# https://wiki.archlinux.org/index.php/VirtualBox_(Portugu%C3%AAs)
	# https://www.virtualbox.org/wiki/Linux_Downloads
	# https://www.edivaldobrito.com.br/sbinvboxconfig-nao-esta-funcionando/
	# virtualbox-host-modules-arch
	# virtualbox-host-dkms
	# systemd-modules-load.service -> (carregar módulos no boot)
	# /usr/lib/modules-load.d/virtualbox-host-modules-arch.conf -> Arquivo de configuração
	
	local array_vb_archlinux=(
		'linux-headers'
		'virtualbox' 
		'virtualbox-host-modules-arch'
	)

	for c in "${array_vb_archlinux[@]}"; do
		green "Instalando $(SPACE_TEXT $c) $c"
		if ! _package_man_distro "$c"; then
			red "Falha $(SPACE_TEXT) $c"
		fi
	done

	# /etc/modules-load.d/virtualbox.conf
	# sudo depmod -a
	white "Configurando módulos"
	sudo /sbin/rcvboxdrv setup
	sudo /sbin/vboxconfig
	sudo modprobe vboxdrv

	# Configuração para carregar o módulo durante o boot.
	# sudo echo vboxdrv >> /etc/modules-load.d/virtualbox.conf

	# Instalar o pacote ExtensionPack.
	_virtualbox_extpack 
}

#-----------------------------------------------------#

function _virtualbox_linux_run()
{
	# Virtualbox para qualquer Linux.
	# Encontar os urls de downloads do executável .run (dor virtualbox)
	# e o arquivo que contém as hashs sha256 para cada versão do virtualbox
	#
	# O download do arquivo contendo as hashs e semelhante ao comando
	# abixo, ATENÇÃO a mudança de versão do virtualbox (6.x)
	# curl -O https://www.virtualbox.org/download/hashes/6.1.6/SHA256SUMS
	#
	# https://download.virtualbox.org/virtualbox/6.1.6/VirtualBox-6.1.6-137129-Linux_amd64.run
	#
	# sudo /etc/init.d/vboxdrv setup
	# sudo /sbin/vboxconfig
	# sudo /sbin/rcvboxdrv setup

	# Pagina de download do virtualbox
	vbox_pag='https://www.virtualbox.org/wiki/Linux_Downloads'

	# Encontrar ocorrências .run ou SHA256 no html da pagina de download.
	vbox_html=$(egrep "(https.*download.*64.run|SHA256)" <<< $(curl -sSL $vbox_pag))

	# Filtrar o url do arquivo executável (.run) 
	# e atribuir path para download.
	vbox_url_run=$(echo "$vbox_html" | grep -m 1 '64.run' | sed 's/.*href="//g;s/run".*/run/g')
	path_file="$Dir_Downloads/$(basename $vbox_url_run)"

	# Usar expansão de variáveis para obter a versão atual do virtualbox
	# que está expressa no url de download "vbox_url_run".
	#
	# Selecionar 5 caracteres apartir do 43 - para obter somente o
	# número da versão atual - leia sobre expanção de variaveis em 
	# shell script.
	vbox_version="${vbox_url_run:43:5}" 
	
	# Definir o url de download do arquivo com as hashs de seu
	# destino de download
	vbox_url_hash="https://www.virtualbox.org/download/hashes/$vbox_version/SHA256SUMS"
	vbox_path_file_hash="$Dir_Downloads/virtualbox_$vbox_version.check"

	_dow "$vbox_url_run" "$path_file" || return 1
	_dow "$vbox_url_hash" "$vbox_path_file_hash" || return

	# Somente baixar
	if [[ "$download_only" == 'True' ]]; then
		_INFO 'download_only' "$path_file"
		return 0 
	fi

	# Obter a HASH da versão atual no que está no arquivo .check
	# em seguida verificar a integridade do pacote usando o módulo
	# CheckSum
	vbox_sum=$(grep '64.run' "$vbox_path_file_hash" | cut -d' ' -f 1)
	_check_sum "$path_file" "$vbox_sum" || return 1
	chmod +x "$path_file"
	sudo "$path_file"
	sudo /sbin/rcvboxdrv setup
	sudo /sbin/vboxconfig
	_virtualbox_extpack
}

#-----------------------------------------------------#


function _virtualbox()
{
	case "$os_id" in
		debian|linuxmint|ubuntu) _virtualbox_debian;;
		fedora) _virtualbox_fedora;;
		arch) _virtualbox_linux_run;;	
		*) _INFO 'pkg_not_found' 'virtualbox'; return 1;;	
	esac
}

#=============================================================#
# Instalar todos os pacotes da categória Sistema.
#=============================================================#
_System_All()
{
	if [[ -z "$install_yes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Sistema'" || return 1 
	fi
	_bluetooth
	_compactadores
	_firmware
	_peazip
	_stacer
	_virtualbox
}
