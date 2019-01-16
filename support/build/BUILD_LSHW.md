
## EL7

```
yum groupinstall "Development Tools"
yum install upx compat-glibc glibc-static libstdc++-static
mkdir /tmp/build
cd /tmp/build
git clone https://github.com/lyonel/lshw
cd lshw/src
make static
```
