#!/bin/bash

# Install CentOS/RHEL
# yum install lshw util-linux 
# Install SLES/Suse
# zypper in lshw util-linux 
# Install Ubuntu
# apt-get install lshw util-linux 

#
# Check for required commands
#
COMMANDS="lshw lsblk"

for cmd in $COMMANDS ; do
    if ! command -v $cmd >/dev/null 2>&1 ;then
        echo "Command '$cmd' not found, ensure it is installed for program to continue"
        echo "Example install commands for various platforms are available in this script"
        echo "Exiting..."
        exit 1
    fi
done

OPTIONAL_CMDS=$(
CMDS="lscpu lsusb lspci lsscsi dmidecode"
for cmd in $CMDS ; do
    if command -v $cmd >/dev/null 2>&1 ; then
        echo -n "$cmd "
    fi
done)

#
# Collect data
#
TMPDIR=$(mktemp -d)
pushd $TMPDIR
lshw -xml > lshw-xml
lsblk -a -P > lsblk-a-P
lshw -short > lshw-short
ifconfig -a > ifconfig-a
fdisk -l > fdisk-l
rpm -qa || dpkg -l > packages
if [[ $OPTIONAL_CMDS == *"lscpu"* ]] ; then lscpu > lscpu ; fi
if [[ $OPTIONAL_CMDS == *"lsusb"* ]] ; then lsusb -v > lsusb-v ; fi
if [[ $OPTIONAL_CMDS == *"lspci"* ]] ; then lspci -v > lspci-v ; fi
if [[ $OPTIONAL_CMDS == *"lsscsi"* ]] ; then lsscsi > lsscsi ; fi
if [[ $OPTIONAL_CMDS == *"dmidecode"* ]] ; then dmidecode > dmidecode ; fi
popd

#
# Zip data
#
ZIPFILE="/tmp/$(hostname -s).zip"
pushd $TMPDIR
zip -r $ZIPFILE ./*
popd

rm -rf $TMPDIR
echo "Data written to $ZIPFILE"
