#!/bin/bash
set -e

# Android NDK build script for ExynosTools
# This compiles for Android using the NDK toolchain

echo "🔧 ExynosTools - Android NDK Build"

# Check for Android NDK
if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "❌ ERROR: ANDROID_NDK_HOME not set!"
    echo ""
    echo "Please install Android NDK and set ANDROID_NDK_HOME:"
    echo "  export ANDROID_NDK_HOME=/path/to/android-ndk"
    echo ""
    echo "Download from: https://developer.android.com/ndk/downloads"
    exit 1
fi

NDK_TOOLCHAIN="$ANDROID_NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64"
CC="$NDK_TOOLCHAIN/bin/aarch64-linux-android31-clang"

if [ ! -f "$CC" ]; then
    echo "❌ ERROR: NDK toolchain not found at: $CC"
    exit 1
fi

echo "✅ Using NDK: $ANDROID_NDK_HOME"
echo "✅ Compiler: $CC"

# Create build directory
mkdir -p build artifacts

# Compile for Android ARM64
echo "🔨 Compiling libxeno_wrapper.so for Android..."

"$CC" -shared -fPIC -O2 -DNDEBUG \
    -I./src \
    -o build/libxeno_wrapper.so \
    src/xeno_wrapper.c \
    src/bc_emulate.c \
    src/features_patch.c \
    src/detect.c \
    src/perf_conf.c \
    src/logging.c \
    src/app_profile.c \
    -lvulkan -lm -ldl -llog

# Verify binary
BINARY_SIZE=$(stat -c%s "build/libxeno_wrapper.so")
if [ "${BINARY_SIZE}" -eq 0 ]; then
    echo "❌ CRITICAL ERROR: Binary is empty!"
    exit 1
fi

# Check it's actually an Android binary
file build/libxeno_wrapper.so | grep -q "ARM aarch64" || {
    echo "❌ ERROR: Not an ARM64 binary!"
    exit 1
}

# Check dependencies
echo "📋 Checking dependencies..."
readelf -d build/libxeno_wrapper.so | grep NEEDED

echo ""
echo "✅ Binary created: libxeno_wrapper.so (${BINARY_SIZE} bytes)"
echo "✅ Architecture: ARM64 Android"

# Strip debug symbols
echo "🔪 Stripping debug symbols..."
"$NDK_TOOLCHAIN/bin/llvm-strip" build/libxeno_wrapper.so

STRIPPED_SIZE=$(stat -c%s "build/libxeno_wrapper.so")
echo "✅ Stripped size: ${STRIPPED_SIZE} bytes"

echo ""
echo "🎉 Build complete! Ready for GameHub/Winlator"
