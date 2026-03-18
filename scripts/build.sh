#!/bin/bash
set -e

ROOT=$(dirname $0)/..
STRATUM="$ROOT/stratum"

usage() {
    echo "usage: $0 <device> [options]"
    echo "  -m, --menu-only    build bootmenu only, skip extras"
    echo "  -e, --extras-only  build extras only, skip bootmenu"
    echo "  -h, --help         show this help"
    exit 0
}

if [ -z "$(ls -A $STRATUM 2>/dev/null)" ]; then
    echo "error: stratum submodule is not initialized"
    echo "run:   git submodule update --init --recursive"
    exit 1
fi

if [ -z "$1" ] || [[ "$1" == -* ]]; then
    echo "error: device not specified"
    echo "usage: $0 <device> [options]"
    exit 1
fi

DEVICE=$1
shift

BUILD_MENU=1
BUILD_EXTRAS=1

while [[ $# -gt 0 ]]; do
    case $1 in
        -m|--menu-only)   BUILD_EXTRAS=0; shift ;;
        -e|--extras-only) BUILD_MENU=0;   shift ;;
        -h|--help)        usage ;;
        -*) echo "unknown option: $1"; usage ;;
        *) shift ;;
    esac
done

DEVICE_DIR="$STRATUM/devices/$DEVICE"
OUT_BINS="$DEVICE_DIR/out/bins"
OUT_LIBS="$DEVICE_DIR/out/libs"

if [ ! -d "$DEVICE_DIR" ]; then
    echo "error: '$DEVICE_DIR' not found — add your device to stratum/devices/"
    exit 1
fi

if [ ! -f "$OUT_LIBS/libstratum.so" ]; then
    echo "[*] libstratum.so not found, building stratum..."
    bash "$STRATUM/scripts/build.sh" "$DEVICE" -l
fi

# ── bootmenu ──────────────────────────────────────────────────────────────────
if [[ $BUILD_MENU -eq 1 ]]; then
    bash "$STRATUM/scripts/build_app.sh" "$DEVICE" "$ROOT/src/bootmenu.cpp" stratum_binary
fi

# ── extras ────────────────────────────────────────────────────────────────────
if [[ $BUILD_EXTRAS -eq 1 ]]; then
    APPS_DIR="$STRATUM/apps"
    if [ -z "$(ls -A $APPS_DIR 2>/dev/null)" ]; then
        echo "error: stratum/apps submodule is not initialized"
        echo "run:   git submodule update --init --recursive"
        exit 1
    fi
    for f in $APPS_DIR/utils/*.cpp; do
        bash "$STRATUM/scripts/build_app.sh" "$DEVICE" "$f"
    done
fi

# ── package module zip ────────────────────────────────────────────────────────
echo "[*] Packaging module zip..."

STAGING=$(mktemp -d)
cp -r "$ROOT/module/." "$STAGING/"
cp "$OUT_BINS/stratum_binary" "$STAGING/system/bin/stratum_binary"
cp "$OUT_LIBS/libstratum.so"  "$STAGING/system/lib64/libstratum.so"
cp "$OUT_LIBS/stub.so"        "$STAGING/system/lib64/stub.so"

for f in brickbreaker calculator signal sysinfo terminal; do
    [ -f "$OUT_BINS/$f" ] && cp "$OUT_BINS/$f" "$STAGING/extras/$f"
done

MODULE_ZIP="$ROOT/${DEVICE}-boot-menu.zip"
cd "$STAGING"
zip -r9 "$OLDPWD/$MODULE_ZIP" . > /dev/null
cd "$OLDPWD"
rm -rf "$STAGING"

echo ""
echo "[*] Done!"
echo "    zip : $MODULE_ZIP"
