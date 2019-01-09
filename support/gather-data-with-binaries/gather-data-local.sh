#!/bin/bash

PRIGROUP=$1
SECGROUPS=$2

# Install CentOS/RHEL
# yum install lshw util-linux redhat-lsb-core
# Install SLES/Suse
# zypper in lshw util-linux lsb-release
# Install Ubuntu
# apt-get install lshw util-linux lsb-release 

#
# Command Paths
#
BASEDIR="$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)"
BINDIR="$BASEDIR/bin"
LSHW="$BINDIR/lshw-static"
LSBLK="$BINDIR/lsblk"
OS_RELEASE="$BINDIR/os-release"
FDISK="$BINDIR/fdisk"
LSCPU="$BINDIR/lscpu"
LSPCI="$BINDIR/lspci"
IFCONFIG="$BINDIR/ifconfig"
IP="$BINDIR/ip"


#
# Check for required commands
#
OPTIONAL_CMDS=$(
CMDS="lscpu lsscsi dmidecode"
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
# Command Versions
cat << EOF > command_versions
lshw: $($LSHW -version)
lsblk: $($LSBLK --version)
lspci: $($LSPCI --version)
ifconfig: $($IFCONFIG --version)
ip: $($IP -V)
fdisk: $($FDISK -v)
packager: $(rpm --version || dpkg --version)
uname: $(uname --version)
$(for cmd in $OPTIONAL_CMDS ; do
echo "$cmd: $($cmd --version 2>&1 )"
)
EOF

# Groups
cat << EOF > groups
primary_group: $PRIGROUP
secondary_groups: $SECGROUPS
EOF

# Everything Else
$LSHW -xml > lshw-xml
$LSBLK -a -P > lsblk-a-P
$LSHW -short > lshw-short
$IFCONFIG -a > ifconfig-a
$IP -o addr > ip-o-addr
$FDISK -l > fdisk-l
(rpm -qa || dpkg -l) > packages
$OS_RELEASE > os-release
uname -a > uname-a
cat /sys/kernel/debug/usb/devices > usb-devices
$LSCPU > lscpu 
$LSPCI -v -mm > lspci-v-mm
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
