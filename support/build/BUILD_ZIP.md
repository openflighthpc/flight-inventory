
## EL7

```
cd /tmp/build
git clone https://github.com/LuaDist/zip
cd zip
git checkout 3.0
make -f unix/Makefile generic CC='gcc -static'
```
