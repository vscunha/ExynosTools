#!/bin/bash
set -e

echo "🔧 ExynosTools - Cross-compile for Android (ARM64 server)"
echo ""

cd /home/vscunha/projects/ExynosTools

# We'll compile using musl-gcc which is compatible with Android
# First check if musl is available
if ! command -v musl-gcc &> /dev/null; then
    echo "📦 Installing musl toolchain..."
    sudo apt-get update
    sudo apt-get install -y musl-tools
fi

echo "🔨 Compiling with musl (Android-compatible)..."

# Compile each source file to object
for src in src/xeno_wrapper.c src/bc_emulate.c src/features_patch.c src/detect.c src/perf_conf.c src/logging.c src/app_profile.c; do
    obj="build/$(basename ${src%.c}.o)"
    echo "  Compiling $src..."
    aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o "$obj" "$src"
done

echo "🔗 Linking shared library..."

# Link without libc dependency, let Android provide it
aarch64-linux-gnu-gcc -shared -nostdlib \
    -Wl,--hash-style=sysv \
    -Wl,-soname,libxeno_wrapper.so \
    -o build/libxeno_wrapper.so \
    build/*.o \
    -Wl,--no-undefined \
    -Wl,-rpath-link,/system/lib64 \
    -lvulkan -lm -ldl -llog -lc

# Check what we got
SIZE=$(stat -c%s "build/libxeno_wrapper.so")
echo ""
echo "✅ Binary created: $SIZE bytes"

echo "🔍 Dependencies:"
readelf -d build/libxeno_wrapper.so | grep NEEDED

echo ""
echo "✅ Build complete!"
