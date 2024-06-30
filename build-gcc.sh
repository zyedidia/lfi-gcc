#!/bin/sh

# usage: ./build-gcc.sh PREFIX

set -ex

PREFIX=$1
export CFLAGS_FOR_TARGET="$(lfi-wrap -flags -toolchain=gcc)"
export CXXFLAGS_FOR_TARGET="$(lfi-wrap -flags -toolchain=gcc)"

mkdir -p build-gcc
cd build-gcc
../gcc/configure --target=aarch64_lfi-linux-musl \
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

mv $PREFIX/bin/aarch64_lfi-linux-musl-gcc $PREFIX/bin/internal-aarch64_lfi-linux-musl-gcc
mv $PREFIX/bin/aarch64_lfi-linux-musl-g++ $PREFIX/bin/internal-aarch64_lfi-linux-musl-g++

lfi-wrap -toolchain=gcc -compiler=aarch64_lfi-linux-musl-gcc > $PREFIX/bin/aarch64_lfi-linux-musl-gcc
lfi-wrap -toolchain=gcc -compiler=aarch64_lfi-linux-musl-g++ > $PREFIX/bin/aarch64_lfi-linux-musl-g++
lfi-wrap -toolchain=gcc -compiler=aarch64_lfi-linux-musl-gfortran > $PREFIX/bin/aarch64_lfi-linux-musl-gfortran
chmod +x $PREFIX/bin/aarch64_lfi-linux-musl-gcc
chmod +x $PREFIX/bin/aarch64_lfi-linux-musl-g++
chmod +x $PREFIX/bin/aarch64_lfi-linux-musl-gfortran

# install musl headers

cd ../musl-1.2.4
make clean
CC=$PREFIX/bin/aarch64_lfi-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/aarch64_lfi-linux-musl/lib --libdir=$PREFIX/lib/gcc/aarch64_lfi-linux-musl/13.2.0 --includedir=$PREFIX/aarch64_lfi-linux-musl/include
# first install musl headers
make install-headers

cd ../build-gcc

# now we can build libgcc (requires libc headers)
make all-target-libgcc
make install-target-libgcc

cd ..

cp musl-custom/memset.S musl-1.2.4/src/string/aarch64/memset.S
cp musl-custom/getopt.c musl-1.2.4/src/misc/getopt.c
cp musl-custom/crti.s musl-1.2.4/crt/aarch64/crti.s

cd musl-1.2.4

make clean

CC=$PREFIX/bin/aarch64_lfi-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/aarch64_lfi-linux-musl/lib --libdir=$PREFIX/lib/gcc/aarch64_lfi-linux-musl/13.2.0 --includedir=$PREFIX/aarch64_lfi-linux-musl/include

# now we can build libc (requires libgcc)
make
make install

# copy musl installation to build-gcc/gcc

cd ../build-gcc

cp -r $PREFIX/lib/gcc/aarch64_lfi-linux-musl/13.2.0/* gcc

# now build libstdc++ (requires libc and libgcc)
make all-target-libstdc++-v3
make install-target-libstdc++-v3
