# Dell Power Edge R515 (AMD Opteron 4000 series)

## Hardware Overview

 * 2U Entry-level AMD-powered server
 * All chassis ship with two 750W PSUs
 * Two chassis versions; 8 x 3.5" disks with DVD, or 12 x 3.5" disks with 2 x 2.5" disks internally
 * Both chassis include 1 x PCIeG2x8 slot and 2 x PCIeG2x4 slots, plus dedicated SAS RAID card slot
 * All three PCI slots are standard height / half-length
 * 8 DIMM slots; requires 1 DIMM to boot; max of 256GB RAM (8 x 32GB); slots 4-8 require CPU2 to be installed; DIMM slot enumeration printed on chassis lid underside and matches PCB printing 
 * Ships with baseboard BMC only, which provides full IPMI v2.0 spec via shared LAN port; can be upgraded to iDRAC6 express or enterprise (dedicated LAN port)

## Profile 'Cluster Slave'
![draft](http://upload.wikimedia.org/wikipedia/commons/f/ff/DRAFT_ICON.png)
# *** BIOS SETTINGS TO BE CONFIRMED ***
***
### BIOS configuration
1. Power on and press F2 to enter BIOS, note the firmware revisions during boot
2. Enter first pass BIOS and configure the following:
```
Exit -> Load Optimal Defaults -> “yes”
```
```
System settings -> Boot settings -> BIOS Boot settings -> Change boot order to 1.NIC, 2.HDD, 3.Embedded-SATA
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
System settings -> System security -> AC power recovery -> headnode = ON, compute node = OFF
```
```
System settings -> Miscellaneous Settings -> Report keyboard error = off
```
```
System settings -> Miscellaneous Settings -> F1 prompt on error = disabled
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
![draft](http://upload.wikimedia.org/wikipedia/commons/f/ff/DRAFT_ICON.png)
# *** iDRAC SETTINGS TO BE CONFIRMED ***
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
 * BIOS; new firmware is uploaded to iDRAC and applied by BMC on next reboot. No failsafe firmware ROM.

2. Other component firmware may also be required:
 * Hard disks; usually ship with recent firmware when new, but update may be needed if drives are replaced
 * NIC; usually ship with latest firmware, but may need to be updated for new features/better performance
 * PERC (RAID card); usually ships on latest version, but may need update for older systems
 * Infiniband; Mellanox HBAs regularly ship with old firmware and should always be updated from Linux. Note that Infiniband PCI-express gen3 cards (e.g. Mellanox Connect-X3 and Connect-IB) are not supported by Dell (although do work at gen2 speed). 

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
 * Note that this server can ship with just BMC (i.e. no iDRAC installed). In this configuration, BMC settings can only be controlled via the BIOS menu, or by using "ipmitool". The Dell "syscfg" tool can only work with iDRAC cards. 
***
### RAID disks and storage

The R515 can be supplied with:

 * No RAID controller (8-disk chassis only); supports SATA disks or SSDs, or no disks at all. This configuration requires no hardware setup. SAS disks are not supported without a RAID controller. RAID controller slot is empty but cannot be used for anything else. 
 * PERC H200 SAS controller in onboard RAID controller slot; Supports RAID0+1 only - see hardware asset record for RAID setup info.
 * PERC H700 SAS controller in onboard RAID controller slot; includes battery (in dedicated internal slot) and 512MB or 1GB RAM (extra cost upgrade); Supports RAID 0,1,5,6 - see hardware asset record for RAID setup info.
 * Requires Nagios SMART disk monitor is no RAID card is installed. 
 * Requires Nagios RAID monitor if SAS RAID card is installed. 
 * Note - 12-disk chassis can include 2 x internal 2.5" disks mounted in the centre of the machine. These disks are connected using ports 5-8 of the RAID controller, along with the front 12 disk slots which are connected to ports 1-4 via a SAS expander. **Customer must power off the server to replace failed internal 2.5" disks.**

***
### Compatible devices

 * R515 always ships with two onboard 1Gb Ethernet ports

Both ports can be configured for PXE boot, and iDRAC can share the first (left-hand) port only. 

The following list of hardware is certified for installation:
 * Mellanox QDR single and dual-port PCI-express HCA; cards can be factory installed
 * Intel/Qlogic TrueScale QDR Infiniband PCI-express 
 * Intel and Broadcom, dual-port 10Gb SFP+ and 10G-baseT (copper) PCI-express cards
 * Dual and quad-port gigabit NIC, Intel and Broadcom
 * 6Gb SAS HBA, FC cards, PERC H800 external RAID card with 512MB/1GB/2GB RAM

Some simple rules for installing add-on cards:
 * The top PCI-express slot is x8 width; install high bandwidth IB cards in this slot
 * The system has a dedicated internal RAID card slot which the PERC cards fit into
 * Cards in PCI slots receive hot air from CPU and RAM; check PCI card tolerances before installing

***
## Hardware support

 * Call Dell on 01344-860456 with the service tag for the machine.
 * 8-disk chassis has asset tag on a pull-out tag on the front of the server
 * 12-disk chassis has asset tag on the front left-hand rack ear
 * [Use this](http://creativyst.com/Doc/Articles/HT/Dell/DellNumb.htm) to convert tags to express service codes
 
Fault finding may require a DSET report to be generated. Use the latest available DSET revision, and use "RHEL6" or "RHEL7" as the OS type. DSET will not install or run properly if the LSI MegaCLI monitor is installed, so use RPM to remove this first and YUM to install it again afterwards if necessary.

***
## Known issues
 
 * Firmware upgrade tools may fail to run without various Linux dependencies 
 * Software BIOS setting tools produce inconsistent results 
 * Internal fans and 2.5" disks are not hot-swappable, and require server to be powered off for maintenance
 * iDRAC processors can ship with SD cards (called Vflash) which presents as /dev/sda in Linux, causing problems installing an OS; remove these cards if installed from the rear of the chassis, or internally from both sides of the PCI slot riser closest to the PSUs
 * Inconsistent behaviour when only one CPU is installed, particularly with Infiniband cards installed; CPUs are cheap, so use two!