# trinity Developer Readme

## Running this app with additional computational resources

This app has the following entry points:

* main

The shell script trinity.sh has HARDCODED max_memory and CPU values which should must be changed if you change the instance type.
max_memory needs to be somewhat less than the instance RAM. The default instance has 60GB RAM and 32 cores, for which max_memory is
set to 48GB and CPU to 32. The default offers a good balance of RAM and CPU.

See <a
href="https://wiki.dnanexus.com/API-Specification-v1.0.0/IO-and-Run-Specifications#Run-Specification">Run
Specification</a> in the API documentation for more information about the
available instance types.
