#!/bin/sh

# usage: build-binutils PREFIX

set -ex

PREFIX=$1

mkdir -p build-binutils
cd build-binutils
../binutils/configure --target=$ARCH-linux-musl \
    --disable-docs \
    --disable-nls \
    --disable-multilib \
    --prefix=$PREFIX \
    --with-pkgversion="LFI"
make
make install-strip

cd ..

mv $PREFIX/bin/$ARCH-linux-musl-as $PREFIX/bin/internal-$ARCH-linux-musl-as
mv $PREFIX/$ARCH-linux-musl/bin/as $PREFIX/$ARCH-linux-musl/bin/internal-as

cp wrappers/$ARCH-linux-musl-as  $PREFIX/bin/$ARCH-linux-musl-as
cp wrappers/$ARCH-as $PREFIX/$ARCH-linux-musl/bin/as
