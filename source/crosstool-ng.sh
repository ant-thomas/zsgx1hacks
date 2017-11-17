#!/bin/sh

# Add the following content to your bash profile

export TARGET=arm-goke-linux-uclibcgnueabi
export CROSS=arm-goke-linux-uclibcgnueabi
export BUILD=x86_64-pc-linux-gnu

export CROSSPREFIX=${CROSS}-

export STRIP=${CROSSPREFIX}strip
export CXX=${CROSSPREFIX}g++
export CC=${CROSSPREFIX}gcc
export LD=${CROSSPREFIX}ld
export AS=${CROSSPREFIX}as
export AR=${CROSSPREFIX}ar
