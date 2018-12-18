#!/bin/bash

NODE=$1
PRIGROUP=$2
SECGROUPS=$3

# Install CentOS/RHEL
# yum install lshw util-linux redhat-lsb-core
# Install SLES/Suse
# zypper in lshw util-linux lsb-release
# Install Ubuntu
# apt-get install lshw util-linux lsb-release

#
# Check for required commands
#
ssh $NODE '
COMMANDS="lshw lsblk lsb_release" 
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
# Command Versions
cat << EOF > command_versions
lshw: $(ssh $NODE "lshw -version")
lsblk: $(ssh $NODE "lsblk --version")
ifconfig: $(ssh $NODE "ifconfig --version")
fdisk: $(ssh $NODE "fdisk -v")
packager: $(ssh $NODE "rpm --version || dpkg --version")
uname: $(ssh $NODE "uname --version")
lsb_release: $(ssh $NODE "lsb_release --version")
$(for cmd in $OPTIONAL_CMDS ; do
VERS=$(ssh $NODE "$cmd --version 2>&1")
echo "$cmd: $VERS"
)
EOF

# Groups
cat << EOF > groups
primary_group: $PRIGROUP
secondary_groups: $SECGROUPS
EOF

# Everything Else
ssh $NODE "lshw -xml" > lshw-xml
ssh $NODE "lsblk -a -P" > lsblk-a-P
ssh $NODE "lshw -short" > lshw-short
ssh $NODE "ifconfig -a" > ifconfig-a
ssh $NODE "fdisk -l" > fdisk-l
ssh $NODE "rpm -qa || dpkg -l" > packages
ssh $NODE "cat /etc/os-release" > os-release
ssh $NODE "uname -a" > uname-a
ssh $NODE "lsb_release -a" > lsb_release-a
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
