#!/bin/sh

# usage: ./build-gcc.sh PREFIX

set -ex

PREFIX=$1

mkdir -p build-gcc
cd build-gcc
../gcc/configure --target=$ARCH-linux-musl \
    --disable-docs \
    --disable-bootstrap \
    --disable-libssp \
    --disable-multilib \
    --disable-shared \
    --enable-languages=c,c++,fortran \
    --enable-lto \
    --prefix=$PREFIX \
    --with-pkgversion="LFI"

make all-gcc
make install-strip-gcc

mkdir -p lib/gcc
go run ../specgen.go > lib/gcc/specs

mkdir -p $PREFIX/$ARCH-linux-musl/lib
go run ../specgen.go > $PREFIX/$ARCH-linux-musl/lib/specs

# install musl headers

cd ../musl-1.2.4
make clean
CC=$PREFIX/bin/$ARCH-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/$ARCH-linux-musl/lib --libdir=$PREFIX/lib/gcc/$ARCH-linux-musl/13.2.0 --includedir=$PREFIX/$ARCH-linux-musl/include
# first install musl headers
make install-headers

cd ../build-gcc

# now we can build libgcc (requires libc headers)
make all-target-libgcc
make install-target-libgcc

cd ..

cp musl-custom/getopt.c musl-1.2.4/src/misc/getopt.c

cd musl-1.2.4

make clean

CC=$PREFIX/bin/$ARCH-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/$ARCH-linux-musl/lib --libdir=$PREFIX/lib/gcc/$ARCH-linux-musl/13.2.0 --includedir=$PREFIX/$ARCH-linux-musl/include --disable-shared

# now we can build libc (requires libgcc)
make
make install

# copy musl installation to build-gcc/gcc

cd ../build-gcc

cp -r $PREFIX/lib/gcc/$ARCH-linux-musl/13.2.0/* gcc

# now build libstdc++ (requires libc and libgcc)
make all-target-libstdc++-v3
make install-target-libstdc++-v3

# add linux/limits.h

mkdir -p $PREFIX/$ARCH-linux-musl/include/linux
cp /usr/include/linux/limits.h $PREFIX/$ARCH-linux-musl/include/linux

# now build libgfortran

make all-target-libgfortran
make install-target-libgfortran
