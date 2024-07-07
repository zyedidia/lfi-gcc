# LFI GCC builder

This repository contains scripts for building a version of GCC from source that
can target the LFI sandboxing system, on either ARM64 or AMD64. Currently
`gcc`, `g++`, and `gfortran` are built, along with the following runtime
libraries: `libgcc`, `musl-libc`, `libstdc++`, `libgfortran`. This means the
toolchain only has support for C, C++, and Fortran. In the future, more
languages might be supported, such as D and Go. The Fortran support is limited
since it is linked with musl-libc instead of glibc, which does not include some
vector math library routines.

The toolchain does not need to be built on an AArch64 machine. You can build on
an x86-64 machine, and get a cross-compiler.

The scripts here build GCC 13.2.0. Bootstrap is not used, so you must have a
version of GCC installed that can build GCC 13.2.0 (such as GCC 13 or 12). To
build a different version of GCC, edit the `download.sh` script.

# Usage

Before building, you must install the LFI rewriter tool: `lfi-leg`.

Then you can begin the build process:

```
$ ./install-toolchain.sh $PWD/toolchain ARCH # must be an absolute path
```

The `ARCH` may be `aarch64_lfi` or `x86_64`. For example, to build the arm64
toolchain:

```
$ ./install-toolchain.sh $PWD/lfi-arm64 aarch64_lfi # must be an absolute path
```

After waiting for the build to complete, you will find a toolchain installed
into `./lfi-arm64`.

You should now be able to run the test programs in LFI.

```
$ ./lfi-arm64/bin/aarch64_lfi-linux-musl-gcc test.c -O2
$ lfi-run ./a.out
Hello world: 0x1e00060000
$ ./lfi-arm64/bin/aarch64_lfi-linux-musl-g++ test.cc -O2
$ lfi-run ./a.out
done!
```
