#!/bin/bash
set -e

ROOT=$(dirname $0)/..
LIBS=$(realpath $ROOT/module/system/lib64)
BIN=$(realpath $ROOT/module/system/bin/stratum_binary)
EXTRAS=$(realpath $ROOT/module/extras)

if [[ ! -f $BIN ]]; then
    echo "[!] Binary not found, run scripts/build.sh first"
    exit 1
fi

export LD_LIBRARY_PATH=$LIBS:/system/lib64
export LD_PRELOAD=$LIBS/stub.so
exec su -c "EXTRAS_DIR=$EXTRAS LD_LIBRARY_PATH=$LIBS:/system/lib64 LD_PRELOAD=$LIBS/stub.so $BIN $*"
