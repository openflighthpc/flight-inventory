
## EL7

```
yum groupinstall "Development Tools"
yum install zlib-static
cd /tmp/build
git clone https://github.com/gittup/pciutils
cd pciutils
make CC="gcc -static"
```
