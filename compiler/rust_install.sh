#!/usr/bin/env bash

set -exo pipefail

export SCRIPT_ROOT=$(cd "$(dirname "$(realpath "$0")")" && pwd)
export TMPDIR=$HOME/temp

RUST_URL="https://github.com/rust-lang/rust.git"
RUST_VERSION="788202a"
WORKDIR=$SCRIPT_ROOT/src
INSTALLDIR=$SCRIPT_ROOT/install/rust-${RUST_VERSION}

SRCDIR="rust-${RUST_VERSION}"

mkdir -p $TMPDIR
mkdir -p $PREFIX
mkdir -p $WORKDIR

cd $WORKDIR
git clone $RUST_URL $SRCDIR
cd $SRCDIR

cp config.example.toml config.toml

sed -i "432a\prefix=\"${INSTALLDIR}\"" config.toml
sed -i '436a\sysconfdir="etc"' config.toml
sed -i '73a\assertions=true' config.toml
sed -i '521a\debug-assertions=true' config.toml
sed -i "365a\profiler=true" config.toml

sed -i '552i\if mode != Mode::Std {\n    rustflags.arg("-Cinstrument-coverage");\n}' src/bootstrap/src/core/builder/cargo.rs

./x build && ./x install
