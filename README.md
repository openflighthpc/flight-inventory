# inventoryware

## Use

Command structure is:
```
./inventoryware NODE ZIP_LOCATION -p PRI_GROUP -s LIST,OF,SECONDARY,GROUPS -t TEMPLATE_LOCATION
```

The zip must contain a lshw-xml.txt and a lsblk-a-P.txt

Output is to a fixed location - `/opt/inventoryware/output/domain`
If no template is provided the node's information is appended to the destination file.
If a template is provided it is filled as eRuby and the desitation file is overwritten with the
resulting markdown.

## Installation

```
cd /opt
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
