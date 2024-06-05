#!/bin/sh

# usage: build-binutils PREFIX

set -ex

PREFIX=$1

mkdir -p build-binutils
cd build-binutils
../binutils/configure --target=x86_64-linux-musl \
    --disable-docs \
    --disable-nls \
    --disable-multilib \
    --prefix=$PREFIX \
    --with-pkgversion="LFI"
make
make install-strip

cd ..

mv $PREFIX/bin/x86_64-linux-musl-as $PREFIX/bin/internal-x86_64-linux-musl-as
mv $PREFIX/x86_64-linux-musl/bin/as $PREFIX/x86_64-linux-musl/bin/internal-as

cp wrappers/x86_64-linux-musl-as  $PREFIX/bin
cp wrappers/as $PREFIX/x86_64-linux-musl/bin
