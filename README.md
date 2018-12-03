# inventoryware

Command structure is:
```
./inventoryware -n NODE -d ZIP_LOCATION -p PRI_GROUP -s LIST,OF,SECONDARY,GROUPS -t TEMPLATE_LOCATION
```

The zip must contain a lshw-xml.txt and a lsblk-a-P.txt

Output is to a fixed location - `/opt/inventory_tools/domain`
If no template is provided the node's information is appended to the destination file.
If a template is provided it is filled as eRuby and the desitation file is overwritten with the
resulting markdown.
