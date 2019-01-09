#!/bin/bash

PRIGROUP=$1
SECGROUPS=$2

#
# Command Paths
#
BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
BINDIR="$BASEDIR/bin"

DMIDECODE="$BINDIR/dmidecode"
FDISK="$BINDIR/fdisk"
IFCONFIG="$BINDIR/ifconfig"
IP="$BINDIR/ip"
LSBLK="$BINDIR/lsblk"
LSCPU="$BINDIR/lscpu"
LSHW="$BINDIR/lshw-static"
LSPCI="$BINDIR/lspci"
LSSCSI="$BINDIR/lsscsi"
OS_RELEASE="$BINDIR/os-release"
UNAME="$BINDIR/uname"
ZIP="$BINDIR/zip"

#
# Collect data
#
TMPDIR=$(mktemp -d)
pushd $TMPDIR

# Command Versions
cat << EOF > command_versions
dmidecode: $($DMIDECODE --version)
fdisk: $($FDISK -v)
ifconfig: $($IFCONFIG --version)
ip: $($IP -V)
lsblk: $($LSBLK --version)
lscpu: $($LSCPU --version)
lshw: $($LSHW -version)
lspci: $($LSPCI --version)
lsscsi: $($LSSCSI --version)
packager: $(rpm --version || dpkg --version)
uname: $($UNAME --version)
EOF

# Groups
cat << EOF > groups
primary_group: $PRIGROUP
secondary_groups: $SECGROUPS
EOF

# Everything Else
$DMIDECODE > dmidecode 
$FDISK -l > fdisk-l
$IFCONFIG -a > ifconfig-a
$IP -o addr > ip-o-addr
$LSBLK -a -P > lsblk-a-P
$LSCPU > lscpu 
$LSHW -short > lshw-short
$LSHW -xml > lshw-xml
$LSPCI -v -mm > lspci-v-mm
$LSSCSI > lsscsi
$OS_RELEASE > os-release
$UNAME -a > uname-a
(rpm -qa || dpkg -l) > packages
cat /sys/kernel/debug/usb/devices > usb-devices

popd

#
# Zip data
#
ZIPFILE="/tmp/$(hostname -s).zip"
pushd $TMPDIR
$ZIP -r $ZIPFILE ./*
popd

rm -rf $TMPDIR
echo "Data written to $ZIPFILE"
