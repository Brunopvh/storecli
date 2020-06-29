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

	_pkg_manager_sys bluez 'bluez-firmware' 'bluez-hcidump'
	echo -e "$space_line"
	white "1 - ${Green}G${Reset}NOME"
	white "2 - ${Green}K${Reset}DE"
	white "3 - ${Green}L${Reset}XDE/${Green}X${Reset}FCE/${Green}L${Reset}XQT/${Green}M${Reset}ATE"
	
	while true; do

		white "Selecione a sua interface gráfica: ${Green}(1 / 2 / 3): ${Reset}" 
		read -t 10 -n 1 desktop; echo ' '

		case "${desktop,,}" in
			1) _pkg_manager_sys 'gnome-bluetooth';;
			2) _pkg_manager_sys bluedevil;;
			3) _pkg_manager_sys blueman;;
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


	if is_executable 'zypper'; then
		_pkg_manager_sys "${compactadores_fedora[@]}"
	elif is_executable 'dnf'; then
		_pkg_manager_sys "${compactadores_fedora[@]}"
	elif is_executable 'apt'; then
		_pkg_manager_sys "${compactadores_debian[@]}"
	elif is_executable 'pacman'; then
		_pkg_manager_sys "${compactadores_arch[@]}"
	else
		_show_info 'ProgramNotFound' 'compactadores'
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
		firmware-ralink) _pkg_manager_sys 'firmware-ralink';;
		firmware-atheros) _pkg_manager_sys 'firmware-atheros';;
		firmware-realtek) _pkg_manager_sys 'firmware-realtek';;
		firmware-linux-nonfree) _pkg_manager_sys 'firmware-linux-nonfree';;
	esac
}


#=====================================================#
# Gparted
#=====================================================#
function _gparted()
{
	_pkg_manager_sys gparted
}

_peazip()
{
	# Url fixo versão 6.8
	local peazip_url__download__nload='http://c3sl.dl.osdn.jp/peazip/71074/peazip_portable-6.8.0.LINUX.x86_64.GTK2.tar.gz'
	local path_file="$Dir_Downloads/$(basename $peazip_url__download__nload)"
	local hash_file='c88f31bbe733ef5895472c78a9d84130a88d2cffd7262d115394b65bbc796d56'

	__download__ "$peazip_url__download__nload" "$path_file" || return 1

	# Somente baixar
	if [[ "$DownloadOnly" == 'True' ]]; then
		_show_info 'DownloadOnly' "$path_file"
		return 0 
	fi
		
	if is_executable 'peazip'; then
		_show_info 'pkg_are_instaled' 'peazip'
		return 0 
	fi

	__shasum__ "$path_file" "$hash_file" || return 1
	_unpack "$path_file" || return 1

	
	cd "$DirUnpack"
	mv -v $(ls -d peazip*) "$DirUnpack/peazip-amd64" 1> /dev/null
	sudo mv "$DirUnpack/peazip-amd64" '/opt/'
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

	if is_executable 'peazip'; then
		_show_info 'SuccessInstalation' 'peazip'
		return 0
	else
		_show_info 'InstalationFailed' 'peazip'
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
	
	__download__ "$url_zip" "$path_file" || return 1
	
	# Somente baixar
	if [[ "$DownloadOnly" == 'True' ]]; then
		_show_info 'DownloadOnly' "$path_file"
		return 0 
	fi
	
	# Já instalado.
	if is_executable 'refind-install'; then
		_show_info 'pkg_are_instaled' 'refind-install'
		return 0
	fi
	
	_unpack "$path_file" || return 1
	cd "$DirUnpack"
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
		debian|ubuntu|linuxmint|arch) _pkg_manager_sys refind;;
		*) _refind_zip;;
	esac
	
	if is_executable 'refind-install'; then
		_show_info 'SuccessInstalation' 'refind-install'
		return 0
	else
		_show_info 'InstalationFailed' 'refind-install'
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

	__download__ "$url" "$path_file" || return 1

	# Somente baixar
	if [[ "$DownloadOnly" == 'True' ]]; then
		_show_info 'DownloadOnly' "$url"
		return 0 
	fi

	_DPKG --install "$path_file"
}

_stacer_fedora()
{
	_pkg_manager_sys stacer	
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
	
	_pkg_manager_sys 'qt5-charts' 'hicolor-icon-theme' 'qt5-declarative' 'qt5-declarative' 'qt5-tools'
	
	__download__ "$url_appimage" "$path_file" || return 1
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
		*) _show_info ProgramNotFound stacer;;
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

	__download__ "$vb_url" "$path_file" || return 1
	
	if [[ "$DownloadOnly" == 'True' ]]; then
		_show_info 'DownloadOnly' "$path_file"
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

	_pkg_manager_sys "${requeriments_vb_fedora[@]}"
	_pkg_manager_sys $(rpm -qa kernel | sort -V | tail -n 1) 
	_pkg_manager_sys kernel-devel-$(uname -r)

	__download__ "https://www.virtualbox.org/download/oracle_vbox.asc" "$Dir_Downloads/oracle_vbox.asc"
	yellow "Importando: $Dir_Downloads/oracle_vbox.asc"
	sudo rpm --import "$Dir_Downloads/oracle_vbox.asc"
	
	white "Adicionando repositório: http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo"
	sudo sh -c 'curl -s -o /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo'
	
	case "$os_version" in
		31) _pkg_manager_sys 'VirtualBox-6.0' || return 1;;
		32) _pkg_manager_sys 'VirtualBox-6.1' || return 1;;
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
		bionic|tricia|focal) vbox_repo="deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian bionic contrib";;
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
	
	#_pkg_manager_sys libvpx6 
	_pkg_manager_sys 'module-assistant' 'build-essential' 'libsdl-ttf2.0-0' dkms
	_pkg_manager_sys linux-headers-$(uname -r)
	
	if [[ "$os_codename" == 'focal' ]]; then
		__download__ "$url_libvpx" "$path_libvpx" || return 1
		__shasum__ "$path_libvpx" "$sum_libvpx" || return 1
		_DPKG --install "$path_libvpx" || _BROKE
	fi
	
	echo -e "$space_line"
	_pkg_manager_sys 'virtualbox-6.0' || return 1
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
		'virtualbox' 
		'virtualbox-host-modules-arch'
		'linux-headers'
	)

	for c in "${array_vb_archlinux[@]}"; do
		_space_text "[+] Instalando" "$c"
		if ! _pkg_manager_sys "$c"; then
			_space_text "${CRed}[!]${CReset} Falha" "$c"
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
	#_virtualbox_extpack 
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
	vbox_version=$(echo "$vbox_url_run" | cut -d '/' -f 5)
	path_file="$Dir_Downloads/$(basename $vbox_url_run)"
	
	# Definir o url de download do arquivo com as hashs de seu
	# destino de download
	vbox_url_hash="https://www.virtualbox.org/download/hashes/$vbox_version/SHA256SUMS"
	vbox_path_file_hash="$Dir_Downloads/virtualbox_$vbox_version.check"

	__download__ "$vbox_url_run" "$path_file" || return 1
	__download__ "$vbox_url_hash" "$vbox_path_file_hash" || return

	# Somente baixar
	if [[ "$DownloadOnly" == 'True' ]]; then
		_show_info 'DownloadOnly' "$path_file"
		return 0 
	fi

	# Obter a HASH da versão atual no que está no arquivo .check
	# em seguida verificar a integridade do pacote usando o módulo
	# CheckSum
	vbox_sum=$(grep '64.run' "$vbox_path_file_hash" | cut -d' ' -f 1)
	__shasum__ "$path_file" "$vbox_sum" || return 1
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
		*) _show_info 'ProgramNotFound' 'virtualbox'; return 1;;	
	esac
}

#=============================================================#
# Instalar todos os pacotes da categória Sistema.
#=============================================================#
_System_All()
{
	if [[ -z "$AssumeYes" ]]; then
		_YESNO "Instalar todos os pacotes da categória 'Sistema'" || return 1 
	fi
	_bluetooth
	_compactadores
	_firmware
	_peazip
	_stacer
	_virtualbox
}
