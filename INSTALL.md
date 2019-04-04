# Installing Flight Inventory

## Generic

Flight Inventory requires a recent version of `ruby` (2.5.1<=) and `bundler`.
The following will install from source using `git`:
```
git clone https://github.com/openflighthpc/flight-inventory.git
cd flight-inventory
bundle install
```

The entry script is located at `bin/inventory`

Note: Interactive editing requires `vim` be installed, this is available in most standard package repositories (yum/zypper/apt/etc).

## Installing with Flight Runway

Flight Runway (and Flight Tools) provides the Ruby environment and command-line helpers for running openflightHPC tools.

To install Flight Runway, see the [Flight Runway installation docs](https://github.com/openflighthpc/flight-runway#installation>) and for Flight Tools, see the [Flight Tools installation docs](https://github.com/openflighthpc/openflight-tools#installation>).

These instructions assume that `flight-runway` and `flight-tools` have been installed from the openflightHPC yum repository and [system-wide integration](https://github.com/openflighthpc/flight-runway#system-wide-integration) enabled.

Integrate Flight Inventory to runway:

```
[root@myhost ~]# flintegrate /opt/flight/opt/openflight-tools/tools/flight-inventory.yml
Loading integration instructions ... OK.
Verifying instructions ... OK.
Downloading from URL: https://github.com/openflighthpc/flight-inventory/archive/master.zip ... OK.
Extracting archive ... OK.
Performing configuration ... OK.
Integrating ... OK.
```

Flight Inventory is now available via the `flight` tool::

```
[root@myhost ~]# flight inventory
  NAME:

    flight inventory

  DESCRIPTION:

    Parser of hardware information into unified formats.

  COMMANDS:

    delete          Delete the stored data for one or more nodes
    edit            Edit stored data for a node
    <snip>
```
