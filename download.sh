#!/bin/sh

set -e

# binutils
BINUTILS=binutils-2.41
wget https://ftp.gnu.org/gnu/binutils/$BINUTILS.tar.xz
tar -xf $BINUTILS.tar.xz
mv $BINUTILS binutils
rm $BINUTILS.tar.xz

# gcc
git submodule update --init
