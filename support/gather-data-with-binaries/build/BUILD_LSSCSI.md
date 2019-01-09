
## EL7

```
cd /tmp/build
git clone https://github.com/hreinecke/lsscsi
cd lsscsi
git checkout v0.28
./configure
export VERBOSE=1
make
# GCC line copied from make output
cd src
gcc -static -DHAVE_CONFIG_H -I. -I..    -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wall -W -g -O2 -MT lsscsi.o -MD -MP -MF .deps/lsscsi.Tpo -c -o lsscsi.o lsscsi.c
gcc -static -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -Wall -W -g -O2   -o lsscsi lsscsi.o

# Binary is at ./lsscsi
```
