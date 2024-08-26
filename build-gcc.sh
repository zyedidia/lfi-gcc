#!/bin/sh

# usage: ./build-gcc.sh PREFIX

set -ex

PREFIX=$1

mkdir -p build-gcc
cd build-gcc
../gcc/configure --target=$ARCH-lfi-linux-musl \
    --disable-docs \
    --disable-bootstrap \
    --disable-libssp \
    --disable-multilib \
    --enable-languages=c,c++ \
    --enable-lto \
    --enable-shared \
    --enable-default-pie \
    --prefix=$PREFIX \
    --with-pkgversion="LFI"

make all-gcc -j$(nproc --all)
make install-strip-gcc

mkdir -p lib/gcc
../specgen.sh > lib/gcc/specs
../specgen.sh > gcc/specs

mkdir -p $PREFIX/$ARCH-lfi-linux-musl/lib
../specgen.sh > $PREFIX/$ARCH-lfi-linux-musl/lib/specs

# install musl headers

cd ../musl-1.2.4
make clean
CC=$PREFIX/bin/$ARCH-lfi-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/$ARCH-lfi-linux-musl/lib --libdir=$PREFIX/$ARCH-lfi-linux-musl/lib --includedir=$PREFIX/$ARCH-lfi-linux-musl/include
# first install musl headers
make install-headers
# install crt start files and a dummy libc.so
make lib/crt1.o lib/crti.o lib/crtn.o
install lib/crt1.o lib/crti.o lib/crtn.o $PREFIX/$ARCH-lfi-linux-musl/lib
$PREFIX/bin/$ARCH-lfi-linux-musl-gcc -nostdlib -nostartfiles -shared -x c /dev/null -o $PREFIX/$ARCH-lfi-linux-musl/lib/libc.so

cd ../build-gcc

# now we can build libgcc (requires libc headers)
make all-target-libgcc -j$(nproc --all)
make install-target-libgcc

cd ..

cp musl-custom/getopt.c musl-1.2.4/src/misc/getopt.c
cp musl-custom/crti.s musl-1.2.4/crt/aarch64/crti.s
cp musl-custom/memset.S musl-1.2.4/src/string/aarch64/memset.S

cp musl-custom/x86_64/memset.s musl-1.2.4/src/string/x86_64/memset.s
cp musl-custom/x86_64/memcpy.s musl-1.2.4/src/string/x86_64/memcpy.s

cd musl-1.2.4

make clean

CC=$PREFIX/bin/$ARCH-lfi-linux-musl-gcc ./configure --prefix=$PREFIX --syslibdir=$PREFIX/$ARCH-lfi-linux-musl/lib --libdir=$PREFIX/$ARCH-lfi-linux-musl/lib --includedir=$PREFIX/$ARCH-lfi-linux-musl/include --disable-gcc-wrapper

# now we can build libc (requires libgcc)
make -j$(nproc --all)
make install

# make the linker symlink relative so that if we move PREFIX around it doesn't break
rm $PREFIX/$ARCH-lfi-linux-musl/lib/ld-musl-$ARCH.so.1
ln -s libc.so $PREFIX/$ARCH-lfi-linux-musl/lib/ld-musl-$ARCH.so.1

# copy musl installation to build-gcc/gcc

cd ../build-gcc

cp -r $PREFIX/lib/gcc/$ARCH-lfi-linux-musl/13.2.0/* gcc

# now build libstdc++ (requires libc and libgcc)
make all-target-libstdc++-v3 -j$(nproc --all)
make install-target-libstdc++-v3

# add linux/limits.h

mkdir -p $PREFIX/$ARCH-lfi-linux-musl/include/linux
cp /usr/include/linux/limits.h $PREFIX/$ARCH-lfi-linux-musl/include/linux

# now build libgfortran

# make all-target-libgfortran -j$(nproc --all)
# make install-target-libgfortran
