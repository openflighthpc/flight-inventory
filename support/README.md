## About

This directory contains static binaries of the system commands used by the gatherer script.

All binaries have been compiled on CentOS 7 and are tested to run on:
- CentOS 6
- CentOS 7
- SLES 11
- Ubuntu 14.04

With assumption that if it works on these older OSes then it will be portable to later SLES and Ubuntu versions.

Build instructions for each static library can be found within the directory `build/`

## Gathering Data

To run the script simply execute the `gather-data.sh` script. As long as the `bin/` directory lives next to the `gather-data.sh` script then the binaries then the script will execute without issue. 
