#!/bin/bash
set -e

echo "🔧 ExynosTools - Android Build (from ARM64 Linux server)"

cd /home/vscunha/projects/ExynosTools

echo "🔨 Compiling object files..."
mkdir -p build

# Compile each source to object file
aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o build/xeno_wrapper.o src/xeno_wrapper.c
aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o build/bc_emulate.o src/bc_emulate.c
aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o build/features_patch.o src/features_patch.c
aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o build/detect.o src/detect.c
aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o build/perf_conf.o src/perf_conf.c
aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o build/logging.o src/logging.c
aarch64-linux-gnu-gcc -c -fPIC -O2 -DNDEBUG -I./src -o build/app_profile.o src/app_profile.c

echo "🔗 Linking shared library for Android..."

# Link without specifying libc version - let Android's linker handle it
# Use -Wl,--version-script to avoid symbol versioning
aarch64-linux-gnu-ld -shared \
    -o build/libxeno_wrapper.so \
    build/xeno_wrapper.o \
    build/bc_emulate.o \
    build/features_patch.o \
    build/detect.o \
    build/perf_conf.o \
    build/logging.o \
    build/app_profile.o \
    -lc -lm -ldl -lvulkan \
    --dynamic-linker=/system/bin/linker64 \
    --hash-style=sysv \
    -soname=libxeno_wrapper.so

# Strip it
aarch64-linux-gnu-strip build/libxeno_wrapper.so

SIZE=$(stat -c%s "build/libxeno_wrapper.so")
echo ""
echo "✅ Binary created: $SIZE bytes"

echo ""
echo "🔍 Dependencies:"
readelf -d build/libxeno_wrapper.so | grep NEEDED

echo ""
echo "📦 Creating package..."
bash package_winlator.sh

echo ""
echo "✅ Done! Package ready at: artifacts/exynostools-winlator-v1.3.0-dev.zip"
