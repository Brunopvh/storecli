#!/usr/bin/env bash
#
# Modificado em: 2020-01-11 
#
# Use: source platform.sh
# echo "Type = $os_type" 
# echo "Id = $os_id" 
# echo "Release = $os_release" 
# echo "Version=$os_version" 
# echo "Codename = $os_codename" 
# echo "Name = $sysname"
#

os_type=''
os_id=''
os_release=''
os_version=''
os_codename=''
sysname=''

#=============================================#
# os_type - Kernel
#=============================================#
os_type=$(uname -s)


if [[ -f '/usr/local/etc/os-release' ]]; then
	file_release='/usr/local/etc/os-release'
elif [[ "$os_type" == 'Linux' ]]; then
	file_release='/etc/os-release'
fi

#=============================================#
# os_id
#=============================================#
if [[ $os_type == 'FreeBSD' ]]; then
	os_id=$(uname -r)
	
elif [[ $os_type == 'Linux' ]]; then
	os_id=$(grep '^ID=' "$file_release" | sed 's/.*=//g;s/\"//g') # debian/ubuntu/linuxmint/fedora....
fi


#=============================================#
# os_version
#=============================================#
if [[ "$file_release" ]]; then
	os_version=$(grep -m 1 '^VERSION_ID=' "$file_release" | sed 's/.*VERSION_ID=//g;s/\"//g')

elif [[ "$os_type" == 'FreeBSD' ]]; then
	os_version=$(uname -r)
fi

#=============================================#
# os_release
#=============================================#
if [[ "$file_release" ]]; then
	os_release=$(grep -m 1 '^VERSION=' "$file_release" | sed 's/.*VERSION=//g;s/\"//g;s/(//g;s/)//g;s/ //g')
fi


#=============================================#
# Codename
#=============================================#
if [[ "$file_release" ]] && [[ $(grep '^VERSION_CODENAME=' "$file_release") ]]; then
	os_codename=$(grep -m 1 '^VERSION_CODENAME=' "$file_release" | sed 's/.*VERSION_CODENAME=//g')
fi

#=============================================#
# Sysname = id+version
#=============================================#
if [[ "$os_type" == 'Linux' ]]; then
	sysname="${os_id}${os_version}"
elif [[ "$os_type" == 'FreeBSD' ]]; then
	sysname="$(uname)$(uname -r)"
	sysname="${sysname,,}"
fi








