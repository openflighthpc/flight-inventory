# Inventoryware

## Use

The commands' syntax is as follows:
```
parse DATA_LOCATION

delete NODE_SPEC

edit NODE [-c]

list

modify groups GROUP NODE_SPEC [-p | -r] [-c]

modify location NODE_SPEC [-c]

modify notes NODE [-c]

modify map NODE [-c]

modify other KEY=[VALUE] NODE_SPEC [-c]

show data NODE

show document TEMPLATE_LOCATION NODE_SPEC [-l DESTINATION]

```

The `parse` command processes zips at the specified location into yaml stored in the `store/`
directory.
If the location is a directory all '.zips' in it will be processed. Each of these zips are expanded
and any nested zips are processed. Only bottom level .zips are processed so don't allow any node's
data to be sibling to a .zip. Each zip must contain a lshw-xml and a lsblk-a-P file. A `groups`
file will be processed if it exists.

`delete` removes the specified nodes' files after a confirmation message.

`edit` opens the node's file in an editor for manual input.

`list` lists all nodes with files in the store.

The `modify groups` command adds GROUP to the specified nodes' secondary groups. If -p is set their
primary group is set to GROUP. If -r is set GROUP will be removed from the nodes' secondary groups.
Primary groups can't be removed, only overwritten.

The `modify location` command starts a REPL interaction to set the nodes' locations.

The `modify other` command allows the setting and un-setting of arbitrary fields in nodes' data.
FIELD is set to VALUE and if VALUE is blank the field is removed from the nodes' data.
A node's location data can be set via this method however it's groups cannot due to the special
constraints for those fields; for groups please use `modify groups`.

`modify notes` opens an editor for a node's 'notes' section. This is general data store that maintains text
formatting.

The `modify map` command opens an editor for a node's 'map' section. A 'map' is a key:value store where all
the keys are numerical and represent port numbers and the values are text. The lines of the editor refer to
the keys of the map, the editor has it's line numbers set to 'on' to aid entry.

`show data` displays the selected node's .yaml file in the terminal.

The `show document` command fills eRuby templates using stored data. The first argument is the template to
be filled, see 'Templates' section for details. First the argument's value will be used to search the
`templates/` directory then, if nothing is found, it will be used as a path. The output will be passed to stdout
unless a destination is specified with the `-l` option.

NODE_SPEC refers to specification of more than one node. This is done in the same way for all commands. Either
nodes names are given, separated by commas, or `--all` can be passed to process all .yaml files in the `store/`
directory. Additionally groups can be selected with the `-g` option in which case all nodes in the specified
groups will be processed.

For all the editing and modifying commands if the `--create/-c` a file will be created for each node if it
doesn't already exist.

## Installation

For installation instructions please read INSTALL.md

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

Templates accepted by Inventoryware are .erb templates filled using Erubis. The data is accessible through
a large recursive OpenStruct called `@node_data`. The equivalent data is also available in a hash called
`@node_hash`. There are helper methods for navigation and formatting this data in `erb_utils.rb`. Additionally,
in order to the accommodate all possible domains of use, the system will dynamically read any code stored in
the top level `helpers/` directory and utilise that for filling the specified template.

# License

AGPLv3+ License, see LICENSE.txt for details.

Copyright (C) 2017 Alces Software Ltd.
