#!/bin/bash
set -e

echo "�� ExynosTools - Meson Android Build"

# Check for Android NDK
if [ -z "$ANDROID_NDK_HOME" ]; then
    echo "❌ ERROR: ANDROID_NDK_HOME not set!"
    exit 1
fi

echo "✅ Using NDK: $ANDROID_NDK_HOME"

# Create cross-file with actual NDK path
CROSS_FILE="android-cross-actual.txt"
sed "s|ANDROID_NDK_HOME|$ANDROID_NDK_HOME|g" android-cross.txt > "$CROSS_FILE"

echo "📝 Generated cross-compilation file: $CROSS_FILE"

# Configure with Meson
if [ ! -d "build-android" ]; then
    echo "🔧 Configuring build..."
    meson setup build-android \
        --cross-file="$CROSS_FILE" \
        --buildtype=release \
        -Dstrip=true
else
    echo "🔧 Reconfiguring existing build..."
    meson setup --reconfigure build-android \
        --cross-file="$CROSS_FILE"
fi

# Build
echo "🔨 Compiling..."
meson compile -C build-android

# Check result
if [ -f "build-android/libxeno_wrapper.so" ]; then
    SIZE=$(stat -c%s "build-android/libxeno_wrapper.so")
    echo ""
    echo "✅ Build successful!"
    echo "📦 Library: build-android/libxeno_wrapper.so"
    echo "📊 Size: $SIZE bytes"
    echo ""
    echo "🔍 Checking dependencies:"
    readelf -d build-android/libxeno_wrapper.so | grep NEEDED
else
    echo "❌ Build failed - library not found"
    exit 1
fi
