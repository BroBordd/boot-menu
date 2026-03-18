#!/bin/bash
set -e

ROOT=$(realpath $(dirname $0)/..)
STRATUM="$ROOT/stratum"
DEVICE=$1

if [ -z "$DEVICE" ]; then
    echo "usage: $0 <device> [-m|--menu-only] [-e|--extras-only]"
    exit 1
fi

if [ -z "$(ls -A $STRATUM 2>/dev/null)" ]; then
    echo "error: stratum submodule not initialized"
    echo "run:   git submodule update --init --recursive"
    exit 1
fi

DEVICE_DIR="$STRATUM/devices/$DEVICE"
OUT_BINS="$DEVICE_DIR/out/bins"
OUT_LIBS="$DEVICE_DIR/out/libs"

if [ ! -d "$DEVICE_DIR" ]; then
    echo "error: '$DEVICE_DIR' not found"
    exit 1
fi

BUILD_MENU=1
BUILD_EXTRAS=1
shift
while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--menu-only)   BUILD_EXTRAS=0; shift ;;
        -e|--extras-only) BUILD_MENU=0;   shift ;;
        *) shift ;;
    esac
done

# ── autobuild stratum if needed ───────────────────────────────────────────────
if [ ! -f "$OUT_LIBS/libstratum.so" ]; then
    echo "[*] libstratum.so not found, building stratum..."
    bash "$STRATUM/scripts/build.sh" "$DEVICE" -l
fi

# ── bootmenu ──────────────────────────────────────────────────────────────────
if [ $BUILD_MENU -eq 1 ]; then
    bash "$STRATUM/scripts/build_app.sh" "$DEVICE" "$ROOT/src/bootmenu.cpp" stratum_binary
fi

# ── extras ────────────────────────────────────────────────────────────────────
if [ $BUILD_EXTRAS -eq 1 ]; then
    APPS_DIR="$STRATUM/apps"
    if [ -z "$(ls -A $APPS_DIR 2>/dev/null)" ]; then
        echo "error: stratum/apps not initialized — run: git submodule update --init --recursive"
        exit 1
    fi
    for f in "$APPS_DIR"/utils/*.cpp; do
        bash "$STRATUM/scripts/build_app.sh" "$DEVICE" "$f"
    done
fi

# ── package zip ───────────────────────────────────────────────────────────────
echo "[*] Packaging module zip..."

STAGING="$ROOT/.staging"
rm -rf "$STAGING"
cp -r "$ROOT/module/." "$STAGING/"
mkdir -p "$STAGING/system/lib64" "$STAGING/system/bin" "$STAGING/extras"

cp "$OUT_LIBS/libstratum.so"  "$STAGING/system/lib64/libstratum.so"
cp "$OUT_LIBS/stub.so"        "$STAGING/system/lib64/stub.so"
cp "$OUT_BINS/stratum_binary" "$STAGING/system/bin/stratum_binary"

for f in brickbreaker calculator signal sysinfo terminal; do
    [ -f "$STRATUM/devices/$DEVICE/out/extras/$f" ] && cp "$STRATUM/devices/$DEVICE/out/extras/$f" "$STAGING/extras/$f"
done

ZIP="$ROOT/${DEVICE}-boot-menu.zip"
cd "$STAGING" && zip -r9 "$ZIP" . > /dev/null
cd "$ROOT"
rm -rf "$STAGING"

echo ""
echo "[*] Done!"
echo "    zip : $ZIP"
