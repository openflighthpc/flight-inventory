# Dell Power Edge C4130 (Intel Haswell/Broadwell)

## Hardware Overview

 * 1U cloud/HPC GPU server
 * Nodes is dual-socket Xeon E5-2600v3; supports 1 or 2 CPUs (max 145W)
 * Four front PCIg3-x16 GPU slots, supporting dual-height GPUs up to 335W each
 * 16 DIMM slots; requires 1 DIMM to boot; max of 512GB RAM (16 x 32GB); slots 8-16 require CPU2 to be installed; DIMM slot enumeration printed on chassis lid underside and matches PCB printing 
 * Ships with iDRAC8 enterprise with dedicated port
 * Dual PSU option supports 2 x rear-mounted 1.8" SATA SSDs only
 * Single PSU option can support up to 4 x 2.5" disks with PERC H330 card (drives are mounted in empty PSU tray)

## Profile 'Cluster Slave'
### BIOS configuration
1. Power on and press F2 to enter "System Setup"
2. Enter System BIOS and configure the following:
```
Press Default Button - Confirm to Load Default Settings -> “yes”
```
3. Press ESC, save settings, press ESC again to reboot.
4. Server reboots; press F2 to enter "System Setup"
5. Enter System BIOS and configure the following:
```
System Information -> Note down Firmware Revisions for BIOS, and server service tag
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

### RAID disks and storage

The C4130 can be supplied with:

 * No RAID controller; supports one or two 1.8" SSDs, or no disks at all. This configuration required no hardware setup. PCI slot 1 (low-profile) is empty and can be used for something else. 
 * PERC H330 SAS controller can be installed in PCI slot-1; Supports RAID0+1 only - see hardware asset record for RAID setup info.
 * Requires Nagios SMART disk monitor is no RAID card is installed. 
 * Requires Nagios RAID monitor if SAS RAID card is installed. 

***
### Compatible devices

C4130 always ships with the following NICs:
 - 2 x 1Gb RJ45 ports, Intel

All ports can be configured for PXE and iSCSI boot, and iDRAC can share any port, on the base or a tagged VLAN. 

The following list of hardware is certified for installation:
 * 1 or 2 Mellanox IB cards, single or dual-port; 2 single-port cards installed in rear PCI-slots 1 and 2 are electrically connected to CPUs 1 and 2, providing a valid configuration with 2 x GPU cards (in centre two slots) for Nvidia GPU-direct
 * 1 x Intel/Qlogic TrueScale QDR Infiniband PCI-express HCA (slot 2 only)
 * 1 x PERC H330 (slot 1 only)
 * 1 or 2 x 10Gb DP cards (slots 1 or 2)
 * Nvidia GPU cards in slots 3,4,5,6; refer to the user manual for electrical slot widths (x8 or x16)


***
## Hardware support

 * Call Dell on 01344-860456 with the service tag for the machine.
 * C4130 asset tag is printed on a pull-out tag on the front of the chassis with a QR code
 * [Use this](http://creativyst.com/Doc/Articles/HT/Dell/DellNumb.htm) to convert tags to express service codes
 
Fault finding may require a DSET report to be generated. Use the latest available DSET revision, and use "RHEL6" or "RHEL7" as the OS type. DSET will not install or run properly if the LSI MegaCLI monitor is installed, so use RPM to remove this first and YUM to install it again afterwards if necessary.

***
## Known issues

 * Chassis is extremely long (~100cm), so will not fit in 1000mm deep racks. Server chassis obscures 0U PDU sockets mounted in same rack, and will not fit alongside APC PDUs with a protruding trip unit. Be careful to observe copper Infiniband cable bend radii when cabling. 
 * Chassis are heavy and will deform if lifted at either end, or from a corner. Support the servers in the middle when transporting. 
 * The front top access hatch can be removed with servers still mounted in a rack to access the GPUs, but servicing of CPU/RAM/disk/PCI devices requires the server to be removed from the rack.  
 * Not all GPUs always get a full-speed PCI slot in all configurations; refer to the manual for details 
 * Fans are not hot-swappable; PSUs cannot be locked, allowing removal in single PSU version of the server
 * Servers are noisy, even at idle. Early firmware revisions run fans at full speed from POST. 
 * All six PCI slots use ribbon extension cables to connect the horizontal PCI risers to the ZIF PCI sockets on the server mainboard; these cables are fragile and easily damaged or dislodged during maintenance. If servers do not detect PCI devices during POST, power down and carefully reseat PCI cables before retesting.