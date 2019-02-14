# HP C7000 Blade Enclosure

## Configuring a new chassis

* Unpack chassis and install into rack
* Install all blades, switches and onboard administrator (OA) modules before powering up
* Note down the OA password, which is printed on the bottom of the OA itself when you eject it from the chassis
* Power on the chassis; wait for it to boot. New blades are usually set to power-on by default. 
* Use the chassis LCD screen and controls to set the IP address of the OA(s)
* Connect a laptop with a browser to the OA network port
* Browse to the chassis IP address
* Use username "Administrator" and the password printed on the OA module you're connecting to
* Once logged in, select "First installation" wizard from the drop-down menu
* Follow the instructions to configure the chassis


## Resetting OA Password

If the OA password has been lost or forgotten, the password can be reset using the following method:

* Using your workstation or laptop, create a file named `reset_password.cfg` and insert the following contents - with the desired username and password, then save to a USB key

`SET USER PASSWORD "admin" "adminpass"`

* Plug the USB key into the active OA USB slot
* Using the chassis screen, select `USB Key Menu`, then click OK
* Select `Restore Configuration`, then select `reset_password.cfg`
* Confirm the operation, then wait for the OA to reboot. Once the OA has been rebooted, the new username and password will be active.

## Restoring to factory defaults

The following steps can be used to restore the HP C7000 Chassis and its blade servers to factory defaults.

* Insert all power cables and power on
* Wait for the chassis and all of the blades to boot
* Using the chassis screen, navigate to `Enclosure Settings` and set OA1 to:

**IP**: (example) 10.11.0.5

**Subnet Mask**: (example) 255.255.0.0

**Gateway**: (example) 10.11.0.1

* Insert Ethernet cable into OA iLO port, then connect to workstation/laptop etc
* Connect to the OA using `telnet 10.11.0.5`
* Log in with the previously set or default administrator username and password
* The chassis and its blades can be reset with the command

```SET FACTORY```

* Answer `YES`
* The process will take approximately 4 minutes
* Once the chassis has reset, the chassis is ready for configuration via the GUI at https://10.11.0.5 etc.

## Known issues

* Chassis cannot properly control what blades do when AC power is first applied. Some blades allow you set this in the "Server availability" menu, but some blades have had this option removed. At least two different blades have had firmware releases which have incorrectly hidden this function, meaning that there is no way to prevent these blades from powering-on when power is first applied to the chassis.
* It can be difficult to work out which interconnect slot switches need to be in to be connected to the correct mez card on blades. Refer to the blade documentation for assistance, and use the green Ethernet link lights on the front of the blades to help identify the correct slot. 
* Some switches do not allow bios-devname support to complete properly in RHEL6 (although this seems to work fine with RHEL7). 