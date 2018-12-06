#!/bin/bash

NODE=$1

# Install CentOS/RHEL
# yum install lshw util-linux 
# Install SLES/Suse
# zypper in lshw util-linux 
# Install Ubuntu
# apt-get install lshw util-linux 

#
# Check for required commands
#
ssh $NODE '
COMMANDS="lshw lsblk" 
for cmd in $COMMANDS ; do
    if ! command -v $cmd >/dev/null 2>&1 ;then
        echo "Command $cmd not found, ensure it is installed for program to continue"
        echo "Example install commands for various platforms are available in this script"
        echo "Exiting..."
        exit 1
    fi
done
'

OPTIONAL_CMDS=$(ssh $NODE '
CMDS="lscpu lsusb lspci lsscsi dmidecode"
for cmd in $CMDS ; do
    if command -v $cmd >/dev/null 2>&1 ; then
        echo -n "$cmd "
    fi
done
')

#
# Collect data
#
TMPDIR=$(mktemp -d)
pushd $TMPDIR
ssh $NODE "lshw -xml" > lshw-xml
ssh $NODE "lsblk -a -P" > lsblk-a-P
ssh $NODE "lshw -short" > lshw-short
ssh $NODE "ifconfig -a" > ifconfig-a
ssh $NODE "fdisk -l" > fdisk-l
ssh $NODE "rpm -qa || dpkg -l" > packages
if [[ $OPTIONAL_CMDS == *"lscpu"* ]] ; then ssh $NODE "lscpu" > lscpu ; fi
if [[ $OPTIONAL_CMDS == *"lsusb"* ]] ; then ssh $NODE "lsusb -v" > lsusb-v ; fi
if [[ $OPTIONAL_CMDS == *"lspci"* ]] ; then ssh $NODE "lspci -v" > lspci-v ; fi
if [[ $OPTIONAL_CMDS == *"lsscsi"* ]] ; then ssh $NODE "lsscsi" > lsscsi ; fi
if [[ $OPTIONAL_CMDS == *"dmidecode"* ]] ; then ssh $NODE "dmidecode" > dmidecode ; fi
popd

#
# Zip data
#
ZIPFILE="/tmp/$(ssh $NODE "hostname -s").zip"
pushd $TMPDIR
zip -r $ZIPFILE ./*
popd

rm -rf $TMPDIR
echo "Data written to $ZIPFILE"
