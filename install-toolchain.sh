#!/bin/sh

# usage: ./install-toolchain.sh PREFIX

set -e

PREFIX=$1

if [ ! -d gcc ]; then
    ./download.sh
    ./setup.sh
fi
./build-all.sh $PREFIX
