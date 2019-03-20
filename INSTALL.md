## Installation

### Generic

Inventoryware requires a recent version of `ruby` (2.5.1<=) and `bundler`.
The following will install from source using `git`:
```
git clone https://github.com/openflighthpc/inventoryware.git
cd inventoryware
bundle install
```

The entry script is located at `bin/inventory`

Note: Interactive editing requires `vim` be installed, this is available in most standard package repositories (yum/zypper/apt/etc).

### Flight Core

Inventoryware can be installed as a tool to the flight-core environment.

### Automated Installation

- Install Flight Core (if not already installed)

```
yum install https://s3-eu-west-1.amazonaws.com/alces-flight/rpms/flight-core-0.1.0%2B20190121150201-1.el7.x86_64.rpm
```

- **Note: If Flight Core has just been installed then logout and in again or source `/etc/profile.d/alces-flight.sh`**

- The installation script (located at `scripts/install`) has variables that can be optionally set in the curl command.
    - `alces_INSTALL_DIR` - The directory to clone the tool into
    - `alces_VERSION` - The version of the tool to install

- Run the installation script

```
# Standard install
curl https://raw.githubusercontent.com/openflighthpc/inventoryware/master/scripts/install |/bin/bash

# Installation with variables
curl https://raw.githubusercontent.com/openflighthpc/inventoryware/master/scripts/install |alces_INSTALL_DIR=/my/install/path/ alces_VERSION=dev-release /bin/bash
```

### Local Installation

Instead of depending on an upstream location, Inventoryware can be installed from a local copy of the repository in the following manner.

- Install Flight Core (if not already installed)

```
yum install https://s3-eu-west-1.amazonaws.com/alces-flight/rpms/flight-core-0.1.0%2B20190121150201-1.el7.x86_64.rpm
```

- **Note: If Flight Core has just been installed then logout and in again or source `/etc/profile.d/alces-flight.sh`**

- Execute the install script from inside the `inventoryware` directory

```
bash scripts/install
```

*Note: Local installations will use the currently checked out branch instead of using the latest release. To override this do `alces_VERSION=branchname bash scripts/install`.*

### Post Installation

- Now logout and in again or source `/etc/profile.d/alces-flight.sh`

- Inventoryware can now be run as follows

```
flight inventory
```

- Alternatively, a sandbox environment for Inventoryware can be entered as follows

```
flight shell inventory
```

