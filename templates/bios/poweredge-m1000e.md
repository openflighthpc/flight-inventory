Document is subject to change.

***




# Dell PowerEdge M1000e Blade Chassis/Server

## Hardware Overview

### Chassis

 * 10U modular enclosure holds up to sixteen half-height or eight full-height blade servers
 * Comes standard with 9 hot pluggable, redundant fan modules
 * 3x (non-redundant) or 6x 2360W PSUs
 * 1x (standard) or 2x (optional) Chassis Management Controller(s) (CMC)
 * 

### Blade

#### 630
#### 640
#### 830

 * Nodes are dual-socket Xeon E5-2600v3 or v4; supports 1 or 2 CPUs (max 145W). 
 * Can support two workstation-class CPUs (160W), but restrictions on drive and GPU type
 * Many chassis versions including 8 x 3.5" disks, 12 x 3.5", 8 x 2.5", 24 x 2.5", also available with dual 2.5" and three 3.5" rear drive options
 * Ships with 3 x std-profile, 3 x low-profile and 2 x full-width PCI slots as standard
 * GPU kit available (factory fit only) which can support 2 x passive 335W GPUs, leaving 3 x low-profile slots available
 * 24 DIMM slots; requires 1 DIMM to boot; max of 1.5TB RAM (24 x 64GB); slots 8-16 require CPU2 to be installed; DIMM slot enumeration printed on chassis lid underside and matches PCB printing 
 * Ships with iDRAC8 express (shared IPMI LAN port, no KVM-over-IP) or iDRAC enterprise with dedicated port

***
## Profile 'Cluster Slave'
### BIOS configuration
1. Power on and press F2 to enter "System Setup"
2. Enter System BIOS and configure the following:

3. Note configuration details on asset record sheet

***
## Hardware support

 * Call Dell on 01344-860456 with the service tag for the machine.
 * asset tag is printed on a pull-out tag on the front of the chassis with a QR code
 * [Use this](http://creativyst.com/Doc/Articles/HT/Dell/DellNumb.htm) to convert tags to express service codes
 
Fault finding may require a DSET report to be generated. Use the latest available DSET revision, and use "RHEL6" or "RHEL7" as the OS type. DSET will not install or run properly if the LSI MegaCLI monitor is installed, so use RPM to remove this first and YUM to install it again afterwards if necessary.

***
## Known issues
 
 * None