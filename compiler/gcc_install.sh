#!/usr/bin/env bash

set -exo pipefail

export SCRIPT_ROOT=$(cd "$(dirname "$(realpath "$0")")" && pwd)

export GCC_VERSION="14.2.0"
export GCC_URL="https://ftp.gnu.org/gnu/gcc/gcc-${GCC_VERSION}/gcc-${GCC_VERSION}.tar.xz"

export WORKDIR=$SCRIPT_ROOT/src
export PREFIX=$SCRIPT_ROOT/install/gcc-${GCC_VERSION}
export BUILDDIR=$SCRIPT_ROOT/build/gcc-${GCC_VERSION}

mkdir -p $WORKDIR
mkdir -p $PREFIX
mkdir -p $BUILDDIR
GCC_INSTALL_DIR=$(realpath $PREFIX)

# trap 'rm -rf ${WORKDIR}' EXIT

cd $WORKDIR

wget -O gcc.src.tar.gz $GCC_URL
tar xf gcc.src.tar.gz
cd gcc-${GCC_VERSION}

./contrib/download_prerequisites

GCC_SRC=$(pwd)

cd "$BUILDDIR"

"$GCC_SRC/configure" \
  --enable-coverage \
  --enable-checking \
  --disable-multilib \
  --disable-shared \
  --disable-bootstrap \
  --enable-languages=c,c++ \
  --prefix="$GCC_INSTALL_DIR"

make -j$(nproc) && make install
