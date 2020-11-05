# Flight Inventory

Parser of various hardware information into workable unified formats.

## Overview

Flight Inventory is an asset management tool that parses various Linux command
outputs (e.g. `lshw` and `lsblk`) into YAML data which can be modified and used
to render asset documents.

## Installation

For installation instructions please read INSTALL.md

## Configuration

### Development

It is recommended that Flight Inventory is developed locally (so you have all your local
development tools available) and synced, run, and tested in a clean remote environment (to
be in an environment close to what it will normally use in production, and to avoid polluting
or depending on things in your local environment).

To aid this there is a MakeFile containing `watch-rsync` instructions
```
gem install rerun # If you don't have this already.
make watch-rsync PASSWORD="password for machine" IP="ip of machine"
```
This will keep your working directory synced to `/tmp/flight-inventory`

## Operation

The commands' syntax is as follows:
```
import DATA_LOCATION

import-hunter DATA_LOCATION

delete [ASSET SPEC]

create ASSET

edit ASSET [-c]

list [--group GROUP] [--type TYPE]

list-map ASSET INDEX

edit-notes ASSET [-c]

edit-map ASSET [-c]

modify-groups GROUP [ASSET SPEC] [-p | -r] [-c]

modify-other KEY=[VALUE] [ASSET SPEC] [-c]

show [ASSET SPEC] [-l DESTINATION] [-t TEMPLATE | -f FORMAT]

```

The `import` command processes zips at the specified location to create files in the `store/`
directory.
If the location is a directory all '.zips' in it will be processed. Each of these zips are expanded
and any nested zips are processed. Only bottom level .zips are processed so don't allow any asset's
data to be sibling to a .zip. Each zip must contain a `lshw-xml` and a `lsblk-a-P` file. A `groups`
file will be processed if it exists.

The `import-hunter` command processes a list of nodes saved as a YAML which has been created via the
data collection tool Flight Hunter.

`create` opens an editor allowing for the creation of a new asset.

`delete` removes the data for one or more assets after a confirmation message.

`edit` opens the asset's data in an editor for manual input.

`list` lists all assets with data in the store. Type and group switches taking comma separated lists are
available to filter the results.

`list-map` lists all the assets names at the specified INDEX of the specified ASSET's map.

`edit-notes` opens an editor for an asset's 'notes' section. This is general data store that maintains text
formatting.

The `edit-map` command opens an editor for an asset's 'map' section. A 'map' is a key:value store where all
the keys are numerical and represent port numbers and the values are text. The lines of the editor refer to
the keys of the map, the editor has its line numbers set to 'on' to aid entry.

The `modify-groups` command adds GROUP to the  secondary groups of one or more assets. If -p is set
their primary group is set to GROUP. If -r is set GROUP will be removed from the assets' secondary groups.
Primary groups can't be removed, only overwritten.

The `modify-other` command allows the setting and un-setting of arbitrary fields for one or more assets.
FIELD is set to VALUE and if VALUE is blank the field is removed from the assets' data.
An asset's groups cannot be set this way because of the special constraints for those fields; for groups please
use `modify groups`.

The `show` command fills eRuby templates using stored data. Either a path to a template can be passed with the
`-t`option or a template can be inferred from the assets' type and a format (given with `-f`).
The output will be passed to stdout unless a destination is specified with the `-l` option.

ASSET_SPEC refers to specification of more than one asset. This is done in the same way for all commands.
Either assets names are given, separated by commas, or `--all` can be passed to supersede this process the
data for all assets directory. Additionally groups can be selected with the `-g` option in which case all
assets in the specified groups will be processed.

For all the editing and modifying commands if the `--create/-c` option is used a new file will be created
for each asset if it doesn't already exist.

### Templates

Templates accepted by Flight Inventory are .erb templates filled using Erubis. The data is accessible through
a large recursive OpenStruct called `@asset_data`. The equivalent data is also available in a hash called
`@asset_hash`. There are helper methods for navigation and formatting this data in `erb_utils.rb`. Additionally,
in order to the accommodate all possible domains of use, the system will dynamically read any code stored in
the top level `helpers/` directory and utilise that for filling the specified template.

## Data Versioning

To support changes in data structure every asset file has a 'schema number'. The current schema number and
minimum accepted schema number can be found in `inventoryware/version.rb`. If an asset's schema number is
less than the minimum accepted execution will halt and the asset's file will need to be migrated.

# Plugins

Flight Inventory also supports plugins. To render asset data in new and interesting ways place additional
code in the `plugins/` directory. These plugins must have an `etc/templates.yml` file specifying formats for
rendered templates and all ruby files will be evaluated as source code.

# Contributing

Fork the project. Make your feature addition or bug fix. Send a pull
request. Bonus points for topic branches.

Read [CONTRIBUTING.md](CONTRIBUTING.md) for more details.

# Copyright and License

Eclipse Public License 2.0, see [LICENSE.txt](LICENSE.txt) for details.

Copyright (C) 2019-present Alces Flight Ltd.

This program and the accompanying materials are made available under
the terms of the Eclipse Public License 2.0 which is available at
[https://www.eclipse.org/legal/epl-2.0](https://www.eclipse.org/legal/epl-2.0),
or alternative license terms made available by Alces Flight Ltd -
please direct inquiries about licensing to
[licensing@alces-flight.com](mailto:licensing@alces-flight.com).

Flight Inventory is distributed in the hope that it will be
useful, but WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, EITHER
EXPRESS OR IMPLIED INCLUDING, WITHOUT LIMITATION, ANY WARRANTIES OR
CONDITIONS OF TITLE, NON-INFRINGEMENT, MERCHANTABILITY OR FITNESS FOR
A PARTICULAR PURPOSE. See the [Eclipse Public License 2.0](https://opensource.org/licenses/EPL-2.0) for more
details.
