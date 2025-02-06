#!/usr/bin/env bash

set -exo pipefail

export SCRIPT_ROOT=$(cd "$(dirname "$(realpath "$0")")" && pwd)
export TMPDIR=$HOME/temp
export PREFIX=$SCRIPT_ROOT/install
export CC=clang CXX=clang++
LLVM_VERSION="12.0.1"
LLVM_URL="https://github.com/llvm/llvm-project/releases/download/llvmorg-${LLVM_VERSION}/llvm-project-${LLVM_VERSION}.src.tar.xz"

mkdir -p $TMPDIR
mkdir -p $PREFIX
LLVM_INSTALL_DIR=$(realpath $PREFIX)

WORKDIR=$(mktemp -d)

trap 'rm -rf ${WORKDIR}' EXIT

cd $WORKDIR

wget -O llvm.src.tar.gz $LLVM_URL
tar xf llvm.src.tar.gz
cd llvm-project-${LLVM_VERSION}.src

if command -v ninja >/dev/null 2>&1; then
  Generator="Ninja"
else
  Generator="Unix Makefiles"
fi

# -DLLVM_BUILD_LLVM_DYLIB=ON, Build Shared Libs: libLLVM.so ...
# -DLLVM_ENABLE_RTTI, Build LLVM with run-time type information, see: https://klee-se.org/releases/docs/v1.4.0/build-llvm34/#rtti_link_error
cmake -Sllvm -Bbuild -G${Generator} \
  -DLLVM_ENABLE_PROJECTS="clang;clang-tools-extra" -DLLVM_ENABLE_RUNTIMES=all \
  -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=${LLVM_INSTALL_DIR} \
  -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX \
  -DLLVM_BUILD_LLVM_DYLIB=ON \
  -DLLVM_ENABLE_RTTI=ON

cmake --build build && cmake --install build
