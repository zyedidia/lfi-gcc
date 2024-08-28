#!/bin/sh

patch -p1 < gas-bundle.patch

cd gcc
./contrib/download_prerequisites
