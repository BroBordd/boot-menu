#!/bin/bash
ROOT=$(realpath $(dirname "$0")/..)
STRATUM="$ROOT/stratum"

if [ -z "$(ls -A $STRATUM 2>/dev/null)" ]; then
    echo "error: stratum submodule is not initialized"
    echo "run:   git submodule update --init --recursive"
    exit 1
fi

if [ -z "$1" ]; then
    echo "usage: $0 <device>"
    exit 1
fi

bash "$STRATUM/scripts/run_app.sh" "$1" stratum_binary
