
## EL7

- Util Linux configuration
```
yum groupinstall "Development Tools"
yum install ncurses-static readline-static
mkdir /tmp/build
cd /tmp/build
git clone git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git
cd util-linux
git checkout stable/RELEASE-VERSION
./autogen.sh

# Configure and build static libraries for creating the binaries
./configure --enable-static --enable-static-programs='fdisk,blkid'

make
```

- Manually compile lsblk 
```
gcc -std=gnu99 -DHAVE_CONFIG_H -I.  -include config.h -I./include -DLOCALEDIR=\"/tmp/build/libblkidtest/share/locale\" -D_PATH_RUNSTATEDIR=\"/tmp/build/libblkidtest/var/run\"  -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libblkid/src -I./libmount/src -I./libsmartcols/src -g -O2 -MT misc-utils/lsblk-lsblk.o -MD -MP -MF misc-utils/.deps/lsblk-lsblk.Tpo -c -o misc-utils/lsblk-lsblk.o `test -f 'misc-utils/lsblk.c' || echo './'`misc-utils/lsblk.c
gcc -static -std=gnu99 -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libblkid/src -I./libmount/src -I./libsmartcols/src -g -O2 -o .libs/lsblk misc-utils/lsblk-lsblk.o  ./.libs/libblkid.a ./.libs/libmount.a /tmp/build/util-linux/.libs/libblkid.a /tmp/build/util-linux/.libs/libuuid.a -lrt ./.libs/libcommon.a ./.libs/libsmartcols.a -Wl,-rpath -Wl,/tmp/build/libblkidtest/lib

# The binary can now be found at `.libs/lsblk`
```

- Manually compile lscpu

```
gcc -static -std=gnu99 -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libsmartcols/src -g -O2 -o .libs/lscpu sys-utils/lscpu-lscpu.o sys-utils/lscpu-lscpu-arm.o sys-utils/lscpu-lscpu-dmi.o  ./.libs/libcommon.a ./.libs/libsmartcols.a

# The binary can now be found at `.libs/lscpu`
```

- Manually compile fdisk
```
gcc -static -std=gnu99 -fsigned-char -fno-common -Wall -Werror=sequence-point -Wextra -Wmissing-declarations -Wmissing-parameter-type -Wmissing-prototypes -Wno-missing-field-initializers -Wredundant-decls -Wsign-compare -Wtype-limits -Wuninitialized -Wunused-but-set-parameter -Wunused-but-set-variable -Wunused-parameter -Wunused-result -Wunused-variable -Wnested-externs -Wpointer-arith -Wstrict-prototypes -Wimplicit-function-declaration -I./libfdisk/src -I./libsmartcols/src -g -O2   -o fdisk disk-utils/fdisk-fdisk.o disk-utils/fdisk-fdisk-menu.o disk-utils/fdisk-fdisk-list.o  .libs/libcommon.a .libs/libfdisk.a .libs/libsmartcols.a .libs/libtcolors.a .libs/libblkid.a .libs/libuuid.a -lreadline -ltinfo

# The binary can now be found at `./fdisk`
```
