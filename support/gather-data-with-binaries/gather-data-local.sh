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
LSB_RELEASE="$BINDIR/lsb_release"
FDISK="$BINDIR/fdisk"
LSCPU="$BINDIR/lscpu"


#
# Check for required commands
#
COMMANDS="lshw lsblk lsb_release"

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
# Command Versions
cat << EOF > command_versions
lshw: $(lshw -version)
lsblk: $(lsblk --version)
ifconfig: $(ifconfig --version)
fdisk: $(fdisk -v)
packager: $(rpm --version || dpkg --version)
uname: $(uname --version)
lsb_release: $(lsb_release --version)
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
lshw -xml > lshw-xml
lsblk -a -P > lsblk-a-P
lshw -short > lshw-short
ifconfig -a > ifconfig-a
fdisk -l > fdisk-l
(rpm -qa || dpkg -l) > packages
cat /etc/os-release > os-release
uname -a > uname-a
lsb_release -a > lsb_release-a
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
