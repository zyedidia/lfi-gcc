#!/bin/sh

# usage: ./build-gcc.sh PREFIX

set -ex

PREFIX=$1
export CFLAGS_FOR_TARGET="-fPIC"
export CXXFLAGS_FOR_TARGET="-fPIC"

mkdir -p build-gcc
cd build-gcc
../gcc/configure --target=x86_64-linux-musl \
    --disable-docs \
    --disable-bootstrap \
    --disable-libssp \
    --disable-multilib \
    --disable-shared \
    --enable-languages=c,c++ \
    --enable-lto \
    --prefix=$PREFIX \
    --with-pkgversion="LFI"

make all-gcc
make install-strip-gcc

mv $PREFIX/bin/x86_64-linux-musl-gcc $PREFIX/bin/internal-x86_64-linux-musl-gcc
mv $PREFIX/bin/x86_64-linux-musl-g++ $PREFIX/bin/internal-x86_64-linux-musl-g++
# mv $PREFIX/x86_64-linux-musl/bin/gcc $PREFIX/x86_64-linux-musl/bin/internal-gcc
#
cp ../wrappers/x86_64-linux-musl-gcc  $PREFIX/bin
cp ../wrappers/x86_64-linux-musl-g++  $PREFIX/bin
cp ../wrappers/gcc $PREFIX/x86_64-linux-musl/bin

# install musl headers

cd ../musl-1.2.4
make clean
CC=$PREFIX/bin/x86_64-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/x86_64-linux-musl/lib --libdir=$PREFIX/lib/gcc/x86_64-linux-musl/13.2.0 --includedir=$PREFIX/x86_64-linux-musl/include
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

CC=$PREFIX/bin/x86_64-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/x86_64-linux-musl/lib --libdir=$PREFIX/lib/gcc/x86_64-linux-musl/13.2.0 --includedir=$PREFIX/x86_64-linux-musl/include --disable-shared

# now we can build libc (requires libgcc)
make
make install

# copy musl installation to build-gcc/gcc

cd ../build-gcc

cp -r $PREFIX/lib/gcc/x86_64-linux-musl/13.2.0/* gcc

# now build libstdc++ (requires libc and libgcc)
make all-target-libstdc++-v3
make install-target-libstdc++-v3

# add linux/limits.h

mkdir -p $PREFIX/x86_64-linux-musl/include/linux
cp /usr/include/linux/limits.h $PREFIX/x86_64-linux-musl/include/linux
