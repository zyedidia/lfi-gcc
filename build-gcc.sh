#!/bin/sh

# usage: ./build-gcc.sh PREFIX

PREFIX=$1
export CFLAGS_FOR_TARGET="-ffixed-x21 -ffixed-x18 -ffixed-x22 -ffixed-x23 -ffixed-x24 -ffixed-x30 -fPIC"
export CXXFLAGS_FOR_TARGET="-ffixed-x21 -ffixed-x18 -ffixed-x22 -ffixed-x23 -ffixed-x24 -ffixed-x30 -fPIC"

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
make install-gcc

mv $PREFIX/bin/aarch64_lfi-linux-musl-gcc $PREFIX/bin/internal-aarch64_lfi-linux-musl-gcc
mv $PREFIX/bin/aarch64_lfi-linux-musl-g++ $PREFIX/bin/internal-aarch64_lfi-linux-musl-g++
# mv $PREFIX/aarch64_lfi-linux-musl/bin/gcc $PREFIX/aarch64_lfi-linux-musl/bin/internal-gcc
#
cp ../wrappers/aarch64_lfi-linux-musl-gcc  $PREFIX/bin
cp ../wrappers/aarch64_lfi-linux-musl-g++  $PREFIX/bin
cp ../wrappers/gcc $PREFIX/aarch64_lfi-linux-musl/bin

# copy headers from musl to $PREFIX/aarch64_lfi-linux-musl/include
cp -r ../musl-include $PREFIX/aarch64_lfi-linux-musl/include

# build musl

cd ../musl-1.2.4
make clean
CC=$PREFIX/bin/aarch64_lfi-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/aarch64_lfi-linux-musl/lib --libdir=$PREFIX/lib/gcc/aarch64_lfi-linux-musl/13.2.0 --includedir=$PREFIX/aarch64_lfi-linux-musl/include
# first install musl headers
make install-headers

cd ../build-gcc

# now we can build libgcc (requires libc headers)
make all-target-libgcc
make install-target-libgcc

cd ../musl-1.2.4

# now we can build libc (requires libgcc)
make
make install

# copy musl installation to build-gcc/gcc

cd ../build-gcc

cp -r $PREFIX/lib/gcc/aarch64_lfi-linux-musl/13.2.0/* gcc

# now build libstdc++ (requires libc and libgcc)
make all-target-libstdc++-v3
make install-target-libstdc++-v3
