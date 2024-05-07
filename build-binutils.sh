#!/bin/sh

# usage: build-binutils PREFIX

PREFIX=$1

mkdir -p build-binutils
cd build-binutils
../binutils/configure --target=aarch64_lfi-linux-musl \
    --disable-docs \
    --disable-nls \
    --disable-multilib \
    --prefix=$PREFIX \
    --with-pkgversion="LFI"
make
make install

cd ..

mv $PREFIX/bin/aarch64_lfi-linux-musl-as $PREFIX/bin/internal-aarch64_lfi-linux-musl-as
mv $PREFIX/aarch64_lfi-linux-musl/bin/as $PREFIX/aarch64_lfi-linux-musl/bin/internal-as

cp wrappers/aarch64_lfi-linux-musl-as  $PREFIX/bin
cp wrappers/as $PREFIX/aarch64_lfi-linux-musl/bin
