## Installation

### Generic

Inventoryware requires a recent version of `ruby` (2.5.1<=) and `bundler`.
The following will install from source using `git`:
```
git clone https://github.com/alces-software/inventoryware.git
cd inventoryware
bundle install
```

The script is located at `lib/inventoryware.rb`

### Flight Core

Inventoryware can be installed as a tool to the flight-core environment.

- Install Flight Core (if not already installed)

```
yum install https://s3-eu-west-1.amazonaws.com/alces-flight/rpms/flight-core-0.1.0%2B20190121150201-1.el7.x86_64.rpm
```

- The installation script (located at `scripts/install`) has variables that can be optionally set in the curl command.
    - `alces_INSTALL_DIR` - The directory to clone the tool into
    - `alces_VERSION` - The version of the tool to install

- Run the installation script

```
# Standard install
curl https://raw.githubusercontent.com/alces-software/inventoryware/master/scripts/install |/bin/bash

# Installation with variables
curl https://raw.githubusercontent.com/alces-software/inventoryware/master/scripts/install |alces_INSTALL_DIR=/my/install/path/ alces_VERSION=dev-release /bin/bash
```
