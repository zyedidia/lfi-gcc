#!/bin/sh

# usage: ./build-all.sh PREFIX

set -ex

PREFIX=$1

mkdir -p $PREFIX
./build-binutils.sh $PREFIX
./build-gcc.sh $PREFIX
