#!/bin/bash
set -e

ROOT=$(dirname $0)/..
STRATUM=${STRATUM:-$ROOT/../stratum}
# prefer freshly built libs from stratum/bin, fall back to module/system/lib64
if [[ -f $STRATUM/bin/libstratum.so ]]; then
    LIBS_DIR=$STRATUM/bin
else
    LIBS_DIR=$ROOT/module/system/lib64
fi
BIN_OUT=$ROOT/module/system/bin/stratum_binary
EXTRAS_OUT=$ROOT/module/extras
EXTRAS_SRC=$ROOT/apps/utils

if [[ ! -d $STRATUM/include ]]; then
    echo "[!] Stratum headers not found at $STRATUM"
    echo "    Set STRATUM=/path/to/stratum or clone it alongside this repo"
    exit 1
fi

mkdir -p $EXTRAS_OUT

usage() {
    echo "Usage: $0 [options] [extra...]"
    echo "  -m, --menu-only      build bootmenu only, skip extras"
    echo "  -e, --extras-only    skip building bootmenu, build extras only"
    echo "  -h, --help           show this help"
    echo ""
    echo "  extra args: specific extra name(s) to build (default: all)"
    echo "  e.g: $0 signal"
    exit 0
}

BUILD_MENU=1
BUILD_EXTRAS=1
ONLY=()

while [[ $# -gt 0 ]]; do
    case $1 in
        -e|--extras-only) BUILD_MENU=0;    shift ;;
        -m|--menu-only)   BUILD_EXTRAS=0;  shift ;;
        -h|--help)        usage ;;
        -*) echo "Unknown option: $1"; usage ;;
        *)  ONLY+=("$1"); shift ;;
    esac
done

if [[ ${#ONLY[@]} -gt 0 ]]; then
    BUILD_MENU=0
fi

echo "[*] Using libs from: $LIBS_DIR"

INCLUDES="\
  -I$STRATUM/include \
  -I$STRATUM/include/v34/arm64/include/frameworks/native/libs/gui/include \
  -I$STRATUM/include/v34/arm64/include/frameworks/native/libs/binder/include \
  -I$STRATUM/include/v34/arm64/include/frameworks/native/libs/ui/include \
  -I$STRATUM/include/v34/arm64/include/frameworks/native/libs/math/include \
  -I$STRATUM/include/v34/arm64/include/frameworks/native/libs/nativewindow/include \
  -I$STRATUM/include/v34/arm64/include/frameworks/native/libs/nativebase/include \
  -I$STRATUM/include/v34/arm64/include/frameworks/native/opengl/include \
  -I$STRATUM/include/v34/arm64/include/system/libbase/include \
  -I$STRATUM/include/v34/arm64/include/system/core/libutils/include \
  -I$STRATUM/include/v34/arm64/include/system/core/libcutils/include \
  -I$STRATUM/include/v34/arm64/include/system/core/libsystem/include \
  -I$STRATUM/include/v34/arm64/include/system/libhidl/base/include \
  -I$STRATUM/include/v34/arm64/include/system/libhidl/transport/token/1.0/utils/include \
  -I$STRATUM/include/v34/arm64/include/system/libfmq/base \
  -I$STRATUM/include/v34/arm64/include/hardware/libhardware/include \
  -I$STRATUM/include/v34/arm64/include/generated-headers/frameworks/native/libs/gui/libgui_aidl_static/android_vendor.34_arm64_armv8-a_static/gen/aidl \
  -I$STRATUM/include/v34/arm64/include/generated-headers/frameworks/native/libs/gui/libgui/android_vendor.34_arm64_armv8-a_shared/gen/aidl \
  -I$STRATUM/include/v34/arm64/include/generated-headers/frameworks/native/libs/gui/libgui_window_info_static/android_vendor.34_arm64_armv8-a_static_afdo-libgui_lto-thin/gen/aidl \
  -I$STRATUM/include/v34/arm64/include/generated-headers/hardware/interfaces/graphics/common/aidl/android.hardware.graphics.common-V4-ndk-source/gen/include \
  -I$STRATUM/include/v34/arm64/include/generated-headers/hardware/interfaces/graphics/common/1.0/android.hardware.graphics.common@1.0_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/generated-headers/hardware/interfaces/graphics/common/1.1/android.hardware.graphics.common@1.1_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/generated-headers/hardware/interfaces/graphics/common/1.2/android.hardware.graphics.common@1.2_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/generated-headers/hardware/interfaces/graphics/bufferqueue/1.0/android.hardware.graphics.bufferqueue@1.0_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/generated-headers/hardware/interfaces/graphics/bufferqueue/2.0/android.hardware.graphics.bufferqueue@2.0_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/generated-headers/system/libhidl/transport/base/1.0/android.hidl.base@1.0_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/generated-headers/system/libhidl/transport/manager/1.0/android.hidl.manager@1.0_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/generated-headers/hardware/interfaces/media/1.0/android.hardware.media@1.0_genc++_headers/gen \
  -I$STRATUM/include/v34/arm64/include/system/libhwbinder/include \
  -I$STRATUM/include/logging/liblog/include"

FLAGS="-std=c++17 -O2 -march=armv8-a -target aarch64-linux-android34 -D__BIONIC__ -w -include $STRATUM/include/compat.h"
LIBS="-L$LIBS_DIR -L/system/lib64 -lstratum -lgui -lui -lEGL -lGLESv2 -lbinder -lutils -llog -Wl,--allow-shlib-undefined -Wl,--unresolved-symbols=ignore-all"

if [[ $BUILD_MENU -eq 1 ]]; then
    echo "[*] Building bootmenu..."
    clang++ $FLAGS $INCLUDES $ROOT/src/bootmenu.cpp $LIBS -o $BIN_OUT
    chmod +x $BIN_OUT
    echo "[*] Done -> $BIN_OUT"
fi

if [[ $BUILD_EXTRAS -eq 1 ]]; then
    if [[ ${#ONLY[@]} -gt 0 ]]; then
        targets=()
        for name in "${ONLY[@]}"; do
            f=$EXTRAS_SRC/$name.cpp
            if [[ ! -f $f ]]; then
                echo "[!] Extra not found: $name"
                exit 1
            fi
            targets+=("$f")
        done
    else
        targets=($EXTRAS_SRC/*.cpp)
    fi

    for f in "${targets[@]}"; do
        [[ -e $f ]] || { echo "[!] No extras found in apps/utils/"; break; }
        name=$(basename $f .cpp)
        echo "[*] Building extra: $name..."
        clang++ $FLAGS $INCLUDES $f $LIBS -o $EXTRAS_OUT/$name
        chmod +x $EXTRAS_OUT/$name
        echo "[*] Done -> $EXTRAS_OUT/$name"
    done
fi

echo "[*] Run with: bash scripts/run.sh"
