#!/bin/bash

#
# Global Vars
#
TYPES="logical physical"

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
# Functions
#
print_help() {
    echo "Gather Data - Collect physical and logical system configuration information"
    echo ""
    echo "./gather-data.sh -p PRIMARY_GROUP [-g comma,separate,secondary,groups] [-t check_type] [-v]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help page"
    echo "  -p, --primary       Primary group for the node [REQUIRED]"
    echo "  -g, --groups        Comma-separated list of secondary groups for the node"
    echo "  -t, --type          Type of check to run (physical or logical), if not provided"
    echo "                      then both types will be collected"
    echo "  -v, --verbose       Print additional debug information"
}

#
# Arg Parsing
#
while test $# -gt 0 ; do
    case "$1" in
        -h|--help)
            print_help
            exit 0
            ;;
        -p|--primary)
            shift

            # Ensure argument passed
            if test $# -gt 0 ; then
                export PRIGROUP=$1
            else
                echo -e "ERROR: No primary groups provided\n"
                print_help
                exit 1
            fi
            shift
            ;;
        -g|--groups)
            shift

            # Ensure argument passed
            if test $# -gt 0 ; then
                export SECGROUPS=$1
            else
                echo -e "ERROR: No secondary groups provided\n"
                print_help
                exit 1
            fi
            shift
            ;;
        -t|--type)
            shift

            # Ensure argument passed
            if test $# -gt 0 ; then
                export TYPE=$1
                if [[ ! $TYPES == *"$TYPE"* ]] ; then
                    echo -e "ERROR: $TYPE is an invalid type, must be one of: $TYPES\n"
                    print_help
                    exit 1
                fi
                TYPES="$TYPE"
            else
                echo -e "ERROR: No type provided\n"
                print_help
                exit 1
            fi
            shift
            ;;
        -v|--verbose)
            shift
            VERBOSE=true
            ;;
        *)
            echo -e "ERROR: Unrecognised argument provided\n"
            print_help
            exit 1
            ;;
    esac
done

#
# Validation
#
if [ -z $PRIGROUP ] ; then
    echo -e "ERROR: Must provide a primary group\n"
    print_help
    exit 1
fi

if [ ! -z $VERBOSE ] ; then
    echo "PRIGROUP = $PRIGROUP"
    echo "SECGROUPS = $SECGROUPS"
    echo "TYPES = $TYPES"
fi

#
# Collect data
#
TMPDIR=$(mktemp -d)
pushd $TMPDIR

# Command Versions
cat << EOF > command_versions
$(if [[ $TYPES == *"physical"* ]] ; then
echo "# Physical
dmidecode: $($DMIDECODE --version 2>&1)
fdisk: $($FDISK -v 2>&1)
lsblk: $($LSBLK --version 2>&1)
lscpu: $($LSCPU --version 2>&1)
lshw: $($LSHW -version 2>/dev/null)
lspci: $($LSPCI --version 2>&1)
lsscsi: $($LSSCSI --version 2>&1)"
fi )
$(if [[ $TYPES == *"logical"* ]] ; then
echo "# Logical
ifconfig: $($IFCONFIG --version 2>&1)
ip: $($IP -V 2>&1)
packager: $(rpm --version 2>/dev/null || dpkg --version 2>/dev/null |head -1)
uname: $($UNAME --version 2>&1 |head -1)"
fi)
EOF

# Groups
cat << EOF > groups
primary_group: $PRIGROUP
secondary_groups: $SECGROUPS
EOF

# Physical
if [[ $TYPES == *"physical"* ]] ; then
$DMIDECODE > dmidecode 
$FDISK -l > fdisk-l
$LSBLK -a -P > lsblk-a-P
$LSCPU > lscpu 
$LSHW -short > lshw-short
$LSHW -xml > lshw-xml
$LSPCI -v -mm > lspci-v-mm
$LSSCSI > lsscsi
cat /sys/kernel/debug/usb/devices > usb-devices
fi

# Logical
if [[ $TYPES == *"logical"* ]] ; then
$IFCONFIG -a > ifconfig-a
$IP -o addr > ip-o-addr
$OS_RELEASE > os-release
$UNAME -a > uname-a
(rpm -qa || dpkg -l) > packages
fi

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
