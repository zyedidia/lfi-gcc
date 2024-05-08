#!/bin/sh

sed -i -e 's/aarch64 | aarch64_be/aarch64 | aarch64_be | aarch64_lfi/g' binutils/config.sub
sed -i -e 's/aarch64-\*/aarch64*-*/g' binutils/ld/configure.tgt
sed -i -e 's/aarch64-\*/aarch64*-*/g' binutils/bfd/config.bfd
sed -i -e 's/aarch64)/aarch64|aarch64_lfi)/g' binutils/gas/configure.tgt
sed -i -e 's/aarch64 | aarch64_be/aarch64 | aarch64_be | aarch64_lfi/g' gcc/config.sub
sed -i -e 's/aarch64-\*-\*/aarch64-*-* | aarch64_lfi-*-*/g' gcc/libstdc++-v3/configure

patch -p0 < aarch64.cc.patch
patch -p0 < aarch64.cc.2.patch
patch -p0 < aarch64-elf.h.patch

cd gcc
./contrib/download_prerequisites
