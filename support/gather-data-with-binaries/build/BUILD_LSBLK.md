
## EL7

```
yum groupinstall "Development Tools"
mkdir /tmp/build
cd /tmp/build
git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git
cd util-linux
git checkout stable/RELEASE-VERSION
./autogen.sh

# Configure and build static libraries for creating the binary
./configure --disable-all-programs --enable-libblkid --enable-static --enable-static-programs=blkid --enable-libmount --enable-libsmartcols --enable-libuuid
make

# Manually compile lsblk command
gcc -std=gnu99 -DHAVE_CONFIG_H -I.  -include config.h -I./include -DLOCALEDIR=\"/tmp/build/libblkidtest/share/locale\" -D_PATH_RUNSTATEDIR=\"/tmp/build/libblkidtest/var/run\"  -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libblkid/src -I./libmount/src -I./libsmartcols/src -g -O2 -MT misc-utils/lsblk-lsblk.o -MD -MP -MF misc-utils/.deps/lsblk-lsblk.Tpo -c -o misc-utils/lsblk-lsblk.o `test -f 'misc-utils/lsblk.c' || echo './'`misc-utils/lsblk.c
gcc -static -std=gnu99 -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libblkid/src -I./libmount/src -I./libsmartcols/src -g -O2 -o .libs/lsblk misc-utils/lsblk-lsblk.o  ./.libs/libblkid.a ./.libs/libmount.a /tmp/build/util-linux/.libs/libblkid.a /tmp/build/util-linux/.libs/libuuid.a -lrt ./.libs/libcommon.a ./.libs/libsmartcols.a -Wl,-rpath -Wl,/tmp/build/libblkidtest/lib

# The binary can now be found at `.libs/lsblk`
```
