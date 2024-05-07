#!/bin/sh

# don't forget the $PWD!!
# usage: ./build-musl.sh $PWD/prefix

PREFIX=$1

export CC=$PREFIX/bin/aarch64_lfi-linux-musl-gcc
cd musl-1.2.4
make clean
./configure --prefix=$PREFIX --syslibdir=$PREFIX/aarch64_lfi-linux-musl/lib --libdir=$PREFIX/lib/gcc/aarch64_lfi-linux-musl/13.2.0 --includedir=$PREFIX/aarch64_lfi-linux-musl/include
make
make install
