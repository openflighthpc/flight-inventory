# HP ProLiant BL460c G8 blade (Sandy-bridge/Ivy-bridge)

## Hardware Overview

 * Single-width half-height blade (up to 16 per chassis)
 * Nodes are dual-socket Xeon E5-2600 or E5-2600v2; supports 1 or 2 CPUs (max 135W)
 * Blades come with or without RAID card; with RAID card supports up to 2 x 2.5" disks
 * Two onboard 10Gb ports (can run at 1Gb if a 1Gb switch is installed in chassis)
 * Has two PCI mez slots, which can take DP 10Gb or Infiniband cards
 * 24 DIMM slots; requires 1 DIMM to boot; max of 768GB RAM (24 x 32GB); slots 8-16 require CPU2 to be installed; DIMM slot enumeration printed on chassis lid underside and matches PCB printing 
 * Ships with iLO by default (can take iLO software license upgrades)

## Profile 'Cluster Slave'

### RAID disk configuration
If your node has RAID disks, follow these instructions to configure them:

 1. Power on the node with a VGA screen and keyboard attached.
 2. At P220 RAID card prompt, press F8 to configure
 3. Delete any logical drives configured. 
 4. Create a new logical drive; select RAID0 or RAID10 for the two disks
 5 . Choose "select boot volume" from the RAID card main menu
 6. Select LUN0 (the logical drive created in step 4)
 7. Press ESC at the main menu to exit

N.B. If you have created a new logical drive, you will need to power cycle the node before you can select it in the BIOS boot order. 

### BIOS configuration

 1. Power on the blade with VGA screen and keyboard attached
 2. Press F9 to enter system setup
 3. Enter System BIOS and configure the following:
```
System Default menu -> System default options: Confirm
```
The node will reboot automatically. 

 4. As the node boots again, press F9 again to enter BIOS settings.
 5. At the BIOS configuration screen, make these settings:
```
System Information -> Note down Firmware Revisions for BIOS and serial number for the blade
```
```
System options -> Processor options -> Intel HT Options -> Disable hyperthreading
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
Standard Boot Order (IPL) -> 2nd option -> P220i RAID volume C:
```
```
Server availability -> ASR status -> disabled
```
```
Server availability -> Automatic power on -> disabled
```
 6. Press ESC to exit and save changes
 7. Note configuration details on asset record sheet

***

## Hardware support

 * Call HP on 0845 161 0030 with the serial number for the machine.
 * BL460 asset tag is printed on a pull-out tag on the front of the chassis with a barcode
 
***
## Known issues
 
 * Blade chassis switches must be in correct interconnect bays in order to connect to onboard server NICs  
 * Mez card slots are not well labelled onboard the G8 blade; use the online documentation to determine which port is which
 * Servers take a long time to cold-boot; > 5 minutes with lots of PCI adapters installed
