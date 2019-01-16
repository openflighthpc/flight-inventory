# Inventoryware

## Use

The commands' syntax is as follows:
```
parse DATA_LOCATION

render TEMPLATE_LOCATION [NODE_NAME(S) -g GROUPS,HERE | --all] [-l DESTINATION]

modify groups GROUP [NODE_NAME(S) -g GROUPS,HERE | --all] [-p | -r]

modify location [NODE_NAME(S) -g GROUPS,HERE | --all]

modify other FIELD=[VALUE] [NODE_NAME(S) -g GROUPS,HERE | --all]
```

The `parse` command processes zips at the specified location into yaml stored in the `store/`
directory.
If the location is a directory all '.zips' in it will be processed. Each of these zips are expanded
and any nested zips are processed. Only bottom level .zips are processed so don't allow any node's
data to be sibling to a .zip. Each zip must contain a lshw-xml and a lsblk-a-P file. A `groups`
file will be processed if it exists.

The following commands all allow specification of nodes in the same way. Either n nodes follow or
`--all` can be passed to process all .yaml files in the `store/` directory. Additionally groups can
be selected with the `-g` option in which case all nodes in the specified groups will be processed.

The `render` command fills eRuby templates using stored data. The first argument is the template to
be filled, see 'Templates' section for details. The output will be passed to stdout unless a
destination is specified with the `-l` option.

The `modify groups` command adds GROUP to the specified nodes' secondary groups. If -p is set their
primary group is set to GROUP. If -r is set GROUP will be removed from the nodes' secondary groups.
Primary groups can't be removed, only overwritten.

The `modify location` command starts a REPL interaction to set the nodes' locations.

The `modify other` command allows the setting and un-setting of arbitrary fields in nodes' data.
FIELD is set to VALUE and if VALUE is blank the field is removed from the nodes' data.
A node's location data can be set via this method however it's groups cannot due to the special
constraints for those fields; for groups please use `modify groups`.

## Installation

Inventoryware requires a recent version of `ruby` (2.5.1<=) and `bundler`.
The following will install from source using `git`:
```
git clone https://github.com/alces-software/inventoryware.git
cd inventoryware
bundle install
```

The script is located at `lib/inventoryware.rb`

## Development

It is recommended that Inventoryware is developed locally (so you have all your local
development tools available) and synced, run, and tested in a clean remote environment (to
be in an environment close to what it will normally use in production, and to avoid polluting
or depending on things in your local environment).

To aid this there is a MakeFile containing `watch-rsync` instructions
```
gem install rerun # If you don't have this already.
make watch-rsync PASSWORD="password for machine" IP="ip of machine"
```
This will keep your working directory synced to `/tmp/inventoryware`

## Templates

Templates accepted by Inventoryware are .erb templates filled using Erubis. The relevant data
is stored in a large hash called `node_data`. There are helper methods for navigation and
formatting this data in `lib/erb_utils.rb`. Additionally, in order to the accommodate all possible
domains of use, the system will dynamically read any code stored in the top level `plugins/`
directory and utilise that for filling the specified template.

# License

AGPLv3+ License, see LICENSE.txt for details.

Copyright (C) 2017 Alces Software Ltd.
