#!/usr/bin/env bash

set -exo pipefail

export SCRIPT_ROOT=$(cd "$(dirname "$(realpath "$0")")" && pwd)
export TMPDIR=$HOME/temp
export PREFIX=$TMPDIR/install
export CC=$PREFIX/bin/clang
export CXX=$PREFIX/bin/clang++

SVF_VERSION="d7f7f6884a6df01dc913d2ec47262bb6a55a3a63"
SVF_URL="https://github.com/SVF-tools/SVF.git"

SVF_INSTALL_DIR=$(realpath $PREFIX)

mkdir -p $TMPDIR
mkdir -p $SVF_INSTALL_DIR
WORKDIR=$(mktemp -d)

trap 'rm -rf ${WORKDIR}' EXIT

cd $WORKDIR

git clone $SVF_URL && cd SVF
git checkout $SVF_VERSION

# -DSVF_WARN_AS_ERROR=OFF, This option is required in newer SVF
cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release -GNinja \
  -DBUILD_SHARED_LIBS=OFF \
  -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
  -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
  -DCMAKE_INSTALL_PREFIX=$PREFIX -DLLVM_DIR=$PREFIX \
  -DSVF_WARN_AS_ERROR=OFF

cmake --build build && cmake --install build
# The following commands are necessary for some versions
install -m 0755 build/include/Util/config.h $SVF_INSTALL_DIR/include/svf/Util
