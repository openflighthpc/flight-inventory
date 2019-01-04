# inventoryware

## Use

The commands' syntax is as follows:
```
parse DATA_LOCATION

render TEMPLATE_LOCATION [NODE_NAME(S) | --all] [-l DESTINATION]
```

The `parse` command processes zips at the specified location into yaml stored in the `store/`
directory.
If the location is a directory all '.zips' in it will be processed. Each of these zips are expanded
and any nested zips are processed. Only bottom level .zips are processed so don't allow any node's
data to be sibling to a .zip. Each zip must contain a lshw-xml and a lsblk-a-P file. A `groups`
file will be processed if it exists.

The `render` command fills eRuby templates using stored data. The first argument is the template to
fill then either n nodes follow or `--all` can be passed to process all .yaml files in the `store/`
directory. The output will be passed to stdout unless a destination is specified with the `-l`
option.

## Installation

```
git clone https://github.com/alces-software/inventoryware.git
```

The script is located within `/opt/inventoryware/lib`

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
formatting this data in `lib/erb_util.rb`. Additionally, in order to the accomodate all possible
domains of use, the system will dynamically read any code stored in the top level `plugins/`
directory and utilise that for filling the specified template.
