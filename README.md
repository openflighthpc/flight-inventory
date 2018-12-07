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

## Creating Templates

Templates accepted by Inventoryware are .erb templates filled using Erubis. The relevant data
is stored in and referenced from a large hash named `hash`. The top level keys indicate the
source of the underlying data: 'Name', 'Primary Group' and 'Secondary Group' are filled via the
command line, 'lshw' and 'lsblk are from their respective files in the zip.
The method `find_hashes_with_key_value` is for use in navigating the hash, it will return all
hashes with the given key-value pair regarless of it's depth in the hash.
Additionally some fields are different based on the OS the target node uses. The OS must be
specified via the command line and these fields must be referenced through the `mapping` obejct.
See the example template for these methods in practice.
