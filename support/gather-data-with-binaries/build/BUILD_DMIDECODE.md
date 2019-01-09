
## EL7

```
cd /tmp/build
wget http://ftp.igh.cnrs.fr/pub/nongnu/dmidecode/dmidecode-3.2.tar.xz
cd dmidecode-3.2
export VERBOSE=1
make
# GCC command from the above make
gcc -static -W -Wall -Wshadow -Wstrict-prototypes -Wpointer-arith -Wcast-qual -Wcast-align -Wwrite-strings -Wmissing-prototypes -Winline -Wundef -D_FILE_OFFSET_BITS=64 -O2 -c dmidecode.c -o dmidecode.o
gcc -static dmidecode.o dmiopt.o dmioem.o util.o -o dmidecode

# Binary is now at ./dmidecode
```
