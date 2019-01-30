# HP ProLiant BL360 G9 1U server (Haswell/Broadwell Xeon CPU)

## Hardware Overview

 * 1U, 2-processor Enterprise Server
 * Nodes are dual-socket Xeon E5-2600v3; supports 1 or 2 CPUs (max 145W)
 * Server comes with or without RAID card; with RAID card supports up to 10 x 2.5" disks
 * Four onboard 1Gb ports, plus dedicated iLO port
 * Has up to 3 low-profile PCI slots, which can take DP 10Gb, FC, SAS or Infiniband cards
 * 24 DIMM slots; requires 1 DIMM to boot; max of 768GB RAM (24 x 32GB); slots 12-24 require CPU2 to be installed; DIMM slot enumeration printed on chassis lid underside and matches PCB printing. 135W/145W CPU support reduces number of DIMMs from 24 to 16
 * Ships with iLO by default (can take iLO software license upgrades)

## Profile 'Cluster Slave'

### BIOS configuration

N.B. HP Gen9 servers ship with UEFI BIOS enabled by default. Many BIOS options (including legacy BIOS boot order) can only be configured in standard BIOS mode, so it is necessary to switch modes several times when configuring servers manually. Follow the instructions below carefully, including waiting for boot cycles to fully complete before configuring. 

 1. Power on the node with VGA screen and keyboard attached
 2. Press F9 to enter system setup
 3. Enter System BIOS, and select ```System options``` from the menu.
 4. Select ```BIOS/Platform configuration (RBSU)``` from the next menu.
 5. Press the F7 key to load defaults, and press ```Enter``` to confirm and reboot.
 6. As the node boots again, press F9 again to enter BIOS settings.
 7. At the BIOS configuration screen, select ```System options``` from the menu.
 8. Select ```BIOS/Platform configuration (RBSU)``` from the next menu.
 9. Make the following BIOS configuration settings:
```
System options -> Serial port options -> Virtual serial port -> COM2
```
```
System Options -> Processor options -> Intel Hyperthreading -> disable
```
```
System options -> Embedded NICs -> NIC2 boot options -> Select "Network boot PXE"
```
```
System options -> Serial port options -> Virtual serial port -> COM2
```
```
System options -> BIOS serial console & EMS -> Port -> COM2
System options -> BIOS serial console & EMS -> Baud -> 115200
System options -> BIOS serial console & EMS -> EMS -> COM2
```
```
Power Management -> HP Power Profile -> Select "Maximum performance"
```
```
Standard Boot Order (IPL) -> 1st option -> NIC1
Standard Boot Order (IPL) -> 2nd option -> RAID volume C:
```
```
Server availability -> ASR status -> disabled
```
```
Server availability -> AC power recovery -> Power off
```

 6. Press ESC to exit and save changes
 7. Note configuration details on asset record sheet

***

## Hardware support

 * Call HP on 0845 161 0030 with the serial number for the machine.
 * BL460 asset tag is printed on a pull-out tag on the front of the chassis with a barcode
 
***
## Known issues
 
 * Servers take a long time to cold-boot; > 5 minutes with lots of PCI adapters installed
 * Servers by default ship with UEFI BIOS enabled, which does not allow standard PXE boot. To configure legacy boot options requires 3 reboots of the server, each of which takes 4-8 minutes. 
 * Unless the optional iLO advanced license is purchased, the graphical iLO display will randomly disconnect every 30 seconds after POST has been completed. This can prevent users from controlling the GRUB menu, although reconnecting will usually give you another 10-30 seconds before disconnecting again. 
 * RHEL6.6 kernels may need "edd=off" option to boot if a SATA DVDROM drive is installed without any disks (or with disks on separate SAS RAID controller)
