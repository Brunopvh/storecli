#!/usr/bin/env bash
#
#
#

#=====================================================#
# Debian Firmwares
#=====================================================#
function _firmware()
{
	[[ "$os_id" == 'debian' ]] || { _prog_not_found; return 1; }

	case "$1" in
		firmware-ralink) sudo apt install firmware-ralink -y;;
		firmware-atheros) sudo apt install firmware-atheros -y;;
		firmware-realtek) sudo apt install firmware-realtek -y;;
		firmware-linux-nonfree) sudo apt install firmware-linux-nonfree -y;;
	esac
}

#=====================================================#
# Debian Bluetooth
#=====================================================#
function _bluetooth()
{
	[[ "$os_id" == 'debian' ]] || { _prog_not_found; return 1; }

	sudo apt install -y bluez bluez-firmware bluez-hcidump
	_info_msgs 'INFO'
	echo "==> 1 - $(_c 32 0)G$(_c)NOME"
	echo "==> 2 - $(_c 32 0)K$(_c)DE"
	echo "==> 3 - $(_c 32 0)L$(_c)XDE/$(_c 32 0)X$(_c)FCE/$(_c 32 0)L$(_c)XQT/$(_c 32 0)M$(_c)ATE"
	
	while true; do

		echo "==> Selecione a sua interface gráfica: $(_c 32 0)(1 / 2 / 3): $(_c)" 
		read -n 1 input; echo ' '
		case "${input,,}" in
			1) sudo apt install gnome-bluetooth;;
			2) sudo apt install bluedevil;;
			3) sudo apt install blueman;;
			*) 
			echo "$(_c 31)==> Opição inválida, você pode $(_c 32)repetir$(_c) ou $(_c 32)cancelar$(_c) (r/c): " 
			read -n 1 input; echo ' '
			if [[ "${input,,}" == 'r' ]]; then
				continue
			elif [[ "${input,,}" == 'c' ]]; then
				return 0; break
			else
				continue
			fi		
			;;
		esac	
		break	
	done
}

#=====================================================#
# Gparted
#=====================================================#
function _gparted()
{
	if [[ -x $(command -v zypper 2> /dev/null) ]]; then
		sudo zypper in -y gparted

	elif [[ -x $(command -v dnf 2> /dev/null) ]]; then
		sudo dnf install -y gparted

	elif [[ -x $(command -v apt 2> /dev/null) ]]; then
		sudo apt install -y gparted

	else
		_prog_not_found; return 1

	fi

}

#=====================================================#
# PeaZip
#=====================================================#
function _peazip()
{
peazip_server='https://osdn.net/dl/peazip'
peazip_pag='https://osdn.net/projects/peazip/downloads'

peazip_html=$(wget -q "$peazip_pag" -O- | grep -m 1 "portable.*tar.gz" | awk '{print $6}')
peazip_pacote=$(echo "$peazip_html" | sed 's/.*peazip_portable/peazip_portable/g;s/\/\".*//g')
peazip_url_download="$peazip_server/$peazip_pacote"
local path_arq="$dir_user_cache/$peazip_pacote"

_dow "$peazip_url_download" "$path_arq" --wget

	# --download-only
	[[ "$download_only" == 'on' ]] && { echo "$(cl 32)==> $(cl)Feito somente download."; return 0; }
	
	[[ -x $(command -v peazip 2> /dev/null) ]] && { _msg_pack_instaled 'peazip'; return 0; }

"$Script_UnPack" "$path_arq" "$dir_temp"

[[ $? == '0' ]] || { echo "$(cor 31)==> $(cor)Falha: (unpack) retornou [Erro]"; return 1; }

echo "$(cor 32)==> $(cor)Instalando"

cd "$dir_temp" && mv -v $(ls -d peazip*) "$dir_temp/peazip-amd64" 1> /dev/null
chmod -R +x "$dir_temp/peazip-amd64"

sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.desktop "${array_peazip_dirs[0]}" # .desktop
sudo mv "$dir_temp"/peazip-amd64/FreeDesktop_integration/peazip.png "${array_peazip_dirs[1]}" # PNG.
sudo mv "$dir_temp"/peazip-amd64/peazip "${array_peazip_dirs[2]}" # binario.
sudo mv "$dir_temp"/peazip-amd64 "${array_peazip_dirs[3]}" # dir.

if [[ -x $(which peazip 2> /dev/null) ]]; then
	_info_msgs; echo "==> peazip instalado com sucesso."
	return 0

else
	echo "$(cor 31)==> $(cor)Falha"
	return 1

fi
}

#-----------------------------------------------------#
