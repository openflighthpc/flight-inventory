# SuperMicro X10DRT-PIBF dual-socket Intel Xeon server

## Hardware Overview

 * One SuperMicro TwinPro2 chassis can hold up to 4 x SuperServer X10DRT-PIBF node
 * X10DRT-PIBF supports up to 2 x Intel Xeon E5-2600v3 series CPUs 
 * 16 DDR4 DIMM slots
 * 3 x PCIe slots (2 x PCIe x16 + 1 x PCIe x8)
 * 1 x dedicated IPMI gigabit Ethernet port 

## Profile 'Cluster Basic'

***
### BIOS configuration
1. Power on and press `Del` to enter BIOS, note the firmware revisions during boot
2. Enter first pass BIOS and configure the following:
```
Save & Exit -> Restore optimised defaults
```
```
Advanced -> Boot Feature -> Quiet boot -> Disabled
```
```
Advanced -> Boot Feature -> Wait for F1 if error -> Disabled
```
```
Advanced -> Boot Feature -> Restore on AC power loss -> Stay off
```
```
Advanced -> CPU Configuration -> Hyperthreading (All) -> Disabled
```
```
Advanced -> CPU Configuration -> Advanced Power Management Configuration -> Energy performance bias setting -> Performance
```
```
Advanced -> Serial Port Console Redirection -> SOL/COMZ Console Redirection Settings -> Redirection after BIOS boot -> Bootloader
```
```
Advanced -> Boot -> Boot mode select -> Legacy
```
```
Advanced -> Boot -> Change boot order -> Network then hard disk (all others disabled)
```
```
Save & Exit
```
```
Save changes & reset
```