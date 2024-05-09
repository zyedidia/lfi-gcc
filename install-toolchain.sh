#!/bin/sh

# usage: ./install-toolchain.sh PREFIX

set -e

if [ ! -d gcc ]; then
    ./download.sh
    ./setup.sh
fi
./build-all.sh $PREFIX
