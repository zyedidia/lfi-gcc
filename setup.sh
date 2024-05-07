#!/bin/sh

sed -i -e 's/aarch64 | aarch64_be/aarch64 | aarch64_be | aarch64_lfi/g' binutils/config.sub
sed -i -e 's/aarch64 | aarch64_be/aarch64 | aarch64_be | aarch64_lfi/g' gcc/config.sub
sed -i -e 's/aarch64-\*-\*/aarch64-*-* | aarch64_lfi-*-*/g' gcc/libstdc++-v3/configure

patch -p0 < aarch64.cc.patch
