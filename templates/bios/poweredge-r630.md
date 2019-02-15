# Dell Power Edge R630 (Intel Haswell/Broadwell)

## Hardware Overview

 * 1U Enterprise server
 * Ships with one or two 550W or 750W PSU
 * Nodes are dual-socket Xeon E5-2600v3; supports 1 or 2 CPUs (max 145W)
 * Two chassis versions; 8 x 2.5" disks with DVD, or 10 x 2.5" disks
 * Two PCI backplane versions; 
    * 3 x low-profile slots (includes risers for all slots)
    * lower cost 2 x full-width slots (2nd slot needs riser to be specially ordered)
 * 24 DIMM slots; requires 1 DIMM to boot; max of 768GB RAM (24 x 32GB); slots 8-16 require CPU2 to be installed; DIMM slot enumeration printed on chassis lid underside and matches PCB printing 
 * Ships with iDRAC8 express (shared IPMI LAN port, no KVM-over-IP) or iDRAC enterprise with dedicated port

## Profile 'Cluster Slave'
### BIOS configuration
1. Power on and press F2 to enter "System Setup"
2. Enter System BIOS and configure the following:
```
Press Default Button - Confirm to Load Default Settings -> “yes”
```
```
System Information -> Note down Firmware Revisions for BIOS
```
```
Processor Settings -> Logical Processor (HyperThreading) -> Disabled 
```
```
Boot settings -> Boot Option Sequence -> Change boot order to 1.NIC, 2.HDD
```
N.B. exit this screen by pressing ENTER, not ESC (which cancels changes)
```
System settings -> Serial communication -> Serial Communication “On with Console Redirection via COM2”
```
```
System settings -> Serial communication -> Serial Port Address “Serial Device 1: COM1, Serial Device 2: COM2”
```
```
System settings -> Serial communication -> Redirect after boot = disabled
```
```
System settings -> System profile settings -> System profile "performance"
```
```
System settings -> System security -> AC power recovery -> OFF
```
```
System settings -> Miscellaneous Settings -> F1 prompt on error = disabled
```
```
Press Finish Button -> Save Changes
```
```
iDRAC menu -> Note iDRAC (BMC) Version Numbers on Main Page
```
```
iDRAC menu -> Network -> Enable IPMI over LAN = enabled
```
```
iDRAC menu -> Front panel security -> LCD message = user-defined
```
```
iDRAC menu -> Front panel security -> User string "hostname"
```
```
Exit -> Save Settings and Exit
```
3. Note configuration details on asset record sheet

***
### iDRAC configuration

 1. Configure iDRAC in BIOS as per iDRAC options in the BIOS configuration (above)
 2. Configure user/password network information via ipmitool using the following parameters
``` 
 LAN_CHANNEL=1
 ADMIN_USER_ID=2 
``` 
 3. N.B. password for user must be at least 8 characters, contain capital letters and numbers
 4. iDRAC serial console is connected to ttyS1 (COM2) speed 115,200 parity 8n1. 

***
### Upgrading firmware

1. Two primary firmware payloads are required which must be compatible with each other. Firmware must be applied in the following order:
 * iDRAC firmware; can be upgraded from Linux without restarting node
 * BIOS; new firmware is uploaded to iDRAC and applied by lifecycle manager on the next reboot. Failsafe firmware ROM automatically stores backup copy of firmware. 

2. Other component firmware may also be required:
 * Hard disks; usually ship with recent firmware when new, but update may be needed if drives are replaced
 * NIC; usually ship with latest firmware, but may need to be updated for new features/better performance
 * PERC (RAID card); usually ships on latest version, but may need update for older systems
 * Infiniband; Mellanox HBAs regularly ship with old firmware and should always be updated from Linux

3. Firmware can be applied from Linux using a BIN file, or from a bootable DOS environment. 
 * Linux firmware upgrade is safe for BIOS (ROM is loaded to BMC first then applied on the next reboot), but can damage the machine if an iDRAC firmware is interrupted. Take precautions to ensure that power will not be interrupted during firmware update procedure. 
 * All DOS firmware upgrades may damage the machine if interrupted while running. 

4. Download new firmware from Dell support site. 

5. If using the Linux update binaries, execute the iDRAC and BIOS update packages on the nodes. The command line switches `-f -n -q` will cause the update packages to run automatically without prompting or rebooting. iDRAC updates can take up to 30 minutes to apply, and BIOS takes around 20 seconds to install (and a reboot to apply). 

6. If using DOS firmware update packages, boot into DOS and run the updates one by one. You don't need to reboot after each one, but reboot at the end of the process. The DOS environment can be delivered via USB boot, or via PXE boot. 

7. BIOS settings usually persist across firmware updates 

***
### Configuring BIOS and iDRAC settings 

Dell provides tools to perform BIOS and BMC configuration settings from Linux. The tools often produce inconsistent behaviour when setting the configuration (depending on the installed firmware version), but are generally fairly reliable for reading the current settings in place from BIOS. 

 * Tools are available from the Dell support site in the "DTK" package
 * Most successful version historically has been "dtk_4.3_350_A00_Linux64.iso"
 * Install the following packages ONLY:
    * syscfg-4.3.0-4.33.4.el6.x86_64.rpm 
    * srvadmin-deng-7.3.0-4.13.2.el6.x86_64.rpm 
    * srvadmin-hapi-7.3.0-4.12.3.el6.x86_64.rpm 
    * srvadmin-isvc-7.3.0-4.21.4.el6.x86_64.rpm 
    * srvadmin-omilcore-7.3.0-4.72.1.el6.x86_64.rpm
 * Once installed, start the firmware management service with:
```
/opt/dell/srvadmin/sbin/srvadmin-services.sh start
```
 * Use the syscfg utility to view and change BIOS and iDRAC settings
```
/opt/dell/toolkit/bin/syscfg
```

***
### RAID disks and storage

The R630 can be supplied with:

 * No RAID controller; supports SATA disks or SSDs, or no disks at all. This configuration required no hardware setup. SAS disks are not supported without a RAID controller. RAID controller slot is empty but cannot be used for anything else. 
 * R630 supports PCI-express SSDs mounted in the front disk bays. These do not require a RAID card. 
 * PERC H330 SAS controller in onboard RAID controller slot; Supports RAID0+1 only - see hardware asset record for RAID setup info.
 * PERC H730 SAS controller in onboard RAID controller slot; includes battery (in dedicated internal slot) and 1GB RAM - PERC H730P controller has 2GB RAM; Supports RAID 0,1,5,6 - see hardware asset record for RAID setup info.
 * Requires Nagios SMART disk monitor is no RAID card is installed. 
 * Requires Nagios RAID monitor if SAS RAID card is installed. 

***
### Compatible devices

R630 always ships with one of the following NIC daughercards:
 - 4 x 1Gb RJ45 ports, Intel or broadcom
 - 2 x 10Gb SFP+ ports and 2 x 1Gb RJ45 ports, Intel or Broadcom
 - 2 x 10Gb RJ45 and 2 x 1Gb RJ45 ports, Intel or Broadcome

All ports can be configured for PXE and iSCSI boot, and iDRAC can share any port, on the base or a tagged VLAN. 

The following list of hardware is certified for installation:
 * Mellanox QDR and FDB, single and dual-port PCI-express and mez HCA; FDR cards can be factory installed
 * Intel/Qlogic TrueScale QDR Infiniband PCI-express and mez HCA
 * Intel and Broadcom, dual-port 10Gb SFP+ and 10G-baseT (copper) PCI-express and mez cards
 * Quad-port Intel gigabit NIC 
 * 12Gb and 6Gb SAS HBA, FC cards, PERC H830 external RAID card

Some simple rules for installing add-on cards:
 * The 3-PCI slot version has low-profile, half-length slots. Check physical card dimensions before installing
 * In the 2-PCI slot version, the second PCI-express riser does not ship with systems by default; order the riser if you need to fit two PCI cards
 * The system has a dedicated internal RAID card slot which the PERC H330/H730 cards fit into
 * Cards in PCI slots receive hot air from CPU and RAM; check PCI card tolerances before installing

***
## Hardware support

 * Call Dell on 01344-860456 with the service tag for the machine.
 * R630 asset tag is printed on a pull-out tag on the front of the chassis with a QR code
 * [Use this](http://creativyst.com/Doc/Articles/HT/Dell/DellNumb.htm) to convert tags to express service codes
 
Fault finding may require a DSET report to be generated. Use the latest available DSET revision, and use "RHEL6" or "RHEL7" as the OS type. DSET will not install or run properly if the LSI MegaCLI monitor is installed, so use RPM to remove this first and YUM to install it again afterwards if necessary.

***
## Known issues
 
 * Firmware upgrade tools may fail to run without various Linux dependencies 
 * Software BIOS setting tools produce inconsistent results 
 * Older iDRAC firmware had memory leaks which caused the entire server to fail after several months of running; this is fixed in recent versions, but the bug has been reintroduced more than once in the past
 * Disks, PSUs and fans are technically hot-swappable (although difficult to reach fans when powered)
 * iDRAC processors can ship with SD cards (called Vflash) which presents as /dev/sda in Linux, causing problems installing an OS; remove these cards if installed from the rear of the chassis, or internally from both sides of the PCI slot riser closest to the PSUs
 * IPMI sensors will fail to detect redundant PSUs properly if iDRAC is not set to "redundant" power; if this happens, login to the iDRAC using a web browser and check the power settings. Older firmware had a bug whereby PSU redundancy would change by itself after many months of running. Mode sometimes needs to be manually set to non-redundant and saved, then set back to redundant mode again before ipmi-sensors will report properly. 