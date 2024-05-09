# LFI GCC builder

This repository contains scripts for building a version of GCC from source that
can target the LFI sandboxing system. Currently `gcc` and `g++` are built,
along with the following runtime libraries: `libgcc`, `musl-libc`, `libstdc++`.
This means the toolchain only has support for C and C++. In the future, more
languages might be supported, such as D, Fortran, and Go.

The toolchain does not need to be built on an AArch64 machine. You can build on
an x86-64 machine, and get a cross-compiler.

The scripts here build GCC 13.2.0. Bootstrap is not used, so you must have a
version of GCC installed that can build GCC 13.2.0 (such as GCC 13 or maybe
12). To build a different version of GCC, edit the `download.sh` script.

# Usage

Before building, you must install the LFI tools `lfi-as` and `lfi-leg-arm64`.

Then you can begin the build process:

```
$ ./download.sh
$ ./setup.sh
$ ./build-all.sh $PWD/aarch64_lfi-toolchain # must be an absolute path
```

After waiting for the build to complete, you will find a toolchain installed
into `./aarch64_lfi-toolchain`.
